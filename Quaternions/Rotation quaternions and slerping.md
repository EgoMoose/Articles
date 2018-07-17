# Rotation Quaternions and slerping

This article aims to cover the technical aspects of rotation quaternions (i.e. how to write a quaternion class). Readers are recommended to have read the [Rodrigues' rotation](https://github.com/EgoMoose/Articles/blob/master/Rodrigues'%20rotation/Rodrigues'%20rotation.md) article ahead of time as it will be used to compare results.

## Crash course on imaginiary/complex numbers

Before we can get into understanding quaternions we first need to understand the concept of imaginary and complex numbers. The names might seem daunting, but for our purposes the concepts are pretty straight forward. 

Imaginary numbers have a very simple purpose, to solve equations that real numbers couldn’t! For example: 

`x^2 + 25 = 0`

There is no real number solution to this equation because any real number we take to the power of two will result in a positive number. So in order for the above equation to be true it must be that:

`x^2 = -25`

This is what we call an imaginary number. They are special in the sense that they square to a real negative value. So far we have used `x` as a variable, but usually when representing imaginary numbers we use what is called the imaginary unit `i` where `i^2 = -1`. That way we can reprsent any imaginary number as a product of a real number and `i`. For example:

`(5i)^2 + 25 = 25(i^2) + 25 = -25 + 25 = 0`

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
(2 + i)*i = 2i + i^2 = -1 + 2i
(2 + i)*i^2 = (-1 + 2i)*i = -i + 2i^2 = -2 - i
(2 + i)*i^3 = (-2 - i)*i = -2i - i^2 = 1 - 2i
(2 + i)*i^4 = (1 - 2i)*i = i - 2i^2 = 2 + i
```

![img4]()

We can expand on this concept by instead multiplying with a complex number that gives us control of the angle we rotate by.

We can trace a unit circle with `cosθ + sinθ*i` so if we multiply it by a complex number we get a general formula for rotating counter-clockwise by any angle.

```
(a + bi)*(cosθ + sinθ*i)
a*cosθ + a*sinθ*i + b*cosθ*i + b*sinθ*i^2
a*cosθ - b*sinθ + (a*sinθ + b*cosθ)i
```

You might be somewhat familiar with this formula. It's just the 2D rotation matrix in complex number form!

## The quaternion is born

Prior to quaternions most mathematicians saw the complex plane in 2D and simply figured if they wanted to add a third dimension they just had to add another imaginary number. However, this led to problems. 