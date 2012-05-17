function [argout] = inspect(varargin)
%INSPECT Open the inspector and inspect object properties
%
%   INSPECT (h) edits all properties of the given object whose handle is h,
%   using a property-sheet-like interface.
%   INSPECT ([h1, h2]) edits both objects h1 and h2; any number of objects
%   can be edited this way.  If you edit two or more objects of different
%   types, the inspector might not be able to show any properties in common.
%   INSPECT with no argument launches a blank inspector window.
%
%   Note that "INSPECT h" edits the string 'h', not the object whose
%   handle is h.

%   Copyright 1984-2008 The MathWorks, Inc.

% error out if there is insufficient java support on this platform
error(javachk('jvm', 'The Property Inspector'));

import com.mathworks.mlservices.*;
nin = nargin;
vargin = varargin;
doPushToFront = true;
doAddDestroyListener = false;

if nargin==1
    if ischar(vargin{1})
        switch(vargin{1})
            case '-close'
                MLInspectorServices.closeWindow;
                return; 
            case '-isopen'
                argout = MLInspectorServices.isInspectorOpen;
                return;
            case '-isnewinspector'
                argout = MLInspectorServices.isNewInspector;
                return;
        end
    end

elseif nargin>=2
    if ischar(vargin{1})

        switch(vargin{1})

            % For debugging
            case 'newinspector'
                if strcmp(varargin{2},'on')
                    MLInspectorServices.setUseNewInspector(true);
                elseif strcmp(varargin{2},'off')
                    MLInspectorServices.setUseNewInspector(false);
                end
                return

            % For debugging
            % Remove this syntax entirely after 7B release
            case 'newtreetable'
                warning('MATLAB:uitools:inspector:invalidsyntax', ....
                        'inspect(''newtreetable'',...) syntax no longer supported');
                return
                
            % For debugging
            case 'desktopclient'
                if strcmp(varargin{2},'on')
                    com.mathworks.mde.inspector.Inspector.setDesktopClient(true);
                elseif strcmp(varargin{2},'off')
                    com.mathworks.mde.inspector.Inspector.setDesktopClient(false);
                end
                return
                
            % For debugging
            case 'autoupdate'
                if strcmp(varargin{2},'on')
                    com.mathworks.mde.inspector.Inspector.setAutoUpdate(true);
                elseif strcmp(varargin{2},'off')
                    com.mathworks.mde.inspector.Inspector.setAutoUpdate(false);
                end
                return
                
            % Called by the inspector Java code
            case '-getInspectorPropertyGrouping'
                obj = varargin{2};
                argout = localGetInspectorPropertyGrouping(obj);
                return;
            
            % Called by the inspector Java code    
            case '-hasHelp'
                obj = varargin{2};
                argout = localHasHelp(obj);
                return;
                
            % Called by the inspector Java code    
            case '-showHelp'
                if length(varargin)>=3
                   obj = varargin{2};
                   propname = varargin{3};
                   localShowHelp(obj,propname);
                end
                return;
                
        end % Switch
        
    elseif ischar(vargin{2})
        switch(vargin{2})
            case '-ifopen'
                if (MLInspectorServices.isInspectorOpen)
                    % prune off string
                    nin = 1;
                    doPushToFront = false;
                else
                    return;
                end
        end
    end
end

