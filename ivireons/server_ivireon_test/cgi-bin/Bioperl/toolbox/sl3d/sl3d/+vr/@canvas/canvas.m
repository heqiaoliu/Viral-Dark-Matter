%CANVAS Create a new virtual reality canvas.
%   C = CANVAS(WORLD) creates a new virtual reality canvas
%   showing the specified WORLD in current figure and returns the newly
%   created canvas object.
%
%   C = CANVAS(WORLD, PARENT) creates a new virtual reality canvas
%   showing the specified WORLD in the figure specified as PARENT
%   and returns the newly created canvas object.
%
%   C = CANVAS(WORLD, PARENT, POSITION) creates a new virtual reality canvas
%   showing the specified WORLD in the figure specified as PARENT at specified
%   POSITION and returns the newly created canvas object. POSITION must be
%   in pixels.
%
%   C = CANVAS(WORLD, 'PropertyName', propertyvalue,...) creates a new
%   virtual reality canvas showing the specified WORLD with specified
%   properties (valid properties and their values are shown below).
%
%   Valid properties are (property names are case-sensitive):
%     Antialiasing (settable) (on/off property)
%         Determines whether antialiasing is used when rendering scene.
%         Antialiasing smoothes textures by interpolating values between
%         texture points. This causes a significant CPU load but makes
%         the scene look more natural.
%
%     CameraBound (settable) (on/off property)
%         This property controls whether the camera is bound to the
%         current viewpoint (i.e. it moves with it) or not.
%         When the camera is bound, its position, direction, and up vector
%         are relative to the viewpoint. For unbound camera, these values
%         are absolute.
%
%     CameraDirection (settable)
%         Camera direction, relative to the current viewpoint's direction.
%
%     CameraDirectionAbs
%         Camera direction, in world coordinates.
%
%     CameraPosition (settable)
%         Camera position, relative to the current viewpoint's position.
%
%     CameraPositionAbs
%         Camera position, in world coordinates.
%
%     CameraUpVector (settable)
%         Camera up vector, relative to the current viewpoint's up vector.
%
%     CameraUpVectorAbs
%         Camera up vector, in world coordinates.
%
%     DeleteFcn (settable)
%         Callback invoked in the canvas destructor.
%
%     Headlight (settable) (on/off property)
%         Specifies whether headlight is enabled.
%         The headlight is an additional white directional light
%         that moves and rotates with the camera.
%
%     Lighting (settable) (on/off property)
%         Specifies whether lighting is taken into account when rendering.
%         If it is off, all objects are drawn as if uniformly lit.
%
%     MaxTextureSize (settable)
%         The maximum pixel size used for drawing textures. The value must be
%         power of two and may be further adjusted to match specific hardware
%         renderer limits. Increasing this value improves image quality but
%         decreases performance. The value 'auto' sets the maximum possible
%         texture size.
%
%     NavMode (settable)
%         Specifies the current navigation mode. Valid settings are
%         'walk', 'examine', or 'fly'.
%
%     NavPanel (settable)
%         Panel mode. This affects how the control panel in the canvas
%         is shown, and can have one of the following values:
%
%           'none'
%              Panel is not visible.
%
%           'translucent'
%              Panel floats half transparently above the scene.
%
%           'opaque'
%              Panel floats above the scene. This is the default.
%
%     NavSpeed (settable)
%         Specifies the current navigation speed. Valid settings are
%         'veryslow', 'slow', 'normal', 'fast', or 'veryfast'.
%
%     NavZones (settable) (on/off property)
%         Specifies if the navigation zones should be displayed.
%
%     Parent
%         Handle of parent of this VR canvas.
%
%     Position (settable)
%         Screen coordinates of this VR canvas.
%
%     Textures (settable) (on/off property)
%         Specifies whether textures are rendered.
%
%     Transparency (settable) (on/off property)
%         Specifies whether transparency is taken into account when
%         rendering. If it is off, all objects are drawn opaque.
%
%     Units (settable)
%       The units used to interpret the Position property.
%
%     Viewpoint (settable)
%         Viewpoint currently active for the given VR canvas
%         (an empty string if the active viewpoint has no description).
%
%     Wireframe (settable) (on/off property)
%         Specifies whether wireframes should be drawn instead of solid
%         objects.
%
%     World
%         World which is this VR canvas showing.
%
%     ZoomFactor (settable)
%         Camera zoom factor. Default zoom factor value is 1,
%         zoom factor of 2 makes the scene look twice as big,
%         zoom factor of 0.1 makes it look 10 times smaller, etc.

%     Name (settable)
%         Name of this VR canvas.
%


%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.22.2.1 $ $Date: 2010/07/01 20:44:30 $ $Author: batserve $

classdef canvas < hgsetget

properties (Dependent)
  Antialiasing@char;
  CameraBound@char;
  CameraDirection@double;
  CameraPosition@double;
  CameraUpVector@double;
  Headlight@char;
  Lighting@char;
  MaxTextureSize;
  NavPanel@char;
  NavMode@char;
  NavSpeed@char;
  NavZones@char;
  Position@double;
  Textures@char;
  Transparency@char;
  Units@char;
  Viewpoint@char;
  Wireframe@char;
  ZoomFactor@double;
end

properties
  DeleteFcn;
end

properties (SetAccess = private, Dependent)
  CameraDirectionAbs@double;
  CameraPositionAbs@double;
  CameraUpVectorAbs@double;
  Parent;
end

properties (SetAccess = private)
  World;
end

properties (Access = private, Hidden)
  BeingDeleted@logical = false;
  ContainerDeleteFcn;
end

