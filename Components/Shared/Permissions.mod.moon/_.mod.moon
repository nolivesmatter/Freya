--//
--// * Permissions for Freya
--// | Permissions management for Freya, supporting permission groups,
--// | inheritance, and replication management
--//

local ^
Intent = require script.Parent.Intents

IsServer = do
  RunService = game\GetService "RunService"
  if RunService\IsRunMode!
    warn "[Warn][Freya Permissions]: Permissions running in Run mode may misbehave."
  RunService\IsServer!

ni = newproxy true

Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...
IsInstance = do
  game = game
  gs = game.GetService
  pcall = pcall
  type = type
  (i) ->
    t = type i
    if t == 'userdata'
      s,e = pcall gs, game, i
      return s and not e
    return false

Permissions = setmetatable {}, __mode: 'v'
PermissionNames = setmetatable {}, __mode: 'k'
PermissionsParents = setmetatable {}, __mode: 'k'
Groups = setmetatable {}, __mode: 'k'
GroupLinks = setmetatable {}, __mode: 'v'
UserGroups = setmetatable {}, {
  __mode: 'k'
  __index: (k) =>
    v = {}
    @[k] = v
    return v
}
UserPermissions = setmetatable {}, {
  __mode: 'k'
  __index: (k) =>
    v = {}
    @[k] = v
    return v
}
GroupClass = {
  GetPlayers: =>
    @ = Groups[@]
    return error "Invalid group for GetPlayers", 2 unless @
    return [k for k,v in pairs @Players]
  AddUser: (user) =>
    self = @
    @ = Groups[@]
    return error "Invalid group for AddUser", 2 unless @
    return error "Invalid user for AddUser", 2 unless IsInstance(user) and user\IsA "Player"
    return if @Players[user]
    ug = UserGroups[user]
    ug[#ug+1] = self
    @Players[user] = true
    Intent\Fire "Permissions.AddUser", @Name, user
  HasUser: (user) => -- Drako: HasUser? () Automatically casts returns to bool
    @ = Groups[@]
    return error "Invalid group for HasUser", 2 unless @
    return error "You must supply a user for HasUser", 2 unless user
    return not not @Players[user]
  RemoveUser: (user) =>
    self = @
    @ = Groups[@]
    return error "Invalid group for RemoveUser", 2 unless @
    return error "You must supply a user for RemoveUser", 2 unless user
    return unless @Players[user]
    ug = UserGroups[user]
    del = false
    for i=1,#ug
      if ug[i] == self
        ug[i] = nil
        del = true
      if del
        ug[i] = ug[i+1]
    @Players[user] = nil
    Intent\Fire "Permissions.RemoveUser", @Name, user
  GetPermissions: =>
    @ = Groups[@]
    return error "Invalid group for GetPermissions", 2 unless @
    return [k for k,v in pairs @Permissions when v]
  AllowPermission: (permission) =>
    @ = Groups[@]
    permission = GetPermission permission
    return error "Invalid group for AllowPermission", 2 unless @
    return error "Invalid permission for AllowPermission", 2 unless permission
    @Permissions[permission] = true
    Intent\Fire "Permissions.AllowPermission", @Name, GetPermissionName permission
  RemovePermission: (permission) =>
    @ = Groups[@]
    permission = GetPermission permission
    return error "Invalid group for RemovePermission", 2 unless @
    return error "Invalid permission for RemovePermission", 2 unless permission
    @Permissions[permission] = nil
    Intent\Fire "Permissions.RemovePermission", @Name, GetPermissionName permission
  BlockPermission: (permission) =>
    @ = Groups[@]
    permission = GetPermission permission
    return error "Invalid group for BlockPermission", 2 unless @
    return error "Invalid permission for BlockPermission", 2 unless permission
    @Permissions[permission] = false
    Intent\Fire "Permissions.BlockPermission", @Name, GetPermissionName permission
  GetPermission: (permission) =>
    @ = Groups[@]
    permission = GetPermission permission
    return error "Invalid group for GetPermission", 2 unless @
    return error "Invalid permission for GetPermission", 2 unless permission
    while permission
      v = @Permissions[permission]
      return v, permission if v ~= nil
      permission = PermissionsParents[permission]
  HasPermission: (...) => not not @GetPermission ...
  GetOnlyPermission: (permission) =>
    @ = Groups[@]
    permission = GetPermission permission
    return error "Invalid group for GetOnlyPermission", 2 unless @
    return error "Invalid permission for GetOnlyPermission", 2 unless permission
    return @Permissions[permission]
  HasOnlyPermission: (...) => not not @GetOnlyPermission ...
  GetName: =>
    @ = Groups[@]
    return error "Invalid group for GetName", 2 unless @
    return @Name
}
GroupMt = {
  __index: GroupClass
  __metatable: "Locked metatable: Freya Permissions"
  __tostring: => @GetName!
  __len: => @GetPlayers!
}

RootPermission = newproxy false
Permissions['*'] = RootPermission

GetPermission = (Permission) ->
  if type(Permission) == 'string'
    Permission = Permission\gsub '%.%*$', ''
    Permission = Permission\gsub '^%*%.', ''
    return Permissions[Permission]
  elseif PermissionsParents[Permission] or Permission == RootPermission
    return Permission

CreatePermission = (Name) ->
  assert type(Name) == 'string',
    "[Error][Freya Permissions] (in CreatePermission): Arg #1 must be a string",
    2
  if Name == '*' then return RootPermission
  Name = Name\gsub '%.%*$', ''
  Name = Name\gsub '^%*%.', ''
  Permission = Permissions[Name]
  return Permission if Permission
  t = {}
  last = RootPermission
  for v in Name\gmatch "([^%.]*)"
    t[#t+1] = v
    tPermName = table.concat t, '.'
    tPerm = newproxy true
    PermissionNames[tPerm] = tPermName
    Permissions[tPermName] = tPerm
    PermissionsParents[tPerm] = last
    last = tPerm
  Intent\Fire "Permissions.CreatePermission", Name
  return last
  
GetPermissionName = (Permission) ->
  Permission = GetPermission(Permission)
  return PermissionNames[Permission] if Permission

GetGroup = (Group) ->
  return unless Group
  return GroupLinks[Group] if GroupLinks[Group]
  return Group if Groups[Group]

CreateGroup = (Name, Inherits) ->
  assert type(Name) == 'string',
    "[Error][Freya Permissions] (in CreateGroup): Arg #1 must be a string",
    2
  if Inherits
    assert type(Inherits) == 'table',
      "[Error][Freya Permissions] (in CreateGroup): Arg #2 must be a table",
      2
  else
    Inherits = {}
  return GroupLinks[Name] if GroupLinks[Name]
  newPermissions = setmetatable {}, __index: (k) =>
    for v in *@Inherits
      perm = v\HasPermission k
      return perm if perm ~= nil
  newGroup = newproxy true
  mt = getmetatable newGroup
  for k,v in pairs GroupMt do mt[k] = v
  Groups[newGroup] = {
    Inherits: Inherits
    Permissions: newPermissions
    Users: {}
    Name: Name
  }
  GroupLinks[Name] = newGroup
  Intent\Fire "Permissions.CreateGroup", Group, [v\GetName! for v in *Inherits]
  return newGroup

GetUserPermission = (User, Permission) ->
  -- Check validity first
  return error "Invalid user for GetUserPermission", 2 unless IsInstance(User) and User\IsA "Player"
  Permission = GetPermission Permission
  return error "Invalid permission for GetUserPermission", 2 unless Permission

  -- Check User
  do
    ptemp = Permission
    plist = UserPermissions[User]
    while ptemp
      v = plist[ptemp]
      return v, ptemp if v ~= nil
      ptemp = PermissionsParents[ptemp]

  -- Check groups
  do
    glist = UserGroups[User]
    ptemp = Permission
    while ptemp
      for v in *glist
        e,p = v\GetOnlyPermission ptemp
        return e, p if e ~= nil
      ptemp = PermissionsParents[ptemp]

AllowUserPermission = (User, Permission) ->
  -- Check validity first
  return error "Invalid user for SetUserPermission", 2 unless IsInstance(User) and User\IsA "Player"
  Permission = GetPermission Permission
  return error "Invalid permission for SetUserPermission", 2 unless Permission
  UserPermissions[User][Permission] = true
  Intent\Fire "Permissions.AllowUserPermission", User, GetPermissionName Permission
  
BlockUserPermission = (User, Permission) ->
  -- Check validity first
  return error "Invalid user for SetUserPermission", 2 unless IsInstance(User) and User\IsA "Player"
  Permission = GetPermission Permission
  return error "Invalid permission for SetUserPermission", 2 unless Permission
  UserPermissions[User][Permission] = false
  Intent\Fire "Permissions.BlockUserPermission", User, GetPermissionName Permission
  
RemoveUserPermission = (User, Permission) ->
  -- Check validity first
  return error "Invalid user for RemoveUserPermission", 2 unless IsInstance(User) and User\IsA "Player"
  Permission = GetPermission Permission
  return error "Invalid permission for RemoveUserPermission", 2 unless Permission
  UserPermissions[User][Permission] = nil
  Intent\Fire "Permissions.RemoveUserPermission", User, GetPermissionName Permission

Controller = {
  GetUserPermission: Hybrid GetUserPermission
  GetPermission: Hybrid GetPermission
  CreateGroup: Hybrid CreateGroup
  CreatePermission: Hybrid CreatePermission
  GetGroup: Hybrid GetGroup
  GetPermissionName: Hybrid GetPermissionName
  AllowUserPermission: Hybrid AllowUserPermission
  BlockUserPermission: Hybrid BlockUserPermission
  RemoveUserPermission: Hybrid RemoveUserPermission
}

if IsServer
  f = => @ and nil
  Intent\Filter "Permissions.RemoveUserPermission", f
  Intent\Filter "Permissions.BlockUserPermission", f
  Intent\Filter "Permissions.AllowUserPermission", f
  Intent\Filter "Permissions.CreatePermission", f
  Intent\Filter "Permissions.AllowPermission", f
  Intent\Filter "Permissions.BlockPermission", f
  Intent\Filter "Permissions.RemovePermission", f
  Intent\Filter "Permissions.AddUser", f
  Intent\Filter "Permissions.RemoveUser", f
  Intent\Filter "Permissions.CreateGroup", f
else
  Intent\Subscribe "Permissions.RemoveUserPermission", (...) =>
    return if @
    RemoveUserPermission ...
  Intent\Subscribe "Permissions.BlockUserPermission", (...) =>
    return if @
    BlockUserPermission ...
  Intent\Subscribe "Permissions.AllowUserPermission", (...) =>
    return if @
    AllowUserPermission ...
  Intent\Subscribe "Permissions.CreatePermission", (...) =>
    return if @
    CreatePermission ...
  Intent\Subscribe "Permissions.AllowPermission", (Group, Permission) =>
    return if @
    GetGroup(Group)\AllowPermission Permission
  Intent\Subscribe "Permissions.BlockPermission", (Group, Permission) =>
    return if @
    GetGroup(Group)\BlockPermission Permission
  Intent\Subscribe "Permissions.RemovePermission", (Group, Permission) =>
    return if @
    GetGroup(Group)\RemovePermission Permission
  Intent\Subscribe "Permissions.AddUser", (Group, User) =>
    return if @
    GetGroup(Group)\AddUser User
  Intent\Subscribe "Permissions.RemoveUser", (Group, User) =>
    return if @
    GetGroup(Group)\RemoveUser User
  Intent\Subscribe "Permissions.CreateGroup", (Group, Inherits) =>
    return if @
    CreateGroup Group, [GetGroup v for v in *Inherits]

with getmetatable ni
  .__index = Controller
  .__tostring = -> "Freya Permissions Controller"
  .__metatable = "Locked metatable: Freya"

ni
