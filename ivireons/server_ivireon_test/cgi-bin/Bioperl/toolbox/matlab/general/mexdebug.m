function mexdebug(arg)
%MEXDEBUG Debug MEX-files (Unix only). 
%   MEXDEBUG has been deprecated, use DBMEX instead.
%
%   See also DBMEX.

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2006/12/20 07:15:47 $

warning('MATLAB:mexdebug:ObsoleteFunction', ...
    'MEXDEBUG is obsolete.  Use DBMEX instead.')

if any(getenv('MATLAB_DEBUG'))  
    if nargin < 1, arg = 'on'; end
    if strcmp(arg,'stop')
        system_dependent(9);
    elseif strcmp(arg,'print')
        system_dependent(8,2);
    else
        system_dependent(8,strcmp(arg,'on'));
    end
else
    disp(' ')
    disp('In order to debug MEX-files, MATLAB must be run within a debugger.');
    disp(' ')
    disp('    To run MATLAB within a debugger start it by typing:');
    disp('           matlab -Ddebugger');
    disp('    where "debugger" is the name of the debugger you wish to use.');
    disp(' ')
end
