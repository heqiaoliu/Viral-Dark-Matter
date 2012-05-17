function paste(h,manager)

% Copyright 2005 The MathWorks, Inc.

%% Calls @tsparentnode paste
if ~isempty(h.up)
    h.getParentNode.paste(manager);
end