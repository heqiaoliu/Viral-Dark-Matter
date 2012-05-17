function [success,msg] = slinstallprefs(filename)
%SLINSTALLPREFS - Restores Simulink Preferences from a file
%
% To restore the Preferences from the default file:
%   [success,msg] = slinstallprefs
%
% To load preferences from a specific file:
%   [success,msg] = slinstallprefs(filename)
%
% If successful, the return values are true and empty respectively.
% If an error occurs, the first output is false and the second is
% the error message.

% Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.7 $  

e = lasterror;

p = Simulink.Preferences.getInstance;

if ~nargin
    filename = p.getPrefsFileName;
end

try
    p.Load(filename);
    success = true;
    msg = '';
catch
    % The most likely error is that the file does not exist.
    success = false;
    msg = lasterr;
    lasterror(e);
end

