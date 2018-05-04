function [melt_av,haz_av] = find_depth(workfolder)

XZT = csvread([workfolder,'/depth_data.csv'],9,0); %read file starting from 9 row below (to skip the title rows)
Nz = XZT(:,2);
b = size(XZT,2);

Nt = b-3; %find total time steps % subtract first "3" columns (x,y,t=0)
Temp = XZT(:,4:b);  % Start from t=0.001 s (Column 4)

Tm = 1923.0; %Kelvin %melting temperature
Th = 1255.0; %Kelvin %haz temperature


%Calculate change in "melt pool depth" with time (starting from 0.001 s)
melt_depth = zeros(Nt,1);
for i=1:Nt
    [Am] = find(abs(Temp(:,i)-Tm)<=3);
    z_posm = Nz(Am);
    melt_depth(i) = -min(z_posm(:));   % Notice the minus sign !
end
melt_av = mean(melt_depth);

%Calculate change in "haz depth" with time (starting from 0.001 s)
haz_depth= zeros(Nt,1);
for i=1:Nt
    [Ah]=find(abs(Temp(:,i)-Th)<=3);
    z_posh=Nz(Ah);
    haz_depth(i) = -min(z_posh(:));    % Notice the minus sign !
end
haz_av = mean(haz_depth);

%write to file
dlmwrite([workfolder,'/melt_depth.csv'],melt_depth,'precision','%10.3e')
dlmwrite([workfolder,'/haz_depth.csv'],haz_depth,'precision','%10.3e')
