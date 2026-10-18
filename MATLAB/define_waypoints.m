% define_waypoints.m  Fase de crucero EGCC-LEPA (de SANBA a POSBA)
% Calcula la ruta por aerovías sin viento y con viento (triángulo de
% velocidades, TAS = 450 kt) y compara los tiempos de vuelo.
% Entrada (definida en el propio script):
%   D          = tabla de fijos: nombre, lat/lon (sexagesimal), FL mín/máx
%   wdir, wspd = previsión de viento en cada fijo (plan LIDO, FL390)
% Salida:
%   EGCC-LEPA-sinviento.kml / .xlsx = ruta y tabla sin viento
%   EGCC-LEPA-viento.kml / .xlsx    = ruta y tabla con viento
%   Tiempos totales de ambos casos por pantalla [min]
% Funciones usadas: create_wp, computeWT, loxo_distazi, sex2dec,
%                   kmlwrite_polyline, myxlswrite_ENR

clear; clc;
addpath('kgbx-lib/kml','kgbx-lib/geo','matlab_utilities');

NM2m = 1852;      % metros por milla náutica
ms2kts = 1.944;   % factor m/s -> kt
V_crucero = 450;  % TAS de crucero [kt]

% ---------------------------------------------------------------------
% Tabla de fijos: nombre | lat [g m s] | lon [g m s] |
%                 FL mínimo | FL máximo | derrota tabla | dist tabla (NM)
% ---------------------------------------------------------------------
D = {
 'SANBA', 'N053°08''22.00"', 'W002°20''03.00"', 245,460,152,8.9;
 'UTXA',  'N053º00''30.45"', 'W002º13''12.52"', 245,460,152,44.1;
 'HON',   'N052º21''24.04"', 'W001º39''49.41"', 245,460,161,36.9;
 'KIDLI', 'N051º46''17.00"', 'W001º21''40.87"', 245,460,162, 7.6;
 'DIGUT', 'N051º39''01.29"', 'W001º17''59.47"', 245,460,162,10.0;
 'CPT',   'N051º29''29.66"', 'W001º13''10.89"', 245,460,154, 6.3;
 'ALHAD', 'N051º23''46.75"', 'W001º08''58.16"', 245,460,154, 9.4;
 'VAPID', 'N051º15''13.97"', 'W001º02''42.40"', 245,460,154,26.3;
 'GWC',   'N050º51''18.79"', 'W000º45''24.25"', 245,460,154,53.8;
 'SITET', 'N050º06''00.00"', 'W000º00''00.00"', 195,500,165,25.8;
 'ETRAT', 'N049º41''00.00"', 'E000º09''48.00"', 195,500,164,23.1;
 'DVL',   'N049º18''38.70"', 'E000º18''45.80"', 195,500,163,32.4;
 'LGL',   'N048º47''26.20"', 'E000º31''49.00"', 195,500,164,16.6;
 'SORAP', 'N048º31''20.00"', 'E000º38''07.00"', 195,500,164,16.7;
 'BENAR', 'N048º15''11.00"', 'E000º44''40.00"', 195,500,164,25.8;
 'VANAD', 'N047º50''14.00"', 'E000º54''26.00"', 195,500,164,25.3;
 'AMB',   'N047º25''44.10"', 'E001º03''52.00"', 195,500,179,24.2;
 'SOPIL', 'N047º01''33.00"', 'E001º03''18.00"', 195,500,180,30.6;
 'BALAN', 'N046º30''58.00"', 'E001º02''00.00"', 195,660,165,64.2;
 'EVPOK', 'N045º28''27.00"', 'E001º22''34.50"', 195,660,166,72.5;
 'NARAK', 'N044º17''43.00"', 'E001º44''56.00"', 195,660,169,20.7;
 'GAI',   'N043º57''14.60"', 'E001º49''27.00"', 195,660,174,36.7;
 'LOMRA', 'N043º20''39.00"', 'E001º52''59.00"', 195,660,174,40.4;
 'ROCAN', 'N042º40''24.00"', 'E001º56''48.00"', 195,660,163,19.4;
 'IBRAP', 'N042º21''41.70"', 'E002º03''30.70"', 195,660,163,36.9;
 'LUKEV', 'N041º45''58.00"', 'E002º16''07.00"', 195,660,163,78.4;
 'LORES', 'N040º30''00.00"', 'E002º42''09.00"', 195,660,150,19.0;
 'POSBA', 'N040º13''11.00"', 'E002º54''19.00"', 070, 0, 150,12.0;
};

