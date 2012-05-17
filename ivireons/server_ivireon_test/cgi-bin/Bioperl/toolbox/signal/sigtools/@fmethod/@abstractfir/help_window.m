function help_window(this)
%HELP_WINDOW   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:37:21 $

window_str = sprintf('%s\n%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''Window'', WINDOW) designs using the window specified by WINDOW.', ...
    '    WINDOW can be a string or function handle which references the window function,', ...
    '    or it can be the window vector itself.  If the window function requires more', ...
    '    inputs, a cell array can be used.',...
    '    Click <a href="matlab:help window">here</a> for the full list of available windows.');

disp(window_str);
disp(' ');

% [EOF]
