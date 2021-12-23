local json = require("json");
local module = {};

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do 
        table.insert(t, str)
    end
    return t
end

function wait(n)
    if tonumber(n) ~= nil then
        local time = os.time()+n;
        local new = 0;
        repeat new = time-os.time() until new <= 0;
    else
        local time = os.time()+0.001;
        local new = 0;
        repeat new = time-os.time() until new <= 0
    end
end

local formatSS = "audio,x|y|ms";
local formatJSON = [[{
    "audio":"rbxassetid://",
    "noteDistance":70,
    "colors":[
        [255,0,0],
        [0,255,255]
    ],
    "objects":[],
    "tracks":[
        {
            "name":"Default",
            "position":[0,0,0],
            "rotation":[0,0,0],
            "animation":[
                {
                    "time":0,
                    "position":[0,0,0],
                    "rotation":[0,0,0]
                }
            ]
        }
    ],
    "events":[]
}]];

local build = {};

function build.ss(data)
  local map = {}
  local sects = string.split(data, ",")
  map.audio = sects[1]
  sects[1] = nil
  map.beats = {}
  for _,v in pairs(sects) do
    local block = {}
    local data = string.split(v, "|")
    block.X = tonumber(data[1])
    block.Y = tonumber(data[2])
    block.T = tonumber(data[3])
    table.insert(map.beats,block)
  end
  return map
end

