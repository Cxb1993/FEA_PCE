function [melt_av,haz_av] = find_width(workfolder)

XYT = csvread([workfolder,'/surface_data.csv'],9,0); %read file starting from 9 row below (to skip the title rows)
Ny=XYT(:,2);
b=size(XYT,2);
Nt=b-3; %Nt=b-3; %find total time steps % subtract first "3" columns (x,y,t=0)
Temp=XYT(:,4:b);  % Start from t=0.001 s (Column 4)%Temp=XYT(:,4:b);

Tm=1923.0;  %Kelvin %melting temperature
Th=1255.0;  %Kelvin %haz temperature

%Calculate change in "melt pool width" with time (starting from 0.001 s)
melt_width = zeros(Nt,1);
for i=1:Nt
    [Am]=find(abs(Temp(:,i)-Tm)<=3);
    y_posm=Ny(Am);
    melt_width(i) = 2*max(y_posm(:));
end
melt_av = mean(melt_width);

%Calculate change in "haz width" with time (starting from 0.001 s)
haz_width = zeros(Nt,1);
for i=1:Nt
    [Ah]=find(abs(Temp(:,i)-Th)<=3);
    y_posh=Ny(Ah);
    haz_width(i) = 2*max(y_posh(:));
end
haz_av = mean(haz_width);

%write to file
dlmwrite([workfolder,'/melt_width.csv'],melt_width,'precision','%10.3e')
dlmwrite([workfolder,'/haz_width.csv'],haz_width,'precision','%10.3e')
