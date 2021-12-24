local length = require("length");
local JSON = require("json");
local settings = require("settings");

if settings ~= nil then
    if settings["FakeCursor"] then
        settings = settings["FakeCursor"]
    end
end

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

    local obj = JSON.decode([[{
        "type":1,
        "time":0,
        "length":0,
        "position":[0,0,1],
        "rotation":[0,0,0],
        "size":[0.675,0.675,0.775],
        "transparency":0.25,
        "material":1,
        "appearance":1,
        "color":[89, 89, 255],
        "animation":[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.675,0.675,0.775],
            "transparency":0.25
        }, {
            "time":1,
            "position":[0,0,1],
            "rotation":[0,0,540],
            "size":[0,0,0],
            "transparency":1
        }]
    }]])

    local new = JSON.decode([[{
        "type":1,
        "time":0,
        "length":0,
        "position":[0,0,1],
        "rotation":[0,0,0],
        "size":[0.775,0.775,0.775],
        "transparency":0.25,
        "material":1,
        "appearance":1,
        "color":[89, 89, 255],
        "animation":[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.775,0.775,0.775],
            "transparency":0.25
        }, {
            "time":1,
            "position":[0,0,1],
            "rotation":[0,0,540],
            "size":[0,0,0],
            "transparency":1
        }]
    }]])

    obj.length = length;
    new.length = length;

    for i, notes in pairs(tbl["objects"]) do
        local ct = (notes.time/new.length);
        local nt = (tbl["objects"][i] ~= nil and tbl["objects"][i].time/new.length or 0);
        local td = (nt-ct)

        local current1 = JSON.decode([[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.525,0.525,0.525],
            "transparency":0.25
            }]]);
        
        local next1 = JSON.decode([[{
            "time":0,
            "position":[0,0,1],
            "rotation":[0,0,0],
            "size":[0.775,0.775,0.775],
            "transparency":0.25
            }]]);

        current1.time = ct;
        current1.position[1] = notes.position[1];
        current1.position[2] = notes.position[2];
        next1.time = ct+(td/2)/2; -- current + (timediff/2)/2
        next1.position[1] = notes.position[1];
        next1.position[2] = notes.position[2];
        
        table.insert(new.animation, current1);

        if not (next1.time == td or next1.time == current1.time or next1.time == nt) and settings["AnimateToNext"] == true then
            table.insert(new.animation, next1);
        end
        
        if settings["ShowInside"] == true then
            local current2 = JSON.decode([[{
                "time":0,
                "position":[0,0,1],
                "rotation":[0,0,0],
                "size":[0.425,0.425,0.525],
                "transparency":0.5
                }]]);
            
            local next2 = JSON.decode([[{
                "time":0,
                "position":[0,0,1],
                "rotation":[0,0,0],
                "size":[0.675,0.675,0.775],
                "transparency":0.5
                }]]);
    
            current2.time = ct;
            current2.position[1] = notes.position[1];
            current2.position[2] = notes.position[2];
            next2.time = ct+(td/2)/2; -- current + (timediff/2)/2
            next2.position[1] = notes.position[1];
            next2.position[2] = notes.position[2];
            
            table.insert(obj.animation, current2);
    
            if not (next2.time == td or next2.time == current2.time or next2.time == nt) and settings["AnimateToNext"] == true then
                table.insert(obj.animation, next2);
            end
        end
    end

    table.insert(tbl.objects, new)

    local newData = JSON.encode(tbl);

    write("output.txt", newData);
    print("Added Data!")
else
    print("File(s) missing")
end