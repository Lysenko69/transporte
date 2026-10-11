function [t, x] = run_00(myac,Vcas,h,wind)

%--------------------------------------------------------------------------
% CRUISE CONSTANT SPEED CONSTANT ALTITUDE
%--------------------------------------------------------------------------

% Add the files needed
addpath('../kgbx-lib/kml','../kgbx-lib/geo','../kgbx-lib/bada');

% Load the Constants & global variables
run Constants;
run Globals;
ac=myac;

%- LOAD AIRCRAFT MODEL ####################################################
% aircraft='B738';
% % Load a color to represent this aircraft results
% color='b';
% close all;
% [myac] = LoadAircraftBADA(['../BADA_3.14/bada_314_96b6f733f5b65f32a5e7/',aircraft,'__.OPF']);

%- SET WIND CONDITIONS ####################################################
% Set Wind in NED
% Wind=[0;0;0]*KTS2MPS;
Wind=wind;


%- SET INITIAL STATE ######################################################
% Set initial IAS/CAS in m/s-----------------------------------------------
cas_0 = Vcas*KTS2MPS;
cas_f = cas_0;

% Set initial altitude in m------------------------------------------------
h_0 = h*FT2M;
h_f=h_0;

% Set initial course in degrees--------------------------------------------
psi_0=0;

% Set initial FPA in degrees-----------------------------------------------
gamma_0=0;

% Set coordinates of initial point-----------------------------------------
%[num, txt, tab] = xlsread('Waypoints_coordinates.xlsx');
% lat_0 = num(1,1) * pi/180;
% lon_0 = num(1,2) * pi/180;
% LEVC
lat_0 = 39.4929*pi/180.0;
lon_0 = -0.476169*pi/180.0;

%- SET TURN PARAMETERES ###################################################
% Compute load factor, lift, radius of turn, and bank

% CASE 1: set psi_dot and deduce bank angle--------------------------------
psi_dot=0;

% Set FINAL CONDITION #####################################################

% Set final range in NM----------------------------------------------------
r_f= 1;
%- Set termination event---------------------------------------------------
RangeTarget = r_f*NM2M;
options = odeset('Events', @RangeEvent);


%- SET LEG SPECIFIC PARAMETERS ############################################
% SET PHASE OF FLIGHT -----------------------------------------------------
flight_phase='cruise';

% % SET LEG TYPE ------------------------------------------------------------
% % CASE 3: set (V_0 & dVdr) and (h_0 & hdot). Let Tr be derived
% V_0=cas2tas(cas_0,h_0);
% Tr=[]; hdot=0; 
% % We will assume Vdot=0 initiall for simplicity although TAS varies a little..
% Vdot=0;
% % Check CAS variation on first run and make adjustments
% %Estimate timeq from initial run
% timeq=12;
% Vdot=(cas2tas(cas_f,h_f)-cas2tas(cas_0,h_0))/timeq; % 2nd run

%% SET LEG TYPE ###########################################################
leg_type='PTH';  FPA=0;
known='dVdr'; dVdr=0;

%- SOLVE DIFFERENTIAL EQUATION ############################################
% Set initial state vector-------------------------------------------------
% State vector x = [V; psi; gamma; h; r; lat; lon; W]
% Find out aircraft initial weight
V_0=cas2tas(cas_0,h_0);
W_0=ac.mass.m_ref*G_CONST;

x_0=[V_0; psi_0*pi/180; gamma_0*pi/180; h_0; 0; lat_0; lon_0; W_0];

% Set BADA function--------------------------------------------------------
BADAfunction=@BADA_jet;

% Integrate----------------------------------------------------------------
[ t,x,xx ] = integrate(0,1000,x_0,options);
%print_results(t,x,xx,aircraft,ac);
%plot_results(t,x,xx,color);

end