function htmlOut = helprpt(name, option)
%HELPRPT  Audit a file or folder for help
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   HELPRPT scans all MATLAB files in the current folder for problems in the
%   help lines. This includes missing examples, "see also" lines,
%   and copyright.
%
%   HELPRPT(FILENAME) or HELPRPT(FILENAME,'file') scans the file
%   FILENAME.
%
%   HELPRPT(DIRNAME,'dir') scans the specified folder.
%
%   HTMLOUT = HELPRPT(...) returns the generated HTML text as a cell array
%
%   See also PROFILE, MLINTRPT, DEPRPT, CONTENTSRPT, COVERAGERPT.

% Copyright 1984-2010 The MathWorks, Inc.

reportName = sprintf('Help Report');
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

if strcmp(option,'dir')
    dirname = name;
    if isdir(dirname)
        dirFileList = dir([dirname filesep '*.m']);
        fileList = {dirFileList.name};
        % Exclude the Contents file from the list
        fileList = fileList(~strcmp(fileList,'Contents.m'));
        % Make the file list into full paths
        fileList = cellfun(@(file) fullfile(dirname,file),fileList,'UniformOutput',false);
    else
        internal.matlab.codetools.reports.webError(sprintf('%s is not a folder', dirname), reportName);
        return
    end
else
    fullname = which(name);
    if isempty(fullname)
        internal.matlab.codetools.reports.webError(sprintf('File %s not found', name), reportName);
        return
    end
    [dirname, realname] = fileparts(fullname);
    % add a '.m' if there is not already one
    fileList = {[dirname filesep realname '.m']};
end


%% Manage the preferences
h1DisplayMode = getpref('dirtools','h1DisplayMode',1);
helpDisplayMode = getpref('dirtools','helpDisplayMode',1);
options.displayCopyright = getpref('dirtools','copyrightDisplayMode',1);
options.displayHelpForMethods = getpref('dirtools','helpSubfunsDisplayMode',1);
options.displayExamples = getpref('dirtools','exampleDisplayMode',1);
options.displaySeeAlso = getpref('dirtools','seeAlsoDisplayMode',1);

%% First gather all the data
strc = internal.matlab.codetools.reports.parseHelpinfo(fileList, options);

%% Make the Header
help = sprintf('The Help Report presents a summary view of the help component of your MATLAB files ');
docPage = 'matlab_env_help_rpt';
thisDirAction = 'helprpt';
rerunAction = sprintf('helprpt(''%s'',''%s'')', name, option);

% Now generate the HTML
s = internal.matlab.codetools.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);

%% Make the form
s{end+1} = '<form method="post" action="matlab:internal.matlab.codetools.reports.handleForm">';
s{end+1} = '<input type="hidden" name="reporttype" value="helprpt" />';
s{end+1} = '<table cellspacing="8">';
s{end+1} = '<tr>';

checkOptions = {'','checked'};

s{end+1} = sprintf('<td><input type="checkbox" name="helpSubfunsDisplayMode" %s onChange="this.form.submit()" />%s</td>',...
    checkOptions{options.displayHelpForMethods + 1}, sprintf('Show class methods'));
s{end+1} = sprintf('<td><input type="checkbox" name="h1DisplayMode" %s onChange="this.form.submit()" />%s</td>',...
    checkOptions{h1DisplayMode+1}, sprintf('Description'));
s{end+1} = sprintf('<td><input type="checkbox" name="exampleDisplayMode" %s onChange="this.form.submit()" />%s</td>',...
    checkOptions{options.displayExamples + 1}, sprintf('Examples'));
s{end+1} = '</tr><tr>';
s{end+1} = sprintf('<td><input type="checkbox" name="helpDisplayMode" %s onChange="this.form.submit()" />%s</td>', ...
    checkOptions{helpDisplayMode+1}, sprintf('Show all help'));
s{end+1} = sprintf('<td><input type="checkbox" name="seeAlsoDisplayMode" %s onChange="this.form.submit()" />%s</td>', ...
    checkOptions{options.displaySeeAlso + 1}, sprintf('See also'));
s{end+1} = sprintf('<td><input type="checkbox" name="copyrightDisplayMode" %s onChange="this.form.submit()" />%s</td>', ...
    checkOptions{options.displayCopyright + 1}, sprintf('Copyright'));

s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '</form>';

s{end+1} = sprintf('%s<p>', sprintf('Report for folder %s', dirname));

