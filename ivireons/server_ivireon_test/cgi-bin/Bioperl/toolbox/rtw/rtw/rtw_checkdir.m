function rtw_checkdir
%RTW_CHECKDIR check if Real-Time Workshop can build in to current directory
%
%  This routine will error out if the dos() command doesn't work or
%  if the current directory is an invalid location for a Real-Time Workshop
%  build.
%
%  1) On Windows PCs, 
%     This file checks to see that the MATLAB 'dos' command is functional.
%     MATLAB does not support banging out and running an executable, when in a 
%     UNC directory (e.g. directory starting with "\\"). 
%     This file also checks to see if you are in a UNC directory.
%  
%  2) To avoid corruption of MATLAB directories under the MATLAB path, this
%     function checks to see if you are working in a protected directory 
%     under MATLABROOT.
%
%  3) Validate that current directory is not a Real-Time Workshop project
%     (build) directory.
%
  
%   Copyright 1994-2008 The MathWorks, Inc.
%   $Revision: 1.8.2.13 $  
  
  % Check to see if 'dos' command is functional
  if ispc 
    CheckIfDosCommandOkay;
  end
  
  % Check to see if current directory is not in one of the protected directories
  valid_rtwdir = CheckValidDir;
  if (valid_rtwdir == 0)
      DAStudio.error('RTW:buildProcess:buildDirInMatlabDir',pwd);
  end

  % Check to see if current directory is a project directory
  ErrorIfInProjDir(pwd);
  ErrorIfInSlprjDir;
%endfunction rtw_checkdir


% Function: CheckValidDir ======================================================
% Abstract:
%     On all platforms, this excludes any directory under
%     matlabroot, unless you are in matlabroot\work (PC) or tempdir.
%
function valid_rtwdir = CheckValidDir
   
  %---------------------------------------------------------------------%
  % Start with the assumption that you are in a valid working directory.%
  %---------------------------------------------------------------------%
  valid_rtwdir = 1;
  isValid_matlabtree_dir = 1;
  current_dir = pwd;
  len_current_dir = size(current_dir, 2);
  mlroot_dir  = matlabroot; 
  len_mlroot_dir = size(mlroot_dir, 2);

  if (ispc)
    % Use lower(matlabroot) on PC's because DOS can't discriminate between
    % upper and lower case file names
    current_dir = lower(pwd);
    mlroot_dir  = lower(matlabroot); 
  end
  
  %---------------------------------------------------------------------------%
  % To avoid corruption of critical MATLAB directories, check to see that     %
  % the current working directory is not one of the protected dirctories in   %
  % the MATLAB tree.                                                          %
  %---------------------------------------------------------------------------%
  if len_current_dir > len_mlroot_dir
    if strncmp(current_dir, mlroot_dir, len_mlroot_dir)
      if ((strncmp(current_dir, fullfile(mlroot_dir,'bin'),      len_mlroot_dir+4)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'etc'),      len_mlroot_dir+4)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'rtw'),      len_mlroot_dir+4)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'help'),     len_mlroot_dir+5)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'extern'),   len_mlroot_dir+7)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'toolbox'),  len_mlroot_dir+8)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'simulink'), len_mlroot_dir+9)) || ...
          (strncmp(current_dir, fullfile(mlroot_dir,'stateflow'),len_mlroot_dir+10)))
      
          isValid_matlabtree_dir = 0;
      end
    end
  end
  
  %---------------------------------------------------------------------------%
  % If a problem exists with the current directory, describe via an error msg %
  %---------------------------------------------------------------------------%
  %
  if ~isValid_matlabtree_dir
      valid_rtwdir = 0;
  end
%endfunction CheckValidDir


% Function CheckIfDosCommandOkay ============================================
% Abstract: 
%   On Windows PC, Verify that we can use dos('syscmd'). 
%   
function CheckIfDosCommandOkay
    if ~isunix
        try
            dosOutput = evalc('dos(''cd'')');
            if isempty(dosOutput)
                DAStudio.error('RTW:buildProcess:dosCmdNotFunctional',pwd);
            end
        catch exc
            cr = sprintf('\n'); 
            DAStudio.error('RTW:buildProcess:dosCmdErrInfo',...
                           strrep(exc.message,cr,[cr,'  ']));
        end
    end

%endfunction CheckIfDosCommandOkay


% Function: ErrorIfInProjDir ===================================================
% Abstract:
%   Issue an error if cwd is a Real-Time Workshop project directory, i.e.,
%   rtw_proj.tmw exists.
%
function ErrorIfInProjDir(cur_dir,cur_depth)

  rtwProjFile  = fullfile(cur_dir,'rtw_proj.tmw');
  if exist(rtwProjFile, 'file')
      fid = fopen(rtwProjFile,'rt');
      if fid == -1
          return; % definitely not in a project directory.
      end
      fline = fgetl(fid);
      fclose(fid);
      %
      % Prior to version 4.0, the
      %  rtw_proj.tmw file looked like: 
      %      'Current RTW Project: ...'
      % with we changed the starting characters to be
      %      'Real-Time Workshop project for: ...'
      % (because we now have project directories).
      %
      if strncmp(fline,'Current RTW Project',19)
          return; % not in project directory (pre 4.0 build)
      end
      DAStudio.error('RTW:buildProcess:buildDirInRTWProjDir',pwd);
   end
 
  % the first caller doesn't pass in a depth, but the recursive call needs it
  % to cap out the max depth allowed.  We could force the original caller
  % to always pass in a 0, but it just adds noise.
  if (nargin == 1)
    cur_depth = 0;
  end
  
  fslist = find(cur_dir == filesep);
  
  % The Current RTW proj dir only goes 1 level deep, however, we can look up
  % the stack 3 more levels, to allow for future expansion.
  if ((cur_depth < 3) && (length(fslist) > 1))
      ErrorIfInProjDir(cur_dir(1:fslist(end)-1),cur_depth+1);
  end
  
%endfunction ErrorIfInProjDir

% Function: ErrorIfInSlprjDir ==================================================
% Abstract:
%   Detect whether we are in project build directory, which follows pattern
% such as slprj/build/<model>/sl/sim/src/core
function ErrorIfInSlprjDir
currentdir = pwd;
slprjIdx = strfind(currentdir, 'slprj');
if ~isempty(slprjIdx)
    slProjFile = fullfile(currentdir(1:slprjIdx+length('slrpj')-1), 'sl_proj.tmw');
    if exist(slProjFile,'file')
        DAStudio.error('RTW:buildProcess:buildDirInSlprjDir',pwd);
    end
end
%endfunction ErrorIfInSlprjDir

% [EOF] rtw_checkdir.m
