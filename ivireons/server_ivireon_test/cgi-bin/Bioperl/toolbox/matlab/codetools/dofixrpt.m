function htmlOut = dofixrpt(name, option)
%DOFIXRPT  Audit a file or folder for all TODO, FIXME, or NOTE messages
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   DOFIXRPT(FILENAME,'file') scans the MATLAB file FILENAME.
%
%   DOFIXRPT(DIRNAME) or DOFIXRPT(DIRNAME,'dir') scans the specified
%   folder. IF DIRNAME is not specified, scans the current folder.
%
%   HTMLOUT = DOFIXRPT(...) returns the generated HTML text as a cell array
%
%   See also PROFILE, MLINTRPT, DEPRPT, CONTENTSRPT, COVERAGERPT, HELPRPT. 

% Copyright 1984-2010 The MathWorks, Inc.

reportName = sprintf('TODO/FIXME Report');

%% Start the web browser.
if nargout == 0
    internal.matlab.codetools.reports.displayLoadingMessage(reportName);
end

%% Are we reporting on a single file or a folder?
if nargin < 1
    name = cd;
end

if nargin < 2
    option = 'dir';
end

%% Validate the input
if strcmpi(option,'dir')
    if isdir(name) %check for valid folder
        dirname = name; %get the files in that dir
        dirFileList = dir([name filesep '*.m']);
        fileList = {dirFileList.name};
    else
        internal.matlab.codetools.reports.webError(sprintf('%s is not a folder',name), reportName);
        return
    end
elseif strcmpi(option,'file')
    [dirname,fname] = fileparts(name);
    if isempty(dirname),dirname = cd; end %in case the file is in the current folder
    name = fullfile(dirname,[fname '.m']);
    if exist(name,'file') %make sure the file is valid
        fileList = {[fname '.m']};
    else
        internal.matlab.codetools.reports.webError(sprintf('file %s not found',name), reportName);
        return
    end
else % user has to specify either 'file' or 'dir'
    internal.matlab.codetools.reports.webError(sprintf('%s is an invalid option, must specify ''dir'' or ''file''', option), reportName);
    return
end

%% Set the options
todoDisplayMode = getpref('dirtools','todoDisplayMode',1);
fixmeDisplayMode = getpref('dirtools','fixmeDisplayMode',1);
regexpDisplayMode = getpref('dirtools','regexpDisplayMode',1);
regexpText = getpref('dirtools','regexpText', sprintf('NOTE'));

%% Gather all of the data
if isempty(fileList)
    %Empty fileList means the report was run on an empty folder.
    strc = [];
else
    strc(length(fileList)).filename = '';
end
for n = 1:length(fileList)
    filename = fileList{n};
    file = getmcode([dirname filesep filename]);
    strc(n).filename = filename; %#ok<*AGROW>
    strc(n).linenumber = [];
    strc(n).linecode = {};

    for m = 1:length(file),
        if ~isempty(file{m}),

            showLine = 0;
            if todoDisplayMode
                if ~isempty(regexpi(file{m},'%.*TODO'))
                    showLine = 1;
                end
            end

            if fixmeDisplayMode
                if ~isempty(regexpi(file{m},'%.*FIXME'))
                    showLine = 1;
                end
            end

            if regexpDisplayMode
                if ~isempty(regexpi(file{m},['%.*' regexpText], 'once'))
                    showLine = 1;
                end
            end

            if showLine
                ln = file{m};
                ln = regexprep(ln,'^\s*%\s*','');
                strc(n).linenumber(end+1) = m;
                strc(n).linecode{end+1} = ln;
            end
        end
    end
    
end

help = sprintf('The TODO/FIXME Report shows MATLAB files that contain the text strings selected below ');
docPage = 'matlab_env_todo_rpt';
thisDirAction = 'dofixrpt';
rerunAction = sprintf('dofixrpt(''%s'',''%s'')', name, option);

% Now generate the HTML
s = internal.matlab.codetools.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);

s{end+1} = '<form method="post" action="matlab:internal.matlab.codetools.reports.handleForm">';
s{end+1} = '<input type="hidden" name="reporttype" value="dofixrpt" />';
s{end+1} = '<table cellspacing="8">';
s{end+1} = '<tr>';

checkOptions = {'','checked'};

s{end+1} = sprintf('<td><input type="checkbox" name="todoDisplayMode" %s onChange="this.form.submit()" />TODO</td>', ...
    checkOptions{todoDisplayMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="fixmeDisplayMode" %s onChange="this.form.submit()" />FIXME</td>', ...
    checkOptions{fixmeDisplayMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="regexpDisplayMode" %s onChange="this.form.submit()" />', ...
    checkOptions{regexpDisplayMode+1});

s{end+1} = sprintf('<input type="text" name="regexpText" id="regexpText" size="20" value="%s" onblur="setRegexpPref(this.value)" /></td>', ...
    char(org.apache.commons.lang.StringEscapeUtils.escapeHtml(regexpText)));

s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '</form>';

s{end+1} = sprintf('Report for folder %s<p>',dirname);

s{end+1} = sprintf('<strong>MATLAB File List</strong><br/>');

% Make sure there is something to show before you build the table
if ~isempty(strc)
    s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
    % Loop over all the files in the structure
    for n = 1:length(strc)
        s{end+1} = sprintf('<tr><td valign="top" class="td-linetop"><a href="matlab: edit(urldecode(''%s''))"><span class="mono">%s</span></a></td>', ...
            urlencode(fullfile(dirname,strc(n).filename)), strrep(strc(n).filename,'.m','')); %#ok<AGROW>
        s{end+1} = '<td class="td-linetopleft">'; %#ok<AGROW>
        if ~isempty(strc(n).linenumber)
            for m = 1:length(strc(n).linenumber)
                s{end+1} = sprintf('<span class="mono"><a href="matlab: opentoline(urldecode(''%s''),%d)">%d</a> %s</span><br/>', ...
                    urlencode(fullfile(dirname,strc(n).filename)), strc(n).linenumber(m), ...
                    strc(n).linenumber(m), code2html(strc(n).linecode{m})); %#ok<AGROW>
            end
        end
        s{end+1} = '</td></tr>'; %#ok<AGROW>
    end
    s{end+1} = '</table>';
end

s{end+1} = '<!-- DOFIX REPORT END -->';
s{end+1} = '</body></html>';


if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = [s{:}];
end
