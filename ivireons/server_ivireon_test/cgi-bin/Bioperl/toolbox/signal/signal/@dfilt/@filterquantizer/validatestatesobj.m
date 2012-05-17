function S = validatestatesobj(q, S)
%VALIDATESTATESOBJ   

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:58:03 $

S.Numerator = validatestates(q,S.Numerator);
S.Denominator = validatestates(q,S.Denominator);

% [EOF]
