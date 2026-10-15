clear; clc;
addpath('./matlab_utilities/kgbx-lib/kml','./matlab_utilities/kgbx-lib/geo');
NM2m = 1852;   % metros por milla nautica

wp_star(1)=create_wp();
wp_star(1).name='LORES';
wp_star(1).lat= sex2dec('N040º30''00.00"'); 
wp_star(1).lon= sex2dec('E002º42''09.00"');
wp_star(2)=create_wp();
wp_star(2).name='POSBA'; 
wp_star(2).lat= sex2dec('N040º13''11.00"'); 
wp_star(2).lon= sex2dec('E002º54''19.00"' );
wp_star(3)=create_wp();
wp_star(3).name='NUDSA'; 
wp_star(3).lat= sex2dec('N040º02''53.00"'); 
wp_star(3).lon= sex2dec('E003º01''44.00"' );
wp_star(4)=create_wp();
wp_star(4).name='XOTNU';
wp_star(4).lat= sex2dec('N039º50''00.00"'); 
wp_star(4).lon= sex2dec('E002º56''01.00"' );
wp_star(5)=create_wp();
wp_star(5).name='TAKUS';
wp_star(5).lat= sex2dec('N039º46''28.00"'); 
wp_star(5).lon= sex2dec('E002º49''17.00"' );
wp_star(6)=create_wp();
wp_star(6).name='EVOLI';
wp_star(6).lat= sex2dec('N039º42''56.00"'); 
wp_star(6).lon= sex2dec('E002º42''35.00"' );
wp_star(7)=create_wp();
wp_star(7).name='ANDRAITX';
wp_star(7).lat= sex2dec('N039º32''58.00"'); 
wp_star(7).lon= sex2dec('E002º23''45.00"');

attr1 = default_attr('ff0000ff', 3, 'STAR_LORES4M');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp_star, 'STAR_LORES4M.kml', attr1);