function build.json(json)
	local map = game.HttpService:JSONDecode(json)
	map.start = 0
	local objs = map.objects
	local tracks = {}
	for _,track in pairs(map.tracks or {}) do
        --[[
		track.calc = function(t)
			local props = {Position=Vector3.new(),Rotation=Vector3.new()}

			local startF,endF
			for _,v in pairs(track.animation) do
				if v.time <= t then
					startF = v
				end
				if (not endF) and v.time >= t then
					endF = v
				end
			end
			startF = startF or {time=0,position=track.position,rotation=Vector3.new()}
			endF = endF or {time=1,position=startF.position,rotation=startF.rotation}

			local esDiff = endF.time-startF.time
			local diffT = (esDiff ~= 0 and (t-startF.time)/esDiff) or t

			props.Position = startF.position:Lerp(endF.position,diffT)
			props.Rotation = startF.rotation:Lerp(endF.rotation,diffT)
			
			local cf = CFrame.new(props.Position)
			cf *= CFrame.Angles(math.rad(props.Rotation.X),math.rad(props.Rotation.Y),math.rad(props.Rotation.Z))

			return cf
		end
        --]]
		table.insert(tracks,track)
	end
	local hitobjs = {}
	local envobjs = {}
	local evs = map.events or {}
	local lights = {}
	local materials = {[0]=Enum.Material.SmoothPlastic,[1]=Enum.Material.Neon,[2]=Enum.Material.ForceField}
	local objBuilders = {
		[0] = function(index,obj)
            --[[
			local inst = script.Block:Clone()
			inst.Name = game.HttpService:GenerateGUID(false)
			inst.Position = Vector3.new(obj.position[1],obj.position[2],-map.noteDistance)
			obj.position = inst.Position
			inst.Transparency = obj.transparency
			if typeof(obj.color) == "number" then
				if obj.color == 0 then
					obj.color = map.colors[1+(index%#map.colors)]
				else
					obj.color = map.colors[1+(obj.color%#map.colors)]
				end
			end
			inst.Color = Color3.fromRGB(unpack(obj.color))
			if obj.fog then
				table.insert(evs,{
					type=0;
					time=obj.time;
					color=obj.color;
				})
			end

			local keyframes = obj.animation
			local startFrame = {time=0,position=obj.position,rotation=Vector3.new(),transparency=obj.transparency}
			local endFrame = {time=2,position=(obj.position-Vector3.new(0,0,2*obj.position.z)),rotation=Vector3.new(),transparency=obj.transparency}
			if #keyframes > 0 then
				table.sort(obj.animation,function(a,b)
					return a.time < b.time
				end)
				local hasStart = false
				local hasEnd = false
				for _,v in pairs(keyframes) do
					if v.time <= 0 then
						hasStart = true
					end
					if v.time >= 1 then
						hasEnd = true
					end
					v.position = Vector3.new(unpack(v.position))
					v.rotation = Vector3.new(unpack(v.rotation))
				end
				if not hasStart then
					obj.animation[-1] = startFrame
				end
				if not hasEnd then
					obj.animation[0] = endFrame
				end
			else
				obj.animation[1] = startFrame
				obj.animation[2] = endFrame
			end
			table.sort(obj.animation,function(a,b)
				return a.time < b.time
			end)
			local function calc(t)
				local lTime = t-(obj.time-obj.length)
				local tofl = lTime/obj.length
				local visible = (tofl >= 0) and (tofl < 1.058)
				local canHit = tofl >= 1
				local miss = tofl > 1.058
				if not visible then
					return false,nil,canHit,miss
				end
				if not visible then
					return false
				end
				local props = {Position=Vector3.new(),Rotation=Vector3.new(),Transparency=0}

				local startF,endF
				for _,v in pairs(obj.animation) do
					if v.time <= tofl then
						startF = v
					end
					if (not endF) and v.time >= tofl then
						endF = v
					end
				end
				startF = startF or {time=0,position=obj.position,rotation=Vector3.new(),transparency=obj.transparency}
				endF = endF or {time=1,position=startF.position,rotation=startF.rotation,transparency=startF.transparency}

				local esDiff = endF.time-startF.time
				local diffT = (esDiff ~= 0 and (tofl-startF.time)/esDiff) or tofl

				props.Position = startF.position:Lerp(endF.position,diffT)-Vector3.new(0,0,inst.Size.Z)
				props.Rotation = startF.rotation:Lerp(endF.rotation,diffT)
				props.Transparency = lerp(startF.transparency,endF.transparency,diffT)

				return visible,props,canHit,miss
			end
			return calc,inst
            --]]
            return nil,nil
		end,
		[1] = function(obj)
            --[[
			local inst = (obj.appearance == 1 and script.Block:Clone()) or script.EnvObject:Clone()
			inst.Name = game.HttpService:GenerateGUID(false)
			inst.Material = materials[obj.material]
			inst.Position = Vector3.new(unpack(obj.position))
			obj.position = inst.Position
			inst.Rotation = Vector3.new(unpack(obj.rotation))
			obj.rotation = inst.Rotation
			inst.Size = Vector3.new(unpack(obj.size))
			obj.size = inst.Size
			inst.Transparency = obj.transparency
			if typeof(obj.color) == "number" then
				if obj.color == 0 then
					obj.color = {255,255,255}
				else
					obj.color = map.colors[1+(obj.color%#map.colors)]
				end
			end
			inst.Color = Color3.fromRGB(unpack(obj.color))
			
			local keyframes = obj.animation
			local startFrame = {time=0,position=obj.position,rotation=obj.rotation,size=obj.size,transparency=obj.transparency}
			if #keyframes > 0 then
				table.sort(obj.animation,function(a,b)
					return a.time < b.time
				end)
				local hasStart = false
				for _,v in pairs(keyframes) do
					if v.time <= 0 then
						hasStart = true
					end
					v.position = Vector3.new(unpack(v.position))
					v.rotation = Vector3.new(unpack(v.rotation))
					v.size = Vector3.new(unpack(v.size))
				end
				if not hasStart then
					obj.animation[0] = startFrame
				end
			else
				obj.animation[1] = startFrame
			end
			local function calc(t)
				local lTime = t-obj.time
				local tofl = lTime/obj.length
				local visible = (tofl >= 0) and (tofl < 1)
				if not visible then
					return false
				end
				
				local props = {Position=Vector3.new(),Rotation=Vector3.new(),Size=Vector3.new(),Transparency=0}
				
				local startF,endF
				for _,v in pairs(obj.animation) do
					if v.time <= tofl then
						startF = v
					end
					if (not endF) and v.time >= tofl then
						endF = v
					end
				end
				startF = startF or {time=0,position=obj.position,rotation=obj.rotation,size=obj.size,transparency=obj.transparency}
				endF = endF or {time=1,position=startF.position,rotation=startF.rotation,size=startF.size,transparency=startF.transparency}
				
				local esDiff = endF.time-startF.time
				local diffT = (esDiff ~= 0 and (tofl-startF.time)/esDiff) or tofl
				
				props.Position = startF.position:Lerp(endF.position,diffT)
				props.Rotation = startF.rotation:Lerp(endF.rotation,diffT)
				props.Size = startF.size:Lerp(endF.size,diffT)
				props.Transparency = lerp(startF.transparency,endF.transparency,diffT)
				
				return visible,props
			end
			return calc,inst
            --]]
            return nil,nil
		end
	}
	local hoI = 0
	for _,obj in pairs(objs or {}) do
		if obj.type == 0 then
			hoI = hoI + 1
			local hitobj = {obj,objBuilders[0](hoI,obj)}
			local start = obj.time - obj.length
			if start < map.start then
				map.start = start
			end
			table.insert(hitobjs,hitobj)
		elseif obj.type == 1 then
			local envobj = {obj,objBuilders[1](obj)}
			local start = obj.time
			if start < map.start then
				map.start = start
			end
			table.insert(envobjs,envobj)
		end
	end
	table.sort(evs,function(a,b)
		return a.time < b.time
	end)
	for _,ev in pairs(evs) do
		table.insert(lights,ev)
	end
	map.Tracks = tracks
	map.HitObjects = hitobjs
	map.EnvObjects = envobjs
	map.LightEvents = lights
    map.start = nil; -- Remove since its not needed
	return map
end

module.build = build;

function getBeatFormat()
    return json.decode([[{
        "type":0,
        "time":0,
        "length":0,
        "position":[0,0],
        "transparency":0,
        "color":0,
        "fog":true,
        "animation":[],
        "track":"Default"
    }]]);
end

function module:CovertToJson(txt)
    local map = build.ss(txt);
    local newJson = json.decode(formatJSON);
    --local beats = {}

    for _, beat in pairs(map.beats) do
        local beatFormat = getBeatFormat();

        local time = beat.T/1000;
        local pos = {2*(beat.X-1), 2*(beat.Y-1)};

        beatFormat.time = time;
        beatFormat.position = pos

        table.insert(newJson.objects, beatFormat)        
    end

    newJson.audio = newJson.audio .. tostring(map.audio);

    return json.encode(newJson);
end

function module:CovertToTxt(txt)
    --[[
    local map = build.ss(txt);
    local newJson = json.decode(formatJSON);
    local beats = {}

    for _, beat in pairs(map.beats) do
        local beatFormat = getBeatFormat();

        local time = beat.T/1000;
        local pos = {2*(beat.X-1), 2*(beat.Y-1)};

        beatFormat.time = time;
        beatFormat.position = pos

        table.insert(beats, beatFormat)        
    end

    newJson.audio = newJson.audio .. tostring(map.audio);

    return json.encode(newJson);
    --]]
    --error("Not scripted")
end

--[[
function module:ValidateMap(json)
end
--]]

return module