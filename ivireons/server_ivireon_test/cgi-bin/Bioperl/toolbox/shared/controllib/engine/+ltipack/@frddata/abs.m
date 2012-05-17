function D = abs(D)
% Computes entry-wise magnitude.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:10 $
D.Response = abs(D.Response);
% RE: I/O delays have no effect
D.Delay.Input(:) = 0;
D.Delay.Output(:) = 0;
D.Delay.IO(:) = 0;

