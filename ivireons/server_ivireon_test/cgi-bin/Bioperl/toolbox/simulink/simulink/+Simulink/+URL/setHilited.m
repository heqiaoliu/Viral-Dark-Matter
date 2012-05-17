function out = setHilited(url)
% SETHILITED Set URL of currently highlighted object

%   Copyright 2009 The MathWorks, Inc.
    
persistent hilited;

error(nargchk(1,1,nargin,'struct'));

prev = hilited;
hilited = url;   % reset

% unhighlight previously set object
if ~isempty(prev);
    mdl = strtok(prev,':');
    if isValidSlObject(slroot,mdl)
        slprivate('remove_hilite',mdl);
    end
end

out = prev;

