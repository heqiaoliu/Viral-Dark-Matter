function postdeserialize(hThis)
% Clean up deserialized scribe underlay.

%   Copyright 2006 The MathWorks, Inc.

% Call the postdeserialize functions of any children.
hChil = findall(double(hThis),'-depth',1);
hChil = hChil(2:end);

for i=1:length(hChil)
    currChild = double(hChil(i));
    if isappdata(currChild,'PostDeserializeFcn')
        feval(getappdata(currChild,'PostDeserializeFcn'),currChild,'load')
    elseif ismethod(handle(currChild),'postdeserialize')
        try %#ok
            postdeserialize(handle(currChild));
        end
    end
end