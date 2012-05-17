function targets_generate_help_file(dirs, help_file_path)
% TARGETS_GENERATE_HELP_FILE - Generate an m-file to provide help for 
%                              m-files that are to be p-coded and NOT
%                              shipped, and hence will have no help content
%                              of their own.
%
% targets_generate_help_file(dirs, help_file_path)
%
% dirs: Cell array of directories to find m-files in - note: these
% directories should be on the MATLAB path.
%
% help_file_path: Full path (including .m extension) to the m-file that
% this function will generate.
%

%   Copyright 2005-2006 The MathWorks, Inc.
    
error(nargchk(2, 2, nargin, 'struct'))

help_topics = [];
% process each start dir, filling up 
% the help_topics variable
for i=1:length(dirs)
    startdir = dirs{i};
    i_processDir(startdir);
end

% check uniqueness of help topics
[topics{1:length(help_topics)}] = deal(help_topics.topic);
[paths{1:length(help_topics)}] = deal(help_topics.path);
% add space
disp(' ');
str = '';
dups_list = i_findDuplicates(topics);
for i=1:length(dups_list)
    dups = dups_list{i};
    nl = sprintf('\n');
    str = ['Duplicate help topics:' nl];
    for j=1:length(dups)
        str = [str fullfile(paths{dups(j)}, topics{dups(j)}) nl];
    end
    str = [str nl];
end
% warn
if ~isempty(str)
    warning(strtrim(str));
end

% process help_topics and generate help_file_path
i_processHelpTopics(help_file_path, help_topics);

    %
    % nested recursive function to populate help_topics with a
    % list of m-file help topics
    function i_processDir(currdir)
        d = dir(currdir);
        for i=1:length(d)
            file = d(i);
            if file.isdir
                % recurse into @ dirs, since these will be on the MATLAB path
                % at this level
                switch file.name(1)
                    case {'@'}
                        i_processDir(fullfile(currdir, file.name));
                    otherwise
                        % ignore other dirs
                end
            else
                % see if file is an m-file
                [p name ext] = fileparts(file.name);
                switch ext
                    case '.m'
                        % remove startdir from currdir
                        relpath = fullfile(currdir(length(startdir)+2:end), file.name);
                        % transform package paths into format for help
                        %
                        % turn \'s into .'s
                        relpath = strrep(relpath, '\', '.');
                        % remove @'s
                        relpath = strrep(relpath, '@', '');
                        % remove trailing .m
                        relpath = relpath(1:length(relpath)-2);
                        help_topics(end+1).topic = relpath;
                        help_topics(end).path = startdir;
                    otherwise
                        % ignore non m-files
                end
            end
        end
    end
end

% generate help_file_path from help_topics
function i_processHelpTopics(help_file_path, help_topics)
    % split help_file_path into components
    [help_file_dir help_file_name help_file_ext] = fileparts(help_file_path);
    %
    help_file = [];
    % define a new line character
    nl = sprintf('\n');
    help_file = ['function varargout = ' help_file_name '(helptopic)' nl ...
                 '% ' upper(help_file_name) ' : Get help information ' ...
                 'for a given "helptopic"' nl ...
                 '% ' nl ...
                 '% varargout = ' help_file_name '(helptopic)' nl ...
                 '% ' nl ...
                 '% Input arguments: ' nl ...
                 '% ' nl ...
                 '% helptopic : The help topic to get help for.' nl ...
                 '% ' nl ...
                 '% Return values: ' nl ...
                 '% ' nl ...
                 '% varargout : If an output argument is requested the ' nl ...
                 '%             help topic is returned as varargout{1} and ' nl ...
                 '%             the help is not displayed in the command ' nl ...
                 '%             window.' nl ...
                 '% ' nl ...
                 '%             If no output argument is requested then the ' nl...
                 '%             the help is displayed in the command window.' nl ...
                 '% ' nl ...
                 '% ' nl nl ...
                 '%  Copyright 2005 The MathWorks, Inc.' nl nl ...
                 '% Check output arguments' nl ...
                 'error(nargoutchk(0, 1, nargout, ''struct''));' nl ...
                 '% Check input arguments' nl ...
                 'error(nargchk(1, 1, nargin, ''struct''));' nl ...
                 '% Define new line character ' nl ...
                 'nl = sprintf(''\n'');' nl ...
                 '% Process helptopic ' nl ...
                 'help_str = [];' nl ...
                 'switch(helptopic)' nl];
    
    % get original dir
    orig_dir = pwd;
    
    % generate cases
    for i=1:length(help_topics)
        help_topic = help_topics(i);
        %
        % make sure that we get the help for the 
        % file under the start dir and not some other m-file
        % on the path
        cd(help_topic.path);
        
        % get the help for the current topic
        help_str = help(help_topic.topic);
        % escape 's
        help_str = regexprep(help_str, '''', '''''');
        % replace newlines with newline char and format nicely
        % in generated file
        spacer = ['               '''];
        help_str = regexprep(help_str, '\n', [''' nl \.\.\.\n'...
                                              spacer]);
        % add case for this help topic
        help_file = [help_file 'case ''' help_topic.topic '''' nl ...
                     '   help_str = [''' help_str '''];' nl];
    end
    
    % restore original dir
    cd(orig_dir);
    
    % deal with uknown topics
    help_file = [help_file 'otherwise' nl ...
                 '   TargetCommon.ProductInfo.error(''common'', ''UnknownHelpTopic'', helptopic);' nl ...
                 'end' nl nl ...
                 'if nargout == 0' nl ...
                 '  % display help_str' nl ...
                 '  disp(help_str);' nl ...
                 'else' nl ...
                 '  % return help_str' nl ...
                 '  varargout{1} = help_str;' nl ...
                 'end'];

    % clear any existing help_file from memory
    % before writing it
    clear(help_file_name);             
    
    % delete any existing help file p-code 
    [pcode_path pcode_name] = fileparts(help_file_name);
    pcode_file = fullfile(pcode_path, [pcode_name '.p']);
    delete(pcode_file);
             
    % create the output file
    fid = fopen(help_file_path, 'w');
    fprintf(fid, '%s', help_file);
    fclose(fid);
   
    % call rehash toolbox to make sure 
    % MATLAB knows about the new file
    rehash('toolbox');
    
    % test the help file we generated by 
    % calling it for each help_topic
    for i=1:length(help_topics)
       help_topic = help_topics(i);
       eval(['tmpout = ' help_file_name '(''' help_topic.topic ''');';]); 
    end
end

% helper function to detect string duplicates in a MATLAB cell array
function dups_list = i_findDuplicates(stringarray)
    dups_list = {};
    unique_strings = unique(stringarray);
    % check for duplicates of each unique entry
    for i=1:length(unique_strings)
       % find dups
       matches = strcmp(unique_strings{i}, stringarray);
       % get indices
       matchindices = find(matches);
       if length(matchindices) > 1
           dups_list{end+1} = matchindices;
       end
    end
end
