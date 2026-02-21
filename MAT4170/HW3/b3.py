def mats():
    for i in range(0, 3):
        for j in range(0,3):
            for k in range(0,3):
                if i == j or j == k or k == i:
                    continue
                for mod in range(2 ** 3):
                    mat = [[0]*3 for _ in range(3)]
                    mat[0][i] = 1 if mod & 1 == 0 else -1
                    mat[1][j] = 1 if mod & 2 == 0 else -1
                    mat[2][k] = 1 if mod & 4 == 0 else -1 
                        
                    yield mat

def det_3x3(mat):
    a, b, c = mat[0]
    d, e, f = mat[1]
    g, h, i = mat[2]
    return a*(e*i - f*h) - b*(d*i - f*g) + c*(d*h - e*g)

def color(det):
    if det == 1:
        return 'color("red")'
    return 'color("green")'

pre = """
module blob() {
  cylinder(20,10,5);
  translate([-5,0,10]) rotate([45,0,0]) cube([20,10,5]);
}

blob();
"""

head = """
multmatrix( 
"""

tail = """
) { blob(); };
"""

print(pre)
for mat in mats():
    print(color(det_3x3(mat)) + head + str(mat) + tail)
