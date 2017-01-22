--//
--// * GitFetch for Freya
--// | Handles resolving GitHub Freya packages
--//

-- You'll need to take a look at the API, bright-eyes.

--// Headers:
--// # Accept: application/vnd.github.v3+json
--// # Authorization: token {OAuth Token}
--// # User-Agent: CrescentCode/Freya

--// APIs:
--// # Trees (https://developer.github.com/v3/git/trees/)
--// ## GET /repos/:owner/:repo/git/trees/:sha?recursive=1
--// # Contents (https://developer.github.com/v3/repos/contents/)
--// ## GET /repos/:owner/:repo/readme
--// ## GET /repos/:owner/:repo/contents/:path

local ^

Http = game\GetService "HttpService"
GET =  (url, headers) ->
  local s
  local r
  i = 1
  while (not s) and i < 3
    s, r = pcall Http.GetAsync, Http, url, true, headers
    i += 1
    unless s
      warn "HTTP GET failed. Trying again in 5 seconds (#{i} of 3)"
      wait(5)
  return error r unless s
  return r, (select 2, pcall Http.JSONDecode, Http, r)
POST =  (url, body, headers) ->
  local s
  local r
  i = 1
  while (not s) and i < 3
    s, r = pcall Http.PostAsync, Http, url, Http\JSONEncode(body), nil, nil, headers
    i += 1
    unless s
      warn "HTTP GET failed. Trying again in 5 seconds (#{i} of 3)"
      wait(5)
  return error r unless s
  return r, (select 2, pcall Http.JSONDecode, Http, r)
ghroot = "https://api.github.com/"
ghraw = "https://raw.githubusercontent.com/"

extignore = {
  "md"
  "properties"
  "gitnore"
  "gitkeep"
  "gitignore"
}

GetPackage = (path, Version) ->
  ptype = select 2, path\gsub('/', '')
  switch ptype
    when 1
      headers = {
        Accept: "application/vnd.github.v3+json"
        --["User-Agent"]: "CrescentCode/Freya (User #{game.CreatorId})"
      }
      -- Test repo for existance
      repo = path -- Old code migration
      _, j = GET "#{ghroot}repos/#{repo}", headers
      return nil, "Package repository does not exist: #{Package} (#{j.message})" if j.message
      -- Get the commit sha
      -- Branch?
      if Version
        v = ResolveVersion Version
        if v.branch
          _, j = GET "#{ghroot}repos/#{repo}/commits?sha=#{v.branch}", headers
        else
          _, j = GET "#{ghroot}repos/#{repo}/commits", headers
      else
        _, j = GET "#{ghroot}repos/#{repo}/commits", headers
      return nil, "Failed to get commit details: #{j.message}" if j.message
      sha = j[1].sha
      _, j = GET "#{ghroot}repos/#{repo}/git/trees/#{sha}", headers
      return nil, "Failed to get repo tree: #{j.message}" if j.message
      _, def = GET "#{ghraw}#{repo}/#{sha}/FreyaPackage.properties"
      return nil, "Bad package definition at FreyaPackage.properties" unless def
      return nil, "Malformed package definition at FreyaPackage.properties" unless def.Type and def.Package
      origin = with Instance.new "Folder"
        .Name = "Package"
      otab = {
        Name: def.Name
        Version: def.Version or Version or sha
        Type: def.Type
        LoadOrder: def.LoadOrder
      }
      if def.Description
        print "[Info][Freya GitFetch] (Description for #{repo}):\ndef.Description"
      j = j.tree
      for i=1, #j do
        v = j[i]
        -- Get content of object if it's not a directory.
        -- If it's a directory, check if it's masking an Instance.
        _,__,ext = v.path\find '$.*/.-%.(.+)^'
        ext or= select 3, v.path\find '$[^%.]+%.(.+)^'
        ext or= v.path
        if extignore[ext]
          print "[Info][Freya GitFetch] Skipping #{v.path}"
          continue
        local inst
        if v.type == 'tree'
          -- Directory
          -- Masking?
          if v.path\find '%.lua^' -- No moon support
            print "[Info][Freya GitFetch] Building #{v.path} as a blank Instance"
            -- Masking.
            -- Create as Instance (blank)
            inst = switch ext
              when 'mod.lua' then Instance.new "ModuleScript"
              when 'loc.lua' then Instance.new "LocalScript"
              when 'lua' then Instance.new "Script"
            if inst
              inst.Name = v.path\match '$.+/(.-)%..+^'
            else
              warn "[Warn][Freya GitFetch] GitFetch does not support .#{ext} extensions"
          else
            print "[Info][Freya GitFetch] Building #{v.path} as a Folder"
            inst = with Instance.new "Folder"
              .Name = v.path\match '$.+/(.-)%..+^'
        else
          name = v.path\match '$.+/(.-)%..+^'
          if name == '_'
            print "[Info][Freya GitFetch] Building #{v.path} as the source to #{v.path\match('^(.+)/[^/]-$')}"
            inst = origin
            for t in v.path\gmatch '[^/]+'
              n = t\match '$([^%.]+).+^'
              unless n == '_'
                inst = origin[n]
            inst.Source = GET "#{ghraw}#{repo}/#{sha}/#{v.path}"
          else
            print "[Info][Freya GitFetch] Building #{v.path}."
            inst = switch ext
              when 'mod.lua' then Instance.new "ModuleScript"
              when 'loc.lua' then Instance.new "LocalScript"
              when 'lua' then Instance.new "Script"
            if inst
              inst.Name = v.path\match '$.+/(.-)%..+^'
              inst.Source = GET "#{ghraw}#{repo}/#{sha}/#{v.path}"
            else
              warn "[Warn][Freya GitFetch] GitFetch does not support .#{ext} extensions"
        if inst
          p = origin
          if v.path\find('$(.+)/[^/]-^')
            for t in v.path\match('$(.+)/[^/]-^')\gmatch '[^/]+'
              p = p[t\match '$([^%.]+).+^']
          inst.Parent = p
        else
          print "[Info][Freya GitFetch] Skipping #{v.path}."
      print "[Info][Freya GitFetch] Loaded #{path}"
      otab.Install = def.Install and origin\FindFirstChild def.Install
      otab.Update = def.Update and origin\FindFirstChild def.Update
      otab.Uninstall = def.Uninstall and origin\FindFirstChild def.Uninstall
      otab.Install and= loadstring otab.Install.Source
      otab.Update and= loadstring otab.Update.Source
      otab.Uninstall and= loadstring otab.Uninstall.Source
      otab.Package = origin\FindFirstChild def.Package
      return otab

Interface = {
  Ignore: extignore
  :ghroot
  :ghraw
  :POST
  :GET
  :GetPackage
}

ni = newproxy true
with getmetatable ni
  .__index = Interface
  .__tostring = -> "GitFetch for Freya"
  .__metatable = "Locked metatable: Freya"

for k,v in pairs Interface
  Interface[k] = (...) ->
    return v ... if ni != ... else v select 2, ...

return ni
