function M  = getz(n,parameters,x)
%gets the sensor data differences at point n from comsol

k=size(x);%number of sensors
veclength=k(2);
pressure_threshold=parameters(3);

comsol_model3d(n,parameters,x);%run comsol to build csv file


%import data from this csv
M=zeros(veclength,1);
csv_string='probetable.csv'; 
datamatrix=csvread(csv_string,5);
for kk=1:veclength
   datacolumn=datamatrix(:,kk+1);%1st colmn is time, others pressure 
   M(kk)=datamatrix(find(datacolumn>pressure_threshold,1),1);
   
end

M=difz(M);

end









