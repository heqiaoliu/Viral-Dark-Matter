function paste(h,manager)

% Copyright 2004 The MathWorks, Inc.

%% Calls @viewcontainer paste
if ~isempty(h.up)
    h.up.paste(manager)
end