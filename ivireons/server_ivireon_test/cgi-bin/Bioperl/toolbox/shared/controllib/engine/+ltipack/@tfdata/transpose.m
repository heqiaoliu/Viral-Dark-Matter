function Dt = transpose(D)
% Transposition of transfer functions.

%   Author(s): P.Gahinet, 4-1-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:05 $
Dt = D;
Dt.Delay = transposeDelay(D);
Dt.num = D.num.';
Dt.den = D.den.';