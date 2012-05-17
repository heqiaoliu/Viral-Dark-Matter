function [status, nlevels] = idfewdatalevels(x, maxlevels, tol)
%IDFEWDATALEVELS: True if data vector contains few different values (levels)
%
% [status, nlevels] = idfewdatalevels(x, maxlevels, tol)
%
% x: real data vector.
% maxlevels: maximum data levels, ("few" means <= maxlevels).
% tol: tolerance for comparing data values.
%
% status: true if few data levels, otherwise false.
% nlevels: the number of data levels, NaN if status=false.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:05:47 $

% Author(s): Qinghua Zhang

ni = nargin;
error(nargchk(1,3,ni,'struct'))

if ni<2
    maxlevels = 5;
end
if ni<3
    tol =  max(sqrt(eps)*(max(x)-min(x))/maxlevels, eps);
end

%{
if ~isrealvec(x)
  error('Ident:general:notrealvec', 'The first input argument of the must be a real vector');
end
%}

status = true;
levels = zeros(maxlevels,1);
nlevels = 1;
levels(1) = x(1);
for k=2:length(x)
    if abs(x(k)-levels(1:nlevels)) > tol
        if nlevels>=maxlevels
            status = false;
            break
        end
        nlevels = nlevels + 1;
        levels(nlevels) = x(k);
    end
end

if ~status
    nlevels = NaN;
end

% FILE END