properties (SetAccess = private, Hidden)
  JCanvas; % Java component with MATLAB callbacks
  MCanvasContainer; % MATLAB javacomponent container
  NativeCanvas@uint64; %pointer to native canvas
  mode@char; % vr.canvas mode -- it can be 'vrfigure', 'standalone', 'edit'
  mfigure; % parent MATLAB figure
end

properties (Dependent, Hidden)
  Name@char;
  PlaneClipMethod@char;
end


methods

  % constructor
  function obj = canvas(world, varargin)

    % preload OpenGL library and validate for use with vr.canvas
    vr.canvas.preloadOpenGL(true);

    % validate parameters
    if nargin == 0
      throwAsCaller(MException('VR:invalidinarg', 'Not enough input arguments.'));
    end

    % create empty vector of vr.canvas objects
    if isempty(world)
      obj = vr.canvas.empty;
      return;
    end

    % default mode
    obj.mode = 'vrfigure';

    % it is undocumented constructor call
    % vr.canvas is internally used in vr.edit class
    if isa(world, 'char') && strcmp(world, 'edit')
      % change mode
      obj.mode = 'edit';

      videopreview = 0;

      % create cell array {names,values}
      inargs = reshape(varargin, 2, []);

      % find World , Parent and JCanvas and MCanvasContainer
      index = find(strcmp('World', inargs(1, :)), 1, 'last');
      world = inargs{2, index};
      index = find(strcmp('Parent', inargs(1, :)), 1, 'last');
      fig = inargs{2, index};
      index = find(strcmp('JCanvas', inargs(1, :)), 1, 'last');
      % it must be handle with callbacks to avoid warning (and possible memory leaks)
      obj.JCanvas = handle(inargs{2, index},'callbackProperties');

      % MCanvasContainer is not direct parent of JCanvas
      % so we must not resize this container from within vr.canvas class
      index = find(strcmp('MCanvasContainer', inargs(1, :)), 1, 'last');
      obj.MCanvasContainer = inargs{2, index};

      % all needed input arguments processed
      % we must not process them later
      inargs = {};

    elseif ~isa(world, 'vrworld')
      throwAsCaller(MException('VR:invalidinarg', 'Argument WORLD must be of type VRWORLD.'));
    end
    if ~isopen(world)
      throwAsCaller(MException('VR:worldnotopen', 'World is not open.'));
    end

    % warn about contexts not shared
    figs4 = vrsfunc('VRT3ListViews', get(world, 'id'));
    if ~isempty(figs4)
      throwAsCaller(MException('VR:contextsharing', ...
              ['Due to renderer limitations, VR.CANVAS objects cannot be created ', ...
               'when the DefaultViewer preference is set to ''internalv4'' and a VRFIGURE object ', ...
               'already exists for the same virtual world. It is necessary to set the DefaultViewer ', ...
               'preference to ''internal'' if coexistence of VR.CANVAS and VRFIGURE objects is required.'] ));
    end

    % flag for setting Position after initialization
    userposition = false;

    if ~strcmp(obj.mode, 'edit') && ~isempty(varargin) && ischar(varargin{1})
      % it is parametrized constructor ('PropertyName', PropertyValue, ...)

      % in varargin there are key-value pairs so it must have even count
      if mod(numel(varargin), 2) ~= 0
        throwAsCaller(MException('VR:invalidinarg', 'Invalid number of input arguments.'));
      end

      % create cell array {names,values}
      inargs = reshape(varargin, 2, []);

      % try to find Parent in passed arguments
      parentindex = find(strcmp('Parent', inargs(1, :)), 1, 'last');
      if ~isempty(parentindex)
        % we found Parent
        fig = inargs{2, parentindex};
      else
        % Parent not found, use gcf
        fig = gcf;
      end

      % try to find Position in passed arguments
      positionindex = find(strcmp('Position', inargs(1, :)), 1, 'last');
      if ~isempty(positionindex)
        % we found Position, remember it
        userposition = true;
      end

      % Videopreview is always zero
      videopreview = 0;

    elseif ~strcmp(obj.mode, 'edit')
      % it is old-fashioned constructor
      % set defaults for missing parameters and create the canvas

      % input arguments cell array
      inargs = cell(2, 0);

      if nargin < 2
        fig = gcf;
      else
        fig = varargin{1};
      end
      if nargin < 3
      else
        % Position specified, remember it
        inargs = [{'Units'; 'pixels'; 'Position'}; varargin(2)];
        userposition = true;
      end
      if nargin < 4
        videopreview = 0;
      else
        videopreview = varargin{3};
      end
    end

    try
      % try initialize empty canvas
      initialize(obj, world, fig, videopreview);

      if ~strcmp(obj.mode, 'vrfigure')
        % it is not canvas in vrfigure mode, set default properties from preferences
        setDefaultProperties(obj);
      end

      if ~isempty(inargs)
        set(obj, inargs{:});
      end

      % UNITS and POSITION are never changed from within vr.canvas class
      if ~strcmp(obj.mode, 'edit') && ~userposition
        % user did not pass Position into constructor, canvas fills parental figure
        units = obj.Units;
        obj.Units = 'normalized';
        obj.Position = [0 0 1 1];
        obj.Units = units;
      end
    catch ME
      delete(obj);
      throwAsCaller(ME);
    end
  end % end of constructor
end % end of constructor methods block

