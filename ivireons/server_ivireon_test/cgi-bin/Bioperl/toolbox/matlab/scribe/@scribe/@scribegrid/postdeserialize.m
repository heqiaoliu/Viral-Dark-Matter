function postdeserialize(hThis)
% Clean up deserialized scribe grid. This includes removing extra
% children.

%   Copyright 2006 The MathWorks, Inc.

% delete children not created in constructor.
goodchildren = double(hThis.Hlines);
goodchildren = [goodchildren;double(hThis.Vlines)];

% Since handle visibility of the children may be "off", use the FINDALL
% function to make sure we find all thie children.
allchildren = findall(double(hThis),'-depth',1);
allchildren = allchildren(2:end);

% Delete the children not explicitly referenced above.
badchildren = setdiff(allchildren,goodchildren);
if ~isempty(badchildren)
    delete(badchildren);
end