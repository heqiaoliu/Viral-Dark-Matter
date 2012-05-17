function op = settargetfrom(Op,NodeList)

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:43 $

error(nargchk(2,2,nargin,'struct'));

op=Op;
for I = 1:length(op.to)
  ip = NodeList.nth(op.to.node).inport(op.to.port);
  ip.setfrom(filtgraph.nodeport(op.nodeIndex,op.selfIndex));
end
