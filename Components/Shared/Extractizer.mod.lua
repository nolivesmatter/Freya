local Proxies           = setmetatable({}, {__mode = "v"});
local Components        = setmetatable({}, {__mode = "k"});

local function WrapMetamethod(Metamethod)
    return function(a, b, c)
        a               = a and Components[a] or a;
        b               = b and Components[b] or b;
        c               = c and Components[c] or c;
        return Metamethod(a, b, c);
    end;
end;

return function(Component)
    if Proxies[Component] then
        return Proxies[Component];
    end
    local Proxy         = newproxy(true);
    local Metatable     = getmetatable(Proxy);

    Metatable.__index   = function(_, Key)
        if type(Component[Key]) == "function" then
            return function(...)
                if ...  == Component then
                    return Component[Key](select(2, ...));
                else
                    return Component[Key](...);
                end
            end;
        else
            return Component[Key];
        end
    end;

    local ProxyMetatable = {
        __len       = function(a) return #a end;
        __unm       = function(a) return -a end;
        __add       = function(a,b) return a+b end;
        __sub       = function(a,b) return a-b end;
        __mul       = function(a,b) return a*b end;
        __div       = function(a,b) return a/b end;
        __mod       = function(a,b) return a%b end;
        __pow       = function(a,b) return a^b end;
        __lt        = function(a,b) return a < b end;
        __eq        = function(a,b) return a == b end;
        __le        = function(a,b) return a <= b end;
        __concat    = function(a,b) return a..b end;
        __call      = function(t,...) return t(...) end;
        __tostring  = tostring;
        __newindex  = function(t, k, v) t[k] = v end;
    };

    for Metaname, Metamethod in next, ProxyMetatable do
        Metatable[Metaname] = WrapMetamethod(Metamethod);
    end

    return Proxy;
end;
