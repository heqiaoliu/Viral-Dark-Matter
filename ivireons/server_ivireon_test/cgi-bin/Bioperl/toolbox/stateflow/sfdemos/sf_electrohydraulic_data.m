        %sf_electrohydraulic initialization file

%   Copyright 2010 The MathWorks, Inc.

%% Controller
Ka = 38000;
Ki = 253080;
dcmin = 10;
dcmax = 85;
dcnull = 50;

%% PWM Driver Circuit
Tpwm = 0.02;        % sec   PWM period     
Ipull = 2.5;        % Amp   Current to be reached during the pulling phase
Ihold = 1;          % Amp   Current to hold during the hold phase
deltai = 0.1;       % Amp   Maximum current variation allowed during hold phase
Vs = 14;            % Volt  Pull voltage
Vz = 50;            % Volt  Release voltage
Vd = 0.5;           % Volt  Hold voltage


%% Magnetic Circuit
A = 8e-005;         % m^2   Cross-sectional area of the air gap 
gmax = 0.001016;    % m     Gap at x = 0
gser = 0.0001905;   % m     Equivalent series gap
mu0 = 1.25664e-006; % H/m   Air permeability

R = 2;              % ohm   Winding Resistance
N = 200;            %       Number of turns of the winding
Lsteel = 0.05;      % m     Length of the steel magnetic circuit

% BHcurve is defined in the model workspace



%% ArmatureMotion

Fs0 = 2;            % N     Spring preload force
Ks = 8998.88;       % N/m   Spring stiffness
Cv = 8.48528;       % N.s/m Armature friction
m = 0.001;          % kg    Armature mass

gmin = 0.000254;    % m     minimum air gap.

%% Hydraulic Circuit

Ps = 682001;        % pa     Supply pressure
Ao = 2.58064e-006;  % m^2    Supply Orifice Area
Ko = 0.0307568;     %        flow coefficient
balltravel = 0.000381;  % m     Ball maximum travel       

Ap = 0.0005;        % m^2   Piston Area
beta = 1.5004e+009; %       Fluid bulk modulus

%% Piston Motion

Mp = 1;             % kg    Piston mass
Ksp = 17322.8;      % N/m   Spring stiffness

xpmin = 0.002;      % m     Minimum piston displacement
xpmax = 0.05;       % m     Maximum piston displacement








