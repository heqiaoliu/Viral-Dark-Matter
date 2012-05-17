function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2008 The MathWorks, Inc.

setConstructorName(code,'errorbar')
  
plotutils('makemcode',this,code)
  
% process XData
ignoreProperty(code,'XData');
ignoreProperty(code,'XDataMode');
ignoreProperty(code,'XDataSource');

% process YData
ignoreProperty(code,'YData');
ignoreProperty(code,'YDataSource');

% process LData and UData
ignoreProperty(code,'LData');
ignoreProperty(code,'LDataSource');
ignoreProperty(code,'UData');
ignoreProperty(code,'UDataSource');

isVectorOutput = false;
hObjMomento = get(code,'MomentoRef');
% process Color
local_generate_color(hObjMomento);

% Check to see if other errorbar series objects with the same
% dimensionality exist. So we can consolidate the construction into one
% call with matrix input

% Get list of peer objects with the same parent. Momento objects
% are created by the code generation engine and represent the object's
% state which needs to be represented in code form.
set(hObjMomento,'Ignore',true);
hParentMomento = up(hObjMomento);
hPeerMomentoList = [];
orig_xdata = get(this,'XData');
orig_ydata = get(this,'YData');
orig_udata = get(this,'UData');
orig_ldata = get(this,'LData');
if ~isempty(hParentMomento)
    hPeerMomentoList = find(hParentMomento,'-depth',1);
    hConstructMomentoList = hObjMomento;
    hConstructErrorList = this;
    net_xdata = orig_xdata;
    net_ydata = orig_ydata;
    net_udata = orig_udata;
    net_ldata = orig_ldata;
end

% Loop through peer momento objects
for n = 2:length(hPeerMomentoList)
    hPeerMomento = hPeerMomentoList(n);
    hPeerObj = get(hPeerMomento,'ObjectRef');
    if isa(hPeerObj,'specgraph.errorbarseries')
        peer_xdata = get(hPeerObj,'XData');
        peer_ydata = get(hPeerObj,'YData');
        peer_udata = get(hPeerObj,'UData');
        peer_ldata = get(hPeerObj,'LData');
        
        % If the momento object is a lineseries with the same
        % xdata as this object.
        if ~isequal(hPeerObj,this) && ...
                ~get(hPeerMomento,'Ignore') && ...
                isequal(length(orig_xdata),length(peer_xdata)) && ...
                isequal(length(orig_ydata),length(peer_ydata)) && ...
                isequal(length(orig_ldata),length(peer_ldata)) && ...
                isequal(length(orig_udata),length(peer_udata)) && ...
                ~localHasConstructor(hPeerObj)
            
            % Add handle to list of constructor output handles
            hConstructMomentoList = [hPeerMomento; hConstructMomentoList];
            hConstructErrorList = [hPeerObj; hConstructErrorList];
            net_xdata = [net_xdata,peer_xdata];
            net_ydata = [net_ydata,peer_ydata];
            net_ldata = [net_ldata,peer_ldata];
            net_udata = [net_udata,peer_udata];
            
            % Mark the monento to be ignored by the code generation engine
            % since this momento object is already being
            % created by this constructor
            set(hPeerMomento,'Ignore',true);
            local_generate_color(hPeerMomento);
            % Constructor output is now a vector of handles
            isVectorOutput = true;
        end
    end
end

% Deal with variable names:
% Come up with names for input variables:
if strcmp(this.XDataMode,'manual')
    % Come up with names for input variables:
    xName = get(this,'XDataSource');
    if ~isVectorOutput
        xName = code.cleanName(xName,'X');
        arg = codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
            'Comment',sprintf('errorbar X'));
    else
        xName = code.cleanName(xName,'XMatrix');
        arg = codegen.codeargument('Name',xName,'Value',net_xdata,'IsParameter',true,...
            'Comment',sprintf('errorbar X matrix'));
    end
    addConstructorArgin(code,arg);
end
yName = get(this,'YDataSource');
if ~isempty(strfind(yName,'getcolumn'))
    yName = [];
end
if ~isVectorOutput
    yName = code.cleanName(yName,'Y');
    arg = codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true,...
        'Comment',sprintf('errorbar Y'));
else
    yName = code.cleanName(yName,'YMatrix');
    arg = codegen.codeargument('Name',yName,'Value',net_ydata,'IsParameter',true,...
        'Comment',sprintf('errorbar Y matrix'));
end
addConstructorArgin(code,arg);
if ~isVectorOutput
    if isequal(this.LData,this.UData)
        eName = get(this,'LDataSource');
        eName = code.cleanName(eName,'E');
        arg = codegen.codeargument('Name',eName,'Value',this.LData,'IsParameter',true,...
            'Comment',sprintf('errorbar E'));
        addConstructorArgin(code,arg);
    else
        % Come up with names for input variables:
        lName = get(this,'LDataSource');
        lName = code.cleanName(lName,'L');
        arg = codegen.codeargument('Name',lName,'Value',this.LData,'IsParameter',true,...
            'Comment',sprintf('errorbar L'));
        addConstructorArgin(code,arg);
        % Come up with names for input variables:
        uName = get(this,'UDataSource');
        uName = code.cleanName(uName,'U');
        arg = codegen.codeargument('Name',uName,'Value',this.UData,'IsParameter',true,...
            'Comment',sprintf('errorbar U'));
        addConstructorArgin(code,arg);
    end
