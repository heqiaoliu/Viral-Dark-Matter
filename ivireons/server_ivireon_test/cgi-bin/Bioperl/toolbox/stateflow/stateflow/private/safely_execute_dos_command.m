function cmdFailed = safely_execute_dos_command(targetDirectory,dosCommand)
%   CMDFAILED = SAFELY_EXECUTE_DOS_COMMAND(TARGETDIR,DOSCOMMAND)

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.6.2.3 $  $Date: 2008/12/01 08:07:02 $

cmdFailed = 0;

currDirectory = pwd;
try
  cd(targetDirectory);
  sf_dos(dosCommand);
  cd(currDirectory);
  cmdFailed = 1;
catch ME
   cd(currDirectory);
   rethrow(ME);
end


