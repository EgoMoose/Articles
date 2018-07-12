Having the ability to rotate vectors is a very useful tool to have in your repotoire. One of the easiest ways to do this is by using Rodrigues' rotation formula. In this article we are going to discuss how the formula is derived.

## Breaking up the formula

To start off let's look at what a Rodrigues' rotation actually looks like.

![img1](imgs/img1.gif)

By drawing a few extra parts we can see the formula is rotating the red vector around the blue vector much like the axel of a car.

![img2](imgs/img2.gif)

We can start by labeling the parts we just drew and then finding their values.

![img3](imgs/img3.png)
![eq1](imgs/eq1.png)

In order to properly rotate we'll need two perpendicular vectors that trace the edge of the circle. We already have one of these in the form of `r`. To get the second one we will cross `k` and `v` to give us `r*`.

![img4](imgs/img4.png)

You might be thinking that crossing `k` and `v` seems like an odd choice, after all we're trying to find a perpendicular vector with the same magnitude as `r`. To show that the magnitude of `r*` is the same as the magnitude of `r` we will compare to a more obvious cross product choice that we know would have the correct magnitude.

Claim:
![eq2](imgs/eq2.png)

### Geometric proof

If we look at a side view of our vectors and use basic trigonic intuition (SOHCAHTOA) we can see the angle between `k` and `v` scales the cross product magnitude to the same as `k x r`.

![eq3](imgs/eq3.png)
![img5](imgs/img5.png)

### Algebraic proof

Alternatively we can plug the values in and simplify:

![eq5](imgs/eq5.png)

## Rotating around a circle

Now that we have two perpendicular vectors we can talk about how to use them to rotate around a circle. 

Since `cosθ` and `sinθ` can be thought of as x and y components on a unit circle we can use them to scale the two perpendicular axes to find a point on the edge of the circle.

![img6](imgs/img6.gif)

Thus, to represent this new vector, `r'`, we can use the following equation:

![eq6](imgs/img6.png)

## Putting it all together

Finally, to get the end result we must add the `r'` vector to the `d` vector to give us our rotated `v` vector.

![eq7](imgs/img7.png)

This leaves us with the final equation and what you would find [on wikipedia](https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula)!

```Lua
local function rodriguesRotation(v, k, t)
	k = k.unit;
	local cos, sin = math.cos(t), math.sin(t);
	return v*cos + (1-cos)*v:Dot(k)*k + k:Cross(v)*sin;
end
```

## 2D rotation matrix

There are a number of ways to find the 2D rotation matrix, but since we have already done all the math for the Rodrigues's rotation formula we may as well use it to find out how to rotate a 2D vector.

To start we'll write the equation in the case where the `k` vector and the `v` vector are orthogonal. We'll also take the opportunity to put the cross product in matrix form:

![eq17](imgs/img17.png)

In the 2D rotation case the axis of rotation, `k`, is the z-value pointing out of the screen `(0, 0, 1)` and `v` will always be laying on the x and y plane. Thus, we can plug in the `k` values into the cross product and simplify.

![eq18](imgs/img18.png)

Finally, after a slight bit of expanding and rearranging we are left with the 2D rotation matrix:

![eq19](imgs/img19.png)

```Lua
local function rotateV2(v, t)
	local cos, sin = math.cos(t), math.sin(t);
	local x = v.x*cos - v.y*sin;
	local y = v.x*sin + v.y*cos;
	return Vector2.new(x, y);
end
```

## Matrix form

In the previous section we had a equation that gave us a rotated vector. Occasionally we may find it useful to be able to preform this same rotation opperation, but with a matrix instead.

To start off we must realize that we need a way to represent the dot product and the cross product as matrix multiplications.

![eq8](imgs/img8.png)
![eq9](imgs/img9.png)

Now we can plug these into the original equation and factor out the vector we want to rotate, `v`. We'll note that we get a clear distinction between the rotation matrix `R` and `v`.

![eq10](imgs/img10.png)

Next we can show that:

![eq11](imgs/img11.png)
![eq12](imgs/img12.png)

Remembering that since `k` is a unit vector it must be true that `kx^2 + ky^2 + kz^2 = 1` which can then be rearranged and used to simplify.

![eq13](imgs/img13.png)

Using this revelation we can rewrite our `R` matrix.

![eq14](imgs/img14.png)

Now expand it:

![eq15](imgs/img15.png)

Again using the knowledge that `kx^2 + ky^2 + kz^2 = 1` we can simplify which leaves us with the final form of the matrix.

![eq16](imgs/img16.png)



