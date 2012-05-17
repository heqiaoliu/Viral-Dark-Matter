function result = eml_template_man(method,libName,fcnName,dominantTypeName)

% Copyright 2003-2008 The MathWorks, Inc.

if nargin == 3
    dominantTypeName = '.';
end

switch(method)
   case 'lib_dir'
      result = eml_lib_dir(libName);
   case 'lib_dirs'
      result = eml_lib_dirs(libName);
   case 'get_support_fcn_list'
      emlLibDir = eml_lib_dir(libName);
      templateSupportFcnListFile  = fullfile(emlLibDir,'template_support_fcn_list.h');
      if(exist(templateSupportFcnListFile,'file'))
         fp = fopen(templateSupportFcnListFile,'r');
         F = fread(fp);
         result = char(F');
         fclose(fp);
      else
         result = [];
      end
   case 'get_list'
      emlLibDirs = eml_lib_dirs(libName);
      result = {};
      for i = 1:length(emlLibDirs)
          dir = emlLibDirs{i};
          r = script_names_in(dir, eml_lib_dir(libName));
          result = [result r];
      end
   case 'get_script'
      fSlashIndex = strfind(fcnName,'\');
      bSlashIndex = strfind(fcnName,'/');
      if ~isempty(fSlashIndex) || ~isempty(bSlashIndex)
          if ~isempty(fSlashIndex)
              slashIndex = fSlashIndex(end);
          else
              slashIndex = bSlashIndex(end);
          end
          typeName0 = fcnName(1:slashIndex-1);
          fcnName0 = fcnName(slashIndex+1:end);
          if typeName0(1) == '@'
              fcnName = fcnName0;
              dominantTypeName = dir_name_to_type(typeName0);
          end
      end
      emlLibDir = eml_lib_dir(libName);
      emlLibDominantTypeDir = eml_lib_dir(libName,dominantTypeName);
      scriptInfo.script = '';
      scriptInfo.checksum = [0 0 0 0];

      scriptFile = fullfile(emlLibDominantTypeDir,[fcnName,'.m']);
      scriptInfo.filepath = scriptFile;
      if(~exist(scriptFile,'file'))
         scriptFile = fullfile(emlLibDir,[fcnName,'.m']);
         scriptInfo.filepath = scriptFile;
         if(~exist(scriptFile,'file'))
             % EML:TODO: Please remove this logic whenever the @double
             % directoy for lib/matlab has been removed.
             scriptFile = fullfile(emlLibDir,'@double',[fcnName,'.m']);
             if(~exist(scriptFile,'file'))
                % Return empty if the request script doesn't exist.
                 result = [];
                 return;
             end
         end
      end
      fp = fopen(scriptFile,'rt');
      F = fread(fp);
      F = char(F');
      fclose(fp);
      scriptInfo.script = F;

      %for authentication
      matFile = fullfile(matlabroot,'toolbox','eml','lib',libName,[fcnName,'.mat']);
      if(exist(matFile,'file'))
         load(matFile);
         scriptInfo.checksum = templateChecksum;
      end
      result = scriptInfo;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function libDir = eml_lib_dir(libName,dominantType)

if nargin == 1 || (nargin == 2 && strcmp(dominantType,'.'))
    libDir = fullfile(matlabroot,'toolbox','eml','lib',libName);
else
    libDir = fullfile(matlabroot,'toolbox','eml','lib',libName,type_to_dir_name(dominantType));
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dirs = eml_lib_dirs(libName)
d = eml_lib_dir(libName);
dirs = eml_lib_dirs0(d);

function dirs = eml_lib_dirs0(d)
dirs = {d};
subFiles = dir(d);
for i = 1:length(subFiles)
    if subFiles(i).isdir
        name = subFiles(i).name;
        if ~isempty(name) && name(1) == '@'
            subD = fullfile(d,subFiles(i).name);
            dirs = [dirs eml_lib_dirs0(subD)];
        end
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dir = type_to_dir_name(type)
    dir = '@';
    for i = 1:length(type)
        if type(i) == '.'
            dir = [dir filesep '@'];
        else
            dir = [dir type(i)];
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function type = dir_name_to_type(dir)
    type = '';
    n = length(dir);
    start = 1;
    if n > 0 && dir(1) == '@'
        start = 2;
    end
    skipNext = false;
    for i = start:n
        if ~skipNext
            if (dir(i) == '\' || dir(i) == '/') && (i+1 < n) && dir(i+1) == '@'
                type = [type '.'];
                skipNext = true;
            else
                type = [type dir(i)];
            end
        else
            skipNext = false;
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = script_names_in(emlLibDir, rootDir) 
      if rootDir(end) ~= filesep
          rootDir = [rootDir filesep];
      end
      emlLibDir0 = emlLibDir;
      if emlLibDir0(end) ~= filesep
          emlLibDir0 = [emlLibDir0 filesep];
      end
      rootDirLen = length(rootDir);
      if(~exist(emlLibDir,'dir'))
         result = {};
         return;
      end
      emlScriptList = dir(fullfile(emlLibDir,'*.m'));
      if(~isempty(emlScriptList))
         scriptNames = {emlScriptList.name};
         r = 1;
         result = {};
         for i=1:length(scriptNames)
            [pathStr,fileName] = fileparts(scriptNames{i});
            if strncmp(rootDir,emlLibDir0,rootDirLen)
                parent = emlLibDir(rootDirLen+1:end);
                if ~isempty(parent)
                    name = [emlLibDir(rootDirLen+1:end) filesep fileName];
                else
                    name = fileName;
                end
                result{r} = name;
                r = r + 1;
            end
         end
      else
         result = {};
      end
