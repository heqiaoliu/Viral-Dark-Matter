function makeCmdOut = setup_for_default(args)
% SETUP_FOR_DEFAULT - sets up a default batch file for RTW builds

% Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/08/23 19:09:22 $
  
  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;
  
  % args.compilerEnvVal not used

    
  cmdFile = ['.\',modelName, '.bat'];
  cmdFileFid = fopen(cmdFile,'wt');
  if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
  end
  fprintf(cmdFileFid, 'set MATLAB=%s\n', matlabroot);
  
  % Write out any build hook environment commands
  rtw.pil.BuildHook.writePcBuildEnvironmentCmds(cmdFileFid, ...
                                                modelName);

  
  fprintf(cmdFileFid, '%s\n', makeCmd );
  fclose(cmdFileFid);
  makeCmdOut = cmdFile;

%endfunction setup_for_default
