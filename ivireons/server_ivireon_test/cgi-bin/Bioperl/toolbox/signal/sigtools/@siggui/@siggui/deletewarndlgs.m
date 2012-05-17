function deletewarndlgs(hObj)
%DELETEWARNDLGS Delete warning dialogs

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2009/01/05 18:01:04 $

h = get(hObj, 'Handles');

if isfield(h, 'warn') && ~isempty(h.warn),
    hwarn = h.warn(ishghandle(h.warn));
    delete(hwarn);
    h.warn = [];
    set(hObj, 'Handles', h);
end

% [EOF]
