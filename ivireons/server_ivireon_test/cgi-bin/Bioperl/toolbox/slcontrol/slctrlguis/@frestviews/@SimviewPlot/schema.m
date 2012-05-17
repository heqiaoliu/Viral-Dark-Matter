function schema
% SCHEMA Class definition for @SimviewPlot (the full figure for the simview
% command)

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/08/29 08:32:30 $

% Find parent package
pkg = findpackage('frestviews');
% Register class
c = schema.class(pkg, 'SimviewPlot');

% Class attributes
schema.prop(c, 'TimePlot', 'handle');   % @timeplot of resppack
schema.prop(c, 'SpectrumPlot', 'handle');   % @fftplot of respack
schema.prop(c, 'SummaryPlot', 'handle');    % @SimviewSummary of frestviews
schema.prop(c, 'PlotOptions', 'MATLAB array');    % @SimviewOptions of frestviews
schema.prop(c, 'SimulationData', 'handle');     % @SimviewSource of frestviews
schema.prop(c, 'Styles', 'MATLAB array');      % a vector of @wavestyle of wavepack
p = schema.prop(c, 'CurrentSelection', 'MATLAB array');
p.setfunction = {@updateSelection};
p = schema.prop(c, 'CurrentChannel', 'MATLAB array');
p.setfunction = {@updateChannel};
schema.prop(c, 'FreqIndices', 'MATLAB array');
schema.prop(c, 'RespIndices', 'MATLAB array');
schema.prop(c, 'Figure', 'MATLAB array');
schema.prop(c, 'ChannelSelector', 'MATLAB array');
schema.prop(c, 'ImportDialog', 'MATLAB array');
schema.prop(c, 'InputVariables', 'MATLAB array');
schema.prop(c, 'TitleBar', 'MATLAB array');