N = size(D,1);
Nw = N - 1;

% ---------------------------------------------------------------------
% Creación de los fijos (se crean los N, incluido POSBA, para poder
% calcular el último tramo; POSBA se elimina antes de las salidas)
% ---------------------------------------------------------------------
for i = 1:N                         % primero se crean todos con los mismos campos
    wp(i) = create_wp();
end

for i = 1:N                         % después se rellenan (y se añaden campos extra)
    wp(i).name    = D{i,1};
    wp(i).lat     = sex2dec(D{i,2});
    wp(i).lon     = sex2dec(D{i,3});
    wp(i).alt_min = D{i,4} * 100;     % ft
    wp(i).alt_max = D{i,5} * 100;     % ft
    wp(i).desc    = sprintf('Crucero wp #%d', i);
end

% ---------------------------------------------------------------------
% Caso sin viento: derrota, distancia y tiempo de cada tramo
% (loxodrómica de rumbo constante)
% ---------------------------------------------------------------------
wp(1).Total_dist = 0; wp(1).time = 0;
for i = 1:N-1
    [s, a12, ~] = loxo_distazi(wp(i).lat, wp(i).lon, wp(i+1).lat, wp(i+1).lon);
    wp(i).track        = mod(a12, 360);                    % derrota inicial del tramo [deg]
    wp(i).dist         = s ;                               % distancia del tramo [m]
    wp(i+1).time = wp(i).time + (wp(i).dist / (V_crucero/ms2kts));   % [s]  % [s]
    wp(i+1).Total_dist = wp(i).Total_dist + wp(i).dist;    % acumulada hasta wp(i+1) [NM]
    wp(i).wind = 0;
    wp(i).wdir = 0;
    wp(i).gs = V_crucero;
end

% ---------------------------------------------------------------------
% Caso con viento: nueva ruta wp_v resolviendo el triángulo de velocidades.
% Cada tramo parte de la posición realmente alcanzada en el anterior.
% ---------------------------------------------------------------------

wdir = [265 262 268 261 260 267 268 269 273 279 278 290 293 293 297 297 312 312 312 345   5   4  12  12  19  19   5];
wspd = [61 66  84  72  70  67  65  61  53  54  54  60  61  61  52  52  44  44  44  44  50  49  50  49  52  52  56];

for i = 1:N
    wp_v(i) = create_wp();
end

for i = 1:N-1
    wp_v(i).name = D{i,1};
    wp_v(i).wdir = wdir(i);   % dirección DESDE la que sopla [deg]
    wp_v(i).wind = wspd(i);   % velocidad [kt]
end

wp_v(1).Total_dist = 0;
wp_v(1).lat = wp(1).lat;
wp_v(1).lon = wp(1).lon;

for i = 1:N-1
    [GS, track, latD, lonD, s, a12, t] = computeWT(wp_v(i).lat, wp_v(i).lon, wp(i+1).lat, wp(i+1).lon, wp_v(i).wind, wp_v(i).wdir);
    wp_v(i+1).lat = latD;                                  % posición real alcanzada
    wp_v(i+1).lon = lonD;
    wp_v(i).track = track;
    wp_v(i).gs = GS;

    wp_v(i).dist = s ;                                          % distancia del tramo [m]
    wp_v(i+1).Total_dist = wp_v(i).Total_dist + wp_v(i).dist;   % acumulada [NM]
    wp_v(i+1).time = wp_v(i).time + t;                          % acumulado [s]

    wp_v(i).alt_min = wp(i).alt_min;
    wp_v(i).alt_max = wp(i).alt_max;
