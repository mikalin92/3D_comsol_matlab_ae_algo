%calculates failure location in concrete structure with internal circ void
%uses grid search

%grid constant for search, dot amount amount is grid^3
gridc=2;



is_drawnow=1;%1=draw figure during algorithm 0=off

%sensor locations (any amount,but more the better and too much is too much)

x=[0.5  -0.5     0     0    0.5     0.5    0.5     0.5   -0.5  -0.5  -0.5   -0.5;%x
      0     0   0.5  -0.5    0.5    -0.5    0.5    -0.5    0.5  -0.5   0.5   -0.5;%y
      0     0     0     0    0.5     0.5   -0.5    -0.5    0.5   0.5  -0.5   -0.5];%z
  %   1     2     3     4      5       6      7       8      9    10    11
  
  
%vertices of rectangular cuboid, 16 to draw
element_vertices_todraw=0.5*[+1 +1 -1 -1 +1 +1 +1 -1 -1 +1 +1 +1 -1 -1 -1 -1;%x
                             -1 -1 -1 -1 -1 +1 +1 +1 +1 +1 +1 -1 -1 +1 +1 -1;%y
                             -1 +1 +1 -1 -1 -1 +1 +1 -1 -1 +1 +1 +1 +1 -1 -1];%z
                          %   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15                        
                         
  
  
%location of the hole and radius
hole_radius=0.23;%0.15;
hole_loc_x=0;
hole_loc_y=0.1;

hole_loc_vec=[hole_loc_x; hole_loc_y;];






mesh_size=8;% mesh size in data(1=fine...9=extremely coarse [please: max 8])
%freq in data
f=25000;
%pulse speed
c=3200;

pressure_threshold=0.5e8;%pressure where signal is registered
parameters=[f,c,pressure_threshold,mesh_size,hole_radius,hole_loc_x,hole_loc_y];



lambda=c/f;%wavelength


%true damage location


loc=[-0.3 -0.3 -0.3]';

%get z i.e data from sensors
z=getz(loc,parameters,x);


mesh_size=8;% mesh size in data(1=fine...9=extremely coarse)
%freq in inversion
f=25000;
parameters=[f,c,pressure_threshold,mesh_size,hole_radius,hole_loc_x,hole_loc_y];







fig1=figure;
axis([-0.5 0.5 -0.5 0.5 -0.5 0.5]);


figure(fig1);

%draw sensors
plot3(x(1,:),x(2,:),x(3,:),'o','Color','black');
hold on;
figure(fig1);
%draw element
plot3(element_vertices_todraw(1,:),element_vertices_todraw(2,:),element_vertices_todraw(3,:),'Color','black');
figure(fig1);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');




t = linspace(0,2*pi);
zminus=-0.5*ones(size(t));
zplus=0.5*ones(size(t));

%draw void outer circles

figure(fig1);
plot3(hole_loc_x+hole_radius*cos(t),hole_loc_y+hole_radius*sin(t),zminus,'color','black'); 

figure(fig1);
plot3(hole_loc_x+hole_radius*cos(t),hole_loc_y+hole_radius*sin(t),zplus,'color','black'); 


lineamount=8;
t = linspace(0,2*pi,lineamount+1);
tsize=size(t);

%draw lines circle to circle
for i=1:tsize(2)
    
    vrtx_todraw=zeros(3,2);
    vrtx_todraw(:,1)=[hole_loc_x+hole_radius*cos(t(i));hole_loc_y+hole_radius*sin(t(i));0.5];
    vrtx_todraw(:,2)=[hole_loc_x+hole_radius*cos(t(i));hole_loc_y+hole_radius*sin(t(i));-0.5];
    
    
    figure(fig1);
    plot3(vrtx_todraw(1,:),vrtx_todraw(2,:),vrtx_todraw(3,:),'color','black');


end









figure(fig1);
plot3(loc(1),loc(2),loc(3),'o','color','red');


if is_drawnow==1
    drawnow;
end



















A=linspace(-0.4,0.4,gridc);    
B=linspace(-0.4,0.4,gridc);  
C=linspace(-0.4,0.4,gridc);  

[A,B,C]=meshgrid(A,B,C);  
 D=zeros(gridc,gridc,gridc);
    
    
%%%build meshgrid D
for ix=1:gridc
    for iy=1:gridc
       for iz=1:gridc
            nn1=[A(ix,iy,iz) B(ix,iy,iz) C(ix,iy,iz)]';

            if (norm([nn1(1) nn1(2)]'-hole_loc_vec)<hole_radius )
                D(ix,iy)=NaN;%NaN if inside void
            else

                figure(fig1);


                plot3(nn1(1),nn1(2),nn1(3),'.','color','blue')
                drawnow
                hold on


                h=getz(nn1,parameters,x);
                D(ix,iy,iz)=norm(z-h);

            end
        end
    end
end

x_val=num2str(A(D==min(min(min(D)))));
y_val=num2str(B(D==min(min(min(D)))));
z_val=num2str(C(D==min(min(min(D)))));


titlestr=strcat('Location by grid:(',x_val,';',y_val,';',z_val,')');
title(titlestr);
















