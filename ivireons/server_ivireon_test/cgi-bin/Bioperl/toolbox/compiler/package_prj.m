function output = package_prj(outputname, files, rootDir, textProgress)
% PACKAGE_PRJ Packages Deployment project
%    
%    This function will package the specified files into a zip 
%    archive specified by the outputname. On Windows, the archive
%    will be a self-extracting executable.
%
%    The meaning of each input is as follows:
%
%     1) OUTPUTNAME is the name of the final package that is created.
%        On Windows, if the extension of the name specified for 
%        the output name is missing or is not exe, it is changed to 
%        exe since a self extracting executable is created on this
%        platform.
%
%     2) FILES is a cell array of all the files that need to be packaged.
%        Note that on Windows platform, the first file that is specified
%        in the list will be executed when the self extracting executable
%        is run. If relative paths are used for filenames, they will be 
%        resolved as per the rules described below.
%
%     3) ROOTDIR is optional. This variable along with the list of files 
%        is passed to the MATLAB ZIP function as is. Look up the 
%        documentation for ZIP for more information on ROOTDIR.
%
%     4) TEXTPROGRESS is optional. This is a boolean value that controls 
%        how the progress is reported. If true, the output is displayed 
%        at the command prompt. If false, the output is displayed in
%        in a pop-up dialog. Default is false.
%
%    If the file names in the second argument are specified as relative
%    paths, they are resolved as follows:
%    
%      1) If ROOTDIR is specified, the files are searched for with respect
%         to this directory.
%
%      2) If ROOTDIR is not specified and the OUTPUTNAME contains is a
%         relative or absolute path to a file, then the files will be
%         searched relative to the parent directory of the OUTPUTNAME.
%
%      3) If ROOTDIR is not specified and the OUTPUTNAME is not a relative
%         or absolute files, all files specified in the second argument will
%         be searched for in the current working directory.
%
%    Note that MATLAB path is not used to look up the files.
%
%    This function is currently only called from the DEPLOYTOOL gui.
%
% See also: DEPLOYTOOL, ZIP


error(nargchk(2,4,nargin, 'struct'));

global mwWaitFig;
global mwCurrentDir;

mwCurrentDir = pwd;
[pathstr, name, ext] = fileparts(outputname);
if ~ispc || strcmpi(ext, '.zip')
    generateExe = false;
elseif ispc
    if ~strcmpi(ext, '.exe')
      ext = '.exe';
    end
    generateExe = true;
end

if ( isempty(pathstr) )
    pathstr = pwd;
end

zipfilename = [name,'.zip'];
output = [name,ext];

if( nargin < 4)
    textProgress = false;
end
if( nargin < 3)
    rootDir = '.';
end

try
    if( pathstr )
        cd(pathstr);
    end
catch ME
    error('Compiler:PACKAGE_PRJ:CDerror',...
        ['Could not CD to the output directory %s. One possible reason is ',...
        'that you have a relative directory specified for the output directory ',...
        'in the project settings and you have changed your current working ',...
        'directory in MATLAB. This makes the relative path for the output ',...
        'directory invalid. To resolve this issue, either CD to the directory ',...
        'where the deployment project resides or specify an absolute directory ',...
        'path for the output directory settings for the project. You can get ',...
        'to this setting by clicking on Project > Settings..., and then selecting ',...
        'the General node on the left hand side. The right hand side panel will ',....
        'show the settings for the output directory.\n'], pathstr);
end

progressMessage = sprintf('Packaging component for distribution...'); 
if( ~textProgress )
    mwWaitFig = waitbar(0.1,'Packaging component for distribution', 'WindowStyle', 'modal');
    set(mwWaitFig, 'name', progressMessage);
end