switch nin

    case 0
        % Show the inspector.
        MLInspectorServices.invoke;

    case 1
        obj = vargin{1};
        
        % inspect([])
        if isempty(obj)
            hdl = []; 
        
        % inspect(java.lang.String)    
        elseif all(isjava(obj))
            hdl = [];
            
        % inspect(gcf)
        elseif all(ishghandle(obj)) || (all(isa(obj, 'handle') && all(isobject(obj)) && all(isvalid(obj))) ...
            || all(ishandle(obj)))

            if isobject(obj) && ~isa(obj, 'JavaVisible')
                error('MATLAB:uitools:inspector:invalidobject','The input is not supported by the Property Inspector.');
            end
            
            hdl = obj;
            
        else
            error('MATLAB:uitools:inspector:invalidinput','Input to inspect must be a valid object as defined by ISHANDLE.');
        end
        
        if ~isempty(hdl)
            len = length(hdl);
            if len == 1
                 if len == 1 && ~isa(obj, 'handle')
                    % obj has value semantics so do not make a copy that was
                    % made from hdl = obj(...)
                    obj = requestJavaAdapter(obj);
                else
                    obj = requestJavaAdapter(hdl);
                end
                if ~localIsUDDObject(obj)
                   doAddDestroyListener = true;
                end
                MLInspectorServices.inspectObject(obj,doPushToFront);
            else
                obj = requestJavaAdapter(hdl);
                if ~localIsUDDObject(obj)
                    doAddDestroyListener = true;
                end
                MLInspectorServices.inspectObjectArray(obj,doPushToFront);
            end
            
            if ~MLInspectorServices.isNewInspector || doAddDestroyListener
                % For original MWT inspector only.
                % listen to when the object gets deleted and remove
                % from inspector. A persistent variable is used since
                % the inspector is a singleton. If we do go away from
                % a singleton then this will have to be stored elsewhere.
                persistent deleteListener; %#ok
                hobj = handle(hdl);
                deleteListener = handle.listener(hobj, 'ObjectBeingDestroyed', ...
                    {@localObjectRemoved, obj, MLInspectorServices.getRegistry});
            end

        else
            % g512786 This is necessary because inrepreter does not
            % convert empty MCOS objects to null and this call would error
            % out. It worked fine for UDD objects because interpreter
            % converted them to null in this case. Pass in [] only for
            % MATLAB objects as returned by isobject(). For all other
            % objects including Java objects use obj reference.
            if isobject(obj)
                MLInspectorServices.inspectObject([],doPushToFront);
            else
                MLInspectorServices.inspectObject(obj,doPushToFront);
            end
        end

    otherwise
        % bug -- need to make java adapters for multiple arguments
        MLInspectorServices.inspectObjectArray(vargin,doPushToFront);

end

%----------------------------------------------------%
function localObjectRemoved(hSrc, event, obj, objRegistry) %#ok
% Used by original MWT Inspector implementation

objRegistry.setSelected({obj}, 0);

%----------------------------------------------------%
function bool = localIsUDDObject(h)
% Returns true if the input handles can be represented as a
% UDDObject in Java. We need to know this in order to determine
% whether or not we can add listeners on the Java side or the
% m-code side.
% 
% Example:
%    handle(0)                 Returns true 
%    handle(java.awt.Button)   Returns false

import com.mathworks.mlservices.*;
bool = false;
if isscalar(h)
   bool = MLInspectorServices.isUDDObjectInJava(h);
elseif isvector(h)
   bool = MLInspectorServices.isUDDObjectArrayInJava(h);  
end

%----------------------------------------------------%
function jhash = localGetInspectorPropertyGrouping(obj)

jhash = java.util.HashMap;

% For now, don't group multiple objects
if iscell(obj)
    obj = obj{1};
end

% Cast to a handle
if ~ishandle(obj)
    return
end
obj = handle(obj);
 
% Get grouping for this object
info = localGetGrouping(obj);

% Convert to a hashtable
for n = 1:length(info)
   group_name = info{n}{1};
   prop_names = info{n}{2};
   for m = 1:length(prop_names);
      jhash.put(prop_names{m},group_name);
   end
end

%----------------------------------------------------%
function info = localGetGrouping(obj)

info = [];

% Delegate to object
if ishandle(obj) && ismethod(obj,'getInspectorGrouping')
    
    % call the method
    try 
       info = getInspectorGrouping(obj,'-cellarray');
    catch
       % do nothing, author of method must debug the error
    end
    
    % add on generic property groups
    if ishghandle(obj)
       generic_info = localGetGenericGrouping;
       info{end+1} = generic_info{:};
    end
end

