function compilerInfo = compilerman(method, varargin)
% STATEFLOW COMPILER MANAGER
% VARARGOUT = COMPILERMAN( METHOD, VARARGIN)

%   Copyright 1995-2009 The MathWorks, Inc.
%
%   $Revision: 1.21.4.27.4.1 $  $Date: 2010/07/06 14:42:59 $

persistent sCompilerInfo

%%% this persistent structure holds all the relevant info.

if isempty(sCompilerInfo)
  sCompilerInfo = unknown_compiler('');
end

if ~ispc
  compilerInfo = sCompilerInfo;
  compilerInfo.mexOptsIgnored = false;
  compilerInfo.mexOptsNotFound = false;
  return;
end

switch(method)
case 'get_compiler_info'
   if(sCompilerInfo.ignoreMexOptsFile==0)
      if(nargin<2)
         mexOptsFile = '';
      else
         mexOptsFile = varargin{1};
      end
      sCompilerInfo = parse_opts_file(sCompilerInfo,mexOptsFile,false);
   end
case 'set_compiler_info'
   if(nargin<2)
      error('Stateflow:UnexpectedError','Usage: compilerman(''set_compiler_info'',customMexOptsFileName)');
   end
   sCompilerInfo = parse_opts_file(sCompilerInfo,varargin{1}, true);
   sCompilerInfo.ignoreMexOptsFile = 1;
case 'reset_compiler_info'
   sCompilerInfo = unknown_compiler('');
end

compilerInfo = sCompilerInfo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compilerInfo = unknown_compiler(compilerName)
compilerInfo.compilerName = compilerName;
compilerInfo.mexOptsFile = '';
compilerInfo.optsFileTimeStamp = 0.0;
compilerInfo.ignoreMexOptsFile = 0;
compilerInfo.mexOptsIgnored = true;
compilerInfo.mexOptsNotFound = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newCompilerInfo = parse_opts_file(cachedCompilerInfo,mexOptsFile,noErrorCheck)

newCompilerInfo = cachedCompilerInfo;

if(isempty(mexOptsFile))
   directoryList = {pwd,prefdir,fullfile(matlabroot,'bin',computer('arch'),'mexopts')};
   
   mexOptsFile = '';
   for i=1:length(directoryList)
      tempOptsFile = fullfile(directoryList{i},'mexopts.bat');
      if(exist(tempOptsFile,'file'))
         mexOptsFile = tempOptsFile;
         break;
      end
   end
end

if isempty(mexOptsFile)
    newCompilerInfo = unknown_compiler('lcc');
    return;
end

newCompilerInfo.mexOptsNotFound = false;
newCompilerInfo.mexOptsFile = mexOptsFile;

if(strcmp(cachedCompilerInfo.mexOptsFile,mexOptsFile) &&...
      check_if_file_is_in_sync(cachedCompilerInfo.mexOptsFile,cachedCompilerInfo.optsFileTimeStamp))
   return;
end

if ispc
    if(~noErrorCheck) 
        try
            cc = mex.getCompilerConfigurations;
            switch cc.Name
                case 'Intel C++'
                    if strcmp(cc.Language,'C++')
                        if strcmp(cc.Version,'9.1')
                            newCompilerInfo.compilerName = 'intelc91msvs2005';
                        elseif strcmp(cc.Version,'11.1')
                            newCompilerInfo.compilerName = 'intelc11msvs2008';
                        end
                        newCompilerInfo.mexOptsIgnored = false;
                        return;
                    end
            end
        catch ME %#ok<NASGU>
            newCompilerInfo = unknown_compiler('lcc');
            return;
        end

        if(~check_if_dir_exists(cc.Location))
            newCompilerInfo = unknown_compiler('lcc');
            return;
        end
    end
    
    %%% parsing of mexopts file is done here
    try
        mexOptsContents = file2str(mexOptsFile);
    catch ME %#ok<NASGU>
        newCompilerInfo = unknown_compiler('lcc');
        return;
    end

    optsFileDirInfo = dir(mexOptsFile);
    newCompilerInfo.optsFileTimeStamp = optsFileDirInfo.datenum;
    mexOptsContents = lower(mexOptsContents);
    
    [success newCompilerInfo.compilerName] = scanOptsContents(mexOptsContents);

    if ~success
        newCompilerInfo = unknown_compiler('lcc');
    else
        newCompilerInfo.mexOptsIgnored = false;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [success compilerName] = scanOptsContents(mexOptsContents)
success = 0;
compilerName = 'lcc';
if ~isempty(regexp(mexOptsContents,'set\s+intel=', 'once'))
    compilerName = 'lcc';
    success = 1;
elseif ~isempty(regexp(mexOptsContents,'msvc', 'once'))
    if ~isempty(regexp(mexOptsContents,'msvc100', 'once'))
        compilerName = 'msvc100';
        success = 1;
    elseif ~isempty(regexp(mexOptsContents,'msvc90', 'once'))
        compilerName = 'msvc90';
        success = 1;
    elseif ~isempty(regexp(mexOptsContents,'msvc80', 'once'))
        compilerName = 'msvc80';
        success = 1;
    elseif ~isempty(regexp(mexOptsContents,'msvc60','once'))
        compilerName = 'msvc60';
        success = 1;
    end
elseif ~isempty(regexp(mexOptsContents,'watcom','once'))
    compilerName = 'watcom';
    success = sanity_check_for_watcom(mexOptsContents);
elseif ~isempty(regexp(mexOptsContents,'bccopts', 'once')) || ~isempty(regexp(mexOptsContents,'borland','once'))
    compilerName = 'borland';
    success = sanity_check_for_borland(mexOptsContents);
elseif ~isempty(regexp(mexOptsContents,'lccopts','once'))
    compilerName = 'lcc';
    success = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function success = sanity_check_mexopts_set_line(mexOptsSetLine)
success = 0;
newLines = find(mexOptsSetLine==10 | mexOptsSetLine==13);
if(isempty(newLines))
   return;
end
dirName = mexOptsSetLine(1:min(newLines)-1);

success = check_if_dir_exists(dirName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function success = check_if_dir_exists(dirName)
success = 0;
% expand ennvironmental vars in string
doAgain = 1;
while(doAgain && ~isempty(dirName))
   [s,e] = regexp(dirName,'%[^%]+%', 'once');
   if(isempty(s))
      doAgain = 0;
   else
      expandedEnvVar = getenv(dirName(s+1:e-1));
      if(isempty(expandedEnvVar))
          success = 0;
          return;
      end
      dirName = [dirName(1:s-1),expandedEnvVar,dirName(e+1:end)];
   end
end
if(isempty(dirName))
   success=0;
   return;
end
if(dirName(1)=='"' && dirName(end)=='"')
   dirName = dirName(2:end-1);
end
if(exist(dirName,'dir'))
   success = 1;
end
return;


%function dirName  = get_compiler_root(mexOptsSetLine)
%dirName  = '';
%newLines = find(mexOptsSetLine==10 | mexOptsSetLine==13);
%if(isempty(newLines))
%   return;
%end
%dirName = mexOptsSetLine(1:min(newLines)-1);


function success = sanity_check_for_watcom(mexOptsContents)
success = 0;
[s,e] = regexp(mexOptsContents,'set[\s]*watcom=','once');
if(~isempty(s))
   success = sanity_check_mexopts_set_line(mexOptsContents(e+1:end));
end

function success = sanity_check_for_borland(mexOptsContents)
success = 0;
[s,e] = regexp(mexOptsContents,'set[\s]*borland=','once');
if(~isempty(s))
   success = sanity_check_mexopts_set_line(mexOptsContents(e+1:end));
end
