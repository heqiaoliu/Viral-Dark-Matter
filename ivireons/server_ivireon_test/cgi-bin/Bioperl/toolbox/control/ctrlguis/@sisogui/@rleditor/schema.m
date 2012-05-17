function schema
%SCHEMA  Schema for the Root Locus Editor.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $ $Date: 2010/03/26 17:22:52 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'rleditor',findclass(sisopack,'grapheditor'));

% Editor data
schema.prop(c,'ClosedPoles','MATLAB array');      % Closed-loop poles for current gain
schema.prop(c,'FrequencyUnits','string');    % Frequency units
schema.prop(c,'LocusGains','MATLAB array');       % Locus gains 
% Relative to normalized open loop, see loopdata/getopenloop
schema.prop(c,'LocusRoots','MATLAB array');       % Locus roots    
% Open-loop data: caches the following data from RLOCUS to facilitate
% computation of consistent closed-loop poles (297998)
%  * z,p,k data for the open-loop transfer
%  * hessenberg form used for closed-loop root computation
schema.prop(c,'OpenLoopData','MATLAB array');     


% Plot attributes
schema.prop(c,'AxisEqual','on/off');              % Equal aspect ratio
schema.prop(c,'GridOptions','MATLAB array');      % Grid options


% Pade order used by editor to support time delays
p = schema.prop(c,'PadeOrder','MATLAB array');  % Pade Order
p.FactoryValue = 2.0;

% Uncertainty
p = schema.prop(c,'UncertainBounds','MATLAB array');
p = schema.prop(c,'UncertainData','MATLAB array');

