function cOut = cloneContainer(cIn)
%cloneContainer Clone the contents of a container.Map
%   HCLONE = testconsole.cloneContainer(H) makes a deep copy, HCLONE, of the
%   container H.

%   Copyright 2009 The MathWorks, Inc.

cOut = containers.Map;
names = keys(cIn);
for idx = 1:length(names)
    cOut(names{idx}) = clone(cIn(names{idx}));
end
