function Dt = transpose(D)
% Transposition of state-space models.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:48 $
Dt = ltipack.ssdata(D.a.',D.c.',D.b.',D.d.',D.e.',D.Ts);
Dt.Delay = transposeDelay(D);
Dt.Scaled = D.Scaled;
