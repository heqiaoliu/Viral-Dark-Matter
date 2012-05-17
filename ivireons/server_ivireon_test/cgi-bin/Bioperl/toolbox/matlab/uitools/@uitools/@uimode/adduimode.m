function adduimode(hThis,hMode)
% This function is undocumented and will change in a future release

%ADDUIMODE
%   ADDUIMODE(THIS,UIMODE) registers the given mode with the mode. After
%   being registered, a mode may be accessed in a manner analogous to other
%   already registered modes.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/04/11 15:38:14 $

if ~isempty(getuimode(hThis,hMode.Name))
    error('MATLAB:adduimode:ExistingMode','A mode by this name is already registered with the mode.');
else
    registerMode(hThis,hMode);
end