function p = getwindowprop(this)
%GETWINDOWPROP   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:26:46 $

winobj = get(this, 'WindowObject');

% Check if window has parameter, if so construct a property with the parameter name
if isa(winobj, 'sigwin.parameterizewin'),
    
    % Construct object
    p = getparamnames(winobj);
elseif isa(winobj, 'sigwin.functiondefined')
    p = 'Parameters';
else
    p = [];
end

% [EOF]
