On occasion you may find it necessary to draw triangles given three points in 3D space. This article aims to go over one method that can be used to create those triangles using knowledge of trigonometry and coordinate frames.

## Triangle decomposition

The first thing we need to be aware of is that Roblox does not have a singular default shape that can be used to create any triangle. However, a shape that Roblox does have is right-angle triangles, otherwise known as wedges. Thus, we can decompose any triangle into a maximum of two right-angle triangles and draw from there. We can easily draw this process by placing a perpendicular line on the longest edge and having it intersect with the opposite vertex.

![img1](imgs/img1.png)

Now that we understand the basics of our goal we have to ask ourselves how we can achieve this mathematically. We'll start this process off by finding some information about the triangle depending on what side is the longest.

![img2](imgs/img2.png)

```Lua
local function draw3dTriangle(a, b, c, parent)
	local edges = {
		{longest = (c - a), other = (b - a), origin = a},
		{longest = (a - b), other = (c - b), origin = b},
		{longest = (b - c), other = (a - c), origin = c}
	};
	
	local edge = edges[1];
	for i = 2, #edges do
		if (edges[i].longest.magnitude > edge.longest.magnitude) then
			edge = edges[i];
		end
	end
end
```

Now that we have that information we can solve for one of the interior angles using the dot product between the two vectors we singled out. Having this angles allows us to use the basics of trigonometry to solve for our width and height for both of the triangles.

![img3](imgs/img3.png)

```Lua
local function draw3dTriangle(a, b, c, parent)
	-- code from before...
	local theta = math.acos(edge.longest.unit:Dot(edge.other.unit));
	-- SOHCAHTOA
	local w1 = math.cos(theta) * edge.other.magnitude;
	local w2 = edge.longest.magnitude - w1;
	local h = math.sin(theta) * edge.other.magnitude;
end
```

Beautiful! We now have the sizes of our two right triangles. Now we have to answer how we can properly position and rotate two wedges so they represent the larger triangle they are apart of.

## Manipulating the rotation matrix

Rarely when using CFrames do we find ourselves in a situation where we manually enter rotation components. This is one of those situations! We know a CFrame's rotation matrix represents the right, up, and back facing directions in any given rotation. If we can find out what those vectors are for each wedge we can plug them in to create a CFrame!

```Lua
local cf = CFrame.new() * CFrame.Angles(math.pi/4, math.pi/3, 0);
local x, y, z, r11, r12, r13, r21, r22, r23, r31, r32, r33 = cf:components();
 
local position = Vector3.new(x, y, z);
local right = Vector3.new(r11, r21, r31); -- right facing direction
local up = Vector3.new(r12, r22, r32); -- up facing direction
local back = Vector3.new(r13, r23, r33); -- back facing direction
 
print(cf.lookVector, -back); -- lookVector's the front facing direction so -back == cf.lookVector
```

However, before we even talk about how we’re going to get the right, up, and back vectors let’s first talk about how we’re going to get the position which is pretty straightforward with some simple vector math. Even though a wedge isn’t a rectangle it’s still positioned as such. That means the position we want for each wedge is the mid-way point across each right triangle’s hypotenuse. 

![img4](imgs/img4.png)

```Lua
local function draw3dTriangle(a, b, c, parent)
	-- code from before...
	local p1 = edge.origin + edge.other * 0.5;
	local p2 = edge.origin + edge.longest + (edge.other - edge.longest) * 0.5;
end
```

Now that we have both positions we can focus entirely on getting the facing directions for the rotation matrix. We can get the `right` vector of the rotation matrix by crossing the `longest` vector with the `other` vector and then normalizing. Once we have the `right` vector we can cross it with the `longest` vector and normalize again to get the `up` vector. Finally the `back` vector is simply just the longest vector normalized.

![img5](imgs/img5.png)

```Lua
local function draw3dTriangle(a, b, c, parent)
	-- code from before...
	local right = edge.longest:Cross(edge.other).unit;
	local up = right:Cross(edge.longest).unit;
	local back = edge.longest.unit;
end
```

Finally, we just have to plug these direction into the two wedge’s CFrames remembering to take into account that because their hypotenuses are sloping away from each other some of the rotational vectors are flipped.

```Lua
local function draw3dTriangle(a, b, c, parent)
	-- code from before...
	local cf1 = CFrame.new( -- wedge1 cframe
		p1.x, p1.y, p1.z,
		-right.x, up.x, back.x,
		-right.y, up.y, back.y,
		-right.z, up.z, back.z
	);
 
	local cf2 = CFrame.new( -- wedge2 cframe
		p2.x, p2.y, p2.z,
		right.x, up.x, -back.x,
		right.y, up.y, -back.y,
		right.z, up.z, -back.z
	);
end
```

## Putting it all together

When you put everything together you have a way to position and properly size two wedges to fit into any triangle!

![img6](imgs/img6.gif)

```Lua
local wedge = Instance.new("WedgePart");
wedge.Anchored = true;
wedge.TopSurface = Enum.SurfaceType.Smooth;
wedge.BottomSurface = Enum.SurfaceType.Smooth;

local function draw3dTriangle(a, b, c, parent)
	local edges = {
		{longest = (c - a), other = (b - a), origin = a},
		{longest = (a - b), other = (c - b), origin = b},
		{longest = (b - c), other = (a - c), origin = c}
	};
	
	local edge = edges[1];
	for i = 2, #edges do
		if (edges[i].longest.magnitude > edge.longest.magnitude) then
			edge = edges[i];
		end
	end
	
	local theta = math.acos(edge.longest.unit:Dot(edge.other.unit));
	local w1 = math.cos(theta) * edge.other.magnitude;
	local w2 = edge.longest.magnitude - w1;
	local h = math.sin(theta) * edge.other.magnitude;
	
	local p1 = edge.origin + edge.other * 0.5;
	local p2 = edge.origin + edge.longest + (edge.other - edge.longest) * 0.5;
	
	local right = edge.longest:Cross(edge.other).unit;
	local up = right:Cross(edge.longest).unit;
	local back = edge.longest.unit;
	
	local cf1 = CFrame.new(
		p1.x, p1.y, p1.z,
		-right.x, up.x, back.x,
		-right.y, up.y, back.y,
		-right.z, up.z, back.z
	);
 
	local cf2 = CFrame.new(
		p2.x, p2.y, p2.z,
		right.x, up.x, -back.x,
		right.y, up.y, -back.y,
		right.z, up.z, -back.z
	);
	
	-- put it all together by creating the wedges
	
	local wedge1 = wedge:Clone();
	wedge1.Size = Vector3.new(0.2, h, w1);
	wedge1.CFrame = cf1;
	wedge1.Parent = parent;
	
	local wedge2 = wedge:Clone();
	wedge2.Size = Vector3.new(0.2, h, w2);
	wedge2.CFrame = cf2;
	wedge2.Parent = parent;
end
```