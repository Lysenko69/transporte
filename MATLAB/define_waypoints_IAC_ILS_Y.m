clear; clc;
addpath('./matlab_utilities/kgbx-lib/kml','./matlab_utilities/kgbx-lib/geo','./matlab_utilities');
NM2m = 1852;   % metros por milla nautica

% Coordenadas JOA en grados decimales
lat0 = 39 + 33/60 + 53/3600;
lon0 = 2 + 44/60 + 48/3600;

wp_iac(1)=create_wp();
wp_iac(1).name='ANDRAITX';
% Coordenadas ANDRAITX en grados decimales
wp_iac(1).lat = 39 + 32/60 + 58/3600;
wp_iac(1).lon = 2 + 23/60 + 45/3600;
wp_iac(2)=create_wp();
wp_iac(2).name='Aux1'; %R-257, 14.93 DME JOA
[wp_iac(2).lat, wp_iac(2).lon]=loxo_reckon(lat0, lon0, 14.93*NM2m, 270 - 12.8);
wp_iac(3)=create_wp();
wp_iac(3).name='Aux2'; %R-246, 14.03 DME JOA
[wp_iac(3).lat, wp_iac(3).lon]=loxo_reckon(lat0, lon0, 14.03*NM2m, 270 - 23.9);
wp_iac(4)=create_wp();
wp_iac(4).name='Aux3'; %R-243, 13.7 DME JOA
[wp_iac(4).lat, wp_iac(4).lon]=loxo_reckon(lat0, lon0, 13.7*NM2m, 270 - 27.1);
wp_iac(5)=create_wp();
wp_iac(5).name='Aux4'; %R-240, 12.71 DME JOA
[wp_iac(5).lat, wp_iac(5).lon]=loxo_reckon(lat0, lon0, 12.71*NM2m, 270 - 30.5);
wp_iac(6)=create_wp();
wp_iac(6).name='Aux5'; %R-239, 11.0 DME JOA
[wp_iac(6).lat, wp_iac(6).lon]=loxo_reckon(lat0, lon0, 11*NM2m, 270 - 31);
wp_iac(7)=create_wp();
wp_iac(7).name='JOA';
wp_iac(7).lat= lat0; % Coordenadas VOR JOA
wp_iac(7).lon= lon0;

for i = 1:7
    wp_iac(i).alt_min = 0;
    wp_iac(i).alt_max = 0;
end

attr1 = default_attr('ff0000ff', 3, 'IAC_ILS_Y');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp_iac, 'IAC_ILS_Y_RWY_06L.kml', attr1);