function P = setindex(Pi,index)

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:46 $

error(nargchk(2,2,nargin,'struct'));
P = Pi;

P.nodeIndex = index;
