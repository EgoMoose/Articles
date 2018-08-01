local v3 = Vector3.new;
local unpack = unpack;
local typeof = typeof;

local pi = math.pi;
local abs = math.abs;
local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local acos = math.acos;
local asin = math.asin;
local atan2 = math.atan2;

local rep = string.rep;
local sub = string.sub;
local lower = string.lower;
local format = string.format;

-- class

local cframe = {};
local mt = {};
local ref = setmetatable({}, {__type = "k"});

-- private functions

local function sumType(t, x)
	local sum = 0;
	for k, v in next, t do
		sum = sum + (typeof(v) == x and 1 or 0);
	end
	return sum;
end

local function cframeToQuaternion(cf)
	local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = cf:components();
	local qw, qx, qy, qz;
	
	if (m11 + m22 + m33 > 0) then
		qw = sqrt(1 + m11 + m22 + m33) * 0.5;
		qx = (m32-m23) / (4*qw);
		qy = (m13-m31) / (4*qw);
		qz = (m21-m12) / (4*qw);
	elseif (m11 > m22 and m11 > m33) then
		qx = sqrt(1 + m11 - m22 - m33) * 0.5;
		qy = (m21+m12) / (4*qx);
		qz = (m31+m13) / (4*qx);
		qw = (m32-m23) / (4*qx);
	elseif (m22 > m33) then
		qy = sqrt(1 + m22 - m11 - m33) * 0.5;
		qx = (m21+m12) / (4*qy);
		qz = (m32+m23) / (4*qy);
		qw = (m13-m31) / (4*qy);
	else
		qz = sqrt(1 + m33 - m11 - m22) * 0.5;
		qx = (m31+m13) / (4*qz);
		qy = (m32+m23) / (4*qz);
		qw = (m21-m12) / (4*qz);
	end
	
	return qw, qx, qy, qz;
end

-- metamethods

function mt.__index(cf, k)
	local c = ref[cf];
	
	local k = lower(sub(k, 1, 1)) .. sub(k, 2);
	
	if (k == "x") then
		return c[1];
	elseif (k == "y") then
		return c[2];
	elseif (k == "z") then
		return c[3];
	elseif (k == "p") then
		return v3(c[1], c[2], c[3]);
	elseif (k == "lookVector") then
		return -v3(c[6], c[9], c[12]);
	elseif (k == "rightVector") then
		return v3(c[4], c[7], c[10]);
	elseif (k == "upVector") then
		return v3(c[5], c[8], c[11]);
	elseif (cframe[k]) then
		return cframe[k];
	else
		error(k .. " is not a valid member of CFrame");
	end
end

function mt.__newindex(cf, k, v)
	error(k .. " cannot be assigned to");
end

function mt.__eq(a, b)
	if (not not ref[a] and not not ref[b]) then
		local a, b = ref[a], ref[b];
		for i = 1, 12 do
			if (a[i] ~= b[i]) then
				return false;
			end
		end
		return true;
	else
		return false;
	end
end

function mt.__add(a, b)
	if (not not ref[a] and typeof(b) == "Vector3") then
		local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = unpack(ref[a]);	
		return cframe.new(x + b.x, y + b.y, z + b.z, m11, m12, m13, m21, m22, m23, m31, m32, m33);
	else
		error("bad argument #2 to '?' (Vector3 expected, got " .. typeof(b) .. ")");
	end
end

function mt.__sub(a, b)
	if (not not ref[a] and typeof(b) == "Vector3") then
		local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = unpack(ref[a]);	
		return cframe.new(x - b.x, y - b.y, z - b.z, m11, m12, m13, m21, m22, m23, m31, m32, m33);
	else
		error("bad argument #2 to '?' (Vector3 expected, got " .. typeof(b) .. ")");
	end
end

