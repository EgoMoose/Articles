local sqrt = math.sqrt;

local rep = string.rep;
local sub = string.sub;
local lower = string.lower;
local format = string.format;

-- class

local vector2 = {};
local mt = {};
local ref = setmetatable({}, {__mode = "k"});

-- metamethods

function mt.__index(v2, k)
	local props = ref[v2];
	local k = lower(sub(k, 1, 1)) .. sub(k, 2);
	
	if (k == "unit") then
		local x, y = props.x, props.y;
		local m = 1 / props.magnitude;
		return vector2.new(x*m, y*m);
	elseif (props[k]) then
		return props[k];
	elseif (vector2[k]) then
		return vector2[k];
	else
		error(k .. " is not a valid member of Vector2");
	end
end

function mt.__newindex(v2, k, v)
	error(k .. " cannot be assigned to");
end

function mt.__eq(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return a.x == b.x and a.y == b.y;
	else
		return false;
	end
end

function mt.__unm(v2)
	local props = ref[v2];
	return vector2.new(-props.x, -props.y);
end

function mt.__add(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector2.new(a.x + b.x, a.y + b.y);
	elseif (not not ref[a]) then
		error("bad argument #2 to '?' (Vector2 expected, got " .. typeof(b) .. ")")
	elseif (not not ref[a]) then
		error("bad argument #1 to '?' (Vector2 expected, got " .. typeof(a) .. ")")
	end
end

function mt.__sub(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector2.new(a.x - b.x, a.y - b.y);
	elseif (not not ref[a]) then
		error("bad argument #2 to '?' (Vector2 expected, got " .. typeof(b) .. ")")
	elseif (not not ref[a]) then
		error("bad argument #1 to '?' (Vector2 expected, got " .. typeof(a) .. ")")
	end
end

function mt.__mul(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector2.new(a.x * b.x, a.y * b.y);
	elseif (not not ref[a] and typeof(b) == "number") then
		local a = ref[a];
		return vector2.new(a.x * b, a.y * b);
	elseif (not not ref[b] and typeof(a) == "number") then
		local b = ref[b];
		return vector2.new(a * b.x, a * b.y);
	else
		error("attempt to multiply a Vector2 with an incompatible value type or nil")
	end
end

function mt.__div(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		return vector3.new(a.x / b.x, a.y / b.y);
	elseif (not not ref[a] and typeof(b) == "number") then
		local a = ref[a];
		return vector2.new(a.x / b, a.y / b);
	elseif (not not ref[b] and typeof(a) == "number") then
		local b = ref[b];
		return vector2.new(a / b.x, a / b.y);
	else
		error("attempt to divide a Vector2 with an incompatible value type or nil")
	end
end

function mt.__tostring(v2)
	local prop = ref[v2];
	return format(rep("%s, ", 1) .. "%s", prop.x, prop.y);
end

mt.__metatable = false;


-- public constructors

function vector2.new(x, y)
	local self = {};
	local props = {};
	
	props.x = x or 0;
	props.y = y or 0;
	props.magnitude = sqrt(props.x*props.x + props.y*props.y);
	
	ref[self] = props;
	return setmetatable(self, mt);
end

-- public methods

function vector2:lerp(b, t)
	return (1-t)*self + t*b;
end

function vector2:dot(b)
	local a, b = ref[self], ref[b];
	return a.x*b.x + a.y*b.y;
end

function vector2:cross(b)
	local a, b = ref[self], ref[b];
	return a.x * b.y - a.y * b.x;
end

-- return class

return vector2;