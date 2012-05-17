function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation

%   Copyright 1984-2008 The MathWorks, Inc.

is3D = ~isempty(this.ZData);
isMatrixData = false;

if is3D
    setConstructorName(code,'stem3');
    constName = 'stem3';
else
    setConstructorName(code,'stem');
    constName = 'stem';
end

plotutils('makemcode',this,code)

% Ignore certain properties
ignoreProperty(code,{'XData','XDataMode','YData','ZData','BaseLine',...
    'XDataSource','YDataSource','ZDataSource'});

hObjMomento = get(code,'MomentoRef');
hObj = get(hObjMomento,'ObjectRef');
local_generate_color(hObjMomento);

% Matrix outputs are returned only in the case of 2-D stem plots
if ~is3D
    set(hObjMomento,'Ignore',true);
    hParentMomento = up(hObjMomento);
    hPeerMomentoList = [];
    net_ydata = [];
    if ~isempty(hParentMomento)
        hPeerMomentoList = find(hParentMomento,'-depth',1);
        hConstructMomentoList = hObjMomento;
        hConstructLineList = hObj;
        net_ydata = get(hObj,'YData')';
        xdata = get(hObj,'XData');
    end
    % Loop through peer momento objects
    for n = 2:length(hPeerMomentoList)
        hPeerMomento = hPeerMomentoList(n);
        hPeerObj = get(hPeerMomento,'ObjectRef');
        if isa(hPeerObj,'specgraph.stemseries')
            peer_xdata = get(hPeerObj,'XData');

            % If the momento object is a lineseries with the same
            % xdata as this object.
            if ~isequal(hPeerObj,hObj) && ...
                    ~get(hPeerMomento,'Ignore') && ...
                    isequal(xdata,peer_xdata) && ...
                    ~localHasConstructor(hPeerObj)

                % Add handle to list of constructor output handles
                hConstructMomentoList = [hConstructMomentoList;hPeerMomento];
                hConstructLineList = [hConstructLineList;hPeerObj];
                net_ydata = [net_ydata,get(hPeerObj,'ydata')'];
                % Mark the monento to be ignored by the code generation engine
                % since this momento object is already being
                % created by this constructor
                set(hPeerMomento,'Ignore',true);
                local_generate_color(hPeerMomento);
                % Constructor output is now a vector of handles
                isMatrixData = true;
            end
        end
    end % for
end

% process XData
if strcmp(this.XDataMode,'manual')
    % Come up with names for input variables:
    xName = get(this,'XDataSource');
    xName = code.cleanName(xName,'X');
    arg = codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
        'Comment', sprintf('%s X', constName));
    addConstructorArgin(code,arg);
end

% process YData
% Come up with names for input variables:
if isMatrixData
    yName = 'ymatrix';
else
    yName = get(this,'YDataSource');
    yName = code.cleanName(yName,'Y');
end
arg = codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true);
if isMatrixData
   set(arg,'Comment',sprintf('stem matrix data'));
else
    set(arg,'Comment', sprintf('%s Y', constName));
end
addConstructorArgin(code,arg);

% process ZData
if is3D
    % Come up with names for input variables:
    zName = get(this,'ZDataSource');
    if ~isempty(strfind(zName,'getcolumn'))
        zName = [];
    end
    zName = code.cleanName(zName,'Z');
    arg = codegen.codeargument('Name',zName,'Value',...
        this.ZData, ...
        'IsParameter',true,...
        'Comment', sprintf('%s Z', constName));
    addConstructorArgin(code,arg);
end


if ~isMatrixData
    % process Color
    if strcmp(this.CodeGenColorMode,'auto')
        ignoreProperty(code,'Color')
    end

    % process LineStyle
    if strcmp(this.CodeGenLineStyleMode,'auto')
        ignoreProperty(code,'LineStyle')
    end

    % process Marker
    if strcmp(this.CodeGenMarkerMode,'auto')
        ignoreProperty(code,'Marker')
    end
    generateDefaultPropValueSyntax(code);
else
    % Generate calls to "set" command
    % Set up output argument
    hFunc = get(code,'Constructor');
    hArg = codegen.codeargument('Value',hConstructLineList,...
        'Name',get(hFunc,'Name'));
    addArgout(hFunc,hArg);    
    % Let user know that the output is multiple line handles
    set(hFunc,'Comment',...
        sprintf('Create multiple lines using matrix input to %s', hFunc.Name));
    codetoolsswitchyard('mcodePlotObjectVectorSet',code,hConstructMomentoList,@isDataSpecificFunction);
end

plotutils('MCodeBaseLine',this,code);

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

%----------------------------------------------------------%
function flag = localHasConstructor(hLine)
% Determine whether the peer object should be ignored due to the presence
% of a custom constructor
% Check app data

flag = false;
info = getappdata(hLine,'MCodeGeneration');
if isstruct(info) && isfield(info,'MCodeConstructorFcn')
    fcn = info.MCodeConstructorFcn;
    if ~isempty(fcn)
        flag = true;
    end

    % Check behavior object
else
    hb = hggetbehavior(hLine,'MCodeGeneration','-peek');
    if ~isempty(hb)
        fcn = get(hb,'MCodeConstructorFcn');
        if ~isempty(fcn)
            flag = true;
        end
    end
end

%--------------------------------------------------------------%
function flag = isDataSpecificFunction(hObj, hProperty)
% Returns true is the function is generated as a side effect of the data,
% false otherwise

name = lower(get(hProperty,'Name'));
switch(name)
    case {'xdatamode','ydatasource','xdatasource','zdatasource','xdata','ydata','baseline','zdata'}
        flag = true;
        
    case 'color'
        if strcmpi(get(hObj,'codeGenColorMode'),'auto');
            flag = true;
        else
            flag = false;
        end
    case 'linestyle'
        if strcmpi(get(hObj,'codeGenLineStyleMode'),'auto');
            flag = true;
        else
            flag = false;
        end
    case 'marker'
        if strcmpi(get(hObj,'codeGenMarkerMode'),'auto');
            flag = true;
        else
            flag = false;
        end
    otherwise
        flag = false;
end