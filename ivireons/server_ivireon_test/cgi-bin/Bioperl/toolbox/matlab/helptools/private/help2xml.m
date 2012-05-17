function [helpNode, helpstr, fcnName] = help2xml(dom, topic, pagetitle, helpCommandOption)
%HELP2HTML Convert M-help to an HTML form.
%
%   This file is a helper function used by the HelpPopup Java component.
%   It is unsupported and may change at any time without notice.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/03/31 18:24:13 $

% Some initializations
CR = sprintf('\n');
if nargin < 3
    helpCommandOption = '-helpwin';
end

helpNode = dom.createElement('help-topic');
dom.getDocumentElement.appendChild(helpNode);

% Is this a help string to display?
if (nargin>0 && (iscell(topic) || size(topic,1) > 1 || any(find(topic==CR))))
    % Set title to default, or use the one provided
    if nargin < 2 || isempty(pagetitle)
        pgtitle = 'MATLAB Help';
    else
        pgtitle = pagetitle;
    end
    pgtitle = fixsymbols(pgtitle);

    if iscell(topic) || size(topic,1) > 1
       helpstr = '';
       for y = 1:size(topic,1)
           helpstr = sprintf('%s%s\n',helpstr,deblank(char(topic(y,:))));
       end
    else
       helpstr = char(topic);
    end

    helpstr = fixsymbols(helpstr);

    addHeaderInfo(dom, helpNode, pgtitle, pgtitle, {}, {});
    % TODO: Is this OK?
    fcnName = '';
    return;
end

[helpstr docTopic] = help(topic, helpCommandOption);

classInfo = helpUtils.splitClassInformation(topic,'',true,false);
if ~isempty(classInfo)
    fcnName = classInfo.fullTopic;
    titleFormat = 'MATLAB File Help: %s';
    if classInfo.isPackage
        viewFormat = [];
    else
        viewFormat = 'View code for %s';
    end
    qualifiedTopic = classInfo.minimalPath;
else
    % Create the formats that we will use for the header text.
    [fcnName,titleFormat,viewFormat] = prepareHeader(topic,topic);

    % If there is a format to view, there needs to be a path to view
    if isempty(viewFormat)
        if length(topic)<=3 && ~any(isstrprop(topic, 'alphanum'))
            % This is help for a special character
            qualifiedTopic = 'matlab\ops';
        else
            qualifiedTopic = topic;
        end
    else
        [qualifyingPath, fcnName, extension] = fileparts(fcnName);
        [fcnName, qualifyingPath] = helpUtils.fixFileNameCase([fcnName, extension], qualifyingPath);
        qualifiedTopic = fullfile(qualifyingPath, fcnName);
    end
end

if isempty(helpstr)
    if strcmp(helpCommandOption, '-helpwin')
        addHeaderInfo(dom, helpNode, fcnName, 'MATLAB File Help', {}, {});
    end
    return;
end

if isempty(topic)
    title = 'MATLAB File Help: Default Topics';
else
    title = sprintf(titleFormat, fcnName);
end

headerText = {};
headerActions = {};

% Setup the left side link (view code for...)
if ~isempty(qualifiedTopic)
    if ~isempty(viewFormat)
        headerText = {sprintf(viewFormat, fcnName)};
        headerActions = {helpUtils.makeDualCommand('open', qualifiedTopic)};
    end
end

if ~isempty(docTopic)
    headerText = [headerText, {sprintf('Go to online doc for %s', fcnName)}];
    headerActions = [headerActions, {helpUtils.makeDualCommand('doc', docTopic)}];
end

addHeaderInfo(dom, helpNode, fcnName, title, headerText, headerActions);

if ~isempty(classInfo) && displayClass(classInfo)
    % We'll display class information even if no help was found, since
    % there is likely to be interesting information in the metadata.
    fcnName = handleClassInfo(classInfo,fcnName,dom,helpNode);
end

