%Wind triangle
clc; clear all;
%Data
wind_dir=0; %deg (TO)
wind_spd=15; %kt
tas=100; %kt
DesiredCourse=120; %deg
wta= DesiredCourse - wind_dir;

%Wind correction angle
wca=asind(wind_spd*sind(wta)/tas); %deg

%Heading angle
heading=DesiredCourse+wca; %deg

%Tail wind
tail_wind=wind_spd*cosd(wta); %knot

%Ground-speed
gs=tas*cosd(wca)+tail_wind; %knot


%% Check results: compute wind vector from TAS and GS
% Tas vector
tas_vec=tas*[cosd(heading);sind(heading)];
% GS vector
gs_vec=gs*[cosd(DesiredCourse);sind(DesiredCourse)];
% Wind vector
wind_vec=gs_vec-tas_vec;
% Wind speed
wind_spd=norm(wind_vec) %knot
% Wind direction
wind_dir=mod(atan2d(wind_vec(2),wind_vec(1)), 360) %deg