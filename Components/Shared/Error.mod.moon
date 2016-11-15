--//
--// * Error objects for Freya
--// | Meaningful error states, with extended info and generic templating.
--// | Allows scripts to account for errors in real time, and for developers to
--// | generate better errors.
--//

local ^

ni = newproxy true
Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...
  
ErrorData = setmetatable {}, mode: 'k'
ResovableData = setmetatable {}, mode: 'k'
TemplateData = setmetatable {}, mode: 'k'
Resolvables = {}

ResolvableMt = {
  __index: (k) => ResolvableData[@][k]
  __len: => @Id
  __tostring: => "Error Type: #{@Origin} [#{@Name}]"
  __metatable: "Locked Metatable: Freya"
}

resproxy = newproxy true
with getmetatable resproxy
  .__index = Resolvables
  .__metatable = "Locked metatable: Freya"

ErrorClassMt = {
  __index: (k) => ErrorData[@][k]
  __call: (j) => 
    msg = ResolvableData[@ErrorCode].Message
    msg = msg\gsub "%%(%a+)%%", @
    msg = "[Error][#{@Component or @Source or 'Something'}]" .. msg
    error msg, j and j+1 or 2
  __len: => @ErrorCode
  __tostring: => ResolvableData[@ErrorCode].Message\gsub "%%(%a+)%%", @
  __metatable: "Locked Metatable: Freya"
}

with TemplateClass = {
    Create: (ErrorType, Data = {}) =>
      tData = TemplateData[@]
      assert tData,
        "[Error][Freya Errors] (in Template.Create): You need to call this as a method.",
        2
      ErrorType and= tData.Category[ErrorType]
      assert ErrorType,
        "[Error][Freya Errors] (in Template.Create): Invalid error type for this template.",
        2
      newErr = newproxy true
      _mt = getmetatable newErr
      for e,m in pairs ErrorClassMt
        _mt[e] = m
      ErrorData[newErr] = Data
      for k,v in pairs tData
        Data[k] or= v
      return newErr
    Insert: (ID, Name, Message) =>
      tData = TemplateData[@]
      assert tData,
        "[Error][Freya Errors] (in Template.Create): You need to call this as a method.",
        2
      cat = tData.Category
      if Category[ID]
        warn "[Warn][Freya Errors] (in Template.Insert): Error ##{ID} already exists. Replacing."
      if Category[Name]
        warn "[Warn][Freya Errors] (in Template.Insert): Error \"#{Name}\" already exists. Replacing."
      newResolvable = newproxy true
      cat[ID] = newResolvable
      cat[Name] = newResolvable
      cat[newResolvable] = newResolvable
      ResolvableData[newResolvable] = {
        ID: i
        Name: Name
        Message: Message
        Origin: tData.Name
      }
      mt = getmetatable newResolvable
      for e,m in pairs ResolvableMt
        mt[e] = m
      return newResolvable
  }
  .Error = (...) -> .Create(...)!
  .Assert = Hybrid (condition, ...) -> 
    return .Error(...) unless condition
  .new = .Create

TemplateClassMt = {
  __index: (k) =>
    return switch k
      when "ErrorTypes", "ErrorType", "Types"
        TemplateData[@].Category
      else
        TemplateClass[k] or TemplateData[@][k]
  __tostring: => "Freya Error Template (#{@Category})"
  __metatable: "Locked metatable: Freya"
}

Error = with {
    Create: Hybrid (ErrorType, Data) ->
      -- Check our ErrorType
      assert ResolvableData[ErrorType],
        "[Error][Freya Errors] (in Create): Missing ErrorType as arg #1",
        2
      assert type(data) == 'table',
        "[Error][Freya Errors] (in Create): Missing Data table as arg #2",
        2
      -- Create the error!
      newErr = newproxy true
      _mt = getmetatable newErr
      for e,m in pairs ErrorClassMt
        _mt[e] = m
      ErrorData[newErr] = Data
      -- It's not immutable how scary
      return newErr
    Template: Hybrid (Name, Errors, DefaultData) ->
      -- New Templateplate
      ni = newproxy true
      warn "[Warn][Freya Errors] (in Template): No errors defined for #{Name}" unless Errors
      Errors or= {}
      warn "[Warn][Freya Errors] (in Template): No default data defined for #{Name}" unless DefaultData
      DefaultData or= {}
      -- Build resolvable tree inc/ proxies
      -- Errors of format {... {string Name, string Error}}
      newtree = newproxy true
      res = {}
      for i=1, #Errors
        v = Errors[i]
        newResolvable = newproxy true
        res[i] = newResolvable
        res[v[1]] = newResolvable
        res[newResolvable] = newResolvable
        ResolvableData[newResolvable] = {
          ID: i
          Name: v[1]
          Message: v[2]
          Origin: Name
        }
        mt = getmetatable newResolvable
        for e,m in pairs ResolvableMt
          mt[e] = m
      
      Resolvables[Name] = newtree
      with getmetatable newtree
        .__index = res
        .__call = (const, last) => next res, last
        .__metatable = "Locked metatable: Freya"
        .__tostring = Name
      
      mt = getmetatable ni
      for e,m in pairs TemplateMt
        mt[e] = m
      TemplateData[ni] = DefaultData
      DefaultData.Name = Name
      DefaultData.Category = newtree
      
      return ni
    Resolvables: resproxy
  }
  .Error = (...) -> .Create(...)!
  .Assert = Hybrid (condition, ...) -> 
    return .Error(...) unless condition
  .new = .Create
  .ErrorType = .Resolvables
  .ErrorTypes = .ErrorType

with getmetatable ni
  .__index = Error
  .__tostring = -> "Freya Error Controller"
  .__metatable = "Locked Metatable: Freya"
  
return ni
