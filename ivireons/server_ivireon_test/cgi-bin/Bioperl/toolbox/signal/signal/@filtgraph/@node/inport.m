function inp = inport(Node,index)

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:25 $

error(nargchk(1,2,nargin,'struct'));

N = Node;

if nargin > 1
    inp = N.block.inport(index);
else
    if length(N.block.inport) > 0
        inp = N.block.inport(1);
    else
        error(generatemsgid('InternalError'),'This node has no inport.');
    end
end