%==========================================================================
function [fcnName,titleFormat,viewFormat] = prepareHeader(fcnName,topic)
% determine the class of help, and prepare header strings for it
titleFormat = 'MATLAB File Help: %s';
viewFormat = '';
switch exist(fcnName, 'file')
case 0
    % do nothing
case 2
    % M File or text file
    viewFormat = 'View code for %s';
case 4
    % MDL File
    viewFormat = 'Open model %s';
    titleFormat = 'Model Help: %s';
case 6
    % P File
    mFcnName = which(fcnName);
    mFcnName(end) = 'm';
    if exist(mFcnName, 'file')
        % P File with the M File still available
        % This should always be the case, since there is no help without the M
        viewFormat = 'View code for %s';
        % strip the .p extension if it had been specified
        fcnName = regexprep(fcnName, '\.p$', '');
    end
otherwise
    % this item exists, but is not viewable, so there is no location or format
    % however, fcnName can still be case corrected if there is a which value
    fcnName = helpUtils.extractCaseCorrectedName(which(fcnName), fcnName);
    if isempty(fcnName)
        fcnName = topic;
    end
end

%==========================================================================
function addHeaderInfo(dom,helpNode,topic,title,headerText,headerActions)
addTextNode(dom,helpNode,'topic',topic);
addTextNode(dom,helpNode,'title',title);

if ~isempty(headerText)
    headersNode = dom.createElement('headers');
    for i = 1:length(headerText)
        headerNode = dom.createElement('header');
        addTextNode(dom,headerNode,'text',headerText{i});
        if ~isempty(headerActions{i})
            addTextNode(dom,headerNode,'action',headerActions{i});
        end
        headersNode.appendChild(headerNode);
    end
    helpNode.appendChild(headersNode);
end

%==========================================================================
function topic = handleClassInfo(classInfo,topic,dom,helpNode)
className = helpUtils.makePackagedName(classInfo.packageName, classInfo.className);

metacls = meta.class.fromName(className);
if ~isempty(metacls)
    if classInfo.isConstructor
        topic = classInfo.className;
        constructorMeta = findClassMemberMeta(metacls.Methods, topic);
        helpUtils.class2xml.buildConstructorXml(constructorMeta, dom,helpNode);

    elseif classInfo.isMethod
        methodName = regexp(topic,'\w+$','once','match');

        methodMeta = findClassMemberMeta(metacls.Methods, methodName);
        helpUtils.class2xml.buildMethodXml(metacls, methodMeta, dom, helpNode);

    elseif classInfo.isProperty
        propertyName = regexp(topic,'\w+$','once','match');

        propMeta = findClassMemberMeta(metacls.Properties, propertyName);
        helpUtils.class2xml.buildPropertyXml(metacls, propMeta,dom,helpNode);

    elseif classInfo.isClass
        classFilePath = classInfo.minimizePath;
        c2x = getClass2XmlObj(classFilePath);
        c2x.buildClassXml(dom,helpNode);
    end
end


%==========================================================================
function ret = displayClass(classInfo)
ret = classInfo.isClass || classInfo.isMethod || classInfo.isProperty;

%==========================================================================
function addTextNode(dom,parent,name,text)
child = dom.createElement(name);
child.appendChild(dom.createTextNode(text));
parent.appendChild(child);

%==========================================================================
function class2xmlObj = getClass2XmlObj(classFilePath)
% GETCLASS2XMLOBJ - helper method that constructs a HELPUTILS.CLASS2XML
% object.
helpContainerObj = helpUtils.containers.HelpContainerFactory.create(classFilePath);
class2xmlObj = helpUtils.class2xml(helpContainerObj);


%==========================================================================
function metaData = findClassMemberMeta(metaArray, memberName)
% FINDCLASSMEMBERMETA - given an array of class member meta data objects,
% FINDCLASSMEMBERMETA returns the meta data object with the name
% MEMBERNAME.
metaData = metaArray{cellfun(@(c)strcmp(c.Name, memberName), metaArray)};

% Truncate to only first found meta data object because class members may appear multiple
% times.
metaData = metaData(1);