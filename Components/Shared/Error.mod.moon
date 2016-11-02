--//
--// * Error objects for Freya
--// | Meaningful error states, with extended info and generic templating.
--// | Allows scripts to account for errors in real time, and for developers to
--// | generate better errors.
--//

ni = newproxy true
Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...

Error = with t = {
    Create: Hybrid (ErrorType, Data) ->
      nil
    Template: Hyrbid (Name, Data) ->
      nil
  }
  .Error = (...) -> .Create(...)!
  .new = .Create
