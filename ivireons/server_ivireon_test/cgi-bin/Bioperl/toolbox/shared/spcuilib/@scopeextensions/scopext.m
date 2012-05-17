function scopext(ext)
%SCOPEXT Register scope extension.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.10 $  $Date: 2009/10/29 16:08:12 $

% Sources
ext.add('Sources', 'File', 'scopeextensions.SrcFile', 'Connect to file');
ext.add('Sources', 'Workspace', 'scopeextensions.SrcWksp', 'Import from MATLAB workspace');
r = ext.add(...
    'Sources', 'Streaming', ...
    'scopeextensions.SrcMLStreaming', 'Streaming data in MATLAB');
r.Visible = false;

% Visuals
ext.add('Visuals', 'Video', 'scopeextensions.VideoVisual', 'Video visualization');
ext.add('Visuals', 'Time Domain', 'scopeextensions.TimeDomainVisual', ...
    'Display signals with reference to simulation time');

% Tools
ext.add('Tools', 'Instrumentation Sets', 'scopeextensions.InstrumentSets', ...
    'Save or load multiple scope settings');
ext.add('Tools', 'Plot Navigation', 'scopeextensions.PlotNavigation', ...
    '2-D zoom and axes adjustment tools');

% Scope specific information (DataHandlers)
uiscopes.addDataHandler(ext, 'File', 'Video', 'scopeextensions.VideoFileHandler');
uiscopes.addDataHandler(ext, 'Workspace', 'Video', 'scopeextensions.VideoWkspHandler');


% [EOF]
