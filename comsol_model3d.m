function comsol_model3d(location,parameters,sensors)


%outputs sensor data as csv files
%loc=fault location, x=sensor locations
size_of_sensormatrix=size(sensors);
sensor_amount=size_of_sensormatrix(2);
f=num2str(parameters(1));%frequncy
c=num2str(parameters(2));%speed of sound in concrete

mesh_size = parameters(4); % mesh size(1=fine...9=extremely coarse)

%internal void parameters (2string as comsol wants):
hole_radius=num2str(parameters(5));
hole_loc_x=num2str(parameters(6));
hole_loc_y=num2str(parameters(7));

%fault location
fault_x=num2str(location(1));
fault_y=num2str(location(2));
fault_z=num2str(location(3));

matlab_path_string=pwd;







%
% comsol_model3d.m
%
% Model exported on Dec 27 2020, 12:33 by COMSOL 5.1.0.234.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\Mika\OneDrive for Business\concrete_3d');

model.label('comsol_model3d.mph');

model.comments(['Untitled\n\n']);

model.modelNode.create('comp1');

model.file.clear;

model.geom.create('geom1', 3);

model.mesh.create('mesh1', 'geom1');

model.geom('geom1').create('blk1', 'Block');
model.geom('geom1').feature('blk1').set('pos', {'-0.5' '-0.5' '-0.5'});

model.geom('geom1').create('cyl1', 'Cylinder');


% model.geom('geom1').feature('cyl1').set('r', '0.3');

model.geom('geom1').feature('cyl1').set('r', hole_radius);

% model.geom('geom1').feature('cyl1').set('pos', {'0' '0' '-0.5'});
model.geom('geom1').feature('cyl1').set('pos', {hole_loc_x hole_loc_y '-0.5'});





model.geom('geom1').create('dif1', 'Difference');
model.geom('geom1').feature('dif1').selection('input2').set({'cyl1'});
model.geom('geom1').feature('dif1').selection('input').set({'blk1'});



model.geom('geom1').create('pt1', 'Point');
model.geom('geom1').feature('pt1').label('Sourcepoint');



% model.geom('geom1').feature('pt1').setIndex('p', '-0.3', 0, 0);
% model.geom('geom1').feature('pt1').setIndex('p', '-0.3', 1, 0);
% model.geom('geom1').feature('pt1').setIndex('p', '-0.3', 2, 0);

model.geom('geom1').feature('pt1').setIndex('p', fault_x, 0, 0);
model.geom('geom1').feature('pt1').setIndex('p', fault_y, 1, 0);
model.geom('geom1').feature('pt1').setIndex('p', fault_z, 2, 0);


model.geom('geom1').run;
model.geom('geom1').run('fin');

model.material.create('mat2', 'Common', 'comp1');
model.material('mat2').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');

model.physics.create('actd', 'TransientPressureAcoustics', 'geom1');
model.physics('actd').create('mps1', 'TransientMonopolePointSource', 0);
model.physics('actd').feature('mps1').selection.set([5]);

model.mesh('mesh1').create('ftet1', 'FreeTet');

model.result.table.create('tbl1', 'Table');

% model.probe.create('pdom1', 'DomainPoint');
% model.probe.create('pdom2', 'DomainPoint');
% model.probe.create('pdom3', 'DomainPoint');
% model.probe.create('pdom4', 'DomainPoint');
% model.probe('pdom1').model('comp1');
% model.probe('pdom2').model('comp1');
% model.probe('pdom3').model('comp1');
% model.probe('pdom4').model('comp1');

for i=1:sensor_amount
    probe_name_string=strcat('pdom',num2str(i));
    model.probe.create(probe_name_string, 'DomainPoint');
    model.probe(probe_name_string).model('comp1');
end




