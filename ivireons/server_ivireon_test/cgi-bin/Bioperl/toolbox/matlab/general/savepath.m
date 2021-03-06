function notsaved = savepath(outputfile)
%SAVEPATH Save the current MATLAB path in the pathdef.m file.
%   SAVEPATH saves the current MATLABPATH in the pathdef.m
%   which was read on startup.
%
%   SAVEPATH outputFile saves the current MATLABPATH in the
%   specified file.
%
%   SAVEPATH returns:
%     0 if the file was saved successfully
%     1 if the file could not be saved
% 
%   See also PATHDEF, ADDPATH, RMPATH, USERPATH, PATH, PATHTOOL.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $ $Date: 2007/12/14 14:52:04 $

% Assume that things are going well until we learn otherwise.
result = 0;

% Unless the user specifies otherwise, we're going to overwrite the
% pathdef.m file that MATLAB currently sees.
if nargin == 0
    outputfile = which('pathdef.m');
else
    if ~ischar(outputfile)
        if nargout == 1
            notsaved = 1;
        end
        return;
    end
end

% This is a token string that we will look for in the template file.
magic_string = 'PLEASE FILL IN ONE DIRECTORY PER LINE';

templatefile = fullfile(matlabroot, 'toolbox', 'local', 'template', 'pathdef.m');

% Try to read the template file.  If we can't, that's OK, we have a
% backup plan.
fid = fopen(templatefile, 'r');

if fid ~= -1
    template = fread(fid,'*char')';
    fclose(fid);
else
    template = ['function p = pathdef', 10, ...
                '%PATHDEF Search path defaults.', 10, ...
                '%   PATHDEF returns a string that can be used as input to MATLABPATH', 10, ...
                '%   in order to set the path.', 10, 10, ...
                '% DO NOT MODIFY THIS FILE.  IT IS AN AUTOGENERATED FILE.', 10, ...
                '% EDITING MAY CAUSE THE FILE TO BECOME UNREADABLE TO', 10, ...
                '% THE PATHTOOL AND THE INSTALLER.', 10, 10, ...
                'p = [...', 10, ...
                '%%% BEGIN ENTRIES %%%', 10, ...
                magic_string, 10, ...
                '%%% END ENTRIES %%%', 10, ...
                '     ...', 10, ...
                '];', 10, 10, ...
                'p = [userpath,p];', 10];
end

% Find the location of the "magic string" in the file.
magic_index = findstr(template, magic_string);

% Take everything that appears *before* the "magic string" line as
% "firstpart," and everything that appears after that line as
% "lastpart."
% We'll sandwich the path particulars between the two ends.
firstpart = template(1:magic_index-1);
lastpart = template(magic_index + 1:end);

lfs_in_firstpart = find(firstpart == 10, 1, 'last');
firstpart = firstpart(1:lfs_in_firstpart);

lfs_in_lastpart = find(lastpart == 10, 1, 'first');
lastpart = lastpart(lfs_in_lastpart+1:end);

% Read the current path.
thepath = matlabpath;

% First, Break the path down into a cell array of strings, one for
% each entry in the path.  We leave the pathsep on the end of each
% string.  The path might not actually *end* with a pathsep, but if
% not, we add one for consistency's sake.
ps = pathsep;
if thepath(end) ~= ps
    thepath = [thepath ps];
end

% Get the exact form of the entries that we want to create in the
% new pathdef file based on the path.  all_path_lines will be a
% cell array of strings.
all_path_lines_matches = regexp(thepath,['(.[^' ps ']*' ps '?)'],'tokens');
all_path_lines = [all_path_lines_matches{:}]';

% Exclude the value of userworkpath
% from being saved because it is dynamic (per user) and
% automatically placed on the path by userpath.m on startup.
cname = computer;
cnameisunix = ~(strncmp(cname,'PC',2));
try
    workpath = system_dependent('getuserworkfolder');
    if cnameisunix
        workpath = strcat(workpath,':');
    else
        workpath = strcat(workpath,';');
    end
    % exclude case-insensitively from path list that will be saved
    pathmatch = cellfun(@(x) strcmpi(x, workpath), all_path_lines);
    % If userpath is not found, then the user deleted it from the
    % path.
    if ~any(pathmatch) && usejava('swing')
         com.mathworks.services.Prefs.setStringPref('UserWorkFolder', '');
    end
    all_path_lines(pathmatch) = [];
  catch exception %#ok
