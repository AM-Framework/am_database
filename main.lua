local map = {}

local mt = {
	__pairs = function(t)
		return pairs(map[t].keys)
	end,
	__index = function(t, k)
		if not map[t].data[k] and map[t].keys[k] then
			local value = GetResourceKvpString(map[t].path .. k)
			map[t].data[k] = tonumber(value) or value
		end
		return map[t].data[k]
	end,
	__newindex = function(t, k, v)
		if not v then
			if map[t].keys[k] then
				map[t].keys[k] = nil
				DeleteResourceKvp(map[t].path .. k)
				local value = map[t].data[k]
				if value then
					if type(value) == 'table' then
						for key in pairs(value) do
							t[k][key] = nil
						end
					end
					map[t].data[k] = nil
				end
			end
		else
			t[k] = nil
			if type(v) == 'table' then
				map[t].data[k] = CreateKVP(map[t].path .. k .. ':')
				for i in pairs(v) do
					t[k][i] = v[i]
				end
			else
				SetResourceKvp(map[t].path .. k, tostring(v))
				map[t].data[k] = v
			end
			map[t].keys[k] = true
		end
	end
}

function CreateKVP(key)
	local obj = {}
	map[obj] = {
		data = {},
		keys = {},
		path = key
	}
	setmetatable(obj, mt)
	return obj
end

function KVP(key)
	key = key .. ':'
	local obj, handler = CreateKVP(key), StartFindKvp(key)
	for path in function() return FindKvp(handler) end do
		local last, data = path:gmatch'[^:]*$'(), obj
		for node in path:sub(#key, -#last - 1):gmatch'[^:]+' do
			node = tonumber(node) or node
			if not data[node] then data[node] = {} end
			data = data[node]
		end
		map[data].keys[tonumber(last) or last] = true
	end
	EndFindKvp(handler)
	return obj
end