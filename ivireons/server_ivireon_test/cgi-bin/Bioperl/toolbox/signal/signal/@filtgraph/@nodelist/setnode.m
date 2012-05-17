function NL = setnode(NLi,Ni,index)
%SETNODE method to add a node into a particular index

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:36 $

error(nargchk(3,3,nargin,'struct'));
NL = NLi;

if index > NL.nodeCount + 1
    error(generatemsgid('InternalError'),'Subscript out of bounds. Can grow a UDD vector only one element at a time.');
end

Ni = Ni.setindex(index);
X = NL.nodes;  

if ~isempty(X)
    X(index) = Ni;
else
    X = Ni;
end
    
NL.nodes = X;

NL.nodeCount = length(NL.nodes);
