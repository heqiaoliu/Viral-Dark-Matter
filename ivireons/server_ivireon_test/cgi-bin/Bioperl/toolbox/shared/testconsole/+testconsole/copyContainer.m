function cOut = copyContainer(cIn)
%copyContainer Copy the contents of a container.Map
%   HCOPY = testconsole.copyContainer(H) makes a shallow copy, HCOPY, of the
%   container H.

%   Copyright 2009 The MathWorks, Inc.

cOut = containers.Map;
names = keys(cIn);
for idx = 1:length(names)
    cOut(names{idx}) = cIn(names{idx});
end
