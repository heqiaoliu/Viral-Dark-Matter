function outp = outport(Node,index)

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:28 $

error(nargchk(1,2,nargin,'struct'));

N = Node;

if nargin > 1
    outp = N.block.outport(index);
else
    if length(N.block.outport) > 0
        outp = N.block.outport;
    else
        error(generatemsgid('InternalError'),'This node has no outport.');
    end
end
