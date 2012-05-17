function c = coefficientvariables(Hb)
%COEFFICIENTVARIABLES Coefficient variables.

%   This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:52:50 $

Hd = dispatch(Hb);
c = coefficientvariables(Hd);

% [EOF]
