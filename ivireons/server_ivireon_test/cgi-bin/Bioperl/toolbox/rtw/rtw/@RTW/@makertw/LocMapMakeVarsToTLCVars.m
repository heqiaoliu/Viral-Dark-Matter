function output = LocMapMakeVarsToTLCVars(h, makeString)
% LocMapMakeVarsToTLCVars - Add options for TLC based on make (build) arguments.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/06/20 08:08:52 $

if h.LocalFindStr(makeString,'MSFCN=1')
    DAStudio.error('RTW:makertw:obsoleteMakeOption','MSFCN');
 end

% For backwards compatibility, check for EXT_MODE=1 in the build arguments.
% If present, make sure we add ExtMode=1 for TLC.
map(1).makename = 'EXT_MODE';
map(1).makevalue = '1';
map(1).tlcname = 'ExtMode';
map(1).tlcvalue = '1';

% For backwards compatibility, check for MAT_FILE=1 in the build
% arguments. If present, tell TLC to add support for mat file logging.
map(2).makename = 'MAT_FILE';
map(2).makevalue = '1';
map(2).tlcname = 'MatFileLogging';
map(2).tlcvalue = '1';

% For backwards compatibility, check for STETHOSCOPE=1 in the build
% arguments. If present, tell TLC to add support for StethoScope.
map(3).makename = 'STETHOSCOPE';
map(3).makevalue = '1';
map(3).tlcname = 'StethoScope';
map(3).tlcvalue = '1';

output = [];
makeString = [' ', makeString];

for j = 1:length(map)
    token = [' ',map(j).makename '=' map(j).makevalue];
    if length(makeString) >= length(token)
        location = findstr(makeString, token);
    else
        location = [];
    end
    if (~isempty(location))
        output = [output ' -a' map(j).tlcname '=' map(j).tlcvalue]; %#ok<AGROW>
    end
end

%endfunction LocMapMakeVarsToTLCVars
