function varargout = getarguments(h, d)
%GETARGUMENTS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:07:56 $

[F, A, W] = getNumericSpecs(h, d);

if nargout == 1,
    varargout = {{F, A, W}};
else
    varargout = {F, A, W, {'hilbert'}};
end

% [EOF]
