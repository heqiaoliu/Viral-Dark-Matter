function calluimode(hThis,name,callback,obj,evd)
% Activates a uimode and triggers a callback function with the given object
% and event data.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2008/12/15 08:53:50 $

hThis.activateuimode(name);
hMode = hThis.getuimode(name);
defaultMode = hMode.DefaultUIMode;
% If the mode has been composited, recurse down to the mode to be called.
while ~isempty(defaultMode)
    hMode = hMode.getuimode(defaultMode);
    defaultMode = hMode.DefaultUIMode;
end
hgfeval(get(hMode,callback),obj,evd);