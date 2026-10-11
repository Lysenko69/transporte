% Clean up workspace
clc; clear all;  clc;
%close all;
addpath('../kgbx-lib/bada');

run Constants
run Globals
%% AIRCRAFT DATA-----------------------------------------------------------
% Load the aircraft model for a B737-800
aircraft='B738';
%aircraft='A20N';
[ac] = LoadAircraftBADA(['../BADA_3.14/bada_314_96b6f733f5b65f32a5e7/',aircraft,'__.OPF']);

fprintf('%s ref. weight %.3f Tonnes \n', aircraft, ac.mass.m_ref*G_CONST/10^3);
fprintf("%s Vref=%g knots, ",aircraft, ac.aero.landing.Vstall*1.3+5);
fprintf('Vmo=%.1f knots / Mmo=%.2f \n', ac.envelope.Vmo, ac.envelope.Mmo);
fprintf('%s hmax=%.2f ft / hmo=%.2f ft \n', aircraft, ac.envelope.hmax, ac.envelope.hmo);
fprintf(['%s Max. Tr - Cruise: 95.0%% / Descent (above %g ft.): %1.2f%% ' ...
    '/ Descent (below %g ft.): %1.2f%% / Landing: %1.2f%% \n\n'],...
    aircraft, ac.enginethrust.h_des, 100*ac.enginethrust.Ctcdeshigh, ac.enginethrust.h_des, 100*ac.enginethrust.Ctcdeslow,100*ac.enginethrust.Ctcdesld);

% Get maximum operating speed & Mach
Vmo = ac.envelope.Vmo; % KCAS
Mmo = ac.envelope.Mmo;

%% COST INDEX--------------------------------------------------------------
% Fuel costs - cost of fuel per lb of fuel
% 25 nov 2025 in europe -> 0.587 $/kg
usd_per_kg = 0.587;

% Time costs - cost per flight minute (crew and maintenance) - $12/min
% or deduce it from fixing a given cost index
% usd_per_min = 12;

% CI = Time_costs ($/min) / fuel cost ($/kg)
% cost_index = usd_per_min / usd_per_kg;
% cost_index=12/.587;
cost_index=15;
usd_per_min = cost_index*usd_per_kg;
fprintf('COST INDEX=%g Kg/min, Fuel_cost=%g $/kg, Time_cost=%g $/min-------\n\n',cost_index, usd_per_kg,usd_per_min);

%% SET OPERATING CONDITIONS -----------------------------------------------
% Set cruising altitude
hcruise = ac.envelope.hmax;
%hcruise = 35000;


%% OPTIMIZATION------------------------------------------------------------
% Iterate for IAS in [0.5*Vmo .. Mmo]
i=1;
ratio(1)=0.5;
Vcas(1) =ratio*Vmo;
M(1)    =ratio*Mmo;

while (M(end)<Mmo && Vcas(end)<Vmo)
    % Integrate Main_00 -> CRUISE PTH SPD
    % We assume the aircraft follows course 360. Set wind relative to it.
    [sol(i).t, sol(i).x] = run_00(ac,Vcas(i),hcruise,[0,0,0]);  %(KTS, ft, KTS) !!!!!!!!
    % V     = x(:,1);
    % psi   = x(:,2);
    % gamma = x(:,3);
    % h     = x(:,4);
    % r     = x(:,5);
    % lat   = x(:,6)*180/pi;
    % lon   = x(:,7)*180/pi;
    % W     = x(:,8);
    % 
    % T     = xx(:,1);
    % Tratio= xx(:,2);
    % D     = xx(:,3);
    % Wdot  = xx(:,4);
    % f     = xx(:,5);
    % cas   = xx(:,6);
    % mach  = xx(:,7);
    % hdot  = xx(:,8);
    % Vdot  = xx(:,9);
    
    % Calculate TAS and Mac for specified IAS at h
    [Vtas(i),M(i)]=cas2tas(Vcas(i)*KTS2MPS,hcruise*FT2M); %(m/s, m)  !!!!!!!!

    % Calculate range, time, fuel burned
    dr(i)=(sol(i).x(end,5) - sol(i).x(1,5))*M2NM;      % NM
    dt(i)=(sol(i).t(end)   - sol(i).t(1))/60;          % min
    df(i)=(sol(i).x(1,8)   - sol(i).x(end,8))/G_CONST; % kg (mass)

    % Fuel costs in $
    fuel_cost(i) = df(i) * usd_per_kg;

    % Time costs in $
    time_cost(i) = dt(i) * usd_per_min;
    
    %- Define metrics to optimize------------------------------------------   
    % Mileage per 1000 kg
    mileage_per_1000kg(i) = 1000 * dr(i)/df(i);  % NM/kg * 1000 kg

    % The Cost Ratio = time_cost/fuel_cost 
    Cost_Ratio(i) =  time_cost(i) / fuel_cost(i);
    
    % The Total Cost  = time_cost + fuel_cost in $ 
    Total_Cost(i) =  time_cost(i) + fuel_cost(i);

    %fprintf('Vcas = %3.1f kt, Vtas=%3.1f kt, M=%1.2f\n', Vcas(i), Vtas(i), M(i));
    fprintf('.');

    % Next iteration
    i=i+1;
    ratio(i)=ratio(i-1)+0.01;    
    Vcas(i)=ratio(i)*Vmo;
