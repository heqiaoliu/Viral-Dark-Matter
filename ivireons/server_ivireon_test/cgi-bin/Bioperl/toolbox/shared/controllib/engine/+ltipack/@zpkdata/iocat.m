function D = iocat(dim,D1,D2)
% Concatenates models along input (2) or output (1) dimension.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:48:12 $

% Check I/O delay consistency along dimension 3-DIM.
[Delay,D1,D2] = catDelay(D1,D2,dim);

% Form concatenated model
D = ltipack.zpkdata(cat(dim,D1.z,D2.z),...
   cat(dim,D1.p,D2.p),cat(dim,D1.k,D2.k),D1.Ts);
D.Delay = Delay;