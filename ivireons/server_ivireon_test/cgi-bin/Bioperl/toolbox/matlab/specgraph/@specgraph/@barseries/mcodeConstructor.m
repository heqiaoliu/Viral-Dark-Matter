function mcodeConstructor(this,hCode)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2008 The MathWorks, Inc.

% If this bar plot has bar peers, then consolidate them into one
% call to bar. This will require finding all the memento objects
% and marking them "ignore"
isMatrixData = false;
hBarPeers = get(this,'BarPeers');
hBarPeerMomentoList = [];
if length(hBarPeers) > 1
    
    % Get a list of the all the memento objects
    hBarPeerMomentoList = get(hCode,'MomentoRef');
    hParentMomento = up(hBarPeerMomentoList(1));
    if ~isempty(hParentMomento)
        hPeerMomentoList = find(hParentMomento,'-depth',1);
        
        % Loop through peer momento objects
        for n = 2:length(hPeerMomentoList)
            hPeerMomento = hPeerMomentoList(n);
            hPeerObj = get(hPeerMomento,'ObjectRef');
            
            % Mark memento object ignore so that no code gets 
            % generated
            if ~isempty(hPeerObj) && any(find(hBarPeers==hPeerObj)) && ...
                    hPeerObj ~= this
                hBarPeerMomentoList = [hBarPeerMomentoList;hPeerMomento];
                set(hPeerMomento,'Ignore',true);   
                isMatrixData = true;
            end
        end
    end
end

setConstructorName(hCode,'bar')

plotutils('makemcode',this,hCode)
  
% process XData
ignoreProperty(hCode,{'XData','XDataMode','XDataSource'});
if strcmp(this.XDataMode,'manual')
    % Come up with names for input variables:
    xName = get(this,'XDataSource');
    xName = hCode.cleanName(xName,'xvector');
    arg = codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
        'Comment',sprintf('bar xvector'));
    addConstructorArgin(hCode,arg);
end

% process YData
ignoreProperty(hCode,{'YData','YDataSource'});
% Come up with names for input variables:
if isMatrixData
    yName = 'ymatrix';
else
    yName = get(this,'YDataSource');
    yName = hCode.cleanName(yName,'yvector');
end
arg = codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true);
if isMatrixData
   set(arg,'Comment',sprintf('bar matrix data'));
else
    set(arg,'Comment',sprintf('bar yvector'));
end
addConstructorArgin(hCode,arg);

ignoreProperty(hCode,'BaseLine');
if ~isMatrixData
    generateDefaultPropValueSyntax(hCode);
else
    % Generate calls to "set" command
    % Set up output argument
    hFunc = get(hCode,'Constructor');
    hArg = codegen.codeargument('Value',hBarPeers,...
        'Name',get(hFunc,'Name'));
    addArgout(hFunc,hArg);
    % Let user know that the output is multiple line handles
    set(hFunc,'Comment',...
        sprintf('Create multiple lines using matrix input to %s', hFunc.Name));
    codetoolsswitchyard('mcodePlotObjectVectorSet',hCode,hBarPeerMomentoList,@isDataSpecificFunction);
end

plotutils('MCodeBaseLine',this,hCode);

%----------------------------------------------------------%
function flag = isDataSpecificFunction(hObj, hProperty)
% Returns true is the function is generated as a side effect of the data,
% false otherwise

name = get(hProperty,'Name');
value = get(hProperty,'Value');

% Don't flag if the property is auto-generated
switch(lower(name))
    case {'xdata','ydata','ydatasource','xdatasource'}
        flag = true;
    case 'edgecolor'
        if strcmpi(value,'flat')
            flag = true;
        else
            flag = false;
        end
    otherwise
        flag = false;
end % switch