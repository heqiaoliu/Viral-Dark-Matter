function s = savereferencecoefficients(this)
%SAVEREFERENCECOEFFICIENTS   Save the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:09:21 $

s.refA = get(this, 'refA');
s.refB = get(this, 'refB');
s.refC = get(this, 'refC');
s.refD = get(this, 'refD');

% [EOF]
