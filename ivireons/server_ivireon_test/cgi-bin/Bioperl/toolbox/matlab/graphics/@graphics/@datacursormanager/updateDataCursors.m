function updateDataCursors(hThis)
% Update and refresh the text of all data cursors managed by the mode

% Copyright 2006 The MathWorks, Inc.

% Update the text of all data cursors
h = get(hThis,'DataCursors');
% UpdateFcn is documented to return an empty first argument
set(h,'EmptyArgUpdateFcn',hThis.UpdateFcn);
% Update the visible data cursors
for i = 1:length(h)
    % Workaround for bug:
    % If the callback is evaluated from a callback, and the file is the
    % same, the update doesn't fire
    updatestring(h(i));
end