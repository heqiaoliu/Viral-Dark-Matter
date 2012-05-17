function mcodeDefaultConstructor(hObj,hCode)
% Default implementation for m-code generation object interface
% Called by MAKEMCODE, the code generator engine

% Copyright 2003-2008 The MathWorks, Inc.

% Generate helper functions
if isa(hObj,'hg.axes')
    localHGAxes_createConstructor(hObj,hCode);
elseif isa(hObj,'hg.surface')
    localHGSurface_createConstructor(hObj,hCode);
elseif isa(hObj,'hg.line')
    localHGLine_createConstructor(hObj,hCode);
elseif isa(hObj,'hg.image')
    localHGImage_createConstructor(hObj,hCode);
elseif isa(hObj,'hg.figure')
    localHGFigure_createConstructor(hObj,hCode);
elseif isa(hObj,'hg.text')
    localHGText_createConstructor(hObj,hCode);
elseif strncmp(class(hObj),'ui',2)
    localUI_createConstructor(hObj,hCode);
else
    % Generate param-value syntax for remaining properties 
    generateDefaultPropValueSyntax(hCode); 
end

%----------------------------------------------------------%
function localHGFigure_createConstructor(hObj,hCode)

% generate a call to 'figure'
% ToDo: This is specific to plot creation and will not be
% suitable for GUIDE applications.

%Generate:
%  colormap(...)
% Find the colormap property
hRef = get(hCode,'MomentoRef');
hProps = get(hRef,'PropertyObject');
propIndex = find(strcmpi(get(hProps,'Name'),'Colormap'));
if ~isempty(propIndex)
    colormap_name = [];
    cmap = get(hObj,'Colormap');
    known_colormaps = {'jet', 'hsv', 'hot', 'gray', 'bone', 'copper', 'pink', 'white', 'flag', 'lines', 'colorcube',  'prism', 'cool', 'autumn', 'spring', 'winter', 'summer'};
    for n = 1:length(known_colormaps)
        if isequal(cmap, feval(known_colormaps{n}, length(cmap)))
            colormap_name = known_colormaps{n};
            % If the colormap is a known colormap, don't add it to the
            % constructor.
            set(hProps(propIndex),'Ignore',true);
            break;
        end
    end
    if ~isempty(colormap_name)
        hArg = codegen.codeargument('Value',colormap_name);
        hFunc = codegen.codefunction('Name','colormap','CodeRef',hCode);
        addArgin(hFunc,hArg);
        addPostConstructorFunction(hCode,hFunc);
    end
end
% Generate param-value syntax for remaining properties
generateDefaultPropValueSyntax(hCode);

%----------------------------------------------------------%
function localHGText_createConstructor(hObj,hCode)
% Specify generated m-code for text

hObj = handle(hObj);
hAxes = get(hObj,'Parent');
if isa(handle(hAxes),'hg.axes')

    % Register labels with m-code generator
    str = [];
    if isequal(hObj, handle(get(hAxes,'XLabel')))
        str = 'xlabel';
    elseif isequal(hObj, handle(get(hAxes,'YLabel')))
        str = 'ylabel';
    elseif isequal(hObj, handle(get(hAxes,'ZLabel')))
        str = 'zlabel';
    elseif isequal(hObj, handle(get(hAxes,'Title')))
        str = 'title';
    end

    if ~isempty(str)
        localAxesLabelMCodeConstructor(hObj,hCode,str)
    else
        generateDefaultPropValueSyntax(hCode);
    end
else
    % Generate param-value syntax for remaining properties
    generateDefaultPropValueSyntax(hCode);
end

%----------------------------------------------------------%
function localAxesLabelMCodeConstructor(hObj,hCode,strname)
% Specify generated m-code for axes label/title objects

val = get(hObj,'String');
hAxes = ancestor(hObj,'axes');
is2Daxes = is2D(hAxes);

