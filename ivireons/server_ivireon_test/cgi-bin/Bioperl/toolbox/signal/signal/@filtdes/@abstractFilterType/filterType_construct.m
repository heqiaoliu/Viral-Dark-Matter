function filterType_construct(h)
%FILTERTYPE  Initializer for the filter type class.
%
%   Inputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:27:30 $


% Construct spec objects needed by filter type and store them
objConstr = whichspecobjs(h);

for n = 1:length(objConstr),
    g(n) = feval(objConstr{n});
end

set(h,'specobjs',g);









