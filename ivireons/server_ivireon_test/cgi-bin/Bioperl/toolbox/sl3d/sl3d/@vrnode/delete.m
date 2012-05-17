function delete(n)
%DELETE Delete a VRNODE object.
%   DELETE(N) deletes a virtual world node referenced by the VRNODE handle N.
%   If N is a vector of VRNODE handles, multiple nodes are deleted.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/02/08 23:02:14 $ $Author: batserve $


for i = 1:numel(n)
  vrsfunc('DeleteNode', getparentid(n(i)), n(i).Name);
end

