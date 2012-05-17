function Dt = ctranspose(D)
% Pertransposition of FRD models.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:15 $
Dt = D;
Dt.Delay = transposeDelay(D);
Dt.Response = conj(permute(D.Response,[2 1 3]));
