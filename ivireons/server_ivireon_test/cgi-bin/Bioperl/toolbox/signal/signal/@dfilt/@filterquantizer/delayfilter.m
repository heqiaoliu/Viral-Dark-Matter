function [y,zf] = delayfilter(q,b,x,zi)
% DELAY Filter for DFILT.DELAY class in double single and fixed point 
% precision mode

%   Author(s): M.Chugh
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/10/14 16:25:59 $

x = quantizeinput(q,x);
N = size(x,1);
if N>=b,
    y = [zi; x(1:N-b,:)];
    zf = x(N-b+1:N,:);
else
    y = zi(1:N,:);
    zf = [zi(N+1:b,:);x(1:N,:)];
end

%EOF