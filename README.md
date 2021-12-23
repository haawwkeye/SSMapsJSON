# JSON Format
```json
{
	"audio":"rbxassetid://1467404779", // audio id
	"noteDistance":70,
	"colors":[
		[255,0,0],
		[0,255,255]
	],
	"objects":[ // hitobjects/envobjects
        {
            "type":0, // 0: regular hitobject
            "time":0, // time of hit in seconds
            "length":0, // length in seconds
            "position":[0,0], // starting position, also determines hitbox
            "transparency":0,
            "color":0, // color3 value OR object color
            "fog":true, // automatic fog effect on hit
            "animation":[ // object animation
                {
                    "time":0, // 0-1 overrides start position but not hitbox
                    "ease":0, // 0: linear, 1: in, 2: out
                    "position":[0,0,0], // overrides approach rate
                    "rotation":[0,0,0], // only in animated hitobjects
                    "transparency":0
                }
            ],
            "track":"trackName" // offsets rotation and position by cframe
        },
        {
            "type":1, // 1: regular envobject, doesn't follow track, should always be animated
            "time":0, // time of appearance in seconds
            "length":0, // length in seconds
            "position":[0,0,0], // starting position
            "rotation":[0,0,0], // starting rotation
            "size":[0,0,0], // size of object
            "transparency":0,
            "material":0, // 0: SmoothPlastic, 1: Neon
            "appearance":0, // 0: default part, 1: hitobject appearance
            "color":0, // color3 value OR object color
            "animation":[ // object animation
                {
                    "time":0, // 0-1 overrides start position
                    "ease":0, // 0: linear, 1: in, 2: out
                    "position":[0,0,0],
                    "rotation":[0,0,0],
                    "size":[0,0,0],
                    "transparency":0
                }
            ],
            "track":"trackName" // offsets rotation and position by cframe
        }
	],
	"tracks":[
        {
            "name":"trackName",
            "position":[0,0,0],
            "rotation":[0,0,0],
            "animation":[ // track animation
                {
                    "time":0, // IN SECONDS
                    "ease":0, // 0: linear, 1: in, 2: out
                    "position":[0,0,0],
                    "rotation":[0,0,0]
                }
            ]
        }
	],
	"events":[ // lighting events
        {
            "type":0, // 0: fog
            "time":0, // start of transition to color
            "color":[0,0,0], // color3 value
            "length":0 // length of transition
        }
	]
}
```

# LUA Code
Add fake cursor to map data
Convert map to JSON
