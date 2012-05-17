function baseCreateScope(this)
%BASECREATESCOPE    Process common features of scopes

%   @commscope/@abstractScope
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:32 $

% Get the screen size
ss = get(0,'ScreenSize');
width = 460;
length = 570;

% Create a figure
this.PrivScopeHandle = figure('IntegerHandle', 'on', ...
    'NextPlot', 'new', ...
    'NumberTitle', 'on', ...
    'Name', sprintf('%s', this.Type), ...
    'Position', [5 ss(4)*.88-length width length]);

% Assign a listener for close/delete
addlistener(this.PrivScopeHandle, 'ObjectBeingDestroyed', ...
    @(hSrc, ed) deleteScope(this));

%-------------------------------------------------------------------------------
% [EOF]
