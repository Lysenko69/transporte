function h = maxCruiseAlt(RouteDistanceNM,hmaxFT)
% Heurístico para calcular la altitud de crucero en rutas cortas
% Garantiza 20 NM de crucero con una angulo de ascenso (y descenso) (AOC) medio del 5.5%
%
% Vx: the speed of an aircraft type at which the angle of climb is largest. 
%      It is always slower than...
% Vy: the speed for the best rate of climb.
%
% Vx increases with altitude, and 
% Vy decreases with altitude until they converge at the airplane's absolute ceiling.
%
% Best angle of climb (BAOC) airspeed for an airplane is the speed 
% at which the maximum excess thrust is available.
% Excess thrust is the difference between the total drag of the aircraft, 
% and the thrust output of the powerplant. 
% For a jet aircraft, this speed is very close to the speed at which the total minimum drag occurs.

FT2NM=1/6076.12;
CruiseLenMin=20; % NM
AOCav=3.15;      % Pendiente media de ascenso y descenso: 3.15º / 5.5%

h = min( ((RouteDistanceNM/2-CruiseLenMin/2)*tand(AOCav)/FT2NM), hmaxFT) ;

end