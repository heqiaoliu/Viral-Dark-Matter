function NL = copy(nl)
% copy method to force a deep copy.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:33 $

error(nargchk(1,1,nargin,'struct'));

NL = feval(str2func(class(nl)));

for I = 1:length(nl.nodes)
    X(I) = copy(nl.nodes(I));
end

NL.nodes = X;
    
NL.nodecount = nl.nodecount;