% Don't generate code for labels if the string is empty
if ~isempty(val)
    setConstructorName(hCode,strname);
    % Ignore the "Position" property until the default units aren't "data".
    ignoreProperty(hCode,{'String','Parent','Position'});
    % Deal with the alignment
    if strcmpi(strname,'title')
        if strcmpi(get(hObj,'HorizontalAlignment'),'center')
            ignoreProperty(hCode,'HorizontalAlignment');
        else
            addProperty(hCode,'HorizontalAlignment');
        end
        if strcmpi(get(hObj,'VerticalAlignment'),'bottom')
            ignoreProperty(hCode,'VerticalAlignment');
        else
            addProperty(hCode,'VerticalAlignment');
        end
    elseif strcmpi(strname,'xlabel')
        if ~is2Daxes
            if strcmpi(get(hObj,'VerticalAlignment'),'top')
                ignoreProperty(hCode,'VerticalAlignment');
            else
                addProperty(hCode,'VerticalAlignment');
            end
            if strcmpi(get(hObj,'HorizontalAlignment'),'left')
                ignoreProperty(hCode,'HorizontalAlignment');
            else
                addProperty(hCode,'HorizontalAlignment');
            end
        else
            if strcmpi(get(hObj,'VerticalAlignment'),'cap')
                ignoreProperty(hCode,'VerticalAlignment');
            else
                addProperty(hCode,'VerticalAlignment');
            end
            if strcmpi(get(hObj,'HorizontalAlignment'),'center')
                ignoreProperty(hCode,'HorizontalAlignment');
            else
                addProperty(hCode,'HorizontalAlignment');
            end
        end
    elseif strcmpi(strname,'ylabel')
        if get(hObj,'Rotation')==90 && is2Daxes
            ignoreProperty(hCode,'Rotation');
        end
        if ~is2Daxes
            if strcmpi(get(hObj,'HorizontalAlignment'),'right')
                ignoreProperty(hCode,'HorizontalAlignment');
            else
                addProperty(hCode,'HorizontalAlignment');
            end
            if strcmpi(get(hObj,'VerticalAlignment'),'top')
                ignoreProperty(hCode,'VerticalAlignment');
            else
                addProperty(hCode,'VerticalAlignment');
            end
        else
            if strcmpi(get(hObj,'HorizontalAlignment'),'center')
                ignoreProperty(hCode,'HorizontalAlignment');
            else
                addProperty(hCode,'HorizontalAlignment');
            end
            if strcmpi(get(hObj,'VerticalAlignment'),'bottom')
                ignoreProperty(hCode,'VerticalAlignment');
            else
                addProperty(hCode,'VerticalAlignment');
            end
        end
    elseif strcmpi(strname,'zlabel')
        if ~is2Daxes
            if strcmpi(get(hObj,'HorizontalAlignment'),'center')
                ignoreProperty(hCode,'HorizontalAlignment');
            else
                addProperty(hCode,'HorizontalAlignment');
            end
            if strcmpi(get(hObj,'VerticalAlignment'),'bottom')
                ignoreProperty(hCode,'VerticalAlignment');
            else
                addProperty(hCode,'VerticalAlignment');
            end
        else
            if strcmpi(get(hObj,'HorizontalAlignment'),'right')
                ignoreProperty(hCode,'HorizontalAlignment');
            else
                addProperty(hCode,'HorizontalAlignment');
            end
            if strcmpi(get(hObj,'VerticalAlignment'),'middle')
                ignoreProperty(hCode,'VerticalAlignment');
            else
                addProperty(hCode,'VerticalAlignment');
            end
        end
        if get(hObj,'Rotation')==90 && ~is2Daxes
            ignoreProperty(hCode,'Rotation')
        end
    end

    % Create constructor input argument: string
    hArg = codegen.codeargument('Value',val); 
    addConstructorArgin(hCode,hArg); % method
    
    % Generate param-value syntax for remaining properties
    generateDefaultPropValueSyntaxNoOutput(hCode);
end

%----------------------------------------------------------%
function localHGImage_createConstructor(hObj,hCode)
% Specify generated m-code for image

% Don't generate param-value syntax for these properties,
ignoreProperty(hCode,{'XData','YData','CData'});

% Determine if xdata, ydata were auto-generated
xdata = get(hObj,'XData');
ydata = get(hObj,'YData');
cdata = get(hObj,'CData');
m = size(cdata,1);
n = size(cdata,2);

% Generate first two input arguments: xdata and ydata
% only if they are not generated by default
if ~isequal(xdata,[1,n]) || ~isequal(ydata,[1,m])
    hArg = codegen.codeargument('Name','xdata','Value',xdata);
    addConstructorArgin(hCode,hArg);
    hArg = codegen.codeargument('Name','ydata','Value',ydata);
    addConstructorArgin(hCode,hArg);
end

% Force cdata to be the next input argument of constructor
hArg = codegen.codeargument('Name','cdata','Value',cdata,'IsParameter',true);
addConstructorArgin(hCode,hArg);