model.material('mat2').label('Concrete');
model.material('mat2').set('family', 'concrete');
model.material('mat2').propertyGroup('def').set('thermalexpansioncoefficient', {'10e-6[1/K]' '0' '0' '0' '10e-6[1/K]' '0' '0' '0' '10e-6[1/K]'});
model.material('mat2').propertyGroup('def').set('density', '2300[kg/m^3]');
model.material('mat2').propertyGroup('def').set('thermalconductivity', {'1.8[W/(m*K)]' '0' '0' '0' '1.8[W/(m*K)]' '0' '0' '0' '1.8[W/(m*K)]'});
model.material('mat2').propertyGroup('def').set('heatcapacity', '880[J/(kg*K)]');



%model.material('mat2').propertyGroup('def').set('soundspeed', '3200');

model.material('mat2').propertyGroup('def').set('soundspeed', c);


model.material('mat2').propertyGroup('Enu').set('youngsmodulus', '25e9[Pa]');
model.material('mat2').propertyGroup('Enu').set('poissonsratio', '0.33');

model.physics('actd').feature('mps1').set('Type', 'GaussianPulse');
model.physics('actd').feature('mps1').set('A', '10');

% model.physics('actd').feature('mps1').set('f0', '25000[Hz]');

model.physics('actd').feature('mps1').set('f0', f);


model.physics('actd').feature('mps1').set('tp', '0.0012[s]');

%model.mesh('mesh1').feature('size').set('hauto', 7);
model.mesh('mesh1').feature('size').set('hauto', mesh_size);
model.mesh('mesh1').run;

model.result.table('tbl1').label('Probe Table 1');

% model.probe('pdom1').setIndex('coords3', '0.5', 0, 0);
% model.probe('pdom1').setIndex('coords3', '0', 0, 1);
% model.probe('pdom1').setIndex('coords3', '0', 0, 2);
% model.probe('pdom1').feature('ppb1').set('window', 'window1');
% model.probe('pdom1').feature('ppb1').set('table', 'tbl1');
% model.probe('pdom2').setIndex('coords3', '-0.5', 0, 0);
% model.probe('pdom2').setIndex('coords3', '0', 0, 1);
% model.probe('pdom2').setIndex('coords3', '0', 0, 2);
% model.probe('pdom2').feature('ppb2').set('window', 'window1');
% model.probe('pdom2').feature('ppb2').set('table', 'tbl1');
% model.probe('pdom3').setIndex('coords3', '0', 0, 0);
% model.probe('pdom3').setIndex('coords3', '0.5', 0, 1);
% model.probe('pdom3').setIndex('coords3', '0', 0, 2);
% model.probe('pdom3').feature('ppb3').set('window', 'window1');
% model.probe('pdom3').feature('ppb3').set('table', 'tbl1');
% model.probe('pdom4').setIndex('coords3', '0', 0, 0);
% model.probe('pdom4').setIndex('coords3', '-0.5', 0, 1);
% model.probe('pdom4').setIndex('coords3', '0', 0, 2);
% model.probe('pdom4').feature('ppb4').set('window', 'window1');
% model.probe('pdom4').feature('ppb4').set('table', 'tbl1');

for i=1:sensor_amount
    probe_name_string=strcat('pdom',num2str(i));
    probepoint_name_string=strcat('ppb',num2str(i));
    for j=0:2%direction 0=x 1=y 2=z java way
        coordinate_string=num2str(sensors(j+1,i));%plus one to matlab way
        model.probe(probe_name_string).setIndex('coords3', coordinate_string, 0, j);
    end
    
    model.probe(probe_name_string).feature(probepoint_name_string).set('window', 'window1');
    model.probe(probe_name_string).feature(probepoint_name_string).set('table', 'tbl1');
end




model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.study('std1').feature('time').set('initstudyhide', 'on');
model.study('std1').feature('time').set('initsolhide', 'on');
model.study('std1').feature('time').set('solnumhide', 'on');
model.study('std1').feature('time').set('notstudyhide', 'on');
model.study('std1').feature('time').set('notsolhide', 'on');
model.study('std1').feature('time').set('notsolnumhide', 'on');

model.result.dataset.create('dset2', 'Solution');


