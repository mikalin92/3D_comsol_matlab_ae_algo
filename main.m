%calculates failure location in concrete structure with internal circ void
%uses perturbation+gauss-newton numerical algorithms

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




%iterations
k=4;



mesh_size=7;% mesh size in data(1=fine...9=extremely coarse [please: max 7])
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


%change mesh to another to prevent inverse crime
mesh_size=7;
%freq in inversion
f=25000;
parameters=[f,c,pressure_threshold,mesh_size,hole_radius,hole_loc_x,hole_loc_y];
%step lenght
alpha=1;
%perturbation epsilon=a*lambda+b
epsa=0;%1/6;%0.1
epsb=0.12;%0.125
eps=epsa*lambda+epsb;
%breaking constant
s=0.5;

history_of_iterations=zeros(3,k);



NN=size(x);%amoutn of sensors
NN=NN(2);
n=[0.35 0.35 0.35]';%initial guess to algorithm


  


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






%initialize for algorithm
% h=zeros(NN,1);
% J1=zeros(NN,1);
% J2=zeros(NN,1);
% J3=zeros(NN,1);



%start algorithm

for index=1:k


%update h

h=getz(n,parameters,x);
%check if forward or backward difference due limitations
if n(1)>0
varx=-1;
end

if n(2)>0
vary=-1;
end

if n(3)>0
varz=-1;
end

%perturbation
nx=n+varx*[eps; 0; 0];
ny=n+vary*[0; eps ; 0];
nz=n+varz*[0; 0; eps];


hx=getz(nx,parameters,x);
hy=getz(ny,parameters,x);
hz=getz(nz,parameters,x);



%update J (jacobian)
J=[varx*(hx-h)/eps   vary*(hy-h)/eps  varz*(hz-h)/eps];




%G-N iteration step
lastn=n;%remember last position

% n=n+alpha*pinv(J)*(z-h);
step=pinv(J)*(z-h);


%this cond does not accept too small step at beginning
if norm(step)<2*(eps/k) 
    step=4*eps*([rand rand rand]-0.5)';
end

%update location
n=n+step; 






%geometrical limitations goes here

%angle relative to center of void
phi=angle((-hole_loc_x+n(1))+((-hole_loc_y+n(2))*1i));

%if going too near void, push away
if norm([n(1) ;n(2)]-hole_loc_vec)<hole_radius+eps/2
    n(1)=hole_loc_vec(1)+(hole_radius+eps*2)*cos(phi+2*pi*20/360);
    n(2)=hole_loc_vec(2)+(hole_radius+eps*2)*sin(phi+2*pi*20/360);
end

%if too near edges   

for i=1:3
    if n(i)>0.5-eps/2
       n(i)=0.5-eps*2;%push further back
    end 
    
    if n(i)<-0.5+eps/2
       n(i)=-0.5+eps*2;%push further back
    end 
    
    
end



    











history_of_iterations(:,index)=n;
figure(fig1);
linematrix_todraw=[n lastn];
plot3(linematrix_todraw(1,:),linematrix_todraw(2,:),linematrix_todraw(3,:),'color','green');

if is_drawnow==1
    drawnow;
end


end

figure(fig1); 
plot3(n(1),n(2),n(3),'o','color','green');






figure(fig1); 
titlestr=strcat('Location by algorithm:(',num2str(n(1)),';', num2str(n(2)),';', num2str(n(3))  ,')');
title(titlestr);


