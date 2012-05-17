function N = copy(n)
% copy method to force a deep copy.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:24 $

error(nargchk(1,1,nargin,'struct'));

N = feval(str2func(class(n)));

N.block = copy(n.block);
N.qparam = n.qparam;
N.position = n.position;
N.setindex(n.index);
