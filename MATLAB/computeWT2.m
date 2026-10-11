function [GS, track, latD, lonD, s, a12, t] = computeWT2(lat1, lon1, lat2, lon2, windSpeed, windDir)
    %Heading
    ms2kts = 1.944;
    [s, a12, ~] = loxo_distazi(lat1,lon1, lat2, lon2);
    heading =  mod(a12, 360);  
    %Vector TAS
    TAS_value = 450;
    TAS = TAS_value  * [sind(heading),cosd(heading)]; 
    %Vector Wind
    windVector = windSpeed * [sind(windDir+180), cosd(windDir + 180)];
    %Vector GS
    groundVector = TAS + windVector;
    %Module GS
    GS = hypot(groundVector(1), groundVector(2));
    %Angle GS o Track
    track = mod(rad2deg(atan2(groundVector(1), groundVector(2))), 360);
    %Distance
    s_ground = s * GS / TAS_value;
    t = s / (TAS_value/ms2kts);
    %Destination Points
    [latD,lonD,~] = loxo_reckon(lat1,lon1,s_ground,track);
end