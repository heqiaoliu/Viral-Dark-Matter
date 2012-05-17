function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2008 The MathWorks, Inc.

setConstructorName(code,'area')

plotutils('makemcode',this,code)

hAreaPeers = get(this,'AreaPeers');
hAreaPeerMomentoList = [];
isMatrixData = false;
if length(hAreaPeers) > 1
    
    % Get a list of the all the memento objects
    hAreaPeerMomentoList = get(code,'MomentoRef');
    hParentMomento = up(hAreaPeerMomentoList(1));
    if ~isempty(hParentMomento)
        hPeerMomentoList = find(hParentMomento,'-depth',1);
        
        % Loop through peer momento objects
        for n = 2:length(hPeerMomentoList)
            hPeerMomento = hPeerMomentoList(n);
            hPeerObj = get(hPeerMomento,'ObjectRef');
            
            % Mark memento object ignore so that no code gets 
            % generated
            if ~isempty(hPeerObj) && any(find(hAreaPeers==hPeerObj)) && ...
                    hPeerObj ~= this
                hAreaPeerMomentoList = [hAreaPeerMomentoList;hPeerMomento];
                set(hPeerMomento,'Ignore',true);   
                isMatrixData = true;
            end
        end
    end
end
  
% process XData
ignoreProperty(code,'XData');
ignoreProperty(code,'XDataMode');
ignoreProperty(code,'XDataSource');
if strcmp(this.xdatamode,'manual')
    % Come up with names for input variables:
    xName = get(this,'XDataSource');
    xName = code.cleanName(xName,'X');
    arg = codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
      'Comment',sprintf('area x'));
  addConstructorArgin(code,arg);
end

% process YData
ignoreProperty(code,'YData');
ignoreProperty(code,'YDataSource');
% Come up with names for input variables:
if isMatrixData
    yName = 'ymatrix';
else
    yName = get(this,'YDataSource');
    yName = code.cleanName(yName,'yvector');
end
arg = codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true);
if isMatrixData
   set(arg,'Comment',sprintf('area matrix data'));
else
    set(arg,'Comment',sprintf('area yvector'));
end
addConstructorArgin(code,arg);

if ~isMatrixData
    generateDefaultPropValueSyntax(code);
else
    % Generate calls to "set" command
    % Set up output argument
    hFunc = get(code,'Constructor');
    hArg = codegen.codeargument('Value',hAreaPeers,...
        'Name',get(hFunc,'Name'));
    addArgout(hFunc,hArg);    
    % Let user know that the output is multiple line handles
    set(hFunc,'Comment',...
        sprintf('Create multiple lines using matrix input to %s', hFunc.Name));
    codetoolsswitchyard('mcodePlotObjectVectorSet',code,hAreaPeerMomentoList,@isDataSpecificFunction);
end

%----------------------------------------------------------%
function flag = isDataSpecificFunction(hObj, hProperty)
% Returns true is the function is generated as a side effect of the data,
% false otherwise

name = get(hProperty,'Name');

% Don't flag if the property is auto-generated
switch(lower(name))
    case {'xdata','xdatamode','ydata','ydatasource','xdatasource'}
        flag = true;
    otherwise
        flag = false;
end % switch