end
fprintf('\n');
Vcas=Vcas(1:end-1);

% list of colors
list = jet(length(ratio));

% Fit polynomial to Fuel Burned and Mileage per 1000 Kg
poly1=polyfit(M,df,2)
poly2=polyfit(M,mileage_per_1000kg,2)

% Calculate ECON speed
[min_cost,ii_econ]=min(Total_Cost);

% Calculate MRC speed
[max_range,ii_mrc]=max(mileage_per_1000kg);

% Calculate LRC speed
ii_lrc=ii_mrc;
for ii=ii_mrc:length(ratio)
    if mileage_per_1000kg(ii)<= 0.99 * mileage_per_1000kg(ii_mrc)
        ii_lrc=ii;
        break;
    end
end

%% PRINT ==================================================================
% Print ECON
fprintf('Vecon=%1.2f  M\n',M(ii_econ));
fprintf('Vecon=%3.1f kts (IAS)\n',Vcas(ii_econ));
fprintf('Vecon=%3.1f kts (TAS)\n\n',Vtas(ii_econ)*MPS2KTS);

% Print MRC, LRC
fprintf('Vmrc=%1.2f M,          Vlrc=%1.2f M\n',M(ii_mrc),M(ii_lrc));
fprintf('Vmrc=%3.1f kts (IAS), Vlrc=%3.1f kts (IAS)\n',Vcas(ii_mrc),Vcas(ii_lrc));
fprintf('Vmrc=%3.1f kts (TAS), Vlrc=%3.1f kts (TAS)\n',Vtas(ii_mrc)*MPS2KTS,Vtas(ii_lrc)*MPS2KTS);

%% PLOT ===================================================================
close all;

figure(1)
plot(M,time_cost,'b'); hold on;
plot(M,fuel_cost,'r'); hold on;
plot(M,Total_Cost,'g'); hold on;
plot(M,Cost_Ratio*10,'m'); hold on;

legend('Time cost in $','Fuel cost in $', 'Total Cost $', 'Cost ratio *10');
plot(M(ii_econ),Total_Cost(ii_econ),'kO', M(ii_mrc),Total_Cost(ii_mrc),'rX', M(ii_lrc),Total_Cost(ii_lrc),'bX');

% plot(M,time_cost,'b.'); hold on;
% plot(M,fuel_cost,'r.'); hold on;
% plot(M,Total_Cost,'g.'); hold on;
% plot(M,Cost_Ratio*1e4,'m.'); hold on;

grid on
xlabel('Mach no.', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Fuel-related Cost (US$)', 'FontSize', 12, 'FontWeight', 'bold');
title('Fuel-related Cost versus Mach no.', 'FontSize', 12, 'FontWeight', 'bold');
grid on

figure(2)
%plot(M,mileage_per_1000kg,'r.'); hold on;
for ii=1:length(M)
    plot(M(ii),mileage_per_1000kg(ii),'.','col', list(ii,:),'LineWidth',3); hold on
end
plot(M,mileage_per_1000kg,'r'); hold on;
plot(M(ii_econ),mileage_per_1000kg(ii_econ),'kO', M(ii_mrc),mileage_per_1000kg(ii_mrc),'rX', M(ii_lrc),mileage_per_1000kg(ii_lrc),'bX');
%plot(M,mileage_per_1000kg,'r',M, 1000 * (RangeTarget*M2NM)./polyval(poly,M),'g'); hold on;
%plot(M,mileage_per_1000kg,'r',M, polyval(poly2,M),'g'); hold on;

grid on
xlabel('Mach no.', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Fuel mileage [NM/1000kg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Fuel Mileage versus Mach no.', 'FontSize', 12, 'FontWeight', 'bold');
grid on


% figure(3)
% for ii=1:length(ratio)
%     plot(sol(ii).t,sol(ii).x(:,5)*M2NM,'col', list(ii,:),'LineWidth',2); hold on
% end
% grid on
% xlabel('Time elapsed [sec]', 'FontSize', 12, 'FontWeight', 'bold')
% ylabel('Range [NM]', 'FontSize', 12, 'FontWeight', 'bold');
% title('Cruise', 'FontSize', 12, 'FontWeight', 'bold');
% grid on
% 
% figure(4)
% for ii=1:length(ratio)
%     plot(sol(ii).t,sol(ii).x(:,1)*MPS2KTS,'col', list(ii,:),'LineWidth',2); hold on
% end
% grid on
% xlabel('Time elapsed [sec]', 'FontSize', 12, 'FontWeight', 'bold')
% ylabel('Airspeed [KTS]', 'FontSize', 12, 'FontWeight', 'bold');
% title('Cruise', 'FontSize', 12, 'FontWeight', 'bold');
% grid on
% 
% figure(5)
% for ii=1:length(ratio)
%     plot(sol(ii).t,(sol(ii).x(:,8)/G_CONST)/1000,'col', list(ii,:),'LineWidth',2);  hold on
% end
% grid on
% xlabel('Time elapsed [sec]', 'FontSize', 12, 'FontWeight', 'bold')
% ylabel('Mass [tonnes]', 'FontSize', 12, 'FontWeight', 'bold');
% title('Cruise', 'FontSize', 12, 'FontWeight', 'bold');
% grid on