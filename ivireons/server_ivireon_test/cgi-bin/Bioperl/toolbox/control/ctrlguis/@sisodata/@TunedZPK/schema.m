function schema
%SCHEMA  Defines properties for @TunedZPK class

%  Copyright 1986-2005 The MathWorks, Inc. 
%  $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:46:35 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'TunedZPK', findclass(pkg, 'TunedBlock'));

% Class attributes
%%%%%%%%%%%%%%%%%%%
p = schema.prop(c, 'Constraints','MATLAB array');

p = schema.prop(c, 'ZPK2ParFcn','MATLAB array');

% Tunable part of the TunedZPK is stored in Gain and PZGroup properties
schema.prop(c,'Gain','MATLAB array');       % DC Gain of the tunable part
schema.prop(c,'PZGroup','handle vector');   % Pole/zero groups

schema.prop(c,'Variable','string');         % Variable used to specify model data

% Fixed part of the TunedZPK
schema.prop(c,'FixedDynamics','MATLAB array');    % Fixed dynamics

% ZPKParamSpec
% Struct GainSpec
%        PZGroupSpec (dirty if 0)
p = schema.prop(c,'ZPKParamSpec','MATLAB array');
p.factoryValue = struct('GainSpec', handle(zeros(0,1)), ...
                        'PZGroupSpec',  handle(zeros(0,1)), ...
                        'Dirty', true);                    
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
     

schema.prop(c,'Listeners','MATLAB array');








