function pause2(n)
%PAUSE2 Pause procedure for specified time.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%  
%  PAUSE2(N)
%    N - number of seconds (may be fractional).
%  Stops procedure for N seconds.
%  
%  PAUSE2 differs from PAUSE in that pauses may take a fractional
%    number of seconds. PAUSE(1.2) will halt a procedure for 1 second.
%    PAUSE2(1.2) will halt a procedure for 1.2 seconds.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2010/03/22 04:08:25 $

if nargin ~= 1, nnerr.throw('Wrong number of input arguments.'); end

drawnow
t1 = clock;
while etime(clock,t1) < n,end;