% model.result.dataset.create('cpt1', 'CutPoint3D');
% model.result.dataset.create('cpt2', 'CutPoint3D');
% model.result.dataset.create('cpt3', 'CutPoint3D');
% model.result.dataset.create('cpt4', 'CutPoint3D');

for i=1:sensor_amount
    cutpointname_string=strcat('cpt',num2str(i));
    model.result.dataset.create(cutpointname_string, 'CutPoint3D');
end




%model.result.dataset('dset2').set('probetag', 'pdom4');
%force first probe to main probe
model.result.dataset('dset2').set('probetag', 'pdom1');




% model.result.dataset('cpt1').set('probetag', 'pdom4');
% model.result.dataset('cpt1').set('data', 'dset2');
% model.result.dataset('cpt2').set('probetag', 'pdom1');
% model.result.dataset('cpt2').set('data', 'dset2');
% model.result.dataset('cpt3').set('probetag', 'pdom2');
% model.result.dataset('cpt3').set('data', 'dset2');
% model.result.dataset('cpt4').set('probetag', 'pdom3');
% model.result.dataset('cpt4').set('data', 'dset2');

%COMSOL set last probe to main
%let us force first to first and force logic cptX->pdomX
for i=1:sensor_amount
    cutpoint_string=strcat('cpt',num2str(i));
    probe_name_string=strcat('pdom',num2str(i));
    
    model.result.dataset(cutpoint_string).set('probetag', probe_name_string);
    model.result.dataset(cutpoint_string).set('data', 'dset2');
    
end



% model.result.numerical.create('pev1', 'EvalPoint');
% model.result.numerical.create('pev2', 'EvalPoint');
% model.result.numerical.create('pev3', 'EvalPoint');
% model.result.numerical.create('pev4', 'EvalPoint');
% 
% 
% 
% model.result.numerical('pev1').set('probetag', 'pdom4/ppb4');
% model.result.numerical('pev2').set('probetag', 'pdom1/ppb1');
% model.result.numerical('pev3').set('probetag', 'pdom2/ppb2');
% model.result.numerical('pev4').set('probetag', 'pdom3/ppb3');
% 


for i=1:sensor_amount
    evalpoint_string=strcat('pev',num2str(i));
    probetag_string=strcat('pdom',num2str(i),'/ppb',num2str(i));
    
    model.result.numerical.create(evalpoint_string, 'EvalPoint');
    model.result.numerical(evalpoint_string).set('probetag', probetag_string);
end



model.result.create('pg1', 'PlotGroup3D');
model.result.create('pg2', 'PlotGroup3D');
model.result.create('pg3', 'PlotGroup1D');




model.result('pg1').create('surf1', 'Surface');
model.result('pg2').create('iso1', 'Isosurface');
model.result('pg3').set('probetag', 'window1_default');
model.result('pg3').create('tblp1', 'Table');



%model.result('pg3').feature('tblp1').set('probetag', 'pdom4/ppb4,pdom1/ppb1,pdom2/ppb2,pdom3/ppb3');



probetag_string_all='pdom1/ppb1';
for i=2:sensor_amount%start from second
    additive=strcat(',pdom',num2str(i),'/ppb',num2str(i));
    probetag_string_all=strcat(probetag_string_all,additive);
end

model.result('pg3').feature('tblp1').set('probetag', probetag_string_all);

% model.probe('pdom1').genResult([]);
% model.probe('pdom2').genResult([]);
% model.probe('pdom3').genResult([]);
% model.probe('pdom4').genResult([]);


for i=1:sensor_amount
    probe_name_string=strcat('pdom',num2str(i));
    model.probe(probe_name_string).genResult([]);
   
end


model.study('std1').feature('time').set('tlist', 'range(0,0.0001,0.002)');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('t1').set('tlist', 'range(0,0.0001,0.002)');
model.sol('sol1').feature('t1').set('timemethod', 'genalpha');
model.sol('sol1').runAll;

model.result.dataset('dset2').label('Probe Solution 2');
model.result.dataset('dset2').set('frametype', 'spatial');