% Create the zip archive
try
    if (strcmp(computer,'MACI64'))
        %
        % Have to resort to mac's zip so that
        % symbolic links are not chased (the MacOS bundle directory
        % is currently a symbolic link).  Matlab's zip which uses java zip
        % is not 'symbolic' link aware.
        %
        if( ~exist(rootDir, 'dir') )
            error('The root directory specified (%s), does not exist', rootDir);
        end
        
        % Create a temporary directory.
        % Copy all the files/dirs there
        % Create an archive in the temp dir
        % move it to the required location.
        tdir = tempname;
        mkdir(tdir);
        
        zipcmd = ['zip -ryMM ' zipfilename];
        for indx=1:length(files)
            system(['cp -RH ', files{indx},' ',tdir]);
            [~, fname, fext, fver] = fileparts(files{indx});
            zipcmd = [zipcmd  ' ' fname,fext,fver];
            progressMessage = sprintf('Adding %s to the package.', char(files(indx)));
            if(textProgress)
                disp(progressMessage);
            else
                waitbar(0.25*indx/length(files), mwWaitFig, progressMessage);
            end
        end
        pwd_restore_val = pwd;
        cd(tdir);
        [result,cmdoutput] = system(zipcmd);
        movefile(zipfilename, pathstr,'f');
        cd(pwd_restore_val);
        rmdir(tdir,'s');
        if result~=0
            error('Compiler:PACKAGE_PRJ:ErrorUsingZIP',cmdoutput);
        end
    else
        for indx=1:length(files)
            progressMessage = sprintf('Adding %s to the package.', char(files(indx)));
            if(textProgress)
                disp(progressMessage);
            else
                waitbar(0.25*indx/length(files), mwWaitFig, progressMessage);
            end
        end
        zip(zipfilename, files, rootDir);
    end
    progressMessage = sprintf('Created zip archive');
    if( ~textProgress )
        waitbar(0.5, mwWaitFig, progressMessage);
    end
catch ex
    cleanup(textProgress);
    error('Compiler:PACKAGE_PRJ:ErrorUsingZIP',...
          ['Failed to create zip archive with the following error. ',...
          'Resolve this error and restart packaging process.\n\n%s'],...
          ex.getReport);
end

% If it is not Windows platform, then we are done.
% Currently we only create self extracting executable for Windows platform.
if( ~generateExe )
    if ~strcmp(output, zipfilename)
        movefile(zipfilename, output);
    end
    output = fullfile(pathstr,zipfilename);
    cleanup(textProgress);
    return;
end


%Turn zip file into self extracting executable for Windows platforms.

cpcommand = 'copy /b ';
mwunzipLoc = fullfile(matlabroot,'extern','lib', lower(computer('arch')),'mwunzipsfx.exe');

%Make binary copy of file prepending unzip utility
if exist(output, 'file')
  delete(output);
end
cmd = [cpcommand ' "' mwunzipLoc '"+"',zipfilename,'" "',output,'"'];
[s,msg] = compilerDos(cmd);
if s
    cleanup(textProgress);
    error('Compiler:PACKAGE_PRJ:ErrorCopyingUnzipSFX',...
          ['The following error occurred when creating the self ',...
           'extracting zip archive. Resolve this error and restart ',...
           'the packaging process.\n\n%s'], msg);
end

progressMessage = sprintf('Creating self-extracting executable...');
if( ~textProgress )
    waitbar(.75,mwWaitFig,progressMessage);
end

%Turn zip file in executable
cmd = ['zip -A "',output,'"'];
[s,msg] = compilerDos(cmd);
if s
    cleanup(textProgress);
    error('Compiler:PACKAGE_PRJ:ErrorCreatingSelfExtractingZIP',...
          ['The following error occurred when creating the self ',...
           'extracting zip archive. Resolve this error and restart ',...
           'the packaging process.\n\n%s'], msg);
end

progressMessage = sprintf('Removing work files...');
if( ~textProgress )
    waitbar(.85,mwWaitFig,progressMessage);
end

%Now that we have an exe, delete the original zip.
if exist(zipfilename, 'file')
    cmd = ['del "',zipfilename,'"'];
    [s,msg] = compilerDos(cmd);
    if s
        cleanup(textProgress);
        error('Compiler:PACKAGE_PRJ:ErrorCreatingSelfExtractingZIP',...
          ['The following error occurred when creating the self ',...
           'extracting zip archive. Resolve this error and restart ',...
           'the packaging process.\n\n%s'], msg);
    end
end

cd(mwCurrentDir);
%Show success and close waitbar
if( ~textProgress)
    waitbar(1,mwWaitFig,'Done.');
end
close(mwWaitFig);
clear global mwCurrentDir;
clear global mwWaitFig;
output = fullfile(pathstr, output);
end


function cleanup(textProgress)
global mwWaitFig;
global mwCurrentDir;
if( ~textProgress )
    close(mwWaitFig);
end
cd(mwCurrentDir);
clear global mwCurrentDir;
clear global mwWaitFig;
end
