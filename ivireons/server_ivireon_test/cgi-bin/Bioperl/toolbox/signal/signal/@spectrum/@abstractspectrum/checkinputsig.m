function [x,nchans,msg] = checkinputsig(this,x)
%CHECKINPUTSIG   Return the input vector column'ized & number of channels.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:17:18 $

% If its a matrix error out.
msg = '';
[lenX,nchans] = size(x);
xIsMatrix = ~any([lenX,nchans]==1);

if xIsMatrix, 
    msg = 'Multi-channel data (matrices) is not supported.';
    return;
else
    x = x(:);
    [lenX,nchans] = size(x);
end 

% [EOF]
