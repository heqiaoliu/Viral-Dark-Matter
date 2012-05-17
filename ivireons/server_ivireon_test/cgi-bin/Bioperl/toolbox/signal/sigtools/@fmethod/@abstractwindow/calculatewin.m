function win = calculatewin(this, N, win)
%CALCULATEWIN   Calculate the window.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:37:24 $

if nargin < 3
    win = get(this, 'Window');
end

if isempty(win)
    win = {};
else

    if ischar(win) || isa(win, 'function_handle')
        win = feval(win, N+1);
    elseif iscell(win)
        if length(win) == 1
            win = feval(win{1}, N+1);
        else
            win = feval(win{1}, N+1, win{2:end});
        end
    end
    win = {win};
end

% [EOF]
