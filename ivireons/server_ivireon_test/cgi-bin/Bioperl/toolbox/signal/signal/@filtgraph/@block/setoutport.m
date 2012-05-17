function B = setoutport(Bi,N,inport)
%SETOUTPORT Connect this block outport to another block inport

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:10 $

error(nargchk(3,3,nargin,'struct'));
B=Bi;

if length(B.outport) >= N
    if ~isa(inport,'filtgraph.inport')
        error(generatemsgid('InternalError'),'An Outport can connect only to an inport.');
    end
    B.outport(N).setto(...
        filtgraph.nodeport(inport.nodeIndex,inport.selfindex));
else
    msg = sprintf('No outport at %d.', N);
    error(generatemsgid('SigErr'),msg);
end