% model.result.dataset('cpt1').set('data', 'dset2');
% model.result.dataset('cpt2').set('data', 'dset2');
% model.result.dataset('cpt3').set('data', 'dset2');
% model.result.dataset('cpt4').set('data', 'dset2');



for i=1:sensor_amount
    cutpoint_name_string=strcat('cpt',num2str(i));
    model.result.dataset(cutpoint_name_string).set('data', 'dset2');
end


model.result.dataset.remove('dset3');



model.result.numerical('pev1').setResult;



% model.result.numerical('pev2').appendResult;
% model.result.numerical('pev3').appendResult;
% model.result.numerical('pev4').appendResult;

for i=2:sensor_amount%start with 2
    evalpoint_name_string=strcat('pev',num2str(i));
    model.result.numerical(evalpoint_name_string).appendResult;
end



model.result('pg1').label('Acoustic Pressure (actd)');
model.result('pg1').set('looplevel', {'18'});
model.result('pg2').label('Acoustic Pressure, Isosurfaces (actd)');
model.result('pg2').set('looplevel', {'1'});
model.result('pg2').feature('iso1').set('number', '10');
model.result('pg3').label('Probe Plot Group 3');
model.result('pg3').set('xlabel', 't');
model.result('pg3').set('windowtitle', 'Probe Plot 1');
model.result('pg3').set('xlabelactive', false);
model.result('pg3').feature('tblp1').label('Probe Table Graph 1');

model.sol('sol1').study('std1');

model.study('std1').feature('time').set('notlistsolnum', 1);
model.study('std1').feature('time').set('notsolnum', '1');
model.study('std1').feature('time').set('listsolnum', 1);
model.study('std1').feature('time').set('solnum', '1');

model.sol('sol1').feature.remove('t1');
model.sol('sol1').feature.remove('v1');
model.sol('sol1').feature.remove('st1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').set('tlist', 'range(0,0.0001,0.002)');
model.sol('sol1').feature('t1').set('plot', 'off');
model.sol('sol1').feature('t1').set('plotgroup', 'pg1');
model.sol('sol1').feature('t1').set('plotfreq', 'tout');
model.sol('sol1').feature('t1').set('probesel', 'all');



% model.sol('sol1').feature('t1').set('probes', {'pdom1' 'pdom2' 'pdom3' 'pdom4'});
probename_cell=cell(1,sensor_amount);%build cell on probe names
for i=1:sensor_amount
    probename_string=strcat('pdom',num2str(i));
    probename_cell{i}=probename_string;
end

model.sol('sol1').feature('t1').set('probes', probename_cell);


model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
model.sol('sol1').feature('t1').set('rtol', 0.01);
model.sol('sol1').feature('t1').set('atolglobalmethod', 'scaled');
model.sol('sol1').feature('t1').set('atolglobal', 0.001);
model.sol('sol1').feature('t1').set('timemethod', 'genalpha');
model.sol('sol1').feature('t1').set('rhoinf', 0.75);
model.sol('sol1').feature('t1').set('maxorder', 5);
model.sol('sol1').feature('t1').set('minorder', 1);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature('fc1').set('linsolver', 'dDef');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').attach('std1');



% model.probe('pdom1').genResult('none');
% model.probe('pdom2').genResult('none');
% model.probe('pdom3').genResult('none');
% model.probe('pdom4').genResult('none');

for i=1:sensor_amount
    probename_string=strcat('pdom',num2str(i));
    model.probe(probename_string).genResult('none');
end


model.sol('sol1').runAll;

model.result('pg1').run;
%model.result.table('tbl1').save('C:\Users\Mika\OneDrive for Business\concrete_3d\probetable.csv');

%save data to csv
result_path=strcat(matlab_path_string,'\probetable.csv');
model.result.table('tbl1').save(result_path);

%use following two commands to get .mph (regular comsol) file of system
%model_path=strcat(matlab_path_string,'\physicalmodel.mph');
%model.save(model_path)
%comment out when unneeded

end
