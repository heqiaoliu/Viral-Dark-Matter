function scopext(ext)
%SCOPEXT Register the Fixed-Point Histogram Scope extension.

%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2009/10/07 14:21:07 $


% Visuals
r = ext.add('Visuals','Fixed-Point Histogram', 'scopeextensions.HistogramVisual', 'Histogram Visualization');
r.Visible = false;

% Scope specific information (DataHandlers)
uiscopes.addDataHandler(ext, 'Workspace', 'Fixed-Point Histogram', 'scopeextensions.HistogramWkspHandler');
uiscopes.addDataHandler(ext, 'Streaming', 'Fixed-Point Histogram', 'scopeextensions.HistogramMLStreamingHandler');

