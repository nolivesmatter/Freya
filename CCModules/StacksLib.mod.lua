local StackTables 		= setmetatable({}, {__mode = "k"});
local StackMetatable;

local function CopyMetatable(Object, Metatable)
	local ObjMetatable	= getmetatable(Object);
	for MethodName, Method in next, Metatable do -- ily Roblox >_>
        ObjMetatable[MethodName] = Method;
    end
end

local function NewStack(...)
	local Stack 		= newproxy(true);
	CopyMetatable(Stack, StackMetatable);
	StackTables[Stack] 	= {...};
end

local function StackToString(Stack) -- Can't use table.concat() because it doesn't tostring() automatically
	local StackTable, Buffer = StackTables[Stack], "";
	for i = 1, #StackTable do
		Buffer = Buffer .. tostring(StackTable[i]) .. ", ";
	end
	return Buffer:sub(1, Buffer:len() - 1);
end

local StackMethods 		= {
	Push 				= function(Stack, ...)
		local PushVariables = {...};
		local StackTable 	= StackTables[Stack];
		-- Push the last variable first to replicate the behaviour of NewStack().
		-- This way the first argument will be first on the stack
		for i = #PushVariables, 1, -1 do
			table.insert(StackTable, 1, PushVariables[i]);
		end

		return Stack;
	end;
	Pop 				= function(Stack, Num)
		local PoppedVariables 	= {};
		local StackTable 		= StackTables[Stack];
		for i = 1, Num do
			table.insert(PoppedVariables, 1, table.remove(StackTable, 1));
		end

		return unpack(PoppedVariables);
	end;
	ToString 			= function(Stack)
		return StackToString(Stack);
	end
};

StackMetatable 	= {
	__add 				= function(Stack1, Stack2)
		local Stack 	= NewStack(unpack(StackTables[Stack1]), unpack(StackTables[Stack2] or Stack2));
		return Stack;
	end;
	__sub 				= function(Stack, Num)
		return {Stack:Pop(Num)};
	end,
	__tostring 			= function(Stack) return "Valkyrie Stack: " .. StackToString(Stack); end;
	__metatable 		= function() return "XeR mdmwii Volderbeek Rasenukyi 7NewHope7 jaeremix10"; end;
	__index 			= function(Stack, Index)
		return StackMethods[Index] or StackTables[Stack][Index];
	end
};

return function(wrapper)
	wrapper:OverrideGlobal "Stack" {
		new 			= function(...)
			return NewStack(...);
		end
	};
end;
