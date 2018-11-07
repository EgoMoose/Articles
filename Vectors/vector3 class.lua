local abs = math.abs;
local sqrt = math.sqrt;

local rep = string.rep;
local sub = string.sub;
local lower = string.lower;
local format = string.format;

-- class

local vector3 = {};
local mt = {};
local ref = setmetatable({}, {__mode = "k"});

-- metamethods

function mt.__index(v3, k)
	local props = ref[v3];
	local k = lower(sub(k, 1, 1)) .. sub(k, 2);
	
	if (k == "unit") then
		local x, y, z = props.x, props.y, props.z;
		local m = 1 / props.magnitude;
		return vector3.new(x*m, y*m, z*m);
	elseif (props[k]) then
		return props[k];
	elseif (vector3[k]) then
		return vector3[k];
	else
		error(k .. " is not a valid member of Vector3");
	end
end

function mt.__newindex(v3, k, v)
	error(k .. " cannot be assigned to");
end

function mt.__eq(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return a.x == b.x and a.y == b.y and a.z == b.z;
	else
		return false;
	end
end

function mt.__unm(v3)
	local props = ref[v3];
	return vector3.new(-props.x, -props.y, -props.z);
end

function mt.__add(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector3.new(a.x + b.x, a.y + b.y, a.z + b.z);
	elseif (not not ref[a]) then
		error("bad argument #2 to '?' (Vector3 expected, got " .. typeof(b) .. ")")
	elseif (not not ref[a]) then
		error("bad argument #1 to '?' (Vector3 expected, got " .. typeof(a) .. ")")
	end
end

function mt.__sub(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector3.new(a.x - b.x, a.y - b.y, a.z - b.z);
	elseif (not not ref[a]) then
		error("bad argument #2 to '?' (Vector3 expected, got " .. typeof(b) .. ")")
	elseif (not not ref[a]) then
		error("bad argument #1 to '?' (Vector3 expected, got " .. typeof(a) .. ")")
	end
end

function mt.__mul(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector3.new(a.x * b.x, a.y * b.y, a.z * b.z);
	elseif (not not ref[a] and typeof(b) == "number") then
		local a = ref[a];
		return vector3.new(a.x * b, a.y * b, a.z * b);
	elseif (not not ref[b] and typeof(a) == "number") then
		local b = ref[b];
		return vector3.new(a * b.x, a * b.y, a * b.z);
	else
		error("attempt to multiply a Vector3 with an incompatible value type or nil")
	end
end

function mt.__div(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector3.new(a.x / b.x, a.y / b.y, a.z / b.z);
	elseif (not not ref[a] and typeof(b) == "number") then
		local a = ref[a];
		return vector3.new(a.x / b, a.y / b, a.z / b);
	elseif (not not ref[b] and typeof(a) == "number") then
		local b = ref[b];
		return vector3.new(a / b.x, a / b.y, a / b.z);
	else
		error("attempt to divide a Vector3 with an incompatible value type or nil")
	end
end

function mt.__tostring(v3)
	local prop = ref[v3];
	return format(rep("%s, ", 2) .. "%s", prop.x, prop.y, prop.z);
end

mt.__metatable = false;


-- public constructors

function vector3.new(x, y, z)
	local self = {};
	local props = {};
	
	props.x = x or 0;
	props.y = y or 0;
	props.z = z or 0;
	props.magnitude = sqrt(props.x*props.x + props.y*props.y + props.z*props.z);
	
	ref[self] = props;
	return setmetatable(self, mt);
end

local DIRECTION  = {
	vector3.new(1, 0, 0),
	vector3.new(0, 1, 0),
	vector3.new(0, 0, 1),
	vector3.new(-1, 0, 0),
	vector3.new(0, -1, 0),
	vector3.new(0, 0, -1)
};

function vector3.fromNormalId(enum)
	if (enum.EnumType ~= Enum.NormalId) then
		error("Vector3.FromNormalId expects Enum.NormalId input");
	end
	return DIRECTION[enum.Value + 1];
end

function vector3.fromAxis(enum)
	if (enum.EnumType ~= Enum.Axis) then
		error("Vector3.FromAxis expects Enum.Axis input");
	end
	return DIRECTION[enum.Value + 1];
end

-- public methods

function vector3:lerp(b, t)
	return (1-t)*self + t*b;
end

function vector3:dot(b)
	local a, b = ref[self], ref[b];
	return a.x*b.x + a.y*b.y + a.z*b.z;
end

function vector3:cross(b)
	local a, b = ref[self], ref[b];
	return vector3.new(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
    );
end

function vector3:isClose(b, epsilon)
	-- i'm unsure of this method since it's not well explained/documented
	local epsilon = epsilon or 0;
	local a, b = ref[self], ref[b];
	return abs(a.x - b.x) <= epsilon and abs(a.y - b.y) <= epsilon and abs(a.z - b.z) <= epsilon;
end

-- return class

return vector3;