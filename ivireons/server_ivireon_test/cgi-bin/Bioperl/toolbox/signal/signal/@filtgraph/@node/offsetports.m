function NL = offsetports(NLi, offset)
%OFFSETPORTS Offset the inports & outports indices of node NLi

%   Author(s): Roshan R Rammohan, S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:27 $

error(nargchk(2,2,nargin,'struct'));
NL = NLi;

for I = 1:length(NLi.block.outport)
    for J = 1:length(NLi.outport(I).to)
        NLi.outport(I).to(J).node = ...
            NLi.outport(I).to(J).node + offset;
    end
end

for I = 1:length(NLi.block.inport)
    for J = 1:length(NLi.inport(I).from)
        NLi.inport(I).from(J).node = ...
            NLi.inport(I).from(J).node + offset;
    end
end