function mt.__mul(a, b)
	if (not not ref[a] and not not ref[b]) then
		-- CFrame * CFrame
		local a, b = ref[a], ref[b];
		
		local a1, a2, a3, ap = v3(a[4], a[5], a[6]), v3(a[7], a[8], a[9]), v3(a[10], a[11], a[12]), v3(a[1], a[2], a[3]);
		local b1, b2, b3, bp = v3(b[4], b[7], b[10]), v3(b[5], b[8], b[11]), v3(b[6], b[9], b[12]), v3(b[1], b[2], b[3]);
		
		return cframe.new(
			a1:Dot(bp)+a[1], a2:Dot(bp)+a[2], a3:Dot(bp)+a[3],
			a1:Dot(b1), a1:Dot(b2), a1:Dot(b3),
			a2:Dot(b1), a2:Dot(b2), a2:Dot(b3),
			a3:Dot(b1), a3:Dot(b2), a3:Dot(b3)
		);
	elseif (not not ref[a] and typeof(b) == "Vector3") then
		-- CFrame * Vector3
		local c = ref[a];
		
		return v3(
			v3(c[4], c[5], c[6]):Dot(b)+c[1],
			v3(c[7], c[8], c[9]):Dot(b)+c[2], 
			v3(c[10], c[11], c[12]):Dot(b)+c[3]
		);
	elseif (not not ref[a]) then
		error("bad argument #2 to '?' (Vector3 expected, got " .. typeof(a) .. " )");
	else
		error("bad argument #1 to '?' (CFrame expected, got " .. typeof(a) .. " )");
	end
end

function mt.__tostring(cf)
	return format(rep("%s, ", 11) .. "%s", unpack(ref[cf]))
end

mt.__metatable = false;

-- public constructors

