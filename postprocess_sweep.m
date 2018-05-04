function postprocess_sweep(k)
% gets melt pool dims from Comsol models

newpath = '/software/tamusc/Comsol/5.3/mli';
path(path,newpath);
mphstart
import com.comsol.model.*
import com.comsol.model.util.*

model_directory = [getenv('SCRATCH'),'/FEA_PCE/sweep/sweep',num2str(k)];
cd(model_directory);
diary('postprocessing_log.txt')
save_name = [getenv('HOME'),'/FEA_PCE/data/sweep',num2str(k)];
refine_level = 1;

% Ti64 PROPERTIES==========================================================
temps = 1920; %[K] Ti64
T_boil = 3315; %[K]Ti64

T_crit = T_boil*0.95; %Critical temperature at which significant evaporation occurs (arbitrary offset)

for T_melt = temps
    a = dir(['sweep',num2str(k),'__*.mph']);
    results = struct('length',[],'width',[],'depth',[],'power',[],'speed',[]);
    for i = 1:size(a,1) % main loop through all model files
        [~, cmdout] = system('free -m');
        free_mem = str2double(cmdout(180:189));
        total_mem = str2double(cmdout(80:95));
        if free_mem/total_mem < 0.15
            ModelUtil.disconnect
            mphstart
            import com.comsol.model.*
            import com.comsol.model.util.*
            clear Ttemp data2 g x y z
        end
        model = mphopen(a(i).name);
        [power, ~] = mphevaluate(model,'beam_p'); %can use unit as string in second output
        [speed, ~] = mphevaluate(model,'beam_v');
        [beamD, ~] = mphevaluate(model,'beam_dia');
        model_count = [num2str(i),'/',num2str(size(a,1))];
        fprintf('loaded model %s: %s\n\n',model_count,a(i).name)
        
        ds = model.result.dataset.create('data1', 'Solution');
        ds.set('solution','sol2');
        
        %         data2 = mpheval(model,{'T','ht.tfluxMag','ht.gradTx','ht.gradTz'},'dataset','data1','refine',refine_level
        data2 = mpheval(model,{'T'},'dataset','data1','refine',refine_level);
        t_steps = size(data2.d1,1);
        T_max = max(max(data2.d1));
        boil_percent = sum(data2.d1(:)>=T_crit)/numel(data2.d1); % normalized by number of simulation points so faster runs (i.e.larger domains) don't dominate.
        len = zeros(1,t_steps);
        wid = zeros(1,t_steps);
        dep = zeros(1,t_steps);
        q_list = zeros(1,t_steps);
        A = zeros(1,t_steps);
        V = zeros(1,t_steps);
        n_points = zeros(1,t_steps);
        % LOOP THROUGH EACH TIME STEP
        s_front_V = [];
        s_front_G = [];
        s_front_point = [];
        %         for j = 1:size(data2.d1,1)
        j=1; % COMMENT THIS AND UNCOMMENT FOR-LOOP LINE ABOVE IF EXTRACTING FROM TIME DEPENDENT SIMULATIIONS
        Ttemp = data2.d1(j,:); % TEMP VECTOR FOR ONE TIMESTEP
        if any(Ttemp>T_melt) % CHECK FOR MELTING
            melt_pool_points = data2.p(:,any(Ttemp>=T_melt,1),1); % EXTRACT GRID POINTS THAT HAVE MELTED
            melt_pool_points = melt_pool_points';
            n_points(j) = size(melt_pool_points,1);
            melt_shape = alphaShape(melt_pool_points,Inf); %create alphaShape object to find volume and area
            if volume(melt_shape) > 0
                [~,melt_pool_bound] = boundaryFacets(melt_shape); %extract just the boundary points from melt pool
                A(j) = surfaceArea(melt_shape); %calculate area of melt pool
                V(j) = volume(melt_shape); %calculate the volume of the melt pool
                b = max(melt_pool_bound,[],1); % FIND THE MAXIMUM X,Y,Z POINTS WHICH HAVE MELTED
                c = min(melt_pool_bound,[],1); % FIND THE MIMIMUM X,Y,Z POINTS WHICH HAVE MELTED
                % CALCULATE MELTPOOL DIMENSIONS AND STORE IN DUMMY VARIABLES
                len(j) = b(1)-c(1); % MELTPOOL LENGTH IS (XMAX - XMIN)
                wid(j) = 2*(b(2)-c(2)); % MELTPOOL WIDTH IS 2*(YMAX-YMIN) DUE TO SYMMETRY PLANE
                dep(j) = b(3)-c(3); % MELTPOOL DEPTH IS (ZMAX-ZMIN)
%                 mpb_noSurface = melt_pool_bound(abs(melt_pool_bound(:,2)-c(2))>=1e-8 & abs(melt_pool_bound(:,3)-b(3))>=1e-8,:);
% %                 %% FIND HEAT FLUX AT EACH POINT AT EACH NON-EXTERNAL MELT POOL SURFACE POINT
% %                 q_this_time = zeros(size(mpb_noSurface,1),1);
% %                 q_data = data2.d2(j,:);
% %                 count = 0;
% %                 for u = 1:size(mpb_noSurface,1)
% %                     try
% %                         q_this_time(u) = q_data(abs(data2.p(1,:)-mpb_noSurface(u,1))<=1e-10 & abs(data2.p(2,:)-mpb_noSurface(u,2))<=1e-10 & abs(data2.p(3,:)-mpb_noSurface(u,3))<=1e-10);
% %                     catch double_point_error
% %                         count = count+1;
% %                         double_q = q_data(abs(data2.p(1,:)-mpb_noSurface(u,1))<=1e-10 & abs(data2.p(2,:)-mpb_noSurface(u,2))<=1e-10 & abs(data2.p(3,:)-mpb_noSurface(u,3))<=1e-10);
% %                         q_this_time(u) = mean(double_q);
% %                     end
% %                 end
% %                 q_list(j) = mean(q_this_time);
% %
% %                 %% FIND GRADIENT AND VELOCITY AT SOLIDIFICATION FRONT
% %                 mpb_XZplane = melt_pool_bound(abs(melt_pool_bound(:,2)-c(2))<1e-8,:); %Keep only the points on the midplane of the simulation
% % %                     G_this_time = zeros(size(mpb_midplane,1),1); % set vector for gradient points
% % %                     V_this_time = zeros(size(mpb_midplane,1),1); % set vector for velocity points
% %                 Tx = data2.d2(j,:);
% %                 Tx_this_time = zeros(size(mpb_XZplane,1),1); % set vector for Temperature gradient in x-direction
% %                 Tz = data2.d3(j,:);
% %                 Tz_this_time = zeros(size(mpb_XZplane,1),1); % set vector for Temperature gradient in z-direction
% %
% %                 %%%%START FROM HERE TO CALCULATE VELOCITY AND GRADIENT
% %                 %%%%AT SOLIDIFICATION FRONT FOR EACH TIME STEP
% %                 count = 0;
% %                 for u = 1:size(mpb_XZplane,1) %This for-loop captures the gradient information at each point in the boundary
% %                     try %first try to extract Tx at a point "u" along the boundary
% %                         Tx_this_time(u) = Tx(abs(data2.p(1,:)-mpb_XZplane(u,1))<=1e-10 & abs(data2.p(2,:)-mpb_XZplane(u,2))<=1e-10 & abs(data2.p(3,:)-mpb_XZplane(u,3))<=1e-10);
% %                         Tz_this_time(u) = Tz(abs(data2.p(1,:)-mpb_XZplane(u,1))<=1e-10 & abs(data2.p(2,:)-mpb_XZplane(u,2))<=1e-10 & abs(data2.p(3,:)-mpb_XZplane(u,3))<=1e-10);
% %                     catch double_point_error % this catch is used when there are multiple points in the same location
% %                         count = count+1;
% %                         multi_Tx = Tx(abs(data2.p(1,:)-mpb_XZplane(u,1))<=1e-10 & abs(data2.p(2,:)-mpb_XZplane(u,2))<=1e-10 & abs(data2.p(3,:)-mpb_XZplane(u,3))<=1e-10);
% %                         multi_Tz = Tz(abs(data2.p(1,:)-mpb_XZplane(u,1))<=1e-10 & abs(data2.p(2,:)-mpb_XZplane(u,2))<=1e-10 & abs(data2.p(3,:)-mpb_XZplane(u,3))<=1e-10);
% %                         Tx_this_time(u) = mean(multi_Tx); %average values of all Tx values at a point are stored
% %                         Tz_this_time(u) = mean(multi_Tz); %average values of all Tz values at a point are stored
% %                     end
% %                 end
% %
% %                 V_this_time = speed*cos(atan2(Tz_this_time,Tx_this_time));
% %
% %                 mpb_solidification = mpb_XZplane(V_this_time>0,:);
% %                 cd(cd_back)
% %                 [mpb_pareto,~] = prtp(mpb_solidification);
% %                 cd(model_directory)
% %                 Tz_bound = zeros(size(mpb_pareto,1),1); % set vector for Temperature gradient in z-direction
% %                 Tx_bound = zeros(size(mpb_pareto,1),1); % set vector for Temperature gradient in z-direction
% %                 for w = 1:size(mpb_pareto,1)
% %                     Tx_bound(w) = mean(Tx_this_time(abs(mpb_XZplane(:,1)-mpb_pareto(w,1))<=1e-10 & abs(mpb_XZplane(:,2)-mpb_pareto(w,2))<=1e-10 & abs(mpb_XZplane(:,3)-mpb_pareto(w,3))<=1e-10));
% %                     Tz_bound(w) = mean(Tz_this_time(abs(mpb_XZplane(:,1)-mpb_pareto(w,1))<=1e-10 & abs(mpb_XZplane(:,2)-mpb_pareto(w,2))<=1e-10 & abs(mpb_XZplane(:,3)-mpb_pareto(w,3))<=1e-10));
% %                 end
% %
% %
% % %                 if j/size(data2.d1,1)>=0.50 % only keep the last half of the simulation
% %                 s_front_V = [s_front_V;speed*cos(atan2(Tz_bound,Tx_bound))];
% %                 s_front_G = [s_front_G;sqrt(Tx_bound.^2+Tz_bound.^2)];
% %                 s_front_point = [s_front_point;mpb_pareto];
% % %                 end
% % 
%             else
%                 melt_pool_points
%                 j
            end
        end
        
%         subplot(1,2,1)
%         hold on
%         scatter(s_front_point(:,3),s_front_V)
%         title(['SPEED:',params{1},'[m/s]  POWER:',params{2},'[W]'])
%         subplot(1,2,2)
%         hold on
%         scatter(s_front_point(:,3),s_front_G)
%         title(['SPEED:',params{1},'[m/s]  POWER:',params{2},'[W]'])
        
        
        if all(V==0)
            results(i).length = len;
            results(i).width = wid;
            results(i).depth = dep;
            results(i).area = A;
            results(i).volume = V;
            results(i).q_list = q_list;
        else
            results(i).length = len(len~=0);
            results(i).width = wid(wid~=0);
            results(i).depth = dep(dep~=0);
            results(i).area = A(A~=0);
            results(i).volume = V(V~=0);
            results(i).q_list = q_list(q_list~=0);
        end
        results(i).n_points = n_points;
        results(i).speed = speed; %*1000;% conversion from [m/s] to [mm/s]
        results(i).power = power;
        results(i).beamD = beamD;
        results(i).l_avg = mean(results(i).length);
        results(i).l_std = std(results(i).length);
        results(i).w_avg = mean(results(i).width);
        results(i).w_std = std(results(i).width);
        results(i).d_avg = mean(results(i).depth);
        results(i).d_std = std(results(i).depth);
        results(i).q_avg = mean(results(i).q_list);
        results(i).T_max = T_max;
        results(i).boil_percent = boil_percent;
        results(i).sfront_V = s_front_V;
        results(i).sfront_G = s_front_G;
        results(i).sfront_p = s_front_point;
%         results(i).aspect = results(i).length./results(i).width;
%         results(i).aspect_avg = mean(results(i).aspect);
%         results(i).aspect_std = std(results(i).aspect);
       
        save(save_name,'results')
    end
end

diary off

ModelUtil.disconnect;
close
