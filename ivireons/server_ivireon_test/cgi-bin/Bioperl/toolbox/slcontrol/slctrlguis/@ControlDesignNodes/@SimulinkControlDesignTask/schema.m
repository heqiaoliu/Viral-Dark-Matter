function schema
%  SCHEMA  Defines properties for SimulinkControlDesignTask class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/08/08 01:19:17 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractLinearizationSettings');

%% Register class (subclass) in package
inpkg = findpackage('ControlDesignNodes');
c = schema.class(inpkg, 'SimulinkControlDesignTask', supclass);

%% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'IOData', 'MATLAB array');
schema.prop(c, 'ValidBlockStruct', 'MATLAB array');
schema.prop(c, 'ValidBlocksTableData', 'MATLAB array');
schema.prop(c, 'BlockTree', 'MATLAB array');
schema.prop(c, 'SignalTree', 'MATLAB array');
p = schema.prop(c, 'OptionsStruct', 'MATLAB array');
p.FactoryValue = struct('SampleTime','-1',...
                        'RateConversionMethod','zoh',...
                        'PreWarpFreq','10',...
                        'UseExactDelayModel','off',...
                        'UseBusSignalLabels','off');
p = schema.prop(c, 'IOListener','MATLAB array');
p.AccessFlags.Serialize = 'off';                    
