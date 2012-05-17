function winName = setwindowname(this,winName)
%SETWINDOWNAME   Set function for the WindowName property.
%
% This function updates the Window private property that stores a sigwin
% object whenever the property WindowName is set.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:40 $

this.Window = getwinobject(winName); 

% [EOF]
