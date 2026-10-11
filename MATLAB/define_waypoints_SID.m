clear; clc;
addpath('./kgbx-lib/kml','./kgbx-lib/geo','matlab_utilities');
NM2m = 1852;   % metros por milla nautica

wp(1)=create_wp();
wp(1).name='EGCC';
wp(1).lat= sex2dec('N053°21''25.00"'); % Coordenadas MCT
wp(1).lon= sex2dec('W002°15''44.00"');
wp(2)=create_wp();
wp(2).name='3.0 MCT VLC'; %Rumbo de pista, MCT D3
[wp(2).lat, wp(2).lon]=orto_reckon(wp(1).lat, wp(1).lon, 3*NM2m, 231.09);
wp(3)=create_wp();
wp(3).name='Aux1-R285'; % Primer punto auxiliar, R248.9, MCT D5
[wp(3).lat, wp(3).lon]=orto_reckon(wp(1).lat, wp(1).lon, 5*NM2m, 248.9);
wp(4)=create_wp();
wp(4).name='Aux2';
[wp(4).lat, wp(4).lon]=orto_reckon(wp(3).lat, wp(3).lon, 1.32*NM2m, 83 + 180);
wp(5)=create_wp();
wp(5).name='Aux3';
[wp(5).lat, wp(5).lon]=orto_reckon(wp(4).lat, wp(4).lon, 0.82*NM2m, 58 + 180);
wp(6)=create_wp();
wp(6).name='Aux4';
[wp(6).lat, wp(6).lon]=orto_reckon(wp(5).lat, wp(5).lon, 0.69*NM2m, 35 + 180);
wp(7)=create_wp();
wp(7).name='Aux5';
[wp(7).lat, wp(7).lon]=orto_reckon(wp(6).lat, wp(6).lon, 0.66*NM2m, 15 + 180);
wp(8)=create_wp();
wp(8).name='Aux6';
[wp(8).lat, wp(8).lon]=orto_reckon(wp(7).lat, wp(7).lon, 0.37*NM2m, 177);
wp(9)=create_wp();
wp(9).name='TABLY';
wp(9).lat= sex2dec('N053°16''19.00"'); % Coordenadas TABLY
wp(9).lon= sex2dec('W002°27''02.00"');
wp(10)=create_wp();
wp(10).name='SANBA';
wp(10).lat= sex2dec('N053°08''22.00"'); % Coordenadas SANBA
wp(10).lon= sex2dec('W002°20''03.00"');

attr1 = default_attr('ff0000ff', 3, 'SID');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp, 'EGCC_SANBA1R.kml', attr1);
myxlswrite_ENR('EGCC_SANBA1R', wp);