end

all_path_lines = matlabrootify(all_path_lines);

% Start constructing the contents of the new file.  We start with
% the firstpart.
cont = firstpart;

% Append the paths separated by newline characters
cont = [cont all_path_lines{:}];

% Conclude with the lastpart.
cont = [cont lastpart];

% We have the completed new text of the file, so we try to write it out.
% Return immediately if a directory.
if isdir(outputfile)
    if nargout == 1
        notsaved = 1;
    end
    return;
end
fid = fopen(outputfile, 'w');
reset_permissions_to_read_only = false;
if fid == -1
    % We failed to open the file for writing.  That might be
    % because we don't have write permission for that file.  Let's
    % try to make it read-write.
    if ispc
        success = fileattrib(outputfile, '+w');
    else
        success = fileattrib(outputfile, '+w', 'u');
    end
    if success
        % Last chance.  Can we write to it?  If we fail here, we have
        % no choice but to fail.
        reset_permissions_to_read_only = true;
        fid = fopen(outputfile, 'w');
    end
    if fid == -1
    	result = 1;
        if nargout == 1
            notsaved = result;
        else
            warning('MATLAB:SavePath:PathNotSaved', 'Unable to save path to file ''%s''.',...
                    outputfile);
        end
        
        if reset_permissions_to_read_only
            if ispc
                fileattrib(outputfile, '-w');
            else
                fileattrib(outputfile, '-w', 'u');
            end
            
        end
        return;
    end
end

% Write it out.
count = fprintf(fid,'%s', cont);
if count < length(template)
    result = 1;
end
fclose(fid);

clear pathdef; %make sure that pathdef gets cleared.
if nargout == 1
    notsaved = result;
elseif result == 1
    warning('MATLAB:SavePath:PathNotSaved', 'Unable to save path to file ''%s''.',...
            outputfile);
end

if reset_permissions_to_read_only
    if ispc
        fileattrib(outputfile, '-w');
    else
        fileattrib(outputfile, '-w', 'u');
    end
end

%---------------------------------------------
function dirnames = matlabrootify(dirnamesIn)
% Given a cell array of path entries, this performs two functions: 
% (1) If the path entry under consideration is a subdirectory of
% matlabroot, it encodes that information directly into the string.
% Therefore, even if the location of the MATLAB installation is changed,
% pathdef.m will still point to the appropriate location. 
% (2) Performs additional formatting.

% If we're on PC, we want to do our comparisons in a case-insensitive
% fashion.  Since it also doesn't matter what case the entries are made in,
% we might as well lowercase everything now - no harm done.
if ispc
    mlroot = lower(matlabroot);
    dirnames = lower(dirnamesIn);
else
    mlroot = matlabroot;
    dirnames = dirnamesIn;
end

% Find indices to entries in the MATLAB root. One match must be at the
% start of the entry. Calculate indices to remaining entries, and preserve
% case-sensitivity
mlr_dirs = cellfun(@(x) ismember(1,x),strfind(dirnames,mlroot));
dirnames(~mlr_dirs) = dirnamesIn(~mlr_dirs);

% We'll need to wrap all the entries in strings, so do some quote escaping
dirnames = strrep(dirnames, '''', '''''');

% Replace MATLAB roots with "matlabroot" only at the start of the entry,
% and wrap entires in quotes. Be sure to escape backslash in mlroot since it
% is a metacharacter to regexprep.
dirnames(mlr_dirs) = regexprep(dirnames(mlr_dirs), ...
                            regexptranslate('escape', mlroot), ...
                            '     matlabroot,''','once');
dirnames(~mlr_dirs) = strcat('     ''',dirnames(~mlr_dirs));
dirnames = strcat(dirnames, ''', ...', {char(10)});
