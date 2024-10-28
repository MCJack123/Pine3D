
-- Made by Xella#8655

local objLoader = require("objLoader")

term.write("> filename: ")
local filename = read()

term.write("> compress? (Y/n) ")
local compressed = read():lower() == "y"

local model = objLoader.load(filename)

print("Serializing model...")
if #model > 5000 then
	term.setTextColor(colors.orange)
	print("Model has " .. (#model) .. " polygons. This can take a while...")
	term.setTextColor(colors.white)
end
if compressed then
	local data = "P3Dm" .. ("<I4"):pack(#model)
	for _, v in ipairs(model) do
		if type(v.c) == "table" then
			data = data .. ("<BfffffffffHHHHHHHH"):pack(
				0x40 + (v.forceRender and 0x80 or 0),
				v.x1, v.y1, v.z1, v.x2, v.y2, v.z2, v.x3, v.y3, v.z3,
				v.c[1], v.c[2], v.c[3], v.c[4], v.c[5], v.c[6], #v.c[7][1], #v.c[7])
			for _, l in ipairs(v.c[7]) do
				for x = 1, #l, 2 do
					data = data .. string.char((select(2, math.frexp(l[x] or 1)) - 1) * 16 + select(2, math.frexp(l[x+1] or 1)) - 1)
				end
			end
		else
			data = data .. ("<Bfffffffff"):pack(
				select(2, math.frexp(v.c)) - 1 + (v.forceRender and 0x80 or 0),
				v.x1, v.y1, v.z1, v.x2, v.y2, v.z2, v.x3, v.y3, v.z3)
		end
	end
	model = data
else model = textutils.serialise(model) end

print("Saving model...")
local file = fs.open("models/" .. filename, "wb") -- Make sure you save the model in the models folder with a new name
file.write(model)
file.close()

term.setTextColor(colors.lime)
print("Done!")
term.setTextColor(colors.white)
