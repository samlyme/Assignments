
module blob() {
  cylinder(h = 10, r = 4);
  translate(v = [2,4,10]) sphere(3);
  translate(v = [-2,5,7]) cube([5,6,7], center = true);
}

blob();

color("red")
multmatrix( 
[[1, 0, 0], [0, 1, 0], [0, 0, 1]]
) { blob(); };

color("green")
multmatrix( 
[[-1, 0, 0], [0, 1, 0], [0, 0, 1]]
) { blob(); };

color("green")
multmatrix( 
[[1, 0, 0], [0, -1, 0], [0, 0, 1]]
) { blob(); };

color("red")
multmatrix( 
[[-1, 0, 0], [0, -1, 0], [0, 0, 1]]
) { blob(); };

color("green")
multmatrix( 
[[1, 0, 0], [0, 1, 0], [0, 0, -1]]
) { blob(); };

color("red")
multmatrix( 
[[-1, 0, 0], [0, 1, 0], [0, 0, -1]]
) { blob(); };

color("red")
multmatrix( 
[[1, 0, 0], [0, -1, 0], [0, 0, -1]]
) { blob(); };

color("green")
multmatrix( 
[[-1, 0, 0], [0, -1, 0], [0, 0, -1]]
) { blob(); };

color("green")
multmatrix( 
[[1, 0, 0], [0, 0, 1], [0, 1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[-1, 0, 0], [0, 0, 1], [0, 1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[1, 0, 0], [0, 0, -1], [0, 1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[-1, 0, 0], [0, 0, -1], [0, 1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[1, 0, 0], [0, 0, 1], [0, -1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[-1, 0, 0], [0, 0, 1], [0, -1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[1, 0, 0], [0, 0, -1], [0, -1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[-1, 0, 0], [0, 0, -1], [0, -1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 1, 0], [1, 0, 0], [0, 0, 1]]
) { blob(); };

color("red")
multmatrix( 
[[0, -1, 0], [1, 0, 0], [0, 0, 1]]
) { blob(); };

color("red")
multmatrix( 
[[0, 1, 0], [-1, 0, 0], [0, 0, 1]]
) { blob(); };

color("green")
multmatrix( 
[[0, -1, 0], [-1, 0, 0], [0, 0, 1]]
) { blob(); };

color("red")
multmatrix( 
[[0, 1, 0], [1, 0, 0], [0, 0, -1]]
) { blob(); };

color("green")
multmatrix( 
[[0, -1, 0], [1, 0, 0], [0, 0, -1]]
) { blob(); };

color("green")
multmatrix( 
[[0, 1, 0], [-1, 0, 0], [0, 0, -1]]
) { blob(); };

color("red")
multmatrix( 
[[0, -1, 0], [-1, 0, 0], [0, 0, -1]]
) { blob(); };

color("red")
multmatrix( 
[[0, 1, 0], [0, 0, 1], [1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, -1, 0], [0, 0, 1], [1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 1, 0], [0, 0, -1], [1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, -1, 0], [0, 0, -1], [1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 1, 0], [0, 0, 1], [-1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, -1, 0], [0, 0, 1], [-1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 1, 0], [0, 0, -1], [-1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, -1, 0], [0, 0, -1], [-1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, 1], [1, 0, 0], [0, 1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, -1], [1, 0, 0], [0, 1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, 1], [-1, 0, 0], [0, 1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, -1], [-1, 0, 0], [0, 1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, 1], [1, 0, 0], [0, -1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, -1], [1, 0, 0], [0, -1, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, 1], [-1, 0, 0], [0, -1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, -1], [-1, 0, 0], [0, -1, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, 1], [0, 1, 0], [1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, -1], [0, 1, 0], [1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, 1], [0, -1, 0], [1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, -1], [0, -1, 0], [1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, 1], [0, 1, 0], [-1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, -1], [0, 1, 0], [-1, 0, 0]]
) { blob(); };

color("green")
multmatrix( 
[[0, 0, 1], [0, -1, 0], [-1, 0, 0]]
) { blob(); };

color("red")
multmatrix( 
[[0, 0, -1], [0, -1, 0], [-1, 0, 0]]
) { blob(); };

