function create_comsol_models(k,n0,deltan)
% create automatically Comsol models depending on csv files for iteration i

newpath = '/software/tamusc/Comsol/5.3/mli';
path(path,newpath);
mphstart
import com.comsol.model.*
import com.comsol.model.util.*

cd([getenv('HOME'),'/FEA_PCE/'])
newdata = csvread(['data/FEA_iter',num2str(k),'.csv'],1,0);

workfolder = [getenv('SCRATCH'),'/FEA_PCE/'];
model = mphopen([workfolder,'Base_model.mph']); %this is the reference comsol model
for i=1:deltan
    fprintf('Creating model %d of %d\n',i,deltan)
    Pow = newdata(i,1);  %Beam Power
    Vel = newdata(i,2);  %Beam Velocity
    fourSigma = newdata(i,3); %beam size

    model.param.set('beam_p', [num2str(Pow),'[W]'], 'Beam power');
    model.param.set('beam_v', [num2str(Vel),'[m/s]'], 'Beam velocity');
    model.param.set('spot_size', [num2str(fourSigma),'[m]'], 'Spot Size');
    model.param.set('abs', num2str(0.7), 'absorptivity');
    
    j = n0 + i;
    mkdir([workfolder,'model',num2str(j)]);
    mphsave(model,[workfolder,'model',num2str(j),'/model_in_',num2str(j),'.mph']);
    fprintf('Model %d successfully created\n',j)
end

ModelUtil.disconnect;
close
