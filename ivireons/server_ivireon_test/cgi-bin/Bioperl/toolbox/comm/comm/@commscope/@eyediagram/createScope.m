function createScope(this)
%CREATESCOPE    Create a scope face

%   @commscope/@eyediagram
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/11/07 18:18:25 $

% Process common features
this.baseCreateScope;

% Add tag
set(this.PrivScopeHandle, 'Tag', 'EyeDiagramPlot');

% Set default ColorMap
set(this.PrivScopeHandle, 'ColorMap', hot(64));

% Create axes
this.createAxes;

%-------------------------------------------------------------------------------
% [EOF]
