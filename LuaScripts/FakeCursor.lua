local length = require("length");
local JSON = require("json");

-- Return true if file exists and is readable.
function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

-- Read an entire file.
-- Use "a" in Lua 5.3; "*a" in Lua 5.1 and 5.2
function readall(filename)
    local fh = assert(io.open(filename, "rb"))
    local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
    fh:close()
    return contents
end
  
  -- Write a string to a file.
function write(filename, contents)
    local fh = assert(io.open(filename, "wb"))
    fh:write(contents)
    fh:flush()
    fh:close()
end

local canUse = file_exists("input.txt") and file_exists("output.txt");

-- print("JSON Loaded: ".. (JSON ~= nil) .."\nCan Convert: ".. (canUse))

if canUse then
    local data = readall("input.txt")

    if length <= 0 then
        print("Please set length in length.lua")
        return;
    elseif data == "" or data == nil then
        print("Please put a json map in input.txt")
        return;
    end

    local tbl = JSON.decode(data);

    if tbl == nil then
        print("Please input a vaild json file into input.txt")
        return;
    end

    local new = JSON.decode([[{
        "type":1,
        "time":0,
        "length":0,
        "position":[0,0,1],
        "rotation":[0,0,0],
        "size":[0.545,0.545,0.545],
        "transparency":0.25,
        "material":1,
        "appearance":1,
        "color":[89, 89, 255],
        "animation":[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.525,0.525,0.525],
            "transparency":0.25
        }, {
            "time":1,
            "position":[0,0,1],
            "rotation":[0,0,540],
            "size":[0.525,0.525,0.525],
            "transparency":1
        }]
    }]])

    new.length = length;

    for index, notes in pairs(tbl["objects"]) do
        local t = (notes.time/new.length);

        local current = JSON.decode([[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.525,0.525,0.525],
            "transparency":0.25
            }]]);
        
        local next = JSON.decode([[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.545,0.545,0.545],
            "transparency":0.25
            }]]);

        current.time = t;
        current.position[1] = notes.position[1];
        current.position[2] = notes.position[2];
        next.time = t+0.0001;
        next.position[1] = notes.position[1];
        next.position[2] = notes.position[2];
        
        table.insert(new.animation, current);
        table.insert(new.animation, next);
    end

    table.insert(tbl.objects, new)

    local newData = JSON.encode(tbl);

    write("output.txt", newData);
    print("Added Data!")
else
    print("File(s) missing")
end