% File: run_rtwdemo_shrlib_app.m 
% Abstract:
%     Script to compile/link/execute example files for rtwdemo_shrlib.mdl
%
% Usage: 
%     It is recommended to creat a new directory before running this
% script. 
%
% Note: 
%     If the model name or application name is modified, be sure to change 
% them in this file accordingly to have a successful build. 
% 
% Requirements:
%     Requires lcc on Win32 platform; requires VC8.0 professional edition 
% on Win64 platform; requires cc on Sol64 platform; requires gcc on other 
% Unix based platforms.
% 
% Copyright 2006-2009 The MathWorks, Inc.
%
% $Revision: 1.1.8.4 $  $Date: 2009/03/30 23:47:00 $

disp(' ');
disp(' === Demo usage of ERT Shared Library Target ===');
model = 'rtwdemo_shrlib';
appName = 'rtwdemo_shrlib_app';
appH = [appName '.h'];
appC = [appName '.c'];

if(~exist(fullfile('.',appH), 'file')||~exist(fullfile('.',appC), 'file'))
    disp(' ');
    disp('### Example application files not found under current directory.'); 
    disp('### Copying from install directory ... ');
    
    copyfile(fullfile((matlabroot), 'toolbox', 'rtw', 'rtwdemos', 'shrlib_demo',appH));
    copyfile(fullfile((matlabroot), 'toolbox', 'rtw', 'rtwdemos', 'shrlib_demo',appC));
    
    disp('### Done.');
end

cmdExec = ['.' filesep appName];

load_system(model);
disp(' ');
disp(' === Parameter List === ');
disp(' ');
disp(['LIMIT: ' num2str(LIMIT) '; INC: ' num2str(INC) '; RESET: ' ...
    num2str(RESET) '; K: ' num2str(K)]);
open_system(model);
set_param(model, 'TemplateMakefile', 'ert_default_tmf');
switch ert_default_tmf
    case 'ert_lcc.tmf'
        def_underscore = '-DLCCDLL ';
    case 'ert_bc.tmf'
        def_underscore = '-DBORLANDCDLL ';
    otherwise
        def_underscore = '';
end
if ~isempty(def_underscore)
    disp(' ');
    disp('### Attention: Symbols in the generated DLL contain leading underscores.');
end

% load model and rebuild the target.
disp(' ');
disp([' === Build ' model ' ===']);
disp(' ');
rtwbuild(model);

% assemble command strings according to platform selection.
switch (computer)
  case {'PCWIN'}
    cmdComp = ['"' (matlabroot) '\sys\lcc\bin\lcc" -I' '"' (matlabroot) ...
               '\sys\lcc\include" -I.\' model '_ert_shrlib_rtw ' def_underscore ' -noregistrylookup ' appC];
    cmdLink = ['"' (matlabroot) '\sys\lcc\bin\lcclnk" -L' '"' (matlabroot) '\sys\lcc\lib" ' ...
               appName '.obj -o ' appName '.exe'];
    
  case {'PCWIN64'}
    VStoolDir = getenv('VS80COMNTOOLS');
    if isempty(VStoolDir)
        error(['Environment variable VS80COMNTOOLS is not defined. Running this sript on Win64' ...
               ' platform requires the install of VC 8.0 and definition of VS80COMNTOOLS.']);
    end
    VCdir = RTW.reduceRelativePath(fullfile(VStoolDir,'..','..','VC'));
    envSet = ['call "' VCdir '\vcvarsall" amd64'];
    cmdComp = ['cl -c -I ' model '_ert_shrlib_rtw ' appC];
    cmdLink = ['link ' appName '.obj -out:' appName '.exe' ];
    
    fid = fopen([appName '_batch.bat'],'w');
    fprintf(fid, '%s\n', envSet);
    fprintf(fid, '%s\n', cmdComp);
    fprintf(fid, '%s\n', cmdLink);
    fclose(fid);
    
  case {'GLNX86','GLNXA64'}
    cmdComp = ['gcc -c -I./' model '_ert_shrlib_rtw ' appC];
    cmdLink = ['gcc -o ' appName ' ' appName '.o -ldl'];
    
  case {'MAC', 'MACI'}
    cmdComp = ['gcc -c -I./' model '_ert_shrlib_rtw ' appC];
    cmdLink = ['gcc -o '  appName ' ' appName '.o'];
    
  case {'MACI64'}
    cmdComp = ['gcc -arch x86_64 -c -I./' model '_ert_shrlib_rtw ' appC];
    cmdLink = ['gcc -arch x86_64 -o '  appName ' ' appName '.o'];
    
  case {'SOL64'} 
    cmdComp = ['cc -xarch=v9a -c -I./' model '_ert_shrlib_rtw ' appC];
    cmdLink = ['cc -xarch=v9a -o ' appName ' ' appName '.o -ldl' ];
    
  otherwise
    error(['This script is not designed to run on this platform. You can either ' ...
           'modify this script or build the example application manually.']);
end

if ~strcmp(computer, 'PCWIN64')
    % run compiler/linker scripts
    disp('### Compiling example application ...');
    disp(cmdComp);
    system(cmdComp);
    
    disp('### Linking example application ...');
    disp(cmdLink);
    system(cmdLink);
    
else
    %run batch file to setup env and compile/link on win64
    disp(['### Calling ' appName '_batch.bat']);
    system([appName '_batch']);
end

if (isunix && ~exist(['./' appName], 'file')) || ...
        (ispc && ~exist([appName '.exe'], 'file'))
    error('No executable is found.');
else
    % run the application executable
    disp(' ');
    disp(' === Execute example application ===');
    disp(' ');
    system(cmdExec);
end

disp(' ');
disp(' === End of Demo ===');
disp(' ');
% [EOF]
