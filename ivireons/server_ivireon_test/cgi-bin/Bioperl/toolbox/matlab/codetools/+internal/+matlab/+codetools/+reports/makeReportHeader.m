function htmlOut = makeReportHeader( reportName, help, docPage, rerunAction, runOnThisDirAction )
% MAKEREPORTHEADER  Add a head for HTML report file.
%   Use locale to determine the appropriate charset encoding.
%
% makeReportHeader( reportName, help, docPage, rerunAction, runOnThisDirAction )
%    reportName: the full name of the report
%    help: the report description
%    docpage: the html page in the matlab environment CSH book
%    rerunAction: the matlab command that would regenerate the report
%    runOnThisDirAction: the matlab command that generates the report for the cwd
%
%   Note: <html> and <head> tags have been opened but not closed. 
%   Be sure to close them in your HTML file.

%   Copyright 2009 The MathWorks, Inc.

htmlOut = {};

%% XML information
h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

%% The character set depends on the language

locale = feature('Locale');
% locale.ctype returns charset strings of this form:
%   ja_JP.Shift_JIS
%   en_US.windows-1252
% and so on. We remove language name and territory name to get the
% appropriate charset.
encoding = regexprep(locale.ctype,'(^.*\.)','');
h3 = sprintf('<head><meta http-equiv="Content-Type" content="text/html; charset=%s" />',encoding);

%% Add cascading style sheet link
reportdir = fullfile(matlabroot,'toolbox','matlab','codetools','+internal','+matlab','+codetools','+reports');
cssfile = fullfile(reportdir,'matlab-report-styles.css');
h4 = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />', cssfile);

jsfile = fullfile(reportdir,'matlabreports.js');
h5 = sprintf('<script type="text/javascript" language="JavaScript" src="file:///%s"></script>',jsfile);

%% HTML header
htmlOut{1} = [h1 h2 h3 h4 h5];

htmlOut{2} = sprintf('<title>%s</title>', reportName);
htmlOut{3} = '</head>';
htmlOut{4} = '<body>';
htmlOut{5} = sprintf('<div class="report-head">%s</div><p>', reportName);

%% Descriptive text
htmlOut{6} = sprintf(['<div class="report-desc">%s '...
    '(<a href="matlab:helpview([docroot ''/techdoc/matlab_env/matlab_env.map''], ''%s'')">' ...
    '%s</a>).</div>'], help, docPage, xlate('Learn More'));

%% Rerun report buttons 
htmlOut{end+1} = '<table border="0"><tr>';
htmlOut{end+1} = '<td>';

htmlOut{end+1} = sprintf('<input type="button" value="%s" id="rerunThisReport" onclick="runreport(''%s'');" />',...
    sprintf('Rerun This Report'), internal.matlab.codetools.reports.escape(rerunAction));
htmlOut{end+1} = '</td>';

htmlOut{end+1} = '<td>';
htmlOut{end+1} = sprintf('<input type="button" value="%s" id="runReportOnCurrent" onclick="runreport(''%s'');" />',...
    sprintf('Run Report on Current Folder'), internal.matlab.codetools.reports.escape(runOnThisDirAction));
htmlOut{end+1} = '</td>';

htmlOut{end+1} = '</tr></table>';
end

