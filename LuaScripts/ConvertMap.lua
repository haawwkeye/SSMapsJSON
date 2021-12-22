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

local json = require("json")
local MapParser = require("MapParser");

local canUse = file_exists("input.txt") and file_exists("output.txt");

if canUse then
    local data = readall("input.txt")
    if data == "" or data == nil then
        print("Please put a map in input.txt")
        return;
    end

    local newData = MapParser:CovertToJson(data)

    local tbl = json.decode(newData);

    if tbl == nil then
        print("Convert Failed")
        return;
    end

    write("output.txt", newData);
    print("Coverted!")
else
    print("File(s) missing")
end