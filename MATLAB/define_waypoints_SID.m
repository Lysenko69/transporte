clear; clc;
addpath('./kgbx-lib/kml','./kgbx-lib/geo','matlab_utilities');
NM2m = 1852;   % metros por milla nautica

wp_sid(1)=create_wp();
wp_sid(1).name='EGCC';
wp_sid(1).lat= sex2dec('N053°21''25.00"'); % Coordenadas MCT
wp_sid(1).lon= sex2dec('W002°15''44.00"');

wp_sid(2)=create_wp();
wp_sid(2).name='MCT D3'; %Rumbo de pista, MCT D3
[wp_sid(2).lat, wp_sid(2).lon]=loxo_reckon(wp_sid(1).lat, wp_sid(1).lon, 3*NM2m, 233.09);

wp_sid(3)=create_wp();
wp_sid(3).name='MCT D5'; % Primer punto auxiliar, R248.9, MCT D5
[wp_sid(3).lat, wp_sid(3).lon]=loxo_reckon(wp_sid(1).lat, wp_sid(1).lon, 5*NM2m, 248.9);
wp_sid(4)=create_wp();
wp_sid(4).name='Aux1';
[wp_sid(4).lat, wp_sid(4).lon]=loxo_reckon(wp_sid(3).lat, wp_sid(3).lon, 1.32*NM2m, 83 + 180);
wp_sid(5)=create_wp();
wp_sid(5).name='Aux2';
[wp_sid(5).lat, wp_sid(5).lon]=loxo_reckon(wp_sid(4).lat, wp_sid(4).lon, 0.82*NM2m, 58 + 180);
wp_sid(6)=create_wp();
wp_sid(6).name='Aux3';
[wp_sid(6).lat, wp_sid(6).lon]=loxo_reckon(wp_sid(5).lat, wp_sid(5).lon, 0.69*NM2m, 35 + 180);
wp_sid(7)=create_wp();
wp_sid(7).name='Aux4';
[wp_sid(7).lat, wp_sid(7).lon]=loxo_reckon(wp_sid(6).lat, wp_sid(6).lon, 0.66*NM2m, 15 + 180);
wp_sid(8)=create_wp();
wp_sid(8).name='Aux5';
[wp_sid(8).lat, wp_sid(8).lon]=loxo_reckon(wp_sid(7).lat, wp_sid(7).lon, 0.37*NM2m, 177);
wp_sid(9)=create_wp();
wp_sid(9).name='TABLY';
wp_sid(9).lat= sex2dec('N053°16''19.00"'); % Coordenadas TABLY
wp_sid(9).lon= sex2dec('W002°27''02.00"');
wp_sid(10)=create_wp();
wp_sid(10).name='HON D58';
[wp_sid(10).lat, wp_sid(10).lon]=loxo_reckon(sex2dec('N052°21''24.00"'),sex2dec('W001°39''49.00"'), 58*NM2m, 152 + 180);
wp_sid(11)=create_wp();
wp_sid(11).name='SANBA';
wp_sid(11).lat= sex2dec('N053°08''22.00"'); % Coordenadas SANBA
wp_sid(11).lon= sex2dec('W002°20''03.00"');

for i = 1:11
    wp_sid(i).alt_min = 0;
    wp_sid(i).alt_max = 0;
end

attr1 = default_attr('ff0000ff', 3, 'SID');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp_sid, 'EGCC_SANBA1R.kml', attr1);
%myxlswrite_ENR('EGCC_SANBA1R', wp_sid);