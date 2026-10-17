function [GS, track, latD, lonD, s, a12, t] = computeWT2(lat1, lon1, lat2, lon2, windSpeed, windDir)
% Resuelve el triángulo de velocidades de un tramo volado a rumbo constante
% (rumbo = derrota deseada) con TAS = 450 kt. Devuelve la GS y la derrota
% efectivas, la posición realmente alcanzada y el tiempo del tramo.
% Entrada:
%   lat1, lon1 = punto inicial [deg]
%   lat2, lon2 = destino deseado [deg]
%   windSpeed  = velocidad del viento en el tramo [kt]
%   windDir    = dirección de procedencia del viento [deg]
% Salida:
%   GS         = velocidad sobre el terreno [kt]
%   track      = derrota efectiva [deg]
%   latD, lonD = coordenadas del destino efectivo [deg]
%   s          = distancia loxodrómica al destino deseado [m]
%   a12        = azimut loxodrómico inicial al destino deseado [deg]
%   t          = tiempo del tramo [s]

    ms2kts = 1.944;                                   % factor m/s -> kt

    % Rumbo = derrota deseada (loxodrómica)
    [s, a12, ~] = loxo_distazi(lat1, lon1, lat2, lon2);
    heading = mod(a12, 360);

    % Vector TAS [este, norte]
    TAS_value = 450;                                  % kt
    TAS = TAS_value * [sind(heading), cosd(heading)];

    % Vector viento (+180°: "desde" -> "hacia")
    windVector = windSpeed * [sind(windDir+180), cosd(windDir+180)];

    % Vector GS = TAS + viento; módulo y ángulo (derrota)
    groundVector = TAS + windVector;
    GS    = hypot(groundVector(1), groundVector(2));
    track = mod(rad2deg(atan2(groundVector(1), groundVector(2))), 360);

    % Distancia sobre el terreno recorrida y tiempo del tramo
    s_ground = s * GS / TAS_value;
    t = s / (TAS_value / ms2kts);                     % [s]

    % Destino efectivo
    [latD, lonD, ~] = loxo_reckon(lat1, lon1, s_ground, track);
end