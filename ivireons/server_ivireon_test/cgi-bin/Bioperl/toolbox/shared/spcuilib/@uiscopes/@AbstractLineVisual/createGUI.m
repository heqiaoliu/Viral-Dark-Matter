function plan = createGUI(this)
%CREATEGUI Create the line specific GUI components.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:42:04 $

plan = lineVisual_createGUI(this);

plan = uimgr.uiinstaller(plan);

% [EOF]
