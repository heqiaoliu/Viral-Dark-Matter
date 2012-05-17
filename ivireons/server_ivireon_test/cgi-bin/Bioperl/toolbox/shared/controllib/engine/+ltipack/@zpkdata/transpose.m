function Dt = transpose(D)
% Transposition of ZPK models.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:59 $
Dt = D;
Dt.Delay = transposeDelay(D);
Dt.z = D.z.';
Dt.p = D.p.';
Dt.k = D.k.';