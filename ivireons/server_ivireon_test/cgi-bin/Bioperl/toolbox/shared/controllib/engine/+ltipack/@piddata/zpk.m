function ZPKData = zpk(PID)
% Conversion to @zpkdata.

%   Author(s): Rong Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision $  $Date: 2010/06/24 19:43:14 $

% Compute zeros, poles and gain from iodynamics
[Num,P] = getTF(PID);
Z = roots(Num);
K = Num(end-length(Z));
ZPKData = ltipack.zpkdata({Z},{P},K,PID.Ts);
