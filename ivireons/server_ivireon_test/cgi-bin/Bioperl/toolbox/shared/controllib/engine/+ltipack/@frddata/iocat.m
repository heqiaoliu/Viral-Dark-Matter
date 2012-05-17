function D = iocat(dim,D1,D2)
% Concatenates models along input (2) or output (1) dimension.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:56 $

% Check I/O delay consistency along dimension 3-DIM.
[Delay,D1,D2] = catDelay(D1,D2,dim);

% Form concatenated model
D = ltipack.frddata(cat(dim,D1.Response,D2.Response),D1.Frequency,D1.Ts);
D.FreqUnits = D1.FreqUnits;
D.Delay = Delay;
