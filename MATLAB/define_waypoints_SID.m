%% SID EGCC - SANBA1R
clear; clc;
addpath('./matlab_utilities/kgbx-lib/kml','./matlab_utilities/kgbx-lib/geo','./matlab_utilities');
NM2m = 1852;   % metros por milla nautica

%% 1. VOR de referencia
MCT = wp_fijo('MCT', 'N053°21''25.00"', 'W002°15''44.00"');
HON = wp_fijo('HON', 'N052°21''24.00"', 'W001°39''49.00"');

%% 2. Waypoints en orden de ruta
% Pista y salida hacia el arco
wp_sid(1) = wp_fijo('EGCC', 'N053°20''26.53"', 'W002°18''06.96"');   % Final pista 23R
wp_sid(2) = wp_polar('MCT D3', MCT, 3, 233.09);                      % Rumbo de pista
wp_sid(3) = wp_polar('Aux1',   MCT, 3.83, 180+58);                   % Auxiliar entre D3 y D5
wp_sid(4) = wp_polar('MCT D5', MCT, 5, 248.9);

% Viraje: cada auxiliar se mide desde el punto anterior
wp_sid(5) = wp_polar('Aux2', wp_sid(4), 1.32, 83+180);
wp_sid(6) = wp_polar('Aux3', wp_sid(5), 0.82, 58+180);
wp_sid(7) = wp_polar('Aux4', wp_sid(6), 0.69, 35+180);
wp_sid(8) = wp_polar('Aux5', wp_sid(7), 0.66, 15+180);
wp_sid(9) = wp_polar('Aux6', wp_sid(8), 0.37, 177);

% Fijos finales de la SID
wp_sid(10) = wp_fijo('TABLY', 'N053°16''19.00"', 'W002°27''02.00"');
wp_sid(11) = wp_polar('HON D58', wp_sid(10), 9, 152);
wp_sid(12) = wp_fijo('SANBA', 'N053°08''22.00"', 'W002°20''03.00"');

N = numel(wp_sid);

%% 3. Derrotas y distancias
wp_sid(1).Total_dist = 0;
for i = 2:N
    [s, rumbo, ~] = loxo_distazi(wp_sid(i-1).lat, wp_sid(i-1).lon, ...
                                 wp_sid(i).lat,   wp_sid(i).lon);
    wp_sid(i).track      = mod(rumbo, 360);               % rumbo del tramo
    wp_sid(i).dist       = s;                             % distancia del tramo [m]
    wp_sid(i).Total_dist = wp_sid(i-1).Total_dist + s;    % distancia acumulada [m]
end

%% 4. Restricciones de altitud y velocidad
k1 = find(strcmp({wp_sid.name}, 'HON D58'));   % posicion del fijo con 3000 ft
k2 = find(strcmp({wp_sid.name}, 'SANBA'));     % posicion del fijo con 5000 ft
pendiente = 3000 / wp_sid(k1).Total_dist;      % [ft/m] hasta HON D58

for k = 1:N
    if k < k1
        wp_sid(k).alt_min = pendiente * wp_sid(k).Total_dist;
    elseif k < k2
        wp_sid(k).alt_min = 3000;
    else
        wp_sid(k).alt_min = 5000;
    end
    wp_sid(k).alt_max = 5000;
    wp_sid(k).ias_min = 0;
    wp_sid(k).ias_max = 250;
end

%% 5. Salidas
attr1 = default_attr('ff0000ff', 3, 'SID');
kmlwrite_polyline(wp_sid, 'EGCC_SANBA1R.kml', attr1);
myxlswrite_SID('EGCC_SANBA1R', wp_sid);

%% 6. Perfil vertical de la SID
dist_NM = [wp_sid.Total_dist] / NM2m;
figure; hold on; grid on;
plot(dist_NM, [wp_sid.alt_min], '-o',  'LineWidth', 1.5, 'DisplayName', 'Altitud minima');
plot(dist_NM, [wp_sid.alt_max], '--o', 'LineWidth', 1.5, 'DisplayName', 'Altitud maxima');
for k = 1:N
    text(dist_NM(k), wp_sid(k).alt_min, ['  ' wp_sid(k).name], 'FontSize', 8);
end
xlabel('Distancia [NM]'); ylabel('Altitud [ft]');
title('Perfil vertical de la SID'); legend('Location', 'best');


%% ===================== FUNCIONES =====================

function wp = wp_fijo(nombre, lat_str, lon_str)
% Funcion: wp_fijo(nombre, lat_str, lon_str)
% Parametros de entrada:
%   nombre  = string, nombre del fijo
%   lat_str = string, latitud sexagesimal  ('N053°21''25.00"')
%   lon_str = string, longitud sexagesimal ('W002°15''44.00"')
% Parametros de salida:
%   wp = struct con name, lat, lon (grados decimales)
    wp = create_wp();
    wp.name = nombre;
    wp.lat  = sex2dec(lat_str);
    wp.lon  = sex2dec(lon_str);
end

function wp = wp_polar(nombre, ref, dist_NM, rumbo)
% Funcion: wp_polar(nombre, ref, dist_NM, rumbo)
% Parametros de entrada:
%   nombre  = string, nombre del fijo
%   ref     = struct con lat y lon del punto de referencia
%   dist_NM = double, distancia desde la referencia [NM]
%   rumbo   = double, rumbo desde la referencia [grados]
% Parametros de salida:
%   wp = struct con name, lat, lon (grados decimales)
    wp = create_wp();
    wp.name = nombre;
    [wp.lat, wp.lon] = loxo_reckon(ref.lat, ref.lon, dist_NM*1852, rumbo);
end