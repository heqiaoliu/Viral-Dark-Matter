function [xpos, ypos, nStacks, V, diam, Ts, Q, Te, theta, U] = airPollutionProblemData
%AIRPOLLUTIONPROBLEMDATA Problem data for air pollution demo
%
%   [XPOS, YPOS, NSTACKS, V, DIAM, TS, Q, TE, THETA, U] = AIRPOLLUTIONPROBLEMDATA 
%   returns the problem specific data for the air pollution demo. A
%   description of each quantity returned is given below:  
%
%   XPOS, YPOS: Positions of chimney stacks
%   NSTACKS: Number of chimney stacks
%   V: Internal stack diameters
%   DIAM: Pollution source diameter
%   TS: Temperature of gas in source
%   Q: Uniform emission rate
%   TE: Environment temperature
%   THETA: Wind direction  
%   U: Mean wind speed
%
%   See also CONCSULFURDIOXIDE, AIRPOLLUTION

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/01 07:20:54 $

% Stack positions
xpos = [-3000;-2600;-1100;1000;1000;2700;3000;-2000;0;1500];
ypos = [-2500;-300;-1700;-2500;2200;1000;-1600;2500;0;-1600];
%xpos = xpos([2,3,5,9,10]);
%ypos = ypos([2,3,5,9,10]);
nStacks = length(xpos);

% Internal stack diameters
V = [19.245;19.245;17.690;17.690;23.404;23.404;27.128;27.128;22.293;22.293];
%V = V([2,3,5,9,10]);
% Pollution source diameter
diam = [8;8;7.6;7.6;6.3;6.3;4.3;4.3;5;5];
%diam = diam([2,3,5,9,10]);

% Temperature of gas in source (Kelvin)
Ts = 413*ones(nStacks, 1);

% Uniform emission rate
Q = [2882.6;2882.6;2391.3;2391.3;2173.9;2173.9;1173.9;1173.9;1304.3;1304.3];
%Q = Q([2,3,5,9,10]);

% Environmental factors
% Environment temperature
Te = 283;
% Wind direction in rad
theta = 3.996;   
% Mean wind speed
U = 5.64;    