% HG objects
if all(ishghandle(obj))
    if isa(obj,'figure')
       generic_info = localGetGenericGrouping;
       info = localGetFigureGrouping;
       info{end+1} = generic_info{:};
    elseif isa(obj,'root')
       generic_info = localGetGenericGrouping;
       info = localGetRootGrouping;
       info{end+1} = generic_info{:};
    elseif isa(obj,'axes')
       generic_info = localGetGenericGrouping;
       info = localGetAxesGrouping;
       info{end+1} = generic_info{:};

    % AXES CHILDREN   
    elseif isa(obj,'surface')
        generic_info = localGetGenericGrouping;
        info = localGetSurfaceGrouping;
        info{end+1} = generic_info{:};
    elseif isa(obj,'patch')
        generic_info = localGetGenericGrouping;
        info = localGetPatchGrouping;
        info{end+1} = generic_info{:};
    elseif isa(obj,'image')
        generic_info = localGetGenericGrouping;
        info = localGetImageGrouping;
        info{end+1} = generic_info{:};
    elseif isa(obj,'rectangle')
        generic_info = localGetGenericGrouping;
        info = localGetRectangleGrouping;
        info{end+1} = generic_info{:};
    elseif isa(obj,'line')
        generic_info = localGetGenericGrouping;
        info = localGetLineGrouping;
        info{end+1} = generic_info{:};
    elseif isa(obj,'light')
        generic_info = localGetGenericGrouping;
        info = localGetLightGrouping;
        info{end+1} = generic_info{:};
    elseif isa(obj,'text')
        generic_info = localGetGenericGrouping;
        info = localGetTextGrouping;
        info{end+1} = generic_info{:};
        
    % UI WIDGETS    
    elseif isa(obj,'uicontrol')
        generic_info = localGetGenericGrouping;
        info = localGetUIControlGrouping;
        info{end+1} = generic_info{:};       
    elseif isa(obj, 'uitable')
        generic_info = localGetGenericGrouping;
        info = localGetUITableGrouping;
        info{end+1} = generic_info{:};       
    elseif isa(obj,'uipanel')
        generic_info = localGetGenericGrouping;
        info = localGetUIPanelGrouping;
        info{end+1} = generic_info{:};           
        % uibuttongroup is a subclass of uipanel
        if isa(obj,'uitools.uibuttongroup')
            subclass_info = localGetUIButtonGroupGrouping;
            info{end+1} = subclass_info{:}; 
        end
    end
end

%----------------------------------------------------%
function retval = localGetGenericGrouping

info{1} = 'Base Properties';
info{2} = {'BeingDeleted','BusyAction','ButtonDownFcn','Children',...
    'Clipping','CreateFcn','DeleteFcn','HandleVisibility',...
    'HitTest','Interruptible','Parent','Selected','SelectionHighlight',...
    'Tag','Type','UIContextMenu','UserData','Visible'};
retval{1} = info;

%----------------------------------------------------%
function retval = localGetFigureGrouping

info{1}= 'Control';
info{2}= {'Resize','NextPlot','IntegerHandle','SelectionType',...
    'CloseRequestFcn','WindowButtonDownFcn',...
	'WindowButtonMotionFcn','WindowButtonUpFcn',...
    'WindowScrollWheelFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', 'ResizeFcn',...
    'KeyPressFcn','CurrentAxes','CurrentCharacter',...
    'CurrentObject','CurrentPoint','WindowScrollWheelFcn','KeyReleaseFcn'};
retval{1} = info;

info{1} = 'Printing';
info{2} = {'FileName','PaperUnits', 'PaperOrientation','PaperPosition',...
	'PaperPositionMode','InvertHardcopy','PaperSize','PaperType'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'FileName','Name','NumberTitle','Units'};
retval{end+1} = info;