% Generate param-value syntax for remaining properties
generateDefaultPropValueSyntax(hCode); % method

%----------------------------------------------------------%
function localHGLine_createConstructor(hObj,hCode)

ignoreProperty(hCode,{'XData','YData','ZData'}); 
    
xdata = get(hObj,'XData');
ydata = get(hObj,'YData');
zdata = get(hObj,'ZData');

% xdata
hArg = codegen.codeargument('Name','XData','Value',xdata,'IsParameter',true);
addConstructorArgin(hCode,hArg);

% ydata
hArg = codegen.codeargument('Name','YData','Value',ydata,'IsParameter',true);
addConstructorArgin(hCode,hArg);

% zdata
if ~isempty(zdata)
   hArg = codegen.codeargument('Name','ZData','Value',zdata,'IsParameter',true);
   addConstructorArgin(hCode,hArg);
end

% Generate param-value syntax for remaining properties
generateDefaultPropValueSyntax(hCode); % method

%----------------------------------------------------------%
function localHGSurface_createConstructor(hObj,hCode)

% Don't show xdata, ydata if auto-generated
% Determine if xdata and ydata were auto generated by
% surface at constructor time. This is basically 
% reverse engineering how the surface constructor wrt
% how it handles zdata when doing: "surface(zdata)"

xdata = get(hObj,'xdata');
ydata = get(hObj,'ydata');
zdata = get(hObj,'zdata');
m = size(zdata,1);
n = size(zdata,2);

