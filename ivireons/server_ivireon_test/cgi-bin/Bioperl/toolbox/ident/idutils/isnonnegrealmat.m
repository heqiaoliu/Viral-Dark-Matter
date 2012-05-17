function status = isnonnegrealmat(x)
% isnonnegrealmat returns 1 if input argument is a matrix of non negative real entries,
% otherwise zero.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:32 $

% Author(s): Qinghua Zhang

if ~isempty(x) && isrealmat(x) && all(all(isfinite(x))) && all(all((x>=0)))
  status = true;
else
  status = false;
end

% FILE END