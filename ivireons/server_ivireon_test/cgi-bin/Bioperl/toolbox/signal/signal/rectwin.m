function w = rectwin(n_est)
%RECTWIN Rectangular window.
%   W = RECTWIN(N) returns the N-point rectangular window.
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN, 
%            FLATTOPWIN, NUTTALLWIN, PARZENWIN, TRIANG, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2007/12/14 15:05:56 $

error(nargchk(1,1,nargin,'struct'));
[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

w = ones(n,1);


% [EOF] 

