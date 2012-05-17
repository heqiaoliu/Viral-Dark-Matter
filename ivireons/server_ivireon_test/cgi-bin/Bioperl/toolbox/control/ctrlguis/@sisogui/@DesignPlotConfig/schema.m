function schema
%SCHEMA SISO Tool Design plot configuration dialog

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:32 $

%---Register class
c = schema.class(findpackage('sisogui'),'DesignPlotConfig');

%---Define properties
schema.prop(c, 'SISODB', 'handle');

schema.prop(c, 'DesignViewsTableData', 'MATLAB array');
schema.prop(c, 'TunedLoopTableData', 'MATLAB array');


schema.prop(c, 'Handles', 'MATLAB array');


%---Listeners
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'PlotVisbilityListeners', 'MATLAB array');
schema.prop(c, 'TitleListener', 'MATLAB array');