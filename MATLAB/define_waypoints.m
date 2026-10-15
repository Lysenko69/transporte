% DEFINE_WAYPOINTS  Define a mano los fijos de la fase en-ruta (crucero).
% Rellena la matriz de structs wp con nombre, coordenadas, limites de nivel
% de vuelo y calcula derrota y distancia de cada tramo con la libreria GEO.
% Los valores de derrota y distancia de la tabla se usan solo para comprobar.
%
% Criterio: cada fijo guarda la derrota (track) y la distancia (dist) del
% tramo que SALE de el hacia el siguiente fijo. El ultimo fijo tiene 0.
% Total_dist es la distancia acumulada desde el primer fijo hasta cada fijo.

clear; clc;
addpath('./matlab_utilities/kgbx-lib/kml','./matlab_utilities/kgbx-lib/geo','./matlab_utilities');
NM2m = 1852;   % metros por milla nautica

% ---------------------------------------------------------------------
% Tabla de fijos: nombre | lat [g m s] | lon [g m s] |
%                 FL minimo | FL maximo | derrota tabla | dist tabla (NM)
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
% Creacion de los fijos (se crean los N, incluido POSBA, para poder
% calcular el ultimo tramo; POSBA se elimina antes de las salidas)
% ---------------------------------------------------------------------
for i = 1:N                         % primero se crean todos con los mismos campos
    wp(i) = create_wp();
end

for i = 1:N                         % despues se rellenan (y se anaden campos extra)
    wp(i).name    = D{i,1};
    wp(i).lat     = sex2dec(D{i,2});
    wp(i).lon     = sex2dec(D{i,3});
    wp(i).alt_min = D{i,4} * 100;     % ft
    wp(i).alt_max = D{i,5} * 100;     % ft
    wp(i).desc    = sprintf('Crucero wp #%d', i);
end

% ---------------------------------------------------------------------
% Prevision de viento en cada fijo (plan LIDO de SimBrief, FL390)
% ---------------------------------------------------------------------
wdir = [265 262 268 261 260 267 268 269 273 279 278 290 293 293 297 297 312 312 312 345   5   4  12  12  19  19   5];
wspd = [61 66  84  72  70  67  65  61  53  54  54  60  61  61  52  52  44  44  44  44  50  49  50  49  52  52  56];
for i = 1:N-1
    wp(i).wdir = wdir(i);   % direccion DESDE la que sopla (grados)
    wp(i).wind = wspd(i);   % velocidad (kt)
end

% ---------------------------------------------------------------------
% Derrota y distancia de cada tramo Loxodrómica de rumbo constante
% ---------------------------------------------------------------------
wp(1).Total_dist = 0;
for i = 1:N-1
    [s, a12, ~] = loxo_distazi(wp(i).lat, wp(i).lon, wp(i+1).lat, wp(i+1).lon);
    wp(i).track        = mod(a12, 360);                              % derrota inicial del tramo (grados)
    wp(i).dist         = s / NM2m;                         % distancia del tramo (NM)
    wp(i+1).Total_dist = wp(i).Total_dist + wp(i).dist;    % acumulada hasta wp(i+1)
end

% ---------------------------------------------------------------------
% Generación de nuevo wp_v, resolviendo triángulo de velocidades.
% ---------------------------------------------------------------------

for i = 1:N
    wp_v(i) = create_wp();
end

for i = 1:N-1                     
    wp_v(i).name    = D{i,1};
end

wp_v(1).Total_dist = 0;
wp_v(1).lat = wp(1).lat;
wp_v(1).lon = wp(1).lon;

for i = 1:N-1                     
    [GS, track, latD, lonD, s, a12, t] = computeWT(wp_v(i).lat, wp_v(i).lon, wp(i+1).lat, wp(i+1).lon, wp(i).wind, wp(i).wdir);
    wp_v(i+1).lat = latD;
    wp_v(i+1).lon = lonD;
    wp_v(i).track = track;
    wp_v(i).gs = GS;
    
    wp_v(i).dist = s / NM2m;
    wp_v(i+1).Total_dist = wp_v(i).Total_dist + wp_v(i).dist;    % acumulada hasta wp(i+1)
    wp_v(i+1).time = wp_v(i).time + t;

    wp_v(i).alt_min = wp(i).alt_min;
    wp_v(i).alt_max = wp(i).alt_max;
    
end

% ---------------------------------------------------------------------
% Se elimina POSBA (solo era el destino del ultimo tramo) -> 26 fijos
% ---------------------------------------------------------------------
wp(N)   = [];
wp_v(N) = [];

% ---------------------------------------------------------------------
% Salidas
% ---------------------------------------------------------------------
attr1 = default_attr('ff0000ff', 3, 'Ruta sin viento');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp, 'EGCC-LEPA-sinviento.kml', attr1);
myxlswrite_ENR('EGCC-LEPA-sinviento', wp);

attr2 = default_attr('ffff0000', 3, 'Ruta con viento');   % rojo opaco (aabbggrr), grosor 3
kmlwrite_polyline(wp_v, 'EGCC-LEPA-viento.kml', attr2);
myxlswrite_ENR('EGCC-LEPA-viento', wp_v);