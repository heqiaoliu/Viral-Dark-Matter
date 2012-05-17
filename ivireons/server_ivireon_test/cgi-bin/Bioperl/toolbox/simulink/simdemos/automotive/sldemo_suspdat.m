%   SLDEMO_SUSPDAT Load suspension demo data
%   SLDEMO_SUSPDAT  when typed at the command line, places suspension model parameters 
%   in the MATLAB workspace (also called as preload function of sldemo_suspn.mdl)
%
%   See also SLDEMO_SUSPGRAPH

%   Author(s): D. Maclay, S. Quinn, 12/1/97 
%   Modified by R. Shenoy, 11/12/04
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

Lf = 0.9;	% front hub displacement from body CG
Lr = 1.2;       % rear hub displacement from body CG
Mb = 1200;      % body mass in kg
Iyy = 2100;	% body moment of inertia about y-axis in kgm^2
kf = 28000;     % front suspension stiffness in N/m
kr = 21000;	% rear suspension stiffness in N/m
cf = 2500;	% front suspension damping in N/(m/s)
cr = 2000; 	% rear suspension damping in N/(m/s)
x0 = [-4.335788328729104e-018;-1.201224489795918e-001;6.462348535570529e-027;-1.033975765691285e-025]; %initial condition