function modules = rtwsfcn_modules(projectDir, sfName)
%RTWSFCN_MODULES - Helper MATLAB function used by RTW S-function target
%   Returns list of include modules for the RTW S-function module include.
%   See sfcnmoduleinc.tlc

%       Copyright 1994-2010 The MathWorks, Inc.
%       $Revision: 1.6.2.13 $

cr = sprintf('\n');
cfiles = dir([projectDir,filesep,'*.c']);
cppfiles = dir([projectDir,filesep,'*.cpp']);

allfiles =[cfiles; cppfiles];
[aDummyPath projectDir] = fileparts(projectDir);

modules = '';
includeStart = '#include "';
for fileIdx=1:length(allfiles)
    addFile = true; % assume
    
    file = [projectDir, filesep, allfiles(fileIdx).name];
    fid  = fopen(file,'rt');
    if fid == -1,
        DAStudio.error('RTW:utility:fileIOError',file,'open');
    end
    
    line = fgetl(fid);
    if ischar(line) && ~isempty(findstr('target specific file',line))
        addFile = false;
    end
    
    fseek(fid, 0, 'bof'); % reposition to the beginning of the file
    fulltext = fscanf(fid, '%c');
    if ischar(fulltext) && isempty(regexp(fulltext, ['#include\s+"' sfName '_private.h"'], 'once' ))
        addFile = false;
    end

    fclose(fid);
    if addFile
        modules = [modules,includeStart,file,'"',cr]; %#ok<AGROW>
    end
end

% EOF
