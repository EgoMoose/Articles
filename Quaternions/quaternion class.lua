local quaternion = {}
local quaternion_mt = {__index = quaternion};

function quaternion_mt.__unm(q)
	return quaternion.new(-q.w, -q.x, -q.y, -q.z)
end

function quaternion_mt.__mul(q0, q1)
	local w0, w1 = q0.w, q1.w;
	local v0, v1 = Vector3.new(q0.x, q0.y, q0.z), Vector3.new(q1.x, q1.y, q1.z);
	local nw = w0*w1 - v0:Dot(v1);
	local nv = v0*w1 + v1*w0 + v0:Cross(v1);
	return quaternion.new(nw, nv.x, nv.y, nv.z);
end

function quaternion_mt.__pow(q, t)
	local axis, theta = q:toAxisAngle();
	theta = theta*t*0.5;
	axis = math.sin(theta)*axis;
	return quaternion.new(math.cos(theta), axis.x, axis.y, axis.z);
end

function quaternion_mt.__tostring(q)
	-- print as floats, be aware a more precise number is actually stored
	return string.format("%f, %f, %f, %f", q.w, q.x, q.y, q.z);
end

function quaternion.new(w, x, y, z)
	local self = {};
	
	local m = 1 / math.sqrt(w*w + x*x + y*y + z*z);
	
	self.w = w * m;
	self.x = x * m;
	self.y = y * m;
	self.z = z * m;
	
	return setmetatable(self, quaternion_mt);
end

function quaternion.fromCFrame(cf)
	local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = cf:components();
	local qw, qx, qy, qz;
	
	if (m11 + m22 + m33 > 0) then
		qw = math.sqrt(1 + m11 + m22 + m33) * 0.5;
		qx = (m32-m23) / (4*qw);
		qy = (m13-m31) / (4*qw);
		qz = (m21-m12) / (4*qw);
	elseif (m11 > m22 and m11 > m33) then
		qx = math.sqrt(1 + m11 - m22 - m33) * 0.5;
		qy = (m21+m12) / (4*qx);
		qz = (m31+m13) / (4*qx);
		qw = (m32-m23) / (4*qx);
	elseif (m22 > m33) then
		qy = math.sqrt(1 + m22 - m11 - m33) * 0.5;
		qx = (m21+m12) / (4*qy);
		qz = (m32+m23) / (4*qy);
		qw = (m13-m31) / (4*qy);
	else
		qz = math.sqrt(1 + m33 - m11 - m22) * 0.5;
		qx = (m31+m13) / (4*qz);
		qy = (m32+m23) / (4*qz);
		qw = (m21-m12) / (4*qz);
	end
	
	return quaternion.new(qw, qx, qy, qz);
end

function quaternion:Dot(q2)
	local q1 = self;
	return q1.w*q2.w + q1.x*q2.x + q1.y*q2.y + q1.z*q2.z;
end

function quaternion:inverse()
	local conjugate = self:Dot(self);
	return quaternion.new(self.w / conjugate, -self.x / conjugate, -self.y / conjugate, -self.z / conjugate);
end

function quaternion:toAxisAngle()
	local v = Vector3.new(self.x, self.y, self.z);
	local theta = math.acos(self.w)*2;
	local axis = v / math.sin(theta*0.5);
	return axis, theta;
end

function quaternion:toCFrame()
	local w, x, y, z = self.w, self.x, self.y, self.z;
	
	return CFrame.new(0, 0, 0,
		1-2*(y*y+z*z), 2*(y*x-w*z), 2*(w*y+z*x),
		2*(w*z+y*x), 1-2*(x*x+z*z), 2*(z*y-w*x),
		2*(z*x-w*y), 2*(w*x+z*y), 1-2*(x*x+y*y)
	);
end

function quaternion:slerp(q2, t)
	local q1 = self;
	
	if (q1:Dot(q2) < 0) then
		q2 = -q2;
	end
	
	return (q2 * q1:inverse())^t * q1;
end

return quaternion;