function ok=validatenodes(t,j)
%VALIDATENODES Validate array of node numbers
%   OK=VALIDATENODES(T,J) returns true if J is a valid array of node
%   numbers or logical array for indexing into an object having a leading
%   dimension with one element per node in the array T.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:22 $

numnodes = numel(t.node);
if islogical(j)
    ok = (numel(j) <= numnodes);
else
    ok = ismember(j,1:numnodes);
    ok = all(ok(:));
end