methods (Access = private)

  % initialize method is called from constructor and fill empty vr.canvas with appropriate values
  function obj = initialize(obj, world, parent, videopreview)

    obj.World = world;
    if ishandle(parent) && strcmpi(get(parent, 'Type'), 'figure')
      % it is standalone or edit mode
      if ~strcmp(obj.mode, 'edit')
        obj.mode = 'standalone';
      end
      obj.mfigure = parent;
    elseif isa(parent, 'vr.figure')
      % it is vrfigure mode
      obj.mode = 'vrfigure';
      obj.mfigure = parent.mfigure;
    else
      throwAsCaller(MException('VR:invalidinarg', 'Input argument PARENT must be a valid FIGURE.'));
    end

    % ensure parent figure is fully rendered at this point
    drawnow;

    if ~strcmp(obj.mode, 'edit')
      % create Java component that holds the canvas
      [obj.JCanvas, obj.MCanvasContainer] = javacomponent( { 'com.mathworks.toolbox.sl3d.vrcanvas.VRGLCanvas', ...
                                                             get(world, 'id'), ...      
                                                             strcmp(obj.mode, 'vrfigure'), ...
                                                             [1 1], ...
                                                             videopreview }, ...
                                                           [0 0 1 1], ...    % JCanvas is resized to its correct size
                                                           obj.mfigure);  
      obj.ContainerDeleteFcn = get(obj.MCanvasContainer, 'DeleteFcn');
      set(obj.MCanvasContainer, 'DeleteFcn', {@containerDelete, obj});
    end

    obj.NativeCanvas = typecast(obj.JCanvas.getPointerToNativeCanvas(), 'uint64');
    if obj.NativeCanvas == 0
      % do not allow to create invalid canvas
      delete(obj);
      throwAsCaller(MException('VR:nonativeresources', 'Native resources could not be created.'));
    end

    if ~strcmp(obj.mode, 'vrfigure')
      % we must not change UNITS in edit mode
      if  strcmp(obj.mode, 'standalone')
        obj.Units = vrgetpref('DefaultCanvasUnits');
      end
      % change navigation panel
      obj.NavPanel = vrgetpref('DefaultCanvasNavPanel');
    else
      % it is vrfigure or edit mode, units are always in pixels
      obj.Units = 'pixels';
    end

    % put object to list
    list = getappdata(0, 'SL3D_vrcanvas_List');
    if isempty(list)
      % initialize Map object with uint64 key, mixed-type value
      list = containers.Map('KeyType', 'uint64', 'ValueType', 'any');
    end
    list(obj.NativeCanvas) = obj;
    setappdata(0, 'SL3D_vrcanvas_List', list);

    createuicontextmenu(obj, videopreview);
    updateViewpointsComboBox(obj);

    % add keyboard callbacks
    set(obj.JCanvas, 'KeyPressedCallback', {@keyPressed, obj});
    set(obj.JCanvas, 'KeyReleasedCallback', {@keyReleased, obj});

    % commit the container creation
    drawnow;
  end

  function obj = createuicontextmenu(obj, videopreview)
    appset = vr.appdependent;
    cmenu = uicontextmenu('Parent',obj.mfigure);
    if ~strcmp(obj.mode, 'edit') && ~videopreview
      filemenu = uimenu(cmenu, 'Label', 'File');
    end
    viewmenu = uimenu(cmenu, 'Label', 'View', 'Tag', 'VR_ViewMenu');
    viewpointsmenu = uimenu(cmenu, 'Label', 'Viewpoints', 'Tag', 'VR_ViewpointsMenu');
    navigationmenu = uimenu(cmenu, 'Label', 'Navigation', 'Tag', 'VR_NavigationMenu');
    renderingmenu = uimenu(cmenu, 'Label', 'Rendering', 'Tag', 'VR_RenderingMenu');

    if ~strcmp(obj.mode, 'edit') && ~videopreview
      uimenu(filemenu, 'Label', 'Open in Editor', 'Enable', appset.filesave, 'Callback', {@vr.callbacks, obj, 'startEditor'});
      uimenu(filemenu, 'Label', 'Reload', 'Separator', 'on', 'Callback', {@vr.callbacks, obj, 'onFileReload'});
      uimenu(filemenu, 'Label', 'Save As...', 'Enable', appset.filesave, 'Callback', {@vr.callbacks, obj, 'onFileSave'});
    end

    uimenu(viewmenu, 'Label', 'Navigation Zones','Tag', 'VR_navzonesmenu', 'Callback', {@vr.callbacks, obj, 'NavZones'});

    if ~videopreview
      navpanelmenu = uimenu(viewmenu, 'Label', 'Navigation Panel', 'Separator', 'on');
      uimenu(navpanelmenu, 'Label', 'None', 'UserData', 'none', 'Tag', 'VR_navpanelmenu', 'Callback', {@vr.callbacks, obj, 'NavPanel'});
      uimenu(navpanelmenu, 'Label', 'Opaque', 'UserData', 'opaque', 'Tag', 'VR_navpanelmenu', 'Callback', {@vr.callbacks, obj, 'NavPanel'});
      uimenu(navpanelmenu, 'Label', 'Translucent', 'UserData', 'translucent', 'Tag', 'VR_navpanelmenu', 'Callback', {@vr.callbacks, obj, 'NavPanel'});
      if strcmp(obj.mode, 'vrfigure')
        uimenu(navpanelmenu, 'Label', 'Halfbar', 'UserData', 'halfbar', 'Tag', 'VR_navpanelmenu', 'Callback', {@vr.callbacks, obj, 'NavPanel'});
        uimenu(navpanelmenu, 'Label', 'Bar', 'UserData', 'bar', 'Tag', 'VR_navpanelmenu', 'Callback', {@vr.callbacks, obj, 'NavPanel'});
      end
    end
    uimenu(viewmenu, 'Label', 'Zoom In', 'Separator', 'on', 'Callback', {@vr.callbacks, obj, 'zoomIn'});
    uimenu(viewmenu, 'Label', 'Zoom Out', 'Callback', {@vr.callbacks, obj, 'zoomOut'});
    uimenu(viewmenu, 'Label', 'Normal (100%)', 'Callback', {@vr.callbacks, obj, 'viewNormal'});

    uimenu(viewpointsmenu, 'Label', 'Previous Viewpoint', 'Callback', {@vr.callbacks, obj,'gotoPrevViewpoint'});
    uimenu(viewpointsmenu, 'Label', 'Next Viewpoint', 'Callback', {@vr.callbacks, obj, 'gotoNextViewpoint'});
    uimenu(viewpointsmenu, 'Label', 'Return to Viewpoint', 'Callback', {@vr.callbacks, obj, 'navGoHome'});
    uimenu(viewpointsmenu, 'Label', 'Go to default Viewpoint', 'Callback', {@vr.callbacks, obj, 'gotoDefaultViewpoint'});

    if ~strcmp(obj.mode, 'edit')
      uimenu(viewpointsmenu, 'Label', 'Create Viewpoint', 'Separator', 'on', 'Callback', {@vr.callbacks, obj, 'createViewpoint'});
      uimenu(viewpointsmenu, 'Label', 'Remove Current Viewpoint', 'Tag', 'VR_RemoveCurrentViewpoint', ...
                             'Callback', {@vr.callbacks, obj, 'removeViewpoint'});
    end

    navmodemenu = uimenu(navigationmenu, 'Label', 'Method');
    uimenu(navmodemenu, 'Label', 'Walk', 'UserData', 'walk', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, obj, 'NavMode'});
    uimenu(navmodemenu, 'Label', 'Examine', 'UserData', 'examine', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, obj, 'NavMode'});
    uimenu(navmodemenu, 'Label', 'Fly', 'UserData', 'fly', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, obj, 'NavMode'});
    uimenu(navmodemenu, 'Label', 'None', 'UserData', 'none', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, obj, 'NavMode'});
    navspeedmenu = uimenu(navigationmenu, 'Label', 'Speed');
    uimenu(navspeedmenu, 'Label', 'Very Slow', 'UserData', 'veryslow', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, obj, 'NavSpeed'});
    uimenu(navspeedmenu, 'Label', 'Slow', 'UserData', 'slow', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, obj, 'NavSpeed'});
    uimenu(navspeedmenu, 'Label', 'Normal', 'UserData', 'normal', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, obj, 'NavSpeed'});
    uimenu(navspeedmenu, 'Label', 'Fast', 'UserData', 'fast', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, obj, 'NavSpeed'});
    uimenu(navspeedmenu, 'Label', 'Very Fast', 'UserData', 'veryfast', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, obj, 'NavSpeed'});
    uimenu(navigationmenu, 'Label', 'Straighten Up', 'Separator', 'on', 'Callback', {@vr.callbacks, obj, 'navStraighten'});
    uimenu(navigationmenu, 'Label', 'Undo Move', 'Callback', {@vr.callbacks, obj, 'navUndoMove'});
    uimenu(navigationmenu, 'Label', 'Camera Bound to Viewpoint', 'Tag', 'VR_cameraboundmenu', 'Separator', 'on', 'Callback', {@vr.callbacks, obj, 'CameraBound'});

    uimenu(renderingmenu, 'Label', 'Antialiasing', 'Tag', 'VR_antialiasingmenu', 'Callback', {@vr.callbacks, obj, 'Antialiasing'});
    uimenu(renderingmenu, 'Label', 'Headlight', 'Tag', 'VR_headlightmenu', 'Callback', {@vr.callbacks, obj, 'Headlight'});
    uimenu(renderingmenu, 'Label', 'Lighting', 'Tag', 'VR_lightingmenu', 'Callback', {@vr.callbacks, obj, 'Lighting'});
    uimenu(renderingmenu, 'Label', 'Textures', 'Tag', 'VR_texturesmenu', 'Callback', {@vr.callbacks, obj, 'Textures'});
    texturesizemenu = uimenu(renderingmenu, 'Label', 'Maximum Texture Size');
    uimenu(texturesizemenu, 'Label', 'Auto', 'UserData', 'auto', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '32', 'UserData', '32', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '64', 'UserData', '64', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '128', 'UserData', '128', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '256', 'UserData', '256', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '512', 'UserData', '512', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '1024', 'UserData', '1024', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(texturesizemenu, 'Label', '2048', 'UserData', '2048', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, obj, 'MaxTextureSize'});
    uimenu(renderingmenu, 'Label', 'Transparency', 'Tag', 'VR_transparencymenu', 'Callback', {@vr.callbacks, obj, 'Transparency'});
    uimenu(renderingmenu, 'Label', 'Wireframe', 'Tag', 'VR_wireframemenu',  'Callback', {@vr.callbacks, obj, 'Wireframe'});

    set(obj.MCanvasContainer, 'UIContextMenu', cmenu);
    set(obj.JCanvas, 'MousePressedCallback', {@mousePressed, obj});
    set(obj.JCanvas, 'MouseReleasedCallback', {@mouseReleased, obj});
  end

  function setDefaultProperties(obj)
    prefnames = { 'DefaultFigureAntialiasing', ...
                  'DefaultFigureLighting', ...
                  'DefaultFigureMaxTextureSize', ...
                  'DefaultFigureNavZones', ...
                  'DefaultFigureTextures', ...
                  'DefaultFigureTransparency', ...
                  'DefaultFigureWireframe'};
    prefs = vrgetpref(prefnames);
    for i=1:numel(prefnames)
      prefnames{i} = prefnames{i}(14:end);
    end
    set(obj, prefnames, prefs);
  end
