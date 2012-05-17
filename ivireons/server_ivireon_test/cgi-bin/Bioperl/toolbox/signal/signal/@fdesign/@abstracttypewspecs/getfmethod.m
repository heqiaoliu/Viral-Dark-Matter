function hfmethod = getfmethod(this, methodname)
%GETFMETHOD   Get the fmethod.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:05 $

% If we are passed a string, we assume that it is the name of the design
% method instead of the design method object.
if ischar(methodname) && isdesignmethod(this, methodname)
    hfmethod = feval(getdesignobj(this.CurrentSpecs, methodname));
elseif ~isa(methodname, 'fmethod.abstractdesign')
    error(generatemsgid('InvalidMethod'), ...
        sprintf('%s is not a valid method.', methodname));
else
    hfmethod = methodname;
end

% [EOF]
