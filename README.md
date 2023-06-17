# am_database
relational KVP database

# Create new data table 
local data = KVP('data')

# Loop through any table in data table 
for key in pairs(data) do 
    local value = data[key]
end  

# Get the whole table to send to the client for example 
data({action = 'build'})

# set data 
data['key'] = value

# How to remove the full data table 
for key in pairs(data) do 
    data[key] = nil 
end 
