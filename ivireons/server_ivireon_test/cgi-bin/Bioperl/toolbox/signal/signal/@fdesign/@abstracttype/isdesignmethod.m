function b = isdesignmethod(this, method)
%ISDESIGNMETHOD   Returns true if the method is a valid designmethod.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:11:29 $

d = designmethods(this);

if isa(method, 'function_handle'),
    method = func2str(method);
end

b = any(strcmpi(method, d));

% [EOF]
