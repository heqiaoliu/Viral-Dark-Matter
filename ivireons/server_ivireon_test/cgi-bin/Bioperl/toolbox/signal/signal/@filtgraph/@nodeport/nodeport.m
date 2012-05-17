function NP = nodeport(node,port)
%NODEPORT Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:38 $

error(nargchk(2,2,nargin,'struct'));

NP = filtgraph.nodeport;

NP.node = node;
NP.port = port;