end

% ---------------------------------------------------------------------
% Se elimina POSBA (solo era el destino del último tramo) -> 26 fijos
% ---------------------------------------------------------------------
wp(N)   = [];
wp_v(N) = [];


% ---------------------------------------------------------------------
% Diferencia entre los dos (con viento - sin viento) -> nuevo wp_d
% Se aprovecha la misma estructura que myxlswrite_ENR ya sabe escribir:
%   lat, lon   = diferencia de coordenadas [deg]
%   track      = diferencia de derrota [deg] (envuelta a +-180)
%   dist       = diferencia de distancia del tramo [m]
%   Total_dist = diferencia de distancia acumulada [m]
%   gs         = diferencia de velocidad sobre el terreno [kt]
%   time       = diferencia de tiempo acumulado [s]
%   wind, wdir = viento (se copia, no es una diferencia)
% Ademas se calcula la desviacion de la posicion real respecto al fijo [NM].
% ---------------------------------------------------------------------
M = numel(wp);                     % fijos tras eliminar POSBA (N-1)
 
for i = 1:M                        % primero se crean todos con los mismos campos
    wp_d(i) = create_wp();
end
 
desv = zeros(M,1);                 % desviacion respecto al fijo [NM]
for i = 1:M
    wp_d(i).name       = wp(i).name;
    wp_d(i).lat        = wp_v(i).lat - wp(i).lat;
    wp_d(i).lon        = wp_v(i).lon - wp(i).lon;
    wp_d(i).alt_min    = wp(i).alt_min;
    wp_d(i).alt_max    = wp(i).alt_max;
    wp_d(i).track      = mod(wp_v(i).track - wp(i).track + 180, 360) - 180;
    wp_d(i).dist       = wp_v(i).dist       - wp(i).dist;
    wp_d(i).Total_dist = wp_v(i).Total_dist - wp(i).Total_dist;
    wp_d(i).wind       = wp_v(i).wind;
    wp_d(i).wdir       = wp_v(i).wdir;
    wp_d(i).gs         = wp_v(i).gs   - wp(i).gs;
    wp_d(i).time       = wp_v(i).time - wp(i).time;
    wp_d(i).desc       = sprintf('Diferencia wp #%d', i);
 
    if i > 1                       % en el primer fijo ambas rutas coinciden
        [s_dev, ~, ~] = loxo_distazi(wp(i).lat, wp(i).lon, wp_v(i).lat, wp_v(i).lon);
        desv(i) = s_dev / NM2m;
    end
end

% ---------------------------------------------------------------------
% Salidas: KML (Google Earth), tablas Excel y tiempos totales
% ---------------------------------------------------------------------
attr1 = default_attr('ff0000ff', 3, 'Ruta sin viento');   % aabbggrr, grosor 3
kmlwrite_polyline(wp, 'EGCC-LEPA-sinviento.kml', attr1);
myxlswrite_ENR('EGCC-LEPA-sinviento', wp);

attr2 = default_attr('ffff0000', 3, 'Ruta con viento');   % aabbggrr, grosor 3
kmlwrite_polyline(wp_v, 'EGCC-LEPA-viento.kml', attr2);
myxlswrite_ENR('EGCC-LEPA-viento', wp_v);

fprintf('Tiempo sin viento [min]: %.2f\n', wp(end).time/60);
fprintf('Tiempo con viento [min]: %.2f\n', wp_v(end).time/60);

% Diferencias (con viento - sin viento): mismo formato de tabla que las demas
myxlswrite_ENR('EGCC-LEPA-diferencias', wp_d);