function cframe.new(...)
	local self = {};
	local components = {...};

	if (#components < 0 or #components > 12) then
		error("Invalid number of arguments: " .. #components);
	elseif (#components == 0) then
		components = {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1};
	elseif (#components == 1 and typeof(components[1]) == "Vector3") then
		-- single vector position case
		components = {components[1].x, components[1].y, components[1].z, 1, 0, 0, 0, 1, 0, 0, 0, 1}
	elseif (#components == 2 and sumType(components, "Vector3") == 2) then
		-- lookAt case
		local eye, target = components[1], components[2]		
		local dir = target - eye;
		local right = dir:Cross(v3(0, 1, 0));
		
		if (right:Dot(right) > 0) then
			local u = right:Cross(dir).unit;
			local b, r = -dir.unit, right.unit;
			components = {eye.x, eye.y, eye.z, r.x, u.x, b.x, r.y, u.y, b.y, r.z, u.z, b.z};
		elseif (v3(0, 1, 0):Dot(dir) > 0) then
			components = {eye.x, eye.y, eye.z, 0, 1, 0, 0, 0, -1, -1, 0, 0};
		else
			components = {eye.x, eye.y, eye.z, 0, 1, 0, 0, 0, 1, 1, 0, 0};
		end
	elseif (#components == 3 and sumType(components, "number") == 3) then
		-- x, y, and z case
		components = {components[1], components[2], components[3], 1, 0, 0, 0, 1, 0, 0, 0, 1};
	elseif (#components == 7 and sumType(components, "number") == 7) then
		-- quaternion case
		local px, py, pz, x, y, z, w = unpack(components);
		local m = 1 / sqrt(x*x + y*y + z*z + w*w);
		x, y, z, w = x*m, y*m, z*m, w*m;
		components = {px, py, pz,
			1-2*(y*y+z*z), 2*(y*x-w*z), 2*(w*y+z*x),
			2*(w*z+y*x), 1-2*(x*x+z*z), 2*(z*y-w*x),
			2*(z*x-w*y), 2*(w*x+z*y), 1-2*(x*x+y*y)
		};
	elseif (#components == 12 and sumType(components, "number") == 12) then
		-- component case
	else
		error("Invalid arguments.")
	end	
	
	ref[self] = components;
	return setmetatable(self, mt)
end

function cframe.fromAxisAngle(k, t)
	local k = k.unit;
	local kx, ky, kz = k.x, k.y, k.z;
	local c, s = cos(t), sin(t);
	return cframe.new(0, 0, 0,
		c + (1-c)*kx*kx, -s*kz + (1-c)*kx*ky, s*ky + (1-c)*kx*kz,
		s*kz + (1-c)*ky*kx, c + (1-c)*ky*ky, -s*kx + (1-c)*ky*kz,
		-s*ky + (1-c)*kz*kx, s*kx + (1-c)*kz*ky, c + (1-c)*kz*kz
	);
end

function cframe.fromEulerAnglesXYZ(rx, ry, rz)
	local cx, sx = cos(rx), sin(rx);
	local cy, sy = cos(ry), sin(ry);
	local cz, sz = cos(rz), sin(rz);
	
	return cframe.new(0, 0, 0,
		cy*cz, -cy*sz, sy,
		sx*sy*cz+cx*sz, -sx*sy*sz+cx*cz, -sx*cy,
		-cx*sy*cz+sx*sz, cx*sy*sz+sx*cz, cx*cy
	);
end

function cframe.fromEulerAnglesYXZ(rx, ry, rz)
	local cx, sx = cos(rx), sin(rx);
	local cy, sy = cos(ry), sin(ry);
	local cz, sz = cos(rz), sin(rz);
	
	return cframe.new(0, 0, 0,
		cy*cz+sy*sx*sz, -cy*sz+sy*sx*cz, sy*cx,
		cx*sz, cx*cz, -sx,
		-sy*cz+cy*sx*sz, sy*sz+cy*sx*cz, cy*cx
	);
end

function cframe.fromMatrix(p, r, u, b)
	if (not b) then
		b = r:Cross(u).unit;
	end
	
	return cframe.new(p.x, p.y, p.z, r.x, u.x, b.x, r.y, u.y, b.y, r.z, u.z, b.z)
end

cframe.Angles = cframe.fromEulerAnglesXYZ;
cframe.fromOrientation = cframe.fromEulerAnglesYXZ;

-- public methods

function cframe:components()
	return unpack(ref[self]);
end

function cframe:inverse()
	local c = ref[self];
	
	return cframe.new(
		-(c[4]*c[1] + c[7]*c[2] + c[10]*c[3]),
		-(c[5]*c[1] + c[8]*c[2] + c[11]*c[3]),
		-(c[6]*c[1] + c[9]*c[2] + c[12]*c[3]),
		c[4], c[7], c[10],
		c[5], c[8], c[11],
		c[6], c[9], c[12]
	);
end

function cframe:toWorldSpace(cf2)
	return self * cf2;
end

function cframe:toObjectSpace(cf2)
	return self:inverse() * cf2;
end

function cframe:pointToWorldSpace(v)
	return self * v;
end

function cframe:pointToObjectSpace(v)
	return self:inverse() * v;
end

function cframe:vectorToWorldSpace(v)
	return (self - self.p) * v;
end

function cframe:vectorToObjectSpace(v)
	return (self - self.p):inverse() * v;
end

function cframe:toEulerAnglesXYZ()
	local c = ref[self];
	local rx = atan2(-c[9], c[12])
	local ry = asin(c[6]);
	local rz = atan2(-c[5], c[4]);
	return rx, ry, rz;
end

function cframe:toEulerAnglesYXZ()
	local c = ref[self];
	local rx = asin(-c[9])
	local ry = atan2(c[6], c[12])
	local rz = atan2(c[7], c[8]);
	return rx, ry, rz;
end

function cframe:toAxisAngle()
	local qw, qx, qy, qz = cframeToQuaternion(self);
	
	-- pick the twin closest to identity quaternion
	if (qw <= 0) then
		qw, qx, qy, qz = -qw, -qx, -qy, -qz
	end	
	
	local theta = acos(qw) * 2;
	local axis = v3(qx, qy, qz) / sin(theta*0.5);
	
	if (axis:Dot(axis) > 0) then
		return axis.unit, theta;
	else
		return v3(1, 0, 0), theta;
	end
end

function cframe:lerp(cf2, t)
	local p = (1-t)*self.p + t*cf2.p;
	local diff = self:inverse() * cf2;
	local axis, theta = diff:toAxisAngle();
	local c = ref[self * cframe.fromAxisAngle(axis, theta*t)];
	return cframe.new(p.x, p.y, p.z, c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12]);
end

-- non-existant method, but useful for debugging
function cframe:toCFrame()
	local c = ref[self];
	return CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12]);
end

cframe.getComponents = cframe.components;
cframe.toOrientation = cframe.toEulerAnglesYXZ;

-- return class

return cframe;