function dbmex(arg)
%DBMEX Enable MEX-file debugging (on UNIX platforms)
%   DBMEX ON enables MEX-file debugging.
%   DBMEX OFF disables MEX-file debugging.
%   DBMEX STOP returns to debugger prompt.
%
%   DBMEX doesn't work on the PC.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2008/12/04 22:38:52 $

if ispc
  disp(sprintf(['DBMEX doesn''t work on the PC.  See the MATLAB External\n',...
        'Interfaces Guide for details on how to debug MEX-files.']));
  
elseif ~isempty(getenv('MATLAB_DEBUG'))
    if nargin < 1, arg = 'on'; end
    
    switch lower(arg)
        case 'stop'
            system_dependent(9);
            
        case 'print'
            % The 'print' option to dbmex is grandfathered
            system_dependent(8, 2);
            
        case 'on'
            system_dependent(8, 1);
            
        case 'off'
            system_dependent(8, 0);
            
        otherwise
            error('MATLAB:dbmex:badInput', 'Illegal option ''%s'' given.', arg);
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
