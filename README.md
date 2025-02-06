# am_database
KVP database

### Create new database table 
local data = KVP('data')

### Loop through database tables 
for key in pairs(data) do 
    local value = data[key]
end  

### Get a table and put all data in cache from that table  
data({action = 'build'})

### unload tables from the cache 
data({action = 'unload'}) 

### register a function that needs to be executed on new index 
data({action = '__newindex', func = function(t, k, v)
    return -- you can cancel the database update 
end})

### remove the function that gets executed on new index 
data({action = '__newindex', func = nil})

### fxmanifest.lua: 
shared_script '@am_database/import.lua'
