function B = setindex(Bi,index)

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:07 $

error(nargchk(2,2,nargin,'struct'));
B=Bi;

B.nodeIndex = index;

for I = 1:length(B.outport)
    B.outport(I).setindex(index);
end

for I = 1:length(B.inport)
    B.inport(I).setindex(index);
end

