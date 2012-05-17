function B = setnuminports(Bi,N)
%add inports to the block

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:08 $

error(nargchk(1,2,nargin,'struct'));

if nargin > 0
    B=Bi;
end

if nargin > 1
    if N > 0
        for I = 1:N
            X(I) = filtgraph.inport(B.nodeIndex,I);
        end
        B.inport = X;
    end
end
