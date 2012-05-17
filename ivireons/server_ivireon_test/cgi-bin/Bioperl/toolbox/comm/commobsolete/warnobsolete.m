function warnobsolete(filename, varargin)
%WARNOBSOLETE Provides a real-time warning about an obsolete function.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:08:05 $

% Saves current warning display
strace = warning('query','backtrace');
% Switches off display of file and line number that produces a warning
warning('off','backtrace');

% Saves previous warning
[lastmsg, lastid] = lastwarn;

% Provides real-time warning, if such warning is enabled (by default it is)
warnid = ['comm:obsolete:' filename];
if nargin >= 2
    inputstring = char(varargin);
    warning(warnid, ...
        ['This is an obsolete function and may be removed in the future.\n' ...
        '         ' inputstring '\n', ...
        '         ' 'To disable this warning, type warning(''off'',''' warnid ''').']);
else
    warning(['comm:obsolete:' filename], ...
        ['This is an obsolete function and may be removed in the future.\n' ...
        '         ' 'To disable this warning, type warning(''off'',''' warnid ''').']);
end

% Restores previous warning in workspace if no warning was thrown by
% warnobsolete
s = warning('query', warnid);
if strcmpi(s.state,'off')
    lastwarn(lastmsg, lastid);
end    

% Restores previous warning display
warning(strace);
