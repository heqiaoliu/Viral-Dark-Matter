function b = isvalid(h)
%ISVALID  True if the object is valid

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:11 $

b = isa(h, 'fxptui.abstractobject') && ...
    (isa(h.daobject, 'DAStudio.Object') ||isa(h.daobject, 'Simulink.ModelReference')) ;

% [EOF]