% surface('zdata',...)
if isequal(xdata,1:m) && isequal(ydata',1:n)
    ignoreProperty(hCode,{'XData','YData','ZData'});
    
    % Force zdata to be first input argument of constructor
    hArg = codegen.codeargument('Name','ZData','Value',zdata,'IsParameter',true);
    addConstructorArgin(hCode,hArg);
end

% Don't show VertexNormals if auto-generated
if strcmpi(get(hObj,'NormalMode'),'auto');
    ignoreProperty(hCode,{'VertexNormals'});
end

% Generate param-value syntax for remaining properties
generateDefaultPropValueSyntax(hCode); % method

%----------------------------------------------------------%
function localHGAxes_createConstructor(hObj,hCode)
% Default implementation for axes.

setConstructorName(hCode,'axes'); % method

% If 'ActivePosition' property is 'Position', then don't generate
% code for 'OuterPosition' property.
if strcmpi(get(hObj,'ActivePositionProperty'),'Position')
    ignoreProperty(hCode,{'ActivePositionProperty','OuterPosition'});
else
    ignoreProperty(hCode,{'ActivePositionProperty','Position'});
end
% Ignore the axes limits
ignoreProperty(hCode,{'xlim','ylim','zlim'});
    
% If 'ActivePosition' property is 'OuterPosition', then don't generate
% code for 'Position'. If, however, the axes was generated by the subplot
% command, then don't generated a call to 'OuterPosition' since the layout
% will be wrong -since 'LooseInsets' is not documented we can't generate 
% the proper code which will work for subplots. 
hFig = handle(ancestor(hObj,'figure'));
appdata = handle(getappdata(hFig,'SubplotGrid'));
if any(hObj==appdata(:)) % if axes is part of a subplot
    ignoreProperty(hCode,{'Position'});
    % Find the subplot where the axes lives:
    [row,col] = find(appdata==hObj);
    % The row index stored is the reverse from the index into the grid
    row = size(appdata,1)-row+1;
    % Compute the size of the grid
    gridRow = size(appdata,1);
    gridCol = size(appdata,2);
    % Convert the (row,index) pair into a row-major linear index:
    ind = sub2ind([gridCol,gridRow],col,row);
    % Change the constructor name and add input arguments:
    setConstructorName(hCode,'subplot');
    hRowArg = codegen.codeargument('Value',gridRow);
    hColArg = codegen.codeargument('Value',gridCol);
    hInd = codegen.codeargument('Value',ind);
    addConstructorArgin(hCode,hRowArg);
    addConstructorArgin(hCode,hColArg);
    addConstructorArgin(hCode,hInd);
end

% Generate code for 'View' or 'CameraPosition' but not both. This is 
% because the two properties are interdependent.
if hasProperty(hCode,'View') && hasProperty(hCode,'CameraPosition')
    ignoreProperty(hCode,'View');
end

% Add helper functions like 'view' and 'axis'
localAddAxesHelperFunctions(hObj,hCode);

% Force the code generator to generate these properties
% since the hg default for XTick is empty.

if strcmp(get(hObj,'XTickMode'),'manual') && ~hasProperty(hCode,'XTick')
    addProperty(hCode,'XTick');
end
if strcmp(get(hObj,'YTickMode'),'manual') && ~hasProperty(hCode,'YTick')
    addProperty(hCode,'YTick');
end
if ~is2D(hObj) && strcmp(get(hObj,'ZTickMode'),'manual') && ~hasProperty(hCode,'ZTick')
    addProperty(hCode,'ZTick');
end

if strcmp(get(hObj,'XTickLabelMode'),'manual') && ~hasProperty(hCode,'XTickLabel')
    addProperty(hCode,'XTickLabel');
end
if strcmp(get(hObj,'YTickLabelMode'),'manual') && ~hasProperty(hCode,'YTickLabel')
    addProperty(hCode,'YTickLabel');
end
if ~is2D(hObj) && strcmp(get(hObj,'ZTickLabelMode'),'manual') && ~hasProperty(hCode,'ZTickLabel')
    addProperty(hCode,'ZTickLabel');
end

if strcmpi(get(hObj,'DataAspectRatioMode'),'manual') && ~hasProperty(hCode,'DataAspectRatio')
    addProperty(hCode,'DataAspectRatio');
end

% Tell the code generator to treat tick labels as 
% strings with no new char line - each row of the array 
% should represent a tick string.
props = {'XTickLabel','YTickLabel','ZTickLabel'}; 
setDataTypeDescriptor(hCode,props,'CharNoNewLine');

% If a legend or colorbar has resized the axes, use the original axes
% position as the "Position" property:
if isappdata(double(hObj),'LegendColorbarExpectedPosition') && ... 
        isequal(getappdata(double(hObj),'LegendColorbarExpectedPosition'),get(hObj,'Position'))
    inset = getappdata(hObj,'LegendColorbarOriginalInset');
    if isempty(inset)
        % during load the appdata might not be present
        inset = get(get(hObj,'Parent'),'DefaultAxesLooseInset');
    end
    inset = offsetsInUnits(hObj,inset,'normalized',get(hObj,'Units'));
    if strcmpi(get(hObj,'ActivePositionProperty'),'position')
        pos = get(hObj,'Position');
        loose = get(hObj,'LooseInset');
        opos = getOuterFromPosAndLoose(pos,loose,get(hObj,'Units'));
        if strcmp(get(hObj,'Units'),'normalized')
            inset = [opos(3:4) opos(3:4)].*inset;
        end
        pos = [opos(1:2)+inset(1:2) opos(3:4)-inset(1:2)-inset(3:4)];
        if ~any(isnan(pos)) && all(pos(3:4) > 0)
            posProp = hCode.getProperty('Position');
            set(posProp,'Value',pos);
        end
    end
end

% Generate param-value syntax for remaining properties
generateDefaultPropValueSyntax(hCode); % method

%----------------------------------------------------------%
function localAddAxesHelperFunctions(hObj,hCode)
% Generate post constructor helper functions for axes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% xlim(...), ylim(...), zlim(...)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ignoreProperty(hCode,{'xlim','ylim','zlim'});

% Get this object's state
is_xauto = strcmpi(get(hObj,'XLimMode'),'auto');
is_yauto = strcmpi(get(hObj,'YLimMode'),'auto');
is_zauto = strcmpi(get(hObj,'ZLimMode'),'auto');
xlm = get(hObj,'XLim');
ylm = get(hObj,'YLim');
zlm = get(hObj,'ZLim');

% Add commented calls to XLIM, YLIM and ZLIM:
hAxesArg = codegen.codeargument('Value',hObj,'IsParameter',true);
if ~is_xauto 
    hCode.addPostConstructorText(sprintf('%% Uncomment the following line to preserve the X-limits of the axes'));
    hArg = codegen.codeargument('Value',xlm);
    hCode.addPostConstructorText('% xlim(',hAxesArg,',',hArg,');');
end
if ~is_yauto
    hCode.addPostConstructorText(sprintf('%% Uncomment the following line to preserve the Y-limits of the axes'));
    hArg = codegen.codeargument('Value',ylm);
    hCode.addPostConstructorText('% ylim(',hAxesArg,',',hArg,');');
end
if ~is_zauto
    hCode.addPostConstructorText(sprintf('%% Uncomment the following line to preserve the Z-limits of the axes'));
    hArg = codegen.codeargument('Value',zlm);
    hCode.addPostConstructorText('% zlim(',hAxesArg,',',hArg,');');
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % xlabel(...), ylabel(...), zlabel(...), title(...)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
props = {'title','xlabel','ylabel','zlabel'};
ignoreProperty(hCode,props); 

%%%%%%%%%%%%%%%%
% view(axes,...)
%%%%%%%%%%%%%%%%
if hasProperty(hCode,'View')
   ignoreProperty(hCode,'View');
   local_CreateAxesHelperFunction(hObj,hCode,'view',get(hObj,'View'));
end

%%%%%%%%%%%%%%%%
% box(axes,...)
%%%%%%%%%%%%%%%%
if hasProperty(hCode,'Box')
   ignoreProperty(hCode,'Box');
   local_CreateAxesHelperFunction(hObj,hCode,'box',get(hObj,'Box'));
end

%%%%%%%%%%%%%%%%
% grid(axes,...)
%%%%%%%%%%%%%%%%
is_xgrid = strcmpi(get(hObj,'XGrid'),'on');
is_ygrid = strcmpi(get(hObj,'YGrid'),'on');
is_zgrid = strcmpi(get(hObj,'ZGrid'),'on');
if is_xgrid && is_ygrid && is_zgrid
   ignoreProperty(hCode,{'XGrid','YGrid','ZGrid'});
   local_CreateAxesHelperFunction(hObj,hCode,'grid','on');
end

do_hold_all = true;

%%%%%%%%%%%%%%%%%%
% hold(axes,'all')
%%%%%%%%%%%%%%%%%%
% Note: We must call hold(...) before the first plot is constructed 
% since some plots like surf.m will wipe out portions of the axes 
% state.
if (  do_hold_all && ...
      (strcmpi(get(hObj,'NextPlot'),'add') || ~isempty(plotchild(hObj))) ...
   )
    local_CreateAxesHelperFunction(hObj,hCode,'hold','all');
end
ignoreProperty(hCode,'NextPlot');
    
%---------------------------------------------------------%
function local_CreateAxesHelperFunction(hObj,hCode,fname,fval)
% Utility for creating axes helper functions in the form of:
%    fname(hAxes,fval);

% Create function object
hFunc = codegen.codefunction('Name',fname,'CodeRef',hCode);
addPostConstructorFunction(hCode,hFunc); % method
       
% Create input argument: string
hAxesArg = codegen.codeargument('Value',hObj,'IsParameter',true);
addArgin(hFunc,hAxesArg); % method
hArg = codegen.codeargument('Value',fval);
addArgin(hFunc,hArg); % method

%---------------------------------------------------------%
function localUI_createConstructor(hObj,hCode)
% Show a message regarding ui* objects

hClass = hObj.classhandle;
constructorString = hClass.Name;

setConstructorName(hCode,constructorString); % method

hFunc = getConstructor(hCode);
str = sprintf('%% %s(...)',constructorString);
comment = sprintf('%% %s currently does not support code generation, enter ''doc %s'' for correct input syntax\n',constructorString,constructorString);
comment = [comment sprintf('%% In order to generate code for %s, you may use GUIDE. Enter ''doc guide'' for more information\n',constructorString)];
set(hFunc,'Comment',comment);
set(hFunc,'Name',str);

%----------------------------------------------------------------%
% Convert units of offsets like LooseInset or TightInset
% Note: Copied from legendcolorbarlayout.m
function out = offsetsInUnits(ax,in,from,to)
fig = ancestor(ax,'figure');
par = get(ax,'Parent');
p1 = hgconvertunits(fig,[0 0 in(1:2)],from,to,par);
p2 = hgconvertunits(fig,[0 0 in(3:4)],from,to,par);
out = [p1(3:4) p2(3:4)];

%----------------------------------------------------------------%
% Compute reference OuterPos from pos and loose. Note that
% loose insets are relative to outerposition
% Note: Copied from legendcolorbarlayout.m
function outer = getOuterFromPosAndLoose(pos,loose,units)
if strcmp(units,'normalized')
    % compute outer width and height and normalize loose to them
    w = pos(3)/(1-loose(1)-loose(3));
    h = pos(4)/(1-loose(2)-loose(4));
    loose = [w h w h].*loose;
end
outer = [pos(1:2)-loose(1:2) pos(3:4)+loose(1:2)+loose(3:4)];