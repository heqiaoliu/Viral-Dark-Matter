function htmlOut = mlintrpt(name,option,config)
%MLINTRPT Run mlint for file or folder, reporting results in browser
%   MLINTRPT scans all MATLAB files in the current folder for messages.
%   MLINTRPT(FILENAME) scans the MATLAB file FILENAME for messages as does the
%   command MLINTRPT(FILENAME,'file')
%   MLINTRPT(DIRNAME,'dir') scans the specified folder.
%   MLINTRPT(...,CONFIG) uses the given configuration file. 
%
%   See also MLINT.

%   Copyright 1984-2010 The MathWorks, Inc.

reportName = sprintf('Code Analyzer Report');

if nargout == 0
    internal.matlab.codetools.reports.displayLoadingMessage(reportName);
end

if nargin < 1
    option = 'dir';
    name = cd;
end

if nargin == 1
    option = 'file';
end

configSpecified = (nargin > 2) && ~isempty(config);

mlintOptions = {'-struct'};
if configSpecified
    mlintOptions{end+1} = ['-config=' config];
end

if strcmp(option,'dir')
    mlintOptions{end+1} = '-fullpath';
    dirname = name;
    if isdir(dirname)
        dirFileList = dir([dirname filesep '*.m']);
        fileList = {dirFileList.name};
    else
        internal.matlab.codetools.reports.webError(sprintf('%s is not a folder.', dirname), reportName);
        return
    end
    if ~isempty(fileList)
        localFilenames = strcat(dirname,filesep,fileList);
    else
        localFilenames = {};
    end
    mlintMsgs = mlint(localFilenames,mlintOptions{:});
else
    % Get the data
    [mlintMsgs,localFilenames] = mlint({name},mlintOptions{:});
    fullname = localFilenames{1};
    if isempty(fullname)
        internal.matlab.codetools.reports.webError(sprintf('File %s not found.',name), title);
        return
    end
    fileList = {name};
end

% Gather all the data into a structure
strc = [];
for i = 1:length(mlintMsgs)

    strc(i).filename = fileList{i}; %#ok<AGROW>
    strc(i).fullfilename = localFilenames{i}; %#ok<AGROW>

    strc(i).linenumber = []; %#ok<AGROW>
    strc(i).linemessage = {}; %#ok<AGROW>

    mlmsg = mlintMsgs{i};
    for j = 1:length(mlmsg)
        ln = mlmsg(j).message;
        ln = code2html(ln);
        for k = 1:length(mlmsg(j).line)
            strc(i).linenumber(end+1) = mlmsg(j).line(k); %#ok<AGROW>
            strc(i).linemessage{end+1} = ln; %#ok<AGROW>
        end
    end

    % Now sort the list by line number
    if ~isempty(strc(i).linenumber)
        lnum = [strc(i).linenumber];
        lmsg = strc(i).linemessage;
        [~, ndx] = sort(lnum);
        lnum = lnum(ndx);
        lmsg = lmsg(ndx);
        strc(i).linenumber = lnum; %#ok<AGROW>
        strc(i).linemessage = lmsg; %#ok<AGROW>
    end

end

% Limit the number of messages displayed to keep from being overwhelmed by
% large pathological files.
displayLimit = 500;

% Now generate the HTML
help = sprintf('This report displays potential errors and problems, as well as opportunities to improve your MATLAB programs ');
doc = 'matlab_env_mlint';
if configSpecified
    configAction = [',''' config ''''];
else
    configAction = '';
end
rerunAction = sprintf('mlintrpt(''%s'',''%s''%s)',name, option, configAction);
runOnThisDirAction = 'mlintrpt';
s = internal.matlab.codetools.reports.makeReportHeader(reportName, help, doc, rerunAction, runOnThisDirAction);

s{end+1} = '<p>';
if strcmp(option,'file')
    s{end+1} = sprintf('Report for file <a href="matlab: edit(urldecode(''%s''))">%s</a>', ...
        urlencode(strc(1).fullfilename), strc(1).fullfilename);
else
    s{end+1} = sprintf('Report for folder %s',name);
end
s{end+1} = '<p>';


s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
for n = 1:length(strc)
    s{end+1} = '<tr><td valign="top" class="td-linetop">'; %#ok<AGROW>
    if strcmp(option,'dir')
        s{end+1} = sprintf('<a href="matlab: edit(urldecode(''%s''))"><span class="mono">%s</span></a><br/>', ...
            urlencode(strc(n).fullfilename), regexprep(strc(n).filename,'\.m$','')); %#ok<AGROW>
    end

    if isempty(strc(n).linenumber)
        msg = sprintf('<span class="soft">No messages</span>');
    elseif length(strc(n).linenumber)==1
        msg = sprintf('<span class="warning">1 message</span>');
    elseif length(strc(n).linenumber) < displayLimit
        msg = sprintf('<span class="warning">%d messages</span>', length(strc(n).linenumber));
    else
        % Truncate the list of messages if there are too many.
        msg = sprintf('<span class="warning">%d messages\n<br/>Showing only first %d</span>', ...
            length(strc(n).linenumber), displayLimit);
    end
    s{end+1} = sprintf('%s</td><td valign="top" class="td-linetopleft">',msg); %#ok<AGROW>

    if ~isempty(strc(n).linenumber)
        for m = 1:min(length(strc(n).linenumber),displayLimit)
            s{end+1} = sprintf('<span class="mono"><a href="matlab: opentoline(urldecode(''%s''),%d)">%d:</a> %s</span><br/>', ...
                urlencode(strc(n).fullfilename), strc(n).linenumber(m), strc(n).linenumber(m), strc(n).linemessage{m}); %#ok<AGROW>
        end
    end
    s{end+1} = '</td></tr>'; %#ok<AGROW>

end

s{end+1} = '</table>';
s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
