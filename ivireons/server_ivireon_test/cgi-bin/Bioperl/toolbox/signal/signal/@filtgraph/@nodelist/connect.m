function NL = connect(NLi, NorP1, PorP1, NorP2, PorP2)

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:32 $

error(nargchk(3,5,nargin,'struct'));

NL = NLi;

%if ~(class(NorP1) == class(NorP2))
if ~(class(NorP1) == class(PorP1))
    error(generatemsgid('InternalError'),'Parameters must be either numbers or filtgraph.nodeport.');
end

Nodes = NL.nodes;

switch class(NorP1)
    case 'filtgraph.nodeport'
        
        NorP2=PorP1;  %if two inputs are filtgraph.nodeport.
        
        Nodes(NorP1.node).outport(NorP1.port).addto(NorP2);
        Nodes(NorP2.node).inport(NorP2.port).setfrom(NorP1);
        
    case 'double'

        Nodes(NorP1).outport(PorP1).addto(filtgraph.nodeport(NorP2,PorP2));
        Nodes(NorP2).inport(PorP2).setfrom(filtgraph.nodeport(NorP1,PorP1));

    otherwise
        error(generatemsgid('InternalError'),'Improper argument type.');
end

NL.nodes = Nodes;
