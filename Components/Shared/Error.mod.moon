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

TemplateClass = {

}

TemplateClassMt = {

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
      -- New Templateplater
      ni = newproxy true
      
    :Resolvables
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