else
    if isequal(net_ldata,net_udata)
        % Come up with names for input variables:
        eName = get(this,'LDataSource');
        eName = code.cleanName(eName,'EMatrix');
        arg = codegen.codeargument('Name',eName,'Value',net_ldata,'IsParameter',true,...
            'Comment',sprintf('errorbar E matrix'));
        addConstructorArgin(code,arg);
    else
        % Come up with names for input variables:
        lName = get(this,'LDataSource');
        lName = code.cleanName(lName,'LMatrix');
        arg = codegen.codeargument('Name',lName,'Value',net_ldata,'IsParameter',true,...
            'Comment',sprintf('errorbar L matrix'));
        addConstructorArgin(code,arg);
        % Come up with names for input variables:
        uName = get(this,'UDataSource');
        uName = code.cleanName(uName,'UMatrix');
        arg = codegen.codeargument('Name',uName,'Value',net_udata,'IsParameter',true,...
            'Comment',sprintf('errorbar U matrix'));
        addConstructorArgin(code,arg);
    end
end

% Output is a vector handle, input is a matrix
if isVectorOutput
    % Customize output to be a vector handle
    hFunc = getConstructor(code);
    constructor_name = get(hFunc,'Name');
    hArg = codegen.codeargument('Value',hConstructErrorList,...
        'Name',get(hFunc,'Name'));
    addArgout(hFunc,hArg);

    % Let user know that the output is multiple line handles
    set(hFunc,'Comment',...
        sprintf('Create multiple error bars using matrix input to %s', constructor_name));

    % Generate calls to "set" command
    codetoolsswitchyard('mcodePlotObjectVectorSet',code,hConstructMomentoList,@isDataSpecificFunction);

    % Output is a scalar handle
else
    generateDefaultPropValueSyntax(code);
end

%----------------------------------------------------------%
function name = localCleanName(name)
% Clean up a name by removing numeric suffixes and parentheses in the case
% of matrix input

% First check for an expression bounded by parentheses:
pInd = regexp(name,'(');
if ~isempty(pInd)
    name = name(1:pInd(1)-1);
end

% Check for numeric suffixes:
while (name(end) >= '0') && (name(end) <= '9')
    name(end) = [];
end

%-----------------------------------------------------------%
function res = localIsValidName(objName)
% Check to see if a *SourceName property will translate to a valid variable
% name:
res = true;
if isempty(objName) %Empty
    res = false;
    return;
elseif objName(1)>='0' && objName(1)<='9' %Numeric start
    res = false;
    return;
elseif objName(1) == '(' || objName(1) == '[' %Symbolic start
    res = false;
    return;
end

%----------------------------------------------------------%
function flag = localHasConstructor(hObj)
% Determine whether the peer object should be ignored due to the presence
% of a custom constructor
% Check app data

flag = false;
info = getappdata(hObj,'MCodeGeneration');
if isstruct(info) && isfield(info,'MCodeConstructorFcn')
    fcn = info.MCodeConstructorFcn;
    if ~isempty(fcn)
        flag = true;
    end

    % Check behavior object
else
    hb = hggetbehavior(hObj,'MCodeGeneration','-peek');
    if ~isempty(hb)
        fcn = get(hb,'MCodeConstructorFcn');
        if ~isempty(fcn)
            flag = true;
        end
    end
end

%--------------------------------------------------------------%
function local_generate_color(hObjMomento)

% Color may not have been generated, but needs to have been since the
% HG default doesn't really apply:
hasColor = true;
hPropertyList = get(hObjMomento,'PropertyObjects');
hObj = get(hObjMomento,'ObjectRef');
if isempty(hPropertyList)
    hasColor = false;
else
    if isempty(find(hPropertyList,'Name','Color'))
        hasColor = false;
    end
end
if ~hasColor && strcmpi(get(hObj,'codeGenColorMode'),'manual')
    pobj = codegen.momentoproperty;
    set(pobj,'Name','Color');
    set(pobj,'Value',get(hObj,'Color'));
    hPropertyList = [hPropertyList pobj];
    set(hObjMomento,'PropertyObject',hPropertyList);
end

%--------------------------------------------------------------%
function flag = isDataSpecificFunction(hObj, hProperty)
% Returns true is the function is generated as a side effect of the data,
% false otherwise

name = lower(get(hProperty,'Name'));

switch(name)
    case {'xdatamode','ydatasource','xdatasource','ldatasource',...
            'udatasource','xdata','ydata','ldata','udata','parent'}
        flag = true;
        
    case 'color'
        if strcmpi(get(hObj,'codeGenColorMode'),'auto');
            flag = true;
        else
            flag = false;
        end
    otherwise
        flag = false;
end