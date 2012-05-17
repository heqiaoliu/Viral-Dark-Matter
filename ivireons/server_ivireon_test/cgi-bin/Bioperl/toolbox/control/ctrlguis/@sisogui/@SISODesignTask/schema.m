function schema
%SCHEMA SISO Tool Design Task

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2010/04/30 00:36:34 $

%---Register class
c = schema.class(findpackage('sisogui'),'SISODesignTask');

%---Define properties
schema.prop(c, 'Parent', 'handle');

schema.prop(c, 'Architecture', 'handle');
schema.prop(c, 'DesignPlotConfig', 'handle');
schema.prop(c, 'AnalysisPlotConfig', 'handle');
schema.prop(c, 'ManualTuning', 'handle');
schema.prop(c, 'AutomatedTuning', 'handle');

schema.prop(c, 'Diagram', 'handle');

schema.prop(c, 'ExportDialog', 'MATLAB array');

schema.prop(c, 'MultiModelDialog', 'MATLAB array');

schema.prop(c, 'Tabs', 'MATLAB array');

schema.prop(c, 'Handles', 'MATLAB array');


%---Listeners
schema.prop(c, 'Listeners', 'MATLAB array');
