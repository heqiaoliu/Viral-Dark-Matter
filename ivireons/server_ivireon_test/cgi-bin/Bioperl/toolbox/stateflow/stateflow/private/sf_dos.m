function sf_dos(command)
%% sf_dos(command) - invoke system command with tee to log file
 
% Vijay Raghavan
% Copyright 1995-2008 The MathWorks, Inc.
% $Revision: 1.13.2.5 $  $Date: 2008/12/29 02:22:50 $

compilerOutput= evalc(['dos(''',command,''');']);
sf_display('Make',sprintf('%s\n',compilerOutput));

