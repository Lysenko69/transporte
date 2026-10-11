clc; clear all;close all;
Vsound=574;

%% Cost index
usd_per_kg = 0.95;  % $/Kg
usd_per_min = 13.4; % 13.4 $/min
cost_index = usd_per_min/ usd_per_kg; %Kg/min

%% Mileage_per_1000 kg
a= -0.8286*1e3;
b= 1.2161*1e3;
c= -0.2591*1e3;

Vmrc=-b/(2*a);
MP1000mrc=a*Vmrc^2+b*Vmrc+c;
MP1000lrc=0.99*MP1000mrc;
% MP1000lrc = a*Vmrc^2+b*Vmrc+c
c_lrc=c-MP1000lrc;
Vlrc= (-b-sqrt(b^2-4*a*c_lrc))/(2*a);

M=[0.5:.01:1];
MP1000=a.*M.^2+b.*M+c;


%% Fuel consumption (burned)
a2= 2.9695*1e4;
b2= -4.3450*1e4;
c2= 2.1216*1e4;

fuel_cost=(a2.*M.^2+b2.*M+c2) * usd_per_kg;
T=1000./(M*Vsound) * 60;

time_cost= T * usd_per_min;

total_cost=fuel_cost+time_cost;

ii_econ=1;
for i=1:length(M)
    if total_cost(i)<total_cost(ii_econ)
        ii_econ=i;
    end
end

Vecon=M(ii_econ);

%% Print results
plot(M,MP1000,M,0.99*MP1000mrc*ones(length(M))); hold on;
plot(Vmrc, MP1000mrc,'rX', Vlrc, MP1000lrc,'bX');
figure;
plot(M,fuel_cost,M,time_cost,M,total_cost); hold on;
legend('Fuel cost', 'Time cost', 'Total cost');
plot(M(ii_econ),total_cost(ii_econ),'kO');

fprintf('Fuel_cost=%g $/kg, Time_cost=%g $/min, CI=%g Kg/min\n',usd_per_kg,usd_per_min,cost_index);
fprintf('Vecon=%g M, Vmrc=%g M, Vlrc=%g M\n',Vecon,Vmrc,Vlrc);
fprintf('Vecon=%g kts, Vmrc=%g kts, Vlrc=%g kts\n',Vecon*Vsound,Vmrc*Vsound,Vlrc*Vsound);
