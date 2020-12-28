%runs comsol_model3d as a test

%sensor locations (can be more than 4)

 
x=[0.5  -0.5     0     0    0.5     0.5    0.5     0.5   -0.5  -0.5  -0.5   -0.5;%x
      0     0   0.5  -0.5    0.5    -0.5    0.5    -0.5    0.5  -0.5   0.5   -0.5;%y
      0     0     0     0    0.5     0.5   -0.5    -0.5    0.5   0.5  -0.5   -0.5];%z
  %   1     2     3     4      5       6      7       8      9    10    11
  


%location of the hole and radius
hole_radius=0.3;%0.15;
hole_loc_x=0;
hole_loc_y=0;

hole_loc_vec=[hole_loc_x; hole_loc_y;];




mesh_size=7;
%freq in data
f=25000;
%pulse speed
c=3200;

pressure_threshold=0.5e8;
parameters=[f,c,pressure_threshold,mesh_size,hole_radius,hole_loc_x,hole_loc_y];



lambda=c/f;%wavelength


%true damage location


loc=[-0.3 -0.3 -0.3]';



comsol_model3d(loc,parameters,x);
