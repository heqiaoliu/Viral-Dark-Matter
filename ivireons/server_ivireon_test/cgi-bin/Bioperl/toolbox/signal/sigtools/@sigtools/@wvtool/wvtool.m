function hV = wvtool(varargin)
%WVTOOL Constructor for the wvtool class.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/12/26 22:23:37 $


% Instantiate the object
hV = sigtools.wvtool;

% Set up the default
addcomponent(hV, siggui.winviewer(varargin{:}));
set(hV, 'Version', 1);

% [EOF]
