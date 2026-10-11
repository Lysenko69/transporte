function [GS, track, latD, lonD, s, a12, t] = computeWT(lat1, lon1, lat2, lon2, windSpeed, windDir)
ms2kts = 1.944;
TAS = 450;% kt

% Distancia (m) y derrota deseada; el heading es igual a la derrota deseada
[s, a12, ~] = loxo_distazi(lat1, lon1, lat2, lon2);
heading = mod(a12, 360);

% GS = TAS + viento (componentes norte y este)
Vn = TAS*cosd(heading) - windSpeed*cosd(windDir);
Ve = TAS*sind(heading) - windSpeed*sind(windDir);

GS    = sqrt(Vn^2+Ve^2);                    % kt
track = mod(atan2d(Ve, Vn), 360);           % derrota efectiva

% Se vuela el tiempo s/TAS;
t = s / (TAS/ms2kts);
Dground = (GS/ms2kts) * t;                           % m
[latD, lonD, ~] = loxo_reckon(lat1, lon1, Dground, track);
end