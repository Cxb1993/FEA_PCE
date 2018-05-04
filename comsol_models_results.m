function comsol_models_results(k,n0,deltan)
% create results automatically from simulated Comsol models
%Input for the script: 
%           1. exp_i_out.mph  (where i=1,2,3,...,num_of_folders)
%Outputs of the script:
%           1. exp_i_out_data_exported.mph  (where i=1,2,3,...,num_of_folders)
%           2. depth_data.csv  %(saved with the same name in each folder) %this will be an input for "find_depth_keep.m"
%           3. surface_data.csv %(saved with the same name in each folder) %this will be an input for "find_width_keep.m" and "find_length_keep.m"

newpath = '/software/tamusc/Comsol/5.3/mli';
path(path,newpath);
mphstart
import com.comsol.model.*
import com.comsol.model.util.*

cd([getenv('HOME'),'/FEA_PCE/'])
newdata = csvread(['data/FEA_iter',num2str(k),'.csv'],1,0);
results = zeros(deltan,3);

for i=(n0+1):(n0+deltan)
    workfolder = [getenv('SCRATCH'),'/FEA_PCE/model',num2str(i)];
    
    % Open Comsol model
    model = mphopen([workfolder,'/model_out_',num2str(i),'.mph']); 
    
    %  Make two cut planes     
    model.result.dataset.create('cpl1', 'CutPlane');
    model.result.dataset.create('cpl2', 'CutPlane');
    
    % Cut Plane 1: %A cross section along xy-plane. %top surface 
    model.result.dataset('cpl1').label('Surface');
    model.result.dataset('cpl1').set('quickplane', 'xy');
    model.result.dataset('cpl1').set('quickz', '30E-6');
    
    % Cut Plane 2: %A cross section along xz-plane. %Rear surface     
    model.result.dataset('cpl2').label('Depth');
    model.result.dataset('cpl2').set('quickplane', 'xz');
    
    % Create data1 and data2    
    model.result.export.create('data1', 'Data');
    model.result.export.create('data2', 'Data');
    
    % Set conditions for data 1
    model.result.export('data1').label('Length_Width_Data');
    model.result.export('data1').set('data', 'cpl1');
    model.result.export('data1').set('location', 'grid');
    model.result.export('data1').set('gridx2', 'range(0,1.0e-6,x_dist)');
    model.result.export('data1').set('descr', {'Temperature'});
    model.result.export('data1').set('gridy2', 'range(0,1.0e-6,y_dist)');
    model.result.export('data1').set('filename', [workfolder,'/surface_data.csv']);
    model.result.export('data1').set('unit', {'K'});
    model.result.export('data1').set('sort', true);
    model.result.export('data1').set('expr', {'T'});
    
    % Set conditions for data 2    
    model.result.export('data2').label('Depth_Data');
    model.result.export('data2').set('data', 'cpl2');
    model.result.export('data2').set('location', 'grid');
    model.result.export('data2').set('gridx2', 'range(0,1.0e-6,x_dist)');
    model.result.export('data2').set('descr', {'Temperature'});
    model.result.export('data2').set('gridy2', 'range(-2.0e-4,1.0e-6,3.0e-5)');
    model.result.export('data2').set('filename', [workfolder,'/depth_data.csv']);
    model.result.export('data2').set('unit', {'K'});
    model.result.export('data2').set('sort', true);
    model.result.export('data2').set('expr', {'T'});
    
    % Export all data to corresponding csv files     
    model.result.export('data1').run;
    model.result.export('data2').run;
    
    % Save the modified comsol model
    mphsave(model,[workfolder,'/model_data_',num2str(i),'.mph']);
    
    d = find_depth(workfolder);
    l = find_length(workfolder);
    w = find_width(workfolder);
    results(i-n0,:) = [d,l,w];
    fprintf('Results created for model %d of %d\n\n',i,n0+deltan);
end

newdata = [newdata,results];
data_file = 'data/FEA_all_data.csv';
if ~exist(data_file,'file')
    fid = fopen(data_file,'wt');
    fprintf(fid,'P,v,D4,depth,length,width\n');
    fclose(fid);
end
dlmwrite(data_file,newdata,'-append','precision','%.8e','delimiter',',')

ModelUtil.disconnect;
close
