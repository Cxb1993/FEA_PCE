function [melt_av,haz_av] = find_length(workfolder)

XYT = csvread([workfolder,'/surface_data.csv'],9,0); %read file starting from 9 row below (to skip the title rows)
Nx=XYT(:,1);
Ny=XYT(:,2);
b = size(XYT,2);
Nt=b-3; %Nt=b-3; %find total time steps % subtract first "3" columns (x,y,t=0)
Temp=XYT(:,4:b);  % Start from t=0.001 s (Column 4)

Tm=1923.0;  %Kelvin %melting temperature
Th=1255.0;  %Kelvin %haz temperature

%Calculate change in "melt pool length" with time (starting from 0.001 s)
minixm = zeros(Nt,1);
maxixm = zeros(Nt,1);
melt_length = zeros(Nt,1);
for i=1:Nt
    [Am]=find(abs(Temp(:,i)-Tm)<=3);
    
    x_posm=Nx(Am);
    y_posm=Ny(Am);
    [Bm]=find(abs(y_posm(:)-0.0)<=1e-4);  %9e-6 --> this is not good. gives
        %wrong results at some points. note that using 1e-4 does not make it less
        %precise since we always look for the min and max values of all candidates in B1.
    minixm(i)=min(x_posm(Bm));
    maxixm(i)=max(x_posm(Bm));
    melt_length(i)=(maxixm(i)-minixm(i));
end
melt_av = mean(melt_length);

%Calculate change in "haz length" with time (starting from 0.001 s)
minixh = zeros(Nt,1);
maxixh = zeros(Nt,1);
haz_length = zeros(Nt,1);
for i=1:Nt
    [Ah]=find(abs(Temp(:,i)-Th)<=3);
    x_posh=Nx(Ah);
    y_posh=Ny(Ah);
    [Bh]=find(abs(y_posh(:)-0.0)<=1e-4); %9e-6 ---> does not satisfy some points !
    minixh(i)=min(x_posh(Bh));
    maxixh(i)=max(x_posh(Bh));
    haz_length(i)=(maxixh(i)-minixh(i));
end
haz_av = mean(haz_length);

%write to file
dlmwrite([workfolder,'/melt_length.csv'],melt_length,'precision','%10.3e')
dlmwrite([workfolder,'/haz_length.csv'],haz_length,'precision','%10.3e')
