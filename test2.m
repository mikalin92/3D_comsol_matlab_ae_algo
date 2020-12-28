function test2(sensor_number)
%plots csv file data

csv_string='probetable.csv'; 
datamatrix=csvread(csv_string,5);
for kk=1:sensor_number
   datacolumn=datamatrix(:,kk+1);%1st colmn is time, others pressure 
   plot(datamatrix(:,1),datacolumn)
   hold on
   xlabel('t [s]')
   ylabel('p [Pa]')
   title('Sensor data example')
end
end