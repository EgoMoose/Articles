# Rotation Quaternions and slerping

This article aims to cover the technical aspects of rotation quaternions (i.e. how to write a quaternion class). Readers are recommended to have read the [Rodrigues' rotation](https://github.com/EgoMoose/Articles/blob/master/Rodrigues'%20rotation/Rodrigues'%20rotation.md) article ahead of time as it will be used to compare results.

## Crash course on imaginiary/complex numbers

Before we can get into understanding quaternions we first need to understand the concept of imaginary and complex numbers. The names might seem daunting, but for our purposes the concepts are pretty straight forward. 

Imaginary numbers have a very simple purpose, to solve equations that real numbers couldn’t! For example: 

`x^2 + 25 = 0`

There is no real number solution to this equation because any real number we take to the power of two will result in a positive number. So in order for the above equation to be true it must be that:

`x^2 = -25`

This is what we call an imaginary number. They are special in the sense that they square to a real negative value. So far we have used `x` as a variable, but usually when representing imaginary numbers we use what is called the imaginary unit `i` where `i^2 = -1`. That way we can reprsent any imaginary number as a product of a real number and `i`. For example:

`(5*i)^2 + 25 = 25*(i^2) + 25 = -25 + 25 = 0`

You might notice that the imaginary unit has a pattern when taken to different powers:

Power Pattern |
------------ |
`i^0 = 1` |
`i^1 = i` |
`i^2 = -1` |
`i^3 = -i` |
`i^4 = 1` |
`i^5 = i` |
`i^6 = -1` |
`i^7 = -i` |
... |

You'll note that this pattern also holds true for negative powers. Simply take notice that `i^-1 = 1/i * i/i = i/i^2 = i/-1 = -i` and the rest of the negative powers become trivial to calculate.

This pattern of `1, i, -1, -i` may feel familiar to you. If we treat the real number part of the pattern as being on the x-axis and the imaginiary parts as being on the y-axis then the pattern is essentially the same as `x , y, -x, -y` which is rotating 90 degrees counter-clockwise.

![img1]()

![img2]()

Since these patterns share so much in common we can use a combination of imaginary and real numbers to represent numbers on a two dimensional grid. We call these complex numbers and we place them on the complex plane.

![img3]()

Interestingly, if we multiply a complex number by `i` we're left with a resulting complex number that has been rotated 90 degrees counter-clockwise.

```
(2 + i)
(2 + i)*i = 2*i + i^2 = -1 + 2*i
(2 + i)*i^2 = (-1 + 2*i)*i = -i + 2*i^2 = -2 - i
(2 + i)*i^3 = (-2 - i)*i = -2*i - i^2 = 1 - 2*i
(2 + i)*i^4 = (1 - 2*i)*i = i - 2*i^2 = 2 + i
```

![img4]()

We can expand on this concept by instead multiplying with a complex number that gives us control of the angle we rotate by.

We can trace a unit circle with `cosθ + sinθ*i` so if we multiply it by a complex number we get a general formula for rotating counter-clockwise by any angle.

```
(w + xi)*(cosθ + sinθ*i)
= w*cosθ + w*sinθ*i + x*cosθ*i + x*sinθ*i^2
= w*cosθ - x*sinθ + (w*sinθ + x*cosθ)i
```

You might be somewhat familiar with this formula. It's just the 2D rotation matrix in complex number form!

## The quaternion is born

Prior to quaternions most people saw the complex plane in 2D and simply figured if they wanted to add a third dimension they just had to add another imaginary number, say `j^2 = -1`. Quickly however they found this didn't quite work due to multiplication requiring us to know the product of two imaginary numbers.

```
(w1 + x1*i + y1*j)*(w2 + x2*i + y2*j) 
= w1*w2 + w1*x2*i + w1*y2*j + x1*w2*i + x1*x2*i^2 + x1*y2*i*j + y1*w2*j + y1*x2*j*i + y1*y2*j^2
= w1*w2 - x1*x2 - y1*y2 + (w1*x2 + x1*w2)*i + (w1*y2 + y1*w2)*j  + x1*y2*i*j + y1*x2*j*i
```

*Note: i*j and j*i are not communative due to their imaginary nature.*

For quite sometime this problem didn't see much attention until an Irish mathemetician named William Rowan Hamilton who figured the best way to solve it was to add a third imaginary number. 

Famously the condition he wrote was:

```
i^2 = j^2 = k^2 = i*j*k = -1
```

This may seem a bit confusing, but it we seperate this out (and again respect the non-commutativity) we get a few equalities we can use to expand.

```
i^2 = -1	j^2 = -1	k^2 = -1
i*j = k		j*k = i		k*i = j
j*i = -k	k*j = -i	i*k = -j
```

In short Hamilton said that instead of stumping ourselves by not knowing a real number that is the resulting product of two imaginary numbers just set its product to another imaginary number and from there we can figure stuff out.

## Quaternion operations

The goal of this section is going to be to start to take some of the knowledge we have learned about quaternions and convert it to code.

We have quaternions in the following form:

```
q = w + x*i + y*j + z*k
```

We can store that same information as an ordered pair by spliting up the real number part from the imagniary part. Thus the above becomes:

```
q = [w, x*i + y*j + z*k]
```

If we treat `i`, `j`, and `k` as seperate axes then we can store the second element of the ordered pair as a 3 dimensional vector.

```
v = (x, y, z)
q = [w, v]
```

If we wanted to add or subtract two quaternions its quite straight forward. We just add/subtract each individual component.

```
q1 = [w1, v1]	q2 = [w2, v2]
q1 + q2 = [w1 + w2, v1 + v2]
q1 - q2 = [w1 - w2, v1 - v2]
```

Multiplication is not quite as simple as addition and subtraction. We can figure out how to do this calculation by applying the equalities hamilton's equation.

```
q1 = w1 + x1*i + y1*j + z1*k	q2 = w2 + x2*i + y2*j + z2*k

q1 * q2 = (w1 + x1*i + y1*j + z1*k)*(w2 + x2*i + y2*j + z2*k)
		= w1*w2 + w1*(x2*i + y2*j + z2*k) + x1*w2*i + x1*x2*i^2 + x1*y2*i*j + x1*z2*i*k + y1*w2*j + y1*x2*j*i + y1*y2*j^2 + y1*z2*j*k + z1*w2*k + z1*x2*k*i + z1*y2*k*j + z1*z2*k^2
	    = w1*w2 - x1*x2 - y1*y2 - z1*z2 + w1*(x2*i + y2*j + z2*k) + w2*(x1*i + y1*j + z1*k) + x1*y2*k - x1*z2*j - y1*x2*k + y1*z2*i + z1*x2*j - z1*y2*i
```

We can then convert this back to the ordered pair form:

```
q1 = [w1, v1]	q2 = [w2, v2]

q1 * q2 = [w1*w2 - (v1 . v2), w1*v2 + w2*v1 + (v1 x v2)]
```

We can use this form of the equation to find the inverse of a quaternion pretty easily. We need to know one more thing, rotation quaternions are unit quaternions meaning their magnitudes equal `1`. We'll explain why this is when we start talking about intuition, but for now:

```
q = w + x*i + y*j + z*k

w^2 + x^2 + y^2 + z^2 = 1
```

Knowing that information the inverse is pretty straightforward to calculate. If we treat `[1, (0, 0, 0)]` as the identity quaternion then all we need to do to invert is flip the `x`, `y`, and `z` components:

```
q = [w, v]	q^-1 = [w, -v]

q * q^-1 = [w*w + (v . v), w*v - w*v + (v x v)]
		 = [1, (0, 0, 0)]
```

In code form:

```Lua
local quaternion = {}
local quaternion_mt = {__index = quaternion};

function quaternion_mt.__mul(q0, q1)
	local w0, w1 = q0.w, q1.w;
	local v0, v1 = Vector3.new(q0.x, q0.y, q0.z), Vector3.new(q1.x, q1.y, q1.z)
	local nw = w0*w1 - v0:Dot(v1);
	local nv = v0*w1 + v1*w0 + v0:Cross(v1);
	return quaternion.new(nw, nv.x, nv.y, nv.z);
end

function quaternion_mt.__tostring(q)
	-- print as floats, be aware a more precise number is actually stored
	return string.format("%f, %f, %f, %f", q.w, q.x, q.y, q.z);
end

function quaternion.new(w, x, y, z)
	local self = {};
	
	self.w = w;
	self.x = x;
	self.y = y;
	self.z = z;
	
	return setmetatable(self, quaternion_mt);
end

function quaternion:inverse()
	return quaternion.new(self.w, -self.x, -self.y, -self.z);
end

-- examples:

local q1 = quaternion.new(0.5, 0.5, 0.5, 0.5);
local q2 = quaternion.new(1/math.sqrt(2), 1/math.sqrt(2), 0, 0);

print(q1 * q2);			  -- 0.000000, 0.707107, 0.707107, 0.000000
print(q1 * q1:inverse()); -- 1.000000, 0.000000, 0.000000, 0.000000
print(q1:inverse() * q1); -- 1.000000, 0.000000, 0.000000, 0.000000
print(q2 * q2:inverse()); -- 1.000000, 0.000000, 0.000000, 0.000000
```
