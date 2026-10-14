clear; clc;
addpath('./kgbx-lib/kml','./kgbx-lib/geo','matlab_utilities');
NM2m = 1852;   % metros por milla nautica

long_VOR_JOA = 'N39°33''53"';
lat_VOR_JOA = 'E002°44''48"';
wp_iac(1)=create_wp();
wp_iac(1).name='ANDRAITX';
wp_iac(1).lat= sex2dec('N39°32''58"'); 
wp_iac(1).lon= sex2dec('E002°23''45"');
wp_iac(2)=create_wp();
wp_iac(2).name='Aux1'; %R-257, 14.93 DME JOA 
[wp_iac(2).lat, wp_iac(2).lon]=loxo_reckon(lat_VOR_JOA, lon_VOR_JOA, 14.93*NM2m, 270 - 12.8);
wp_iac(3)=create_wp();
wp_iac(3).name='Aux2'; %R-246, 14.03 DME JOA 
[wp_iac(3).lat, wp_iac(3).lon]=loxo_reckon(lat_VOR_JOA, lon_VOR_JOA, 14.03*NM2m, 270 - 23.9);
wp_iac(4)=create_wp();
wp_iac(4).name='Aux3'; %R-243, 13.7 DME JOA 
[wp_iac(4).lat, wp_iac(4).lon]=loxo_reckon(lat_VOR_JOA, lon_VOR_JOA, 13.7*NM2m, 270 - 27.1);
wp_iac(5)=create_wp();
wp_iac(5).name='Aux4'; %R-240, 12.71 DME JOA 
[wp_iac(5).lat, wp_iac(5).lon]=loxo_reckon(lat_VOR_JOA, lon_VOR_JOA, 12.71*NM2m, 270 - 30.5);
wp_iac(6)=create_wp();
wp_iac(6).name='Aux5'; %R-239, 11.0 DME JOA
[wp_iac(6).lat, wp_iac(6).lon]=loxo_reckon(lat_VOR_JOA, lon_VOR_JOA, 11*NM2m, 270 -31);
wp_iac(7)=create_wp();
wp_iac(7).name='JOA';
wp_iac(7).lat= sex2dec(lat_VOR_JOA); % Coordenadas VOR JOA
wp_iac(7).lon= sex2dec(long_VOR_JOA);

attr1 = default_attr('ff0000ff', 3, 'IAC_ILS_Y');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp_iac, 'IAC_ILS_Y_RWY_06L.kml', attr1);