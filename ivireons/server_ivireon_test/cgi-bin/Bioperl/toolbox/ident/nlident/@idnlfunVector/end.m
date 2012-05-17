function ind = end(obj, k, n)
%END overloaded for idnlfunVector.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:35 $

% Author(s): Qinghua Zhang

if k==1
  ind = length(obj.ObjVector);
else %k>1
  ind = 1;
end

% FILE END