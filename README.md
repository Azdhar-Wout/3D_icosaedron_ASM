======= 3D_icosahedron_ASM =======

1. Project
This is a project I had to do for school. 
The purpose of this project is to draw an icosahedron (polyhedron with 20 faces) in 3D in NASM x86-64 with Linux.
The faces that are at the back must be hidden. Also, the user must be able to rotate the polyhedron around x, y and z.

2. Code
Some parts were provided as a basis by the teacher :
- VM : Debian 9.13
- compileX11.sh : allow to generate the executable file from the '.asm' file
- icosaedre.asm : basis of the program, call of the main functions from X11 and stdio library, coordinates of the vertices of the polyhedron

3. Run
Firts, before running the program, you must convert 'compileX11.sh' into executable file :
chmod a+x compileX11.sh

Then you must run 'Projet.asm' with 'compileX11' :
. ./compileX11.sh Projet.asm

You will have to enter the rotation you want to apply to the polyhedron. 
Note : the rotations are made in this order : x -> y -> z.
Enter x = 0, y = 0, z = 0 if you don't want to rotate the polyhedron.

4. Known Issues
The basic display work perfectly fine but the rotation induce a segmentation fault in the program.
I'm not sure where it comes from so I can't resolve it right now.
Just delet the code that rotate the polyhedron and the display will be fine.

5. Post-scriptum
To prevent the futur students from cheating, I will delete all the comments that I wrote in the code. I will also destroy the formating.
Sorry for the inconvenience.