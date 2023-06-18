# am_database
relational KVP database

### Create new database table 
local data = KVP('data')

### Loop through database tables 
for key in pairs(data) do 
    local value = data[key]
end  

### Get the whole table and put all data in cache 
data({action = 'build'})

### fxmanifest.lua: 
shared_script '@am_database/import.lua'