s{end+1} = sprintf('<strong>%s</strong><br/>', sprintf('MATLAB File List'));
s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';

for n = 1:length(strc)
    
    s{end+1} = '<tr>';
    isSubFun = strcmp(strc(n).type, 'subfunction') || strcmp(strc(n).type, 'class method');
    
    % Display all the results
    if isSubFun
        s{end+1} = sprintf('<td valign="top" class="td-dashtop"><a href="matlab: editorservices.openAndGoToFunction(urldecode(''%s''),''%s'')"><span class="mono">%s</span></a></td>', ...
            urlencode(strc(n).filename), ...
            strc(n).shortfilename, ...
            strc(n).fullname);
        s{end+1} = '<td class="td-dashtopleft">';
    else
        s{end+1} = sprintf('<td valign="top" class="td-linetop"><a href="matlab: edit(urldecode(''%s''))"><span class="mono">%s</span></a></td>', ...
            urlencode(strc(n).filename), ...
            strc(n).shortfilename);
        s{end+1} = '<td class="td-linetopleft">';
    end
    
    if h1DisplayMode
        if isempty(strc(n).description)
            s{end+1} = missingHelpMessage(sprintf('No description line'));
        else
            s{end+1} = sprintf('<pre>%s</pre>',strc(n).description);
        end
    end
    
    if helpDisplayMode
        if isempty(strc(n).help)
            s{end+1} = missingHelpMessage(sprintf('No help'));
        else
            s{end+1} = '<pre>';
            s{end+1} = sprintf('%s<br/>',regexprep(strc(n).help,'^ %',' '));
            s{end+1} = '</pre>';
        end
    end
    
    if options.displayExamples
        if isempty(strc(n).example)
            s{end+1} = missingHelpMessage(sprintf('No examples'));
        else
            lineLabel = sprintf('%2d:',strc(n).exampleLine);
            lineLabel = strrep(lineLabel,' ','&nbsp;');
            s{end+1} = sprintf('<pre><a href="matlab: opentoline(urldecode(''%s''),%d)">%s</a> %s</pre>', ...
                urlencode(strc(n).filename), ...
                strc(n).exampleLine, ...
                lineLabel, ...
                strc(n).example);
        end
    end
    
    if options.displaySeeAlso
        if isempty(strc(n).seeAlso)
            s{end+1} = missingHelpMessage(sprintf('No See Also line'));
        else
            lineLabel = sprintf('%2d:',strc(n).seeAlsoLine);
            lineLabel = strrep(lineLabel,' ','&nbsp;');
            s{end+1} = sprintf('<pre><a href="matlab: opentoline(urldecode(''%s''),%d)">%s</a> %s</pre>', ...
                urlencode(strc(n).filename), ...
                strc(n).seeAlsoLine, ...
                lineLabel, ...
                strc(n).seeAlso);
            
            checkSeeAlsoFcn = 1;
            if checkSeeAlsoFcn
                for m = 1:length(strc(n).seeAlsoFcnList)
                    
                    % Throw a warning if the file can't be found.
                    % Since MATLAB convention UPPERCASES function names
                    % in SEE ALSO lines, we test for both the literal and
                    % lowercase version of this filename.
                    testNameLiteral = strc(n).seeAlsoFcnList{m}{1};
                    testNameLowerCase = lower(strc(n).seeAlsoFcnList{m}{1});
                    
                    if isempty(which(testNameLiteral)) && isempty(which(testNameLowerCase))
                        s{end+1} = missingHelpMessage(sprintf('Function %s does not appear on the path', ...
                            strc(n).seeAlsoFcnList{m}{1}));
                    end
                    
                end
            end
            
        end
    end
        
    if ~isSubFun && options.displayCopyright
        if isempty(strc(n).copyright)
            s{end+1} = missingHelpMessage(sprintf('No copyright line'));
        else
            s{end+1} = sprintf('<pre><span style="font-size: 11">%s</span></pre>', ...
                strc(n).copyright);
            dv = datevec(now);
            if strc(n).copyrightEndYear ~= dv(1)
                s{end+1} = missingHelpMessage(sprintf('Copyright year is not current'));
            end
        end
    end
    
    s{end+1} = '</td></tr>';

end
s{end+1} = '</table>';
s{end+1} = '</body></html>';

sOut = [s{:}];
if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = sOut;
end
end
function str = missingHelpMessage(message)
str = ['<span style="background: #FFC0C0">' message '</span><br/>'];
end

%#ok<*AGROW>