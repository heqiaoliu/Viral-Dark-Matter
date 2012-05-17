function [outStr, found] = help2html(topic,pagetitle,helpCommandOption)
%HELP2HTML Convert M-help to an HTML form.
% 
%   This file is a helper function used by the HelpPopup Java component.  
%   It is unsupported and may change at any time without notice.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $ $Date: 2010/04/21 21:32:14 $
if nargin == 0
    topic = '';
end
if nargin < 2
    pagetitle = '';
end
if nargin < 3
    helpCommandOption = '-helpwin';
end
dom = com.mathworks.xml.XMLUtils.createDocument('help-info');
dom.getDomConfig.setParameter('cdata-sections',true);

[helpNode, helpstr, fcnName] = help2xml(dom, topic, pagetitle, helpCommandOption);
found = ~isempty(helpstr);

afterHelp = '';
if found
    % Handle characters that are special to HTML 
    helpstr = fixsymbols(helpstr);

    % Extract the see also and overloaded links from the help text.
    % Since these are already formatted as links, we'll keep them 
    % intact rather than parsing them into XML and transforming
    % them back to HTML.
    helpParts = helpUtils.helpParts(helpstr);
    afterHelp = moveToAfterHelp(afterHelp, helpParts, {'seeAlso', 'overloaded', 'demo'});
    
    helpstr = deblank(helpParts.getFullHelpText);
    helpstr = highlightHelp(fcnName, helpstr);
elseif ~strcmp(helpCommandOption, '-helpwin')
    outStr = '';
    return;
end

helpdir = fileparts(mfilename('fullpath'));
helpdir = ['file:///' strrep(helpdir,'\','/')];
addTextNode(dom,dom.getDocumentElement,'helptools-dir',helpdir);

if found
    addAttribute(dom,helpNode,'helpfound','true');
else
    addAttribute(dom,helpNode,'helpfound','false');
    % It's easier to escape the quotes in M than in XSL, so do it here.
    addTextNode(dom,helpNode,'escaped-topic',strrep(fcnName,'''',''''''));
end

% Prepend warning about empty docroot, if we've been called by doc.m
if strcmp(helpCommandOption, '-doc') && ~helpUtils.isDocInstalled
    addAttribute(dom,dom.getDocumentElement,'doc-installed','false');
    warningGif = sprintf('file:///%s',strrep(fullfile(matlabroot,'toolbox','matlab','icons','warning.gif'),'\','/'));
    addTextNode(dom,dom.getDocumentElement,'warning-image',warningGif);
    helperrPage = sprintf('file:///%s',strrep(fullfile(matlabroot,'toolbox','local','helperr.html'),'\','/'));
    addTextNode(dom,dom.getDocumentElement,'error-page',helperrPage);
end

addTextNode(dom,dom.getDocumentElement,'default-topics-text',sprintf('Default Topics'));
xslfile = fullfile(fileparts(mfilename('fullpath')),'private','helpwin.xsl');
outStr = xslt(dom,xslfile,'-tostring');

% Use HTML entities for non-ASCII characters
helpstr = regexprep(helpstr,'[^\x0-\x7f]','&#x${dec2hex($0)};');
afterHelp = regexprep(afterHelp,'[^\x0-\x7f]','&#x${dec2hex($0)};');
outStr = regexprep(outStr,'\s*(<!--\s*helptext\s*-->)', sprintf('$1%s',regexptranslate('escape',helpstr)));
outStr = regexprep(outStr,'\s*(<!--\s*after help\s*-->)', ['$1' regexptranslate('escape',afterHelp)]);

%==========================================================================
function helpstr = highlightHelp(fcnName,helpstr)
% Highlight occurrences of the function name, ignoring occurrences
% immediately preceded or followed by some punctuation as well as
% occurrences that occur within hyperlinks.
if ~isempty(fcnName) && ~strcmpi(fcnName,'matlab')
     if ~isempty(regexp(fcnName,'\w','once'))
         lowerFcnName = lower(fcnName);
         fcnRegexp = regexprep(fcnName,'[^\w\s]','[^\\w\\s]');
         upperRegexp = regexprep(upper(fcnName),'[^\w\s]','[^\\w\\s]');
         if ~strcmp(lowerFcnName,fcnName)
             fcnPattern = ['(' fcnRegexp '|' upperRegexp ')'];
         else
             fcnPattern = upperRegexp;
         end
     else
         fcnPattern = regexptranslate('escape',fcnName);
     end
     
     toReplace = ['\<(?<![./\\>])' fcnPattern '\>(?![./\\>])'];
     highlightText = ['<span class="helptopic">' fcnName '</span>'];
     highlightFunc = @(match)(highlightMatch(match, highlightText)); %#ok<NASGU>
     helpstr = regexprep(helpstr,['((?i:<a\s+href.*?</a>))?(' toReplace ')?'], '$1${highlightFunc($2)}');
end

%==========================================================================
function match = highlightMatch(match, highlighted)
if ~isempty(match)
    match = highlighted; 
end

%==========================================================================
function afterHelp = moveToAfterHelp(afterHelp, helpParts, parts)
for i = 1:length(parts)
    part = helpParts.getPart(parts{i});
    if ~isempty(part)
        title = part.getTitle;
        if title(end) == ':'
            title = title(1:end-1);
        end
        afterHelp = sprintf('%s<!--%s-->', afterHelp, parts{i});
        afterHelp = sprintf('%s<div class="footerlinktitle">%s</div>', afterHelp, title);
        afterHelp = sprintf('%s<div class="footerlink">%s</div>', afterHelp, part.getText);
        part.clearPart;
    end
end

%==========================================================================
function addTextNode(dom,parent,name,text)
child = dom.createElement(name);
child.appendChild(dom.createTextNode(text));
parent.appendChild(child);

%==========================================================================
function addAttribute(dom,elt,name,text)
att = dom.createAttribute(name);
att.appendChild(dom.createTextNode(text));
elt.getAttributes.setNamedItem(att);
