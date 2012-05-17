function schema
%SCHEMA  Schema for TunedBlock abstract class.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:39:24 $

% Register class 
c = schema.class(findpackage('sisodata'),'TunedBlock');

% Public properties
schema.prop(c,'Name','string');        % Model name
schema.prop(c,'Identifier','string');  % Model identifier (wrt loop config)
schema.prop(c,'Description','string'); % Model description

p = schema.prop(c,'Format','string');  % Model format
p.FactoryValue = 'TimeConstant1';
% TimeConstant1: (1 + T s)   
% TimeConstant2: (1 + s/p)
% ZeroPoleGain:  (s + p)

schema.prop(c,'Ts','double');             % Sample time 
schema.prop(c,'TsOrig','double');         % Sample time

schema.prop(c,'MaskParamSpec','MATLAB array');

schema.prop(c,'Parameters','MATLAB array');   % Parameters of the parameterization

schema.prop(c,'SSData','MATLAB array');   % Normalized state-space data (cached)

schema.prop(c,'Par2ZpkFcn','MATLAB array'); % function handle to par2zpk function

schema.prop(c,'C2DMethod','MATLAB array'); % function for converting sample time

schema.prop(c,'D2CMethod','MATLAB array'); % function for converting sample time

schema.prop(c,'AuxData','MATLAB array'); % property to store the port IO [outport inport]