info{1} = 'Style/Appearance';
info{2} = {'Renderer','RendererMode','DoubleBuffer','BackingStore',...
    'Alphamap','WindowStyle','Color','Colormap','WVisual',...
    'MenuBar','DockControls','Toolbar','Pointer','PointerShapeHotSpot',...
    'PointerShapeCData','Position','ToolBar',...
    'WVisualMode','XVisualMode','XDisplay','XVisual'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetRootGrouping

info{1}= 'Style/Appearance';
info{2}= {'CommandWindowSize','FixedWidthFontName','Language','Format','FormatSpacing',...
          'PointerLocation','PointerWindow'};
retval{1} = info;

info{1} = 'Screen';
info{2} = {'MonitorPositions','ScreenSize','ScreenPixelsPerInch','ScreenDepth'};
retval{end+1} = info;

info{1} = 'Control';
info{2} = {'CallbackObject','Diary','DiaryFile','Echo','More','RecursionLimit','ShowHiddenHandles',...
    'Units'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAxesGrouping

info{1}= 'Font';
info{2}= {'FontAngle','FontName','FontSize','FontUnits',...
    'FontWeight'};
retval{1} = info;

info{1} = 'Camera';
info{2} = {'CameraPosition','CameraPositionMode','CameraTarget',...
    'CameraTargetMode','CameraUpVector','CameraUpVectorMode',...
    'CameraViewAngle','CameraViewAngleMode','Projection','View'};
retval{end+1} = info;

info{1} = 'Style/Appearance';
info{2} = {'ALim','ALimMode','Box',...
    'DataAspectRatio','DataAspectRatioMode','GridLineStyle','Layer',...
    'LineStyleOrder','LineWidth','MinorGridLineStyle',...
    'PlotBoxAspectRatio','PlotBoxAspectRatioMode','Title'};
retval{end+1} = info;

info{1} = 'Color';
info{2} = {'Color','ColorOrder','AmbientLightColor','CLim','CLimMode'};
retval{end+1} = info;

info{1} = 'Position';
info{2} = {'ActivePositionProperty','OuterPosition','Position','Units'};
retval{end+1} = info;

info{1} = 'Control';
info{2} = {'DrawMode','NextPlot','CurrentPoint'};
retval{end+1} = info;

info{1} = 'Tick';
info{2} = {'TickLength','TickDir','TickDirMode','TightInset'};
retval{end+1} = info;

info{1} = 'Axis Rulers';
info{2} = {'XColor','XDir','XGrid','XLabel','XAxisLocation','XLim',...
           'XLimMode','XMinorGrid','XMinorTick','XScale','XTick',...
           'XTickLabel','XTickLabelMode','XTickMode',...
           'YColor','YDir','YGrid','YLabel','YAxisLocation','YLim',...
           'YLimMode','YMinorGrid','YMinorTick','YScale','YTick',...
           'YTickLabel','YTickLabelMode','YTickMode',...           
           'ZColor','ZDir','ZGrid','ZLabel','ZAxisLocation','ZLim',...
           'ZLimMode','ZMinorGrid','ZMinorTick','ZScale','ZTick',...
           'ZTickLabel','ZTickLabelMode','ZTickMode'};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetSurfaceGrouping

info{1}= 'Style/Appearance';
info{2}= {'MeshStyle','EdgeAlpha','EdgeColor','FaceAlpha','FaceColor',...
    'Faces','LineStyle','LineWidth','Marker','MarkerEdgeColor','MarkerFaceColor',...
    'MarkerSize'};
retval{1} = info;

info{1} = 'Lighting';
info{2} = {'FaceLighting','EdgeLighting','BackFaceLighting','AmbientStrength',...
    'DiffuseStrength','SpecularStrength','SpecularExponent','SpecularColorReflectance',...
    'NormalMode'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'AlphaData','AlphaDataMapping','CData','CDataMapping','FaceVertexAlphaData',...
    'FaceVertexCData','XData','YData','ZData','Vertices','VertexNormals'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetPatchGrouping

info{1}= 'Style/Appearance';
info{2}= {'EdgeAlpha','EdgeColor','FaceAlpha','FaceColor',...
    'Faces','LineStyle','LineWidth','Marker','MarkerEdgeColor','MarkerFaceColor',...
    'MarkerSize'};
retval{1} = info;

info{1} = 'Lighting';
info{2} = {'FaceLighting','EdgeLighting','BackFaceLighting','AmbientStrength',...
    'DiffuseStrength','SpecularStrength','SpecularExponent','SpecularColorReflectance',...
    'NormalMode'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'AlphaData','AlphaDataMapping','CData','CDataMapping','FaceVertexAlphaData',...
    'FaceVertexCData','XData','YData','ZData','Vertices','VertexNormals'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetImageGrouping

info{1} = 'Data';
info{2} = {'AlphaData','AlphaDataMapping','CData','CDataMapping','XData','YData'};
retval{1} = info;

%----------------------------------------------------%
function retval = localGetLightGrouping

info{1}= 'Style/Appearance';
info{2}= {'Color','Position','Style'};
retval{1} = info;

%----------------------------------------------------%
function retval = localGetTextGrouping

info{1}= 'Style/Appearance';
info{2}= {'BackgroundColor','Color','EdgeColor','HorizontalAlignment',...
          'Interpreter','LineStyle','LineWidth','Margin','String','VerticalAlignment'};
retval{1} = info;

info{1} = 'Font';
info{2} = {'FontAngle','FontName','FontSize','FontUnits','FontWeight'};
retval{end+1} = info;

info{1} = 'Control';
info{2} = {'Editing'};
retval{end+1} = info;

info{1} = 'Position';
info{2} = {'Position','Extent','Rotation','Units'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetRectangleGrouping

info{1}= 'Style/Appearance';
info{2}= {'EdgeColor','FaceColor','LineStyle','LineWidth','Position'};
retval{1} = info;

info{1} = 'Position';
info{2} = {'Position'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetLineGrouping

info{1}= 'Style/Appearance';
info{2}= {'LineStyle','LineWidth','Color','Marker',...
    'MarkerEdgeColor','MarkerFaceColor','MarkerSize'};
retval{1} = info;

%----------------------------------------------------%
function retval = localGetUIControlGrouping

info{1}= 'Style/Appearance';
info{2}= {'FontAngle','FontName','FontSize','FontUnits',...
          'FontWeight','CData','BackgroundColor','ForegroundColor',...
          'Style'};
retval{1} = info;

info{1} = 'Position';
info{2} = {'Position','HorizontalAlignment','Extent'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'Value','String','Max','Min',...
           'SliderStep','TooltipString','Units'};
retval{end+1} = info;

info{1} = 'Control';
info{2} = {'Enable','ListboxTop','Callback','KeyPressFcn'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUITableGrouping

info{1}= 'Style/Appearance';
info{2}= {'BackgroundColor','ForegroundColor','RowStriping', ...
          'TooltipString'};
retval{1} = info;

info{1} = 'Position';
info{2} = {'Position','Units','Extent'};
retval{end+1} = info;

info{1} = 'Font';
info{2} = {'FontAngle','FontName','FontSize','FontUnits','FontWeight'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'Data'};
retval{end+1} = info;

info{1} = 'Columns & Rows';
info{2} = {'ColumnEditable','ColumnFormat','ColumnName','ColumnWidth', ...
    'RowName'};
retval{end+1} = info;

info{1} = 'Control';
info{2} = {'Enable','CellEditCallback','CellSelectionCallback',...
    'KeyPressFcn','RearrangeableColumns','FooBar'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUIPanelGrouping

info{1}= 'Style/Appearance';
info{2}= {'HighlightColor','ShadowColor','BorderType','BorderWidth',...
    'FontAngle','FontName','FontSize','FontUnits','FontWeight','ForegroundColor',....
    'Title','TitlePosition','BackgroundColor'};
retval{1} = info;

info{1} = 'Control';
info{2} = {'ResizeFcn'};
retval{end+1} = info;

info{1} = 'Position';
info{2} = {'Position','Units'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUIButtonGroupGrouping

info{1} = 'Control';
info{2} = {'SelectedObject'};
retval{1} = info;

%----------------------------------------------------%
function b = localHasHelp(hObj)
% Returns true if this instance has a property reference page

% For now, don't group multiple objects
if iscell(hObj)
    hObj = hObj{1};
end

% Defensive, remove try/catch after topic map API is stable 
try
    classname = localGetClassName(hObj);
    map = com.mathworks.mlwidgets.help.TopicMapLocator.getMapPath(classname);
    b = java.lang.Boolean(~isempty(map));
catch
    b = java.lang.Boolean(false);
end

%----------------------------------------------------%
function localShowHelp(hObj,propname)
% Displays help for the supplied instance and property

% For now, don't group multiple objects
if iscell(hObj)
    hObj = hObj{1};
end

if ishandle(hObj) && ischar(propname)
    classname = localGetClassName(hObj);
    helpview(['mapkey:',classname],propname,'CSHelpWindow');
end

%----------------------------------------------------%
function classname = localGetClassName(hObj)
% Returns the full absolute class name for a supplied instance

classname = [];
if ishandle(hObj)
    hObj = handle(hObj);
    hCls = classhandle(hObj);
    hPk = get(hCls,'Package');
    classname = [get(hPk,'Name'), '.',get(hCls,'Name')];
end

    