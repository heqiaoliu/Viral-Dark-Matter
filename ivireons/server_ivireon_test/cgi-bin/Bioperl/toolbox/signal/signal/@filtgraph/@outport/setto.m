function op = setto(Op,NodesAndPorts)
%SETTO Sets the input ports that accept output from this output port

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:13:44 $

error(nargchk(1,2,nargin,'struct'));

if nargin > 0
    op=Op;
end

if nargin > 1
%     op.to = copy(NodesAndPorts);
    op.to = NodesAndPorts;
end