end

methods
  % destructor
  function delete(obj)
    % do not delete HG container in edit mode
    if strcmp(obj.mode, 'edit')
      return;
    end

    % delete HG container
    % everything else is cleaned up in container's DeleteFcn
    if ~obj.BeingDeleted && ~isempty(obj.MCanvasContainer) && ishandle(obj.MCanvasContainer)
      delete(obj.MCanvasContainer);
    end

    % commit the container deletion
    drawnow;
  end

  % do not save object at all
  function A = saveobj(obj) %#ok<MANU>
    A = [];
  end

  % reimplemented from hgsetget, now it displays nothing
  function setdisp(obj) %#ok<MANU>
  end

  %% GETTERS
  function value = get.Antialiasing(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Antialiasing');
  end

  function value = get.CameraBound(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraBound');
  end

  function value = get.CameraDirection(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraDirection');
  end

  function value = get.CameraPosition(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraPosition');
  end

  function value = get.CameraUpVector(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraUpVector');
  end

  function value = get.Headlight(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Headlight');
  end

  function value = get.Lighting(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Lighting');
  end

  function value = get.MaxTextureSize(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'MaxTextureSize');
  end

  function value = get.Name(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Name');
  end

  function value = get.NavPanel(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'NavPanel');
    if isempty(value) %;!!
      value = vrgetpref('DefaultCanvasNavPanel');
    end
  end

  function value = get.NavMode(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'NavMode');
  end

  function value = get.NavSpeed(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'NavSpeed');
  end

  function value = get.NavZones(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'NavZones');
  end

  function value = get.PlaneClipMethod(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'PlaneClipMethod');
  end

  function value = get.Position(obj)
    if strcmp(obj.mode, 'vrfigure')
      units = obj.Units;
      obj.Units = 'pixels';
      value = get(obj.MCanvasContainer, 'Position');
      obj.Units = units;
    elseif strcmp(obj.mode, 'edit')
      jcsize = javaMethodEDT('getSize', obj.JCanvas);
      jcheight = jcsize.getHeight;
      jcloc = javaMethodEDT('getLocation', obj.JCanvas);
      mcontpos = get(obj.MCanvasContainer, 'Position');
      value = [jcloc.x, mcontpos(4)-jcheight, jcsize.getWidth, jcheight];
    else    
      value = get(obj.MCanvasContainer, 'Position');
    end
  end

  function value = get.Transparency(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Transparency');
  end

  function value = get.Textures(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Textures');
  end

  function value = get.Units(obj)
    value=get(obj.MCanvasContainer, 'Units');
  end

  function value = get.Viewpoint(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Viewpoint');
  end

  function value = get.Wireframe(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Wireframe');
  end

  function value = get.ZoomFactor(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'ZoomFactor');
  end

  function value = get.CameraDirectionAbs(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraDirectionAbs');
  end

  function value = get.CameraPositionAbs(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraPositionAbs');
  end

  function value = get.CameraUpVectorAbs(obj)
    value = vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'CameraUpVectorAbs');
  end

  function value = get.Parent(obj)
    value = get(obj.MCanvasContainer, 'Parent');
  end

  function value = get.World(obj)
    value = obj.World;
  end

  %% end of GETTERS

  %% SETTERS

  function set.Antialiasing(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Antialiasing', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.CameraBound(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'CameraBound', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.CameraDirection(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'CameraDirection', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.CameraDirectionAbs(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Canvas property ''CameraDirectionAbs'' is read-only.'));
  end

  function set.CameraPosition(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'CameraPosition', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.CameraPositionAbs(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Canvas property ''CameraPositionAbs'' is read-only.'));
  end

  function set.CameraUpVector(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'CameraUpVector', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.CameraUpVectorAbs(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Canvas property ''CameraUpVectorAbs'' is read-only.'));
  end

  function set.DeleteFcn(obj, arg)
    if ~(ischar(arg) || isa(arg, 'function_handle') || (iscell(arg) && isa(arg{1}, 'function_handle')))
      throwAsCaller(MException('VR:invalidfn', 'Input argument ''DeleteFcn'' must be of type ''char'' or ''function handle''.'));
    else
      obj.DeleteFcn = arg;
    end
  end

  function set.Headlight(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Headlight', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.Lighting(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Lighting', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.MaxTextureSize(obj, arg)
    if strcmp(obj.mode, 'vrfigure')
      menuitem = findobj(obj.mfigure, 'Tag', 'VR_textsizemenu', 'UserData', 'auto');
    else
      menuitem = findobj(get(obj.MCanvasContainer, 'UIContextMenu'), 'Tag', 'VR_textsizemenu', 'UserData', 'auto');
    end

    if ischar(arg)
      if strcmpi(arg, 'auto')
        arg = lower(arg);
        set(menuitem, 'Checked', 'on');
      else
        arg = str2double(arg);
      end
    end
    if isnumeric(arg)
      set(menuitem, 'Checked', 'off');
    end
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'MaxTextureSize', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.Name(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Name', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.NavPanel(obj, arg)
    % halfbar or bar allow only in vrfigure mode
    if ~strcmp(obj.mode, 'vrfigure') && ~any(strcmpi(arg, {'none', 'translucent', 'opaque'}))
      throwAsCaller(MException('VR:invalidinarg', 'Value for ''NavPanel'' property must be ''none'',''translucent'' or ''opaque''.'));
    end

    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'NavPanel', arg);
    obj.JCanvas.setNavPanel(arg);
    obj.JCanvas.requestRedraw();
    
    % do not attempt to change container and figure position in fullscreen mode
    if strcmp(obj.mode, 'vrfigure') && strcmpi(get(obj.mfigure, 'Visible'), 'off')
      return;
    end

    % do not attempt to resize figure when docked
    if strcmp(obj.mode, 'vrfigure') && strcmpi(get(obj.mfigure, 'WindowStyle'), 'docked')
      units = get(obj.MCanvasContainer, 'Units');
      set(obj.MCanvasContainer, 'Units', 'pixels');
      containerpos = get(obj.MCanvasContainer, 'Position');
      set(obj.MCanvasContainer, 'Units', units);
      obj.JCanvas.setSize(containerpos(3), containerpos(4));
      drawnow;
      return;
    end

    gap = obj.JCanvas.getNavPanelVariation();      
    units = get(obj.MCanvasContainer, 'Units');
    set(obj.MCanvasContainer, 'Units', 'pixels');
    set(obj.MCanvasContainer, 'Position', get(obj.MCanvasContainer, 'Position') + [0 -gap 0 gap]);
    set(obj.MCanvasContainer, 'Units', units);
    drawnow;
    
    % resize figure
    if strcmp(obj.mode, 'vrfigure')
      set(obj.mfigure, 'Position', get(obj.mfigure, 'Position') + [0 -gap 0 gap]);
      drawnow;
    end
  end

  function set.NavMode(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'NavMode', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.NavSpeed(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'NavSpeed', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.PlaneClipMethod(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'PlaneClipMethod', arg);
  end

  function set.NavZones(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'NavZones', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.Parent(~, ~)
    % this method is empty and is only used during constructing phase
  end

  function set.Position(obj, position)
    if strcmp(obj.mode, 'edit')
      % do not change POSITION in edit mode
      return;
    end

    units = obj.Units;
    if strcmp(units, 'normalized') && (any(position<0) || any(position>1))
      warning('VR:invalidinarg', 'Units are set to ''normalized''. Position is not in normalized form and is ignored.');
      return;
    end
    if strcmp(obj.mode, 'vrfigure')
      obj.Units = 'pixels';
    end
    set(obj.MCanvasContainer, 'Position', position);
    obj.Units = units;
    drawnow;
  end

  function set.Transparency(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Transparency', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.Textures(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Textures', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.Units(obj, arg)
    if strcmp(obj.mode, 'edit')
      % do not change UNITS in edit mode
      return;
    end

    try
      set(obj.MCanvasContainer, 'Units', arg);
    catch ME
      throwAsCaller(MException('VR:invalidinarg', 'Invalid value for the ''Units'' property.'));
    end
  end

  function set.Viewpoint(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Viewpoint', arg);
    updateViewpointsComboBox(obj);
    obj.JCanvas.requestRedraw();
  end

  function set.Wireframe(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'Wireframe', arg);
    obj.JCanvas.requestRedraw();
  end

  function set.World(obj, arg)
    if isempty(obj.World)
      obj.World = arg;
    else
      throwAsCaller(MException('VR:propreadonly', 'Canvas property ''World'' is read-only.'));
    end
  end

  function set.ZoomFactor(obj, arg)
    vrsfunc('SetCanvasProperty', obj.NativeCanvas, 'ZoomFactor', arg);
    obj.JCanvas.requestRedraw();
  end

  %% end of SETTERS
end

methods (Hidden)

  function setOnOffProperty(obj, propname)
    onoff = get(obj, propname);
    if strcmpi(onoff, 'on')
      set(obj, propname, 'off');
    else
      set(obj, propname, 'on');
    end
  end

  function zoomIn(obj)
    vrsfunc('ZoomIn', obj.NativeCanvas);
  end

  function zoomOut(obj)
    vrsfunc('ZoomOut', obj.NativeCanvas);
  end

  function viewNormal(obj)
    vrsfunc('ViewNormal', obj.NativeCanvas);
  end

  function navStraighten(obj)
    vrsfunc('NavStraighten', obj.NativeCanvas);
  end

  function navUndoMove(obj)
    vrsfunc('NavUndoMove', obj.NativeCanvas);
  end

  function gotoPrevViewpoint(obj)
    vrsfunc('GotoPrevViewpoint', obj.NativeCanvas);
    updateViewpointsComboBox(obj);
  end

  function gotoNextViewpoint(obj)
    vrsfunc('GotoNextViewpoint', obj.NativeCanvas);
    updateViewpointsComboBox(obj);
  end

  function gotoDefaultViewpoint(obj)
    vrsfunc('GotoDefaultViewpoint', obj.NativeCanvas);
    updateViewpointsComboBox(obj);
  end

  function navGoHome(obj)
    vrsfunc('NavGoHome', obj.NativeCanvas);
    updateViewpointsComboBox(obj);
  end

  function retval = createViewpoint(obj, desc, placement, jumptoviewpoint)
    if isempty(desc)
      throwAsCaller(MException('VR:invalidinarg', 'Parameter ''desc'' must not be empty'));
    end
    errstr = vrsfunc('CreateViewpoint', obj.NativeCanvas, desc, placement, jumptoviewpoint);
    retval = isempty(errstr);
    if ~retval
      errordlg(errstr, 'Viewpoint not created', 'modal');
    else
      updateViewpointsComboBox(obj);
    end
  end

  function removeViewpoint(obj)
    vrsfunc('RemoveViewpoint', obj.NativeCanvas);
    updateViewpointsComboBox(obj);
  end

  function [position, list] = getViewpointList(obj)
    [position, list] = vrsfunc('GetViewpointList', obj.NativeCanvas);
  end

  % returns string value 'on'/'off'
  %;!! is this method of canvas?
  function value = getCreateViewpointPlacementOnOff(obj)
    value = vrsfunc('GetCreateViewpointPlacementOnOff', obj.NativeCanvas);
  end

  function updateViewpointsComboBox(obj)
    % we replace combobox every time the viewpoint is set.

    if strcmp(obj.mode, 'vrfigure')
      jc = getappdata(obj.mfigure, 'VRViewpointsComboBox');
      if strcmp(class(jc), 'com.mathworks.mwswing.MJComboBox')
        if jc.getItemCount()>0
          listeners = jc.getActionListeners;
          jcll = java.util.Arrays.asList(listeners);
          iterator = jcll.iterator();
          while iterator.hasNext()
            jc.removeActionListener(iterator.next());
          end
          jc.removeAllItems;
        end
      end
    end


    % get all viewpoints
    [position, viewpoints] = getViewpointList(obj);

    % create new menu items
    for i=1:numel(viewpoints)
      if strcmp(obj.mode, 'vrfigure')
        jc = getappdata(obj.mfigure, 'VRViewpointsComboBox');
        if strcmp(class(jc), 'com.mathworks.mwswing.MJComboBox')
          jc.addItem(java.lang.String(viewpoints(i)));
        end
      end
    end
    % select current viewpoint add listeners
    if strcmp(obj.mode, 'vrfigure')
      jc = getappdata(obj.mfigure, 'VRViewpointsComboBox');
      if strcmp(class(jc), 'com.mathworks.mwswing.MJComboBox')
        if jc.getItemCount()>0
          jc.setSelectedIndex(position);
          jc.addActionListener(com.mathworks.toolbox.sl3d.vrcanvas.UIToolBarComboBoxListener(obj.JCanvas, 0));
        end
      end
    end
  end

  function updateNavModeComboBox(obj, arg)
    % it is called only in vrfigure mode
    navmodecombobox = getappdata(obj.mfigure, 'VRNavMethodComboBox');
    if ~isempty(navmodecombobox)
      if ischar(arg)
        if strcmpi(arg, 'walk')
          index = 0;
        elseif strcmpi(arg, 'examine')
          index = 1;
        elseif strcmpi(arg, 'fly')
          index = 2;
        else   % 'none'
          index = 3;
        end
      else
        index = arg;  % numeric argument must correspond to menu order
      end
      if javaMethodEDT('getSelectedIndex', navmodecombobox)~=index
        % if block needed -- there is recursion if we set index every time
        javaMethodEDT('setSelectedIndex', navmodecombobox, index);
      end
    end
  end
  
  function obj = setJCanvasVisible(obj)
    % VRGLCanvas visibility in Fullscreen mode workaround -- 
    % -- components created by javacomponent.m have visibility listeners
    % which set visible/invisible all children of parent hg component.
    % Even if we change VRGLCanvas parent in fullscreen mode; matlab HG
    % code keeps original parent and call visibility callback on its
    % visibility state change.
    % We just simply set VRGLCanvas visible in new (fullscreen) container to
    % workaround this problem.
    % We can't delete HGContainer during fullscreen mode active, because it
    % is owner of mouse and keyboard actions which are needed in fullscreen too.
    obj.JCanvas.setVisible(true); 
    % focus lost when canvas made invisible -- try to gain it
    obj.JCanvas.requestFocusInWindow();
  end
  
  function obj = createNewCanvasContainer(obj, vrfigure)
    if ~strcmp(obj.mode, 'vrfigure')
      % return if we are not in vrfigure mode
      return;
    end

    set(obj.MCanvasContainer, 'Visible', 'on');
    pos = obj.Position;

    set(obj.MCanvasContainer, 'DeleteFcn', obj.ContainerDeleteFcn);
    jcanvas = java(obj.JCanvas);
    delete(obj.MCanvasContainer); % delete obj.MCanvasContainer object and create new one
    [obj.JCanvas, obj.MCanvasContainer] = javacomponent(jcanvas, pos, obj.mfigure);
    obj.ContainerDeleteFcn = get(obj.MCanvasContainer, 'DeleteFcn');
    set(obj.MCanvasContainer, 'DeleteFcn', {@containerDelete, obj});

    % create new context menu
    createuicontextmenu(obj, vrfigure.Videopreview);
    % add keyboard callbacks
    set(obj.JCanvas, 'KeyPressedCallback', {@keyPressed, obj});
    set(obj.JCanvas, 'KeyReleasedCallback', {@keyReleased, obj});
  end

  function setPositionCallback(obj, position)
    % it is callback for vrfigure mode
    if ~strcmp(obj.mode, 'vrfigure')
      return;
    end
    set(obj.MCanvasContainer, 'Position', position);
  end
end  % methods

methods (Static, Hidden)

  % preload OpenGL library and optionally validate for use with vr.canvas
  function preloadOpenGL(validate, msg)

    % store OpenGL preload information passed from vrclimex_init
    persistent openglerrmsg openglok openglwarn
    if nargin>1
      openglerrmsg = msg;
      return;
    end

    % report error if OpenGL not loaded
    if ~isempty(openglerrmsg)
      throwAsCaller(MException('VR:cantinitialize', 'Error initializing OpenGL. Simulink 3D Animation cannot be used on this computer.\n%s', openglerrmsg));
    end
    if ~validate
      return;
    end

    % rule out known broken OpenGL drivers
    if isempty(openglok)
      % by default driver is OK
      openglok = validate;
      openglwarn = false;

      % test for known broken drivers - currently only ATI on PC
      if any(strcmp(computer('arch'), {'win32', 'win64', 'glnx86', 'glnxa64'}))
        ogldata = opengl('data');
        switch(ogldata.Vendor)
          case 'ATI Technologies Inc.'
            ativer = sscanf(ogldata.Version, '%d.%d.%d');
            if numel(ativer)>=3
              openglok = (100*ativer(1)+ativer(2)) >= 201;
              openglwarn = ativer(3)<7873;
            end
        end
      end
    end
    if ~openglok
      throwAsCaller(MException('VR:badopengldriver', 'Simulink 3D Animation is known not to work with your graphics driver.\n%s', ...
                                                     'Please contact your graphics board vendor for driver update.'));
    end
    if openglwarn
      warning('VR:badopengldriver', 'Simulink 3D Animation may not perform optimally with your graphics driver.\n%s', ...
                                    'Please contact your graphics board vendor for driver update.');
    end
  end


  % returns height in pixels which is needed for drawing panel
  function value = getNavPanelReservedHeight(navPanel)
    switch navPanel
      case 'none'
        value = 0;
      case 'translucent'
        value = 0;
      case 'opaque'
        value = 0;
      case 'halfbar'
        value = 30;
      case 'bar'
        value = 64;
    end
  end

end  % methods

end % classdef



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    CALLBACKS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function containerDelete(this,evt,obj)

  % indicate delete in progress
  obj.BeingDeleted = true;

  % make container invisible
  set(this, 'Visible', 'off')

  % evaluate vr.canvas DeleteFcn
  if ~isempty(obj.DeleteFcn)
    try
      if ischar(obj.DeleteFcn)
        evalin('base', obj.DeleteFcn);
      elseif iscell(obj.DeleteFcn)
        feval(obj.DeleteFcn{:});
      else
        feval(obj.DeleteFcn);
      end
    catch ME
      warning('VR:callbackevalerr', ['Could not evaluate vr.canvas DELETEFCN property: ', ME.message]);
    end
  end

  % remove canvas from global list of canvas
  if ~isempty(obj.NativeCanvas)
    list = getappdata(0, 'SL3D_vrcanvas_List');
    list.remove(obj.NativeCanvas);
    setappdata(0, 'SL3D_vrcanvas_List', list);
  end

  % close any associated create viewpoint dialog
  dlg = getappdata(this, 'CreateViewpointDialog');
  if ishandle(dlg)
    close(dlg);
  end

  % flag JCanvas for deletion
  if ~isempty(obj.JCanvas)
    javaMethodMT('onCanvasDelete', obj.JCanvas);
  end

 % call original DeleteFcn
  switch numel(obj.ContainerDeleteFcn)
    case 0
      % no action
    case 1
      feval(obj.ContainerDeleteFcn, this, evt);
    otherwise
      feval(obj.ContainerDeleteFcn{1}, this, evt, obj.ContainerDeleteFcn{2:end});
  end

  % delete the vr.canvas object
  delete(obj);
end

function mousePressed(this,evt,obj)
  % process event
  checkuicontextmenu(this,evt,obj);
end

function mouseReleased(this,evt,obj)
  % process event
  checkuicontextmenu(this,evt,obj);
end

function value = checkuicontextmenu(this,evt,obj)
  value = false;
  if evt.isPopupTrigger && strcmpi(vrsfunc('GetCanvasProperty', obj.NativeCanvas, 'Fullscreen'), 'off')
    value = true;
    contextmenu = get(obj.MCanvasContainer, 'UIContextMenu');
    vr.callbacks(this,evt,obj,'updateUIContextMenu');
    units = obj.Units;
    obj.Units = 'pixels';
    opos = get(obj.MCanvasContainer, 'Position');
    obj.Units = units;
    if ~strcmp(obj.mode, 'edit')
      pos = [evt.getX + opos(1), opos(4) + opos(2) - evt.getY];
    else
      jloc =  javaMethodEDT('getLocation', obj.JCanvas); 
      pos = [evt.getX + jloc.x, opos(4) - evt.getY + opos(2)];  
    end
    set(contextmenu, 'Position', pos, 'Visible', 'on');
  end
end

function keyPressed(~, evt, obj)

  if ~isvalid(obj)
    return;
  end

  % process the key press event
  % actionvalues holds any post-process action to be done
  actionvalues = cell(obj.JCanvas.processKeyPress(evt));

  % process keyboard shortcuts
  action = actionvalues{1};
  switch(action)
    case ''
      % no action

    case 'set'
      feval(action, obj, actionvalues{2:end});

    case 'setOnOffProperty'
      % send Fullscreen to parent figure if there's any
      if strcmp(actionvalues{2}, 'Fullscreen')
        if ~strcmp(obj.mode, 'vrfigure')
          return;
        else
          obj = getappdata(obj.mfigure, 'vrfigure');
        end
      end
      feval(action, obj, actionvalues{2});

    case 'playstopSim'
      appset = vr.appdependent;
      if strcmp(obj.mode, 'vrfigure') && appset.simulation
        vr.callbacks([], [], obj, action);
      end

    case { 'startstopRecording', 'capture' }
      appset = vr.appdependent;
      if strcmp(obj.mode, 'vrfigure') && strcmp(appset.recording, 'on')
        vr.callbacks([], [], obj, action);
      end

    otherwise
      feval(action, obj);
  end
end


function keyReleased(~, evt, obj)
  if isvalid(obj)
    obj.JCanvas.processKeyRelease(evt);
  end
end
