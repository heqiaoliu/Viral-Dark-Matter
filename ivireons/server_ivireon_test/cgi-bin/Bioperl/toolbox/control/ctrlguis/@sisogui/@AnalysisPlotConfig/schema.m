function schema
%SCHEMA SISO Tool Analysis plot configuration

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:41:06 $

%---Register class
c = schema.class(findpackage('sisogui'),'AnalysisPlotConfig');


%---Define properties

schema.prop(c, 'SISODB', 'handle');

p = schema.prop(c, 'PlotList', 'MATLAB array'); % List of plot Types
p.FactoryValue = {'None'; 'Step'; 'Impulse'; 'Bode';  ...
    'Nyquist'; 'Nichols'; 'Pole/Zero'};

p = schema.prop(c, 'PlotTag', 'MATLAB array'); % List of plot Types
p.FactoryValue = {'none'; 'step'; 'impulse'; 'bode';  ...
    'nyquist'; 'nichols'; 'pzmap'};

schema.prop(c, 'RespData',  'MATLAB array'); % Plot Content data

schema.prop(c, 'Handles', 'MATLAB array'); % GUI items

schema.prop(c, 'PlotTypes', 'MATLAB array'); % Current setting for 6 plot types

%---Listeners
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'PlotVisbilityListeners', 'MATLAB array');
