local proxy, methods = {}, {}

function methods:Load()
    local t = {}
    for k in pairs(self) do
        local v = self[k]
        t[k] = type(v) == 'table' and v:Load() or v
    end
    return t
end

function methods:Unload()
    local t = proxy[self].values
    for k, v in pairs(t) do
        if type(v) == 'table' then v:Unload() else t[k] = nil end
    end
end

function methods:Destroy()
    for k, v in pairs(proxy[self].values) do
        if type(v) == 'table' then v:Destroy() end
    end
    proxy[self] = nil
end

function methods:Delete()
    for k in pairs(self) do
        self[k] = nil
    end
end

local mt = {
    __len = function(t)
        return proxy[t].length
    end,
    __pairs = function(t)
        return pairs(proxy[t].keys)
    end,
    __index = function(t, k)
        local obj = proxy[t]
        if not obj.values[k] and obj.keys[k] then
            local v = GetResourceKvpString(obj.path .. k)
            obj.values[k] = tonumber(v) or v
        end
        return obj.values[k] or methods[k]
    end,
    __newindex = function(t, k, v)
        local obj = proxy[t]
        if v then
            t[k] = nil
            if type(v) == 'table' then
                obj.values[k] = CreateKvp(obj.path .. k .. ':')
                for key in pairs(v) do
                    t[k][key] = v[key]
                end
            else
                SetResourceKvp(obj.path .. k, tostring(v))
                obj.values[k] = v
            end
            obj.keys[k] = true
            if type(k) == 'number' and k > obj.length then obj.length = k end
        elseif obj.keys[k] then
            obj.keys[k] = nil
            DeleteResourceKvp(obj.path .. k)
            if k == obj.length then
                local length = 0
                for key in pairs(t) do
                    if type(key) == 'number' and key > length then
                        length = key
                    end
                end
                obj.length = length
            end
            local value = obj.values[k]
            if value then
                if type(value) == 'table' then
                    for key in pairs(value) do
                        t[k][key] = nil
                    end
                    proxy[value] = nil
                end
                obj.values[k] = nil
            end
        end
    end
}

function CreateKvp(path)
    local obj = {}
    proxy[obj] = {path = path, length = 0, keys = {}, values = {}}
    return setmetatable(obj, mt)
end

function KVP(key)
    key = key .. ':'
    for obj, data in pairs(proxy) do
        if data.path == key then
            return obj
        end
    end
    local obj = CreateKvp(key)
    local handle = StartFindKvp(key)
    if handle ~= -1 then
        local path repeat path = FindKvp(handle) if path then
        local last, data = path:gmatch'[^:]*$'(), obj
        for node in path:sub(#key, -#last - 1):gmatch'[^:]+' do
            node = tonumber(node) or node
            if not data[node] then data[node] = {} end
            data = data[node]
        end
        last = tonumber(last) or last
        proxy[data].keys[last] = true
        if type(last) == 'number' and last > proxy[data].length then proxy[data].length = last end
    end until not path
        EndFindKvp(handle)
    end
    return obj
end
