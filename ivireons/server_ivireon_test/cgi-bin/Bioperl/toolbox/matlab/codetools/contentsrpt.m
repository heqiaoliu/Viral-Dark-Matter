function htmlOut = contentsrpt(dirname)
%CONTENTSRPT  Audit the Contents.m for the given directory
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   CONTENTSRPT checks for the existence and correctness of the
%   Contents.m file in the current directory.
%
%   CONTENTSRPT(DIRNAME) scans the specified directory.
%
%   HTMLOUT = CONTENTSRPT(...) returns the generated HTML text as a cell
%   array.
%
%   See also PROFILE, MLINTRPT, DEPRPT, HELPRPT, COVERAGERPT.

%   Copyright 1984-2010 The MathWorks, Inc.

reportName = sprintf('Contents File Report');

if nargout == 0
    internal.matlab.codetools.reports.displayLoadingMessage(reportName);
end

if nargin < 1
    dirname = cd;
end

dirContents = fullfile(dirname,'Contents.m');

% Is there a Contents.m file?
noContentsFlag = 0;
if isempty(dir([dirname filesep 'Contents.m']))
    noContentsFlag = 1;
else
    [ct, ex] = auditcontents(dirname);
end


%% Make the Header
help = sprintf('The Contents Report displays information about the integrity of the Contents.m file for the folder ');
docPage = 'matlab_env_contents_rpt';
rerunAction = sprintf('contentsrpt(''%s'')', dirname);
thisDirAction = 'contentsrpt';

% Now generate the HTML
s = internal.matlab.codetools.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);
s{end+1} = '<p>';


if noContentsFlag
    s{end+1} = sprintf('No Contents.m file. Make one? [ <a href="matlab:makecontentsfile(urldecode(''%s'')); contentsrpt(urldecode(''%s''))">yes</a> ]', ...
        urlencode(dirname),urlencode(dirname));
else
    s{end+1} = sprintf('[ <a href="matlab: edit(urldecode(''%s''))">edit Contents.m</a> |', ...
        urlencode(dirContents));
    s{end+1} = sprintf(' <a href="matlab: fixcontents(urldecode(''%s''),''prettyprint''); contentsrpt(urldecode(''%s''))">fix spacing</a> |', ...
        urlencode(dirContents), urlencode(dirname));
    s{end+1} = sprintf(' <a href="matlab: fixcontents(urldecode(''%s''),''all''); contentsrpt(urldecode(''%s''))">fix all</a> ]<p>', ...
        urlencode(dirContents), urlencode(dirname));
    
    s{end+1} = sprintf('Report for folder %s<p>',dirname);

    s{end+1} = '<pre>';

    for n = 1:length(ct)
        fileline = regexprep(ct(n).text,'^%','');
        fileline = code2html(fileline);
        if ct(n).ismfile
            
            % Make the first mention of the file name a clickable link to
            % bring up the file in the editor. The exception to this case
            % is when the file doesn't appear to exist (i.e. auditcontents
            % suggests the "remove" action
            
            if strcmp(ct(n).action,'remove')
                fileline2 = fileline;
            else
                linkStr = sprintf('<a href="matlab:edit(urldecode(''%s''))">%s</a>', urlencode([dirname filesep ct(n).mfilename]), ct(n).mfilename);
                % Escape out any backslashes or they will mess up the regular
                % expression replacement below.
                linkStr = strrep(linkStr,'\','\\');
                fileline2 = regexprep(fileline, ...
                    ct(n).mfilename, ...
                    linkStr, ...
                    'once');
            end

            s{end+1} = sprintf('%s\n',fileline2); %#ok<*AGROW>

            if strcmp(ct(n).action,'update')
                s{end+1} = '</pre><div style="background:#FEE">';
                s{end+1} = sprintf('Description lines do not match for file <a href="matlab: edit(urldecode(''%s''))">%s</a>.<br/>', ...
                    urlencode([dirname filesep ct(n).mfilename]), ct(n).mfilename);

                s{end+1} = sprintf('Use this description from the <b>file</b>? (default) ');
                s{end+1} = sprintf('[ <a href="matlab:fixcontents(urldecode(''%s''),''update'',urldecode(''%s'')); contentsrpt(urldecode(''%s''))">yes</a> ]', ...
                    urlencode(dirContents), urlencode([dirname filesep ct(n).mfilename]), urlencode(dirname));
                filelineFile = fileline;
                idx = strfind(filelineFile,' - ');
                filelineFile(idx:end) = [];
                filelineFile = [filelineFile ' - ' ct(n).filedescription];
                filelineFile = code2html(filelineFile);
                s{end+1} = sprintf('<pre>%s</pre>\n',filelineFile);

                s{end+1} = sprintf('Or put this description from the <b>Contents</b> into the file? ');
                s{end+1} = sprintf('[ <a href="matlab:fixcontents(urldecode(''%s''),''updatefromcontents'',urldecode(''%s'')); contentsrpt(urldecode(''%s''))">yes</a> ]', ...
                    urlencode(dirContents), urlencode([dirname filesep ct(n).mfilename]), urlencode(dirname));
                s{end+1} = sprintf('<pre>%s</pre>\n',fileline);
                s{end+1} = '</div><pre>';

            elseif strcmp(ct(n).action,'remove')
                s{end+1} = '</pre><div style="background:#FEE">';
                s{end+1} = sprintf('File %s does not appear in this folder.<br/>',  ...
                    ct(n).mfilename);
                s{end+1} = sprintf('Remove it from Contents.m? ');
                s{end+1} = sprintf('[ <a href="matlab: fixcontents(urldecode(''%s''),''remove'',urldecode(''%s'')); contentsrpt(urldecode(''%s''))">yes</a> ] ', ...
                    urlencode(dirContents), urlencode(ct(n).mfilename), urlencode(dirname));
                s{end+1} = '</div><pre>';
            end
        else
            s{end+1} = sprintf('%s\n',fileline);
        end
    end

    for n = 1:length(ex)
        s{end+1} = sprintf('</pre><div style="background:#EEE">File <a href="matlab: edit(urldecode(''%s''))">%s</a> is in the folder but not Contents.m<pre>', ...
            urlencode(ex(n).mfilename), ex(n).mfilename);
        s{end+1} = code2html(ex(n).contentsline);
        fileStr = regexprep(ex(n).contentsline,'-.*$','');

        s{end+1} = sprintf('</pre>Add the line shown above? ');

        s{end+1} = sprintf('[ <a href="matlab: fixcontents(urldecode(''%s''),''append'',urldecode(''%s'')); contentsrpt(urldecode(''%s''))">yes</a> ]</div><pre>', ...
            urlencode(dirContents), urlencode(fileStr), urlencode(dirname));
    end

    s{end+1} = '</pre>';

end

s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
