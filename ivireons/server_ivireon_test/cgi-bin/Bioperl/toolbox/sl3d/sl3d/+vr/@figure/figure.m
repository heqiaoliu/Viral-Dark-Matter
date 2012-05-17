%FIGURE Create a new virtual reality figure.
%   F = FIGURE(WORLD) creates a new virtual reality figure
%   showing the specified world(s) and returns an appropriate
%   FIGURE object.
%
%   F = FIGURE returns an empty FIGURE object which does not
%   have a visual representation and has all properties empty.
%
%   F = FIGURE([]) returns an empty vector of type FIGURE.
%
%   F = FIGURE(WORLD, 'PropertyName', propertyvalue, ...) creates a new 
%   virtual reality figure showing the specified world(s) with specified
%   properties and returns an appropriate FIGURE object.
%
%   The following properties are valid (names are case sensitive):
%
%      'Antialiasing' (settable)
%         Determines whether antialiasing is used when rendering scene.
%         Antialiasing smoothes textures by interpolating values between
%         texture points. This causes a significant CPU load but makes
%         the scene look more natural.
%
%      'CameraBound' (settable)
%         This property controls whether the camera is bound to the
%         current viewpoint (i.e. it moves with it) or not.
%         When the camera is bound, its position, direction, and up vector
%         are relative to the viewpoint. For unbound camera, these values
%         are absolute.
%
%      'CameraDirection' (settable)
%         Camera direction, relative to the current viewpoint's direction.
%
%      'CameraDirectionAbs' (read-only)
%         Camera direction, in world coordinates.
%
%      'CameraPosition' (settable)
%         Camera position, relative to the current viewpoint's position.
%
%      'CameraPositionAbs' (read-only)
%         Camera position, in world coordinates.
%
%      'CameraUpVector' (settable)
%         Camera up vector, relative to the current viewpoint's up vector.
%
%      'CameraUpVectorAbs' (read-only)
%         Camera up vector, in world coordinates.
%
%      'CaptureFileFormat' (settable)
%         File format for VR figure capture files.
%
%      'CaptureFileName' (settable)
%         File name for VR figure capture files.
%         The file name can contain following tokens that will be interpreted
%         at the time of creating the graphic file:
%
%           '%f' will be replaced by the virtual world filename  
%           '%d' will be replaced by the full path of the world file directory  
%           '%n' will be replaced by an incremental number  
%           '%h' will be replaced by current time hour (hh)  
%           '%m' will be replaced by current time minute (mm)  
%           '%s' will be replaced by current time second (ss)  
%           '%D' will be replaced by current day in month (dd)  
%           '%M' will be replaced by current month (mm)  
%           '%Y' will be replaced by current year (yyyy)  
%
%      'DeleteFcn' (settable)
%         Callback invoked when the figure is closing.
%
%      'Fullscreen' (settable)
%         Specifies whether the figure is in the fullscreen mode.
%
%      'Headlight' (settable)
%         Specifies whether headlight is enabled.
%         The headlight is an additional white directional light
%         that moves and rotates with the camera.
%
%      'Lighting' (settable)
%         Specifies whether lighting is taken into account when rendering.
%         If it is off, all objects are drawn as if uniformly lit.
%
%      'MaxTextureSize' (settable)
%         The maximum pixel size used for drawing textures. The value must be
%         power of two and may be further adjusted to match specific hardware
%         renderer limits. Increasing this value improves image quality but
%         decreases performance. The value 'auto' sets the maximum possible
%         texture size.
%
%      'Name' (settable)
%         Name of this VR figure.
%
%      'NavMode' (settable)
%         Specifies the current navigation mode. Valid settings are
%         'walk', 'examine', or 'fly'.
%
%      'NavSpeed' (settable)
%         Specifies the current navigation speed. Valid settings are
%         'veryslow', 'slow', 'normal', 'fast', or 'veryfast'.
%
%      'NavPanel' (settable)
%         Panel mode. This affects how the control panel in the figure
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
%           'halfbar'
%              Most of the panel (except large items, like navigation wheel)
%              is drawn into a bar below the scene.
%
%           'bar'
%              Whole panel is drawn into a bar below the scene.
%
%      'NavZones' (settable)
%         Specifies if the navigation zones should be displayed.
%
%      'Position' (settable)
%         Screen coordinates of this VR figure.
%
%      'Record2D' (settable)
%         Enables 2D offline animation recording.
%
%      'Record2DCompressMethod' (settable)
%         Specifies compression method for creating 2D animation files.
%         Valid settings are '', 'auto', 'lossless', 'codec_code'
%         For valid 'codec_code' settings see AVIFILE.
%
%      'Record2DCompressQuality' (settable)
%         Specifies quality of 2D animation file compression.
%
%      'Record2DFileName' (settable)
%         2D offline animation file name.
%         The file name can contain following tokens that will be interpreted
%         at the time of creating the animation file:
%
%           '%f' will be replaced by the virtual world filename  
%           '%d' will be replaced by the full path of the world file directory  
%           '%n' will be replaced by an incremental number  
%           '%h' will be replaced by current time hour (hh)  
%           '%m' will be replaced by current time minute (mm)  
%           '%s' will be replaced by current time second (ss)  
%           '%D' will be replaced by current day in month (dd)  
%           '%M' will be replaced by current month (mm)  
%           '%Y' will be replaced by current year (yyyy)  
%
%      'Record2DFPS' (settable)
%         2D offline animation file frames per second parameter.
%         Scalar value specifying the speed of the AVI movie 
%         in frames per second (fps). 
%         For further information see AVIFILE.
%
%      'StatusBar' (settable)
%         Specifies whether the status bar is shown.
%
%      'ToolBar' (settable)
%         Specifies whether the toolbar is shown.
%
%      'Textures' (settable)
%         Specifies whether textures are rendered.
%
%      'Transparency' (settable)
%         Specifies whether transparency is taken into account when
%         rendering. If it is off, all objects are drawn opaque.
%
%      'Viewpoint' (settable)
%         Viewpoint currently active for the given VR figure
%         (an empty string if the active viewpoint has no description).
%
%      'Wireframe' (settable)
%         Specifies whether wireframes should be drawn instead of solid
%         objects.
%
%      'World' (read-only)
%         World this VR figure is showing.
%
%      'ZoomFactor' (settable)
%         Camera zoom factor. Default zoom factor value is 1,
%         zoom factor of 2 makes the scene look twice as big,
%         zoom factor of 0.1 makes it look 10 times smaller, etc.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.19.2.2 $ $Date: 2010/07/01 20:44:31 $ $Author: batserve $

classdef figure < hgsetget 

properties (Dependent)
  %#ok<*MCSUP>  allow to access dependent properties without MLint warning
  Antialiasing@char;
  CameraBound@char;
  CameraDirection@double;
  CameraPosition@double;
  CameraUpVector@double;
  CaptureFileName@char;
  CaptureFileFormat@char;
  Fullscreen@char;
  Headlight@char;
  Lighting@char;
  MaxTextureSize;
  Name@char;
  NavPanel@char;
  NavMode@char;
  NavSpeed@char;
  NavZones@char;
  Position@double;
  Record2D@char;
  Record2DFileName@char;
  Record2DCompressMethod@char;
  Record2DCompressQuality@double;
  Record2DFPS@double;
  StatusBar@char;
  Textures@char;
  ToolBar@char;
  Transparency@char;
  Viewpoint@char;
  Wireframe@char;
  ZoomFactor@double;
end

properties
  DeleteFcn@char;  
end

properties (Dependent, Hidden)
  PlaneClipMethod@char;
end

properties (SetAccess = private, Dependent)
  CameraDirectionAbs@double;
  CameraPositionAbs@double;
  CameraUpVectorAbs@double;
  World;
end

properties (SetAccess = private, Hidden)
  mfigure;
  canvas;
end

properties (Hidden)
  BlockParametersFcn@char;
  CreateFigureFcn@char = '';
  SimStatus@char = 'disabled'; % all figures' statuses are updated in vrmfunc

  SimContinueFcn@char;
  SimPauseFcn@char;
  SimStartFcn@char;
  SimStopFcn@char;
end

properties (GetAccess = private, Hidden, Dependent) 
  WindowCommand@char;
end

properties (SetAccess = private, GetAccess = public, Hidden)
  Videopreview@logical = false;
end

properties (Constant, Hidden)
  StatusBarGap@double = 20;
end

methods

  function obj = figure(world, varargin)
    if nargin == 0
      % it is needed for array of instances initialization (we cannot throw exception)   
      return;
    end

    % create empty vector of vr.figure objects
    if isempty(world)
      obj = vr.figure.empty;
      return;
    end 

    if ~isa(world, 'vrworld')  
      throwAsCaller(MException('VR:invalidinarg', 'Argument WORLD must be of type VRWORLD.'));
    end
    
    % default videopreview
    videopreview = 0;
    % empty inargs 
    inargs = cell(2,0);
    
    if ~isempty(varargin)
      % in varargin there are key-value pairs so it must have even count
      if mod(numel(varargin), 2) ~= 0
        throwAsCaller(MException('VR:invalidinarg', 'Invalid number of arguments.'));       
      end
      
      % rearrange cell array to two sets (property names and values)
      inargs = reshape(varargin, 2, []);
      
      % try to find Videopreview in passed properties 
      videoprevindex = find(strcmp('Videopreview', inargs(1, :)), 1, 'last');
      if ~isempty(videoprevindex)
        % we found Videopreview
        videopreview = inargs{2, videoprevindex};
        if ~isnumeric(videopreview) || (videopreview~=0 && videopreview~=1)
          throwAsCaller(MException('VR:invalidinarg', 'Videopreview must be 0 or 1.'));
        end
      end
    end
       
    % try to find Fullscreen in passed properties 
    fullscreenindex = find(strcmp('Fullscreen', inargs(1, :)), 1, 'last');
    fullscreenargs = inargs(:, fullscreenindex); 
    inargs(:, fullscreenindex) = [];
    
    worldcount = numel(world);
    obj(worldcount) = vr.figure;       
    for i=1:worldcount
      obj(i) = initialize(obj(i), world(i), videopreview);  
      try
        vr.figure.setDefaultProperties(obj(i));       
        if ~isempty(inargs)
          set(obj(i), inargs{:});
        end 
        
        % set figure visible after initialization
        set(obj(i).mfigure, 'Visible', 'on');
        drawnow;      

        % and in the end set Fullscreen if needed
        if ~isempty(fullscreenargs)
          set(obj(i), fullscreenargs{:});      
        end
      catch ME
        delete(obj);    
        throwAsCaller(ME);    
      end 
    end
  end

end

methods (Hidden)  
  function obj = initialize(obj, world, videopreview)   
    % default position in pixels
    position = vrgetpref('DefaultFigurePosition');            
    % create the figure
    obj.mfigure = figure('Units', 'pixels', ...
        'HandleVisibility', 'callback', ...
        'IntegerHandle', 'off',...
        'ToolBar', 'none', ...
        'MenuBar', 'none', ...
        'Visible', 'off', ...
        'NumberTitle', 'off', ...
        'Name', get(world, 'Description'));
    try
      obj.canvas = vr.canvas(world, obj, [0, 0, position(3), position(4)], videopreview);
    catch ME
      delete(obj.mfigure);
      throwAsCaller(ME);
    end   

    obj.Videopreview = logical(videopreview);
    obj.Position = position;
    obj.Name = get(world, 'Description');
    setappdata(obj.mfigure, 'vrfigure', obj);
    setappdata(obj.mfigure, 'canvas', obj.canvas);
    createuimenu(obj, videopreview);
    if ~videopreview
      createuistatusbar(obj);
      createuitoolbar(obj);
    else
      set(obj.mfigure, 'Resize', 'off', 'DockControls', 'off');
    end
    set(obj.mfigure, 'CloseRequestFcn', {@requestClose, obj});
    set(obj.mfigure, 'ResizeFcn', @resizeFigureFcn);

    % store figure into global list of figures
    allfigs = getappdata(0, 'SL3D_vrfigure_List');
    if isempty(allfigs)
      % initialize Map object with uint64 key, mixed-type value
      allfigs = containers.Map('KeyType', 'uint64', 'ValueType', 'any');
    end
    allfigs(obj.canvas.NativeCanvas) = obj;
    setappdata(0, 'SL3D_vrfigure_List', allfigs);
  end
end

methods
  function delete(obj)
    % object may not fully constructed after exception in constructor
    % we handle this condition by isempty and isvalid tests below

    % call DeleteFcn
    setappdata(0, 'SL3D_vrfigure_gcbf',  obj);
    if ~isempty(obj.DeleteFcn)
      try    
        evalin('base', obj.DeleteFcn);
      catch ME  
        warning('VR:callbackerror', 'Error evaluating vr.figure ''DeleteFcn'' callback: "%s"', ME.message);    
      end
    end

    % remove figure from global list of figures
    if ~isempty(obj.canvas) && isvalid(obj.canvas)
      allfigs = getappdata(0, 'SL3D_vrfigure_List');
      if ~isempty(allfigs) && allfigs.isKey(obj.canvas.NativeCanvas)
        allfigs.remove(obj.canvas.NativeCanvas);
      end
      setappdata(0, 'SL3D_vrfigure_List', allfigs);
    end

    % delete container figure - this also deletes embedded vr.canvas object
    if ishandle(obj.mfigure)

      % close any associated recording parameters dialog
      recdlg = getappdata(obj.mfigure, 'RecordingDialog');
      if ishandle(recdlg)
        close(recdlg);
      end
      
      delete(obj.mfigure);
    end
    setappdata(0, 'SL3D_vrfigure_gcbf', []);
  end

  % reimplemented from hgsetget, now it displays nothing
  function setdisp(~)
  end

  function close(obj)
    if isvalid(obj)
      delete(obj);
    end
  end
end 


methods (Static, Hidden)
  function value = gcbf()
    if ~isempty(gcbf)
      value = getappdata(gcbf, 'vrfigure');
    else
      value = getappdata(0, 'SL3D_vrfigure_gcbf');
    end
  end

  function setDefaultProperties(obj)
    % read preferences that start with 'DefaultFigure' but not 'DefaultFigurePosition'
    prefs = vrgetpref;
    prefnames = fieldnames(prefs);
    prefs = struct2cell(prefs);
    prefidx = strncmp(prefnames, 'DefaultFigure', 13) & ~strcmp(prefnames, 'DefaultFigurePosition');
    prefnames = prefnames(prefidx);
    prefs = prefs(prefidx);

    % remove the 'DefaultFigure' string from the preference name
    for i=1:numel(prefnames)
      prefnames{i} = prefnames{i}(14:end);
    end

    % add clone function
    prefnames = [prefnames; {'CreateFigureFcn'}]; %;!!
    prefs = [prefs; {'vrfigure(get(vrgcbf,''World''));'}];

    % add edit function
    if isa(obj, 'vrfigure')  
      prefnames = [prefnames; {'StartEditorFcn'}];
      prefs = [prefs; {'edit(get(vrgcbf,''World''));'}];
    end

    % set figure defaults
    set(obj, prefnames, prefs');      
  end

  function y = isDefaultViewer
  % tests if vr.figure is the default viewer
    pref = vrgetpref('DefaultViewer');
    y = (strcmpi(pref, 'internal') && vr.figure.isFactoryViewer) || strcmpi(pref, 'internalv5');
  end

  function y = isFactoryViewer
  % tests if vr.figure is the factory-default viewer
    % the code below in effect means "true for all platforms"
    y = ispc || ismac || strcmp(computer('arch'), 'glnxa64') || isempty(which('qeinbat')) || ~qeinbat;
  end

  function vf = fromHGFigure(f)
  % convert MATLAB HG figure to vr.figure if possible
    vf = getappdata(f, 'vrfigure');
    if ~isa(vf, 'vr.figure')
      vf = vr.figure([]);
    end
  end

end


methods % getters
  function value = get.Antialiasing(obj)
    value = obj.canvas.Antialiasing;
  end

  function value = get.CameraBound(obj)
    value = obj.canvas.CameraBound;
  end

  function value = get.CameraDirection(obj)
    value = obj.canvas.CameraDirection;
  end

  function value = get.CameraDirectionAbs(obj)
    value = obj.canvas.CameraDirectionAbs;
  end

  function value = get.CameraPosition(obj)
    value = obj.canvas.CameraPosition;
  end

  function value = get.CameraPositionAbs(obj)
    value = obj.canvas.CameraPositionAbs;
  end

  function value = get.CameraUpVector(obj)
    value = obj.canvas.CameraUpVector;
  end

  function value = get.CameraUpVectorAbs(obj)
    value = obj.canvas.CameraUpVectorAbs;
  end

  function value = get.CaptureFileName(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'CaptureFileName');
  end

  function value = get.CaptureFileFormat(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'CaptureFileFormat');
  end

  function value = get.Fullscreen(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'Fullscreen');
  end

  function value = get.Headlight(obj)
    value = obj.canvas.Headlight;
  end

  function value = get.Lighting(obj)
    value = obj.canvas.Lighting;
  end

  function value = get.MaxTextureSize(obj)
    value = obj.canvas.MaxTextureSize;
  end

  function value = get.Name(obj)
    value = obj.canvas.Name; %;!!
  end

  function value = get.NavPanel(obj)
    value = obj.canvas.NavPanel;
  end

  function value = get.NavMode(obj)
    value = obj.canvas.NavMode;
  end

  function value = get.NavSpeed(obj)
    value = obj.canvas.NavSpeed;
  end

  function value = get.NavZones(obj)
    value = obj.canvas.NavZones;
  end

  function value = get.PlaneClipMethod(obj)
    value = obj.canvas.PlaneClipMethod;
  end

  function value = get.Position(obj)
    scrunits = get(0, 'Units');
    set(0, 'Units', 'pixels');
    scrpos = get(0, 'ScreenSize');
    set(0, 'Units', scrunits);
    gap = vr.canvas.getNavPanelReservedHeight(obj.NavPanel);
    canvaspos = obj.canvas.Position + [0 gap 0 -gap];
    figpos = get(obj.mfigure, 'Position');
    statusbargap = zeros(1,4);
    if strcmpi(obj.StatusBar, 'on')
      statusbargap = [0 obj.StatusBarGap 0 0];
    end
    % recompute position, reference point is top-left corner.
    value = [figpos(1:2) canvaspos(3:4)] + [0 canvaspos(4) 0 0] + statusbargap + [0 vr.canvas.getNavPanelReservedHeight(obj.NavPanel) 0 0];
    value(2) = scrpos(4) - value(2);
  end

  function value = get.Record2D(obj)
      value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'Record2D');
  end

  function value = get.Record2DFileName(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DFileName');
  end

  function value = get.Record2DCompressMethod(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DCompressMethod');
  end

  function value = get.Record2DCompressQuality(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DCompressQuality');
  end

  function value = get.Record2DFPS(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DFPS');
  end

  function value = get.StatusBar(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'StatusBar');
  end

  function value = get.Textures(obj)
    value = obj.canvas.Textures;
  end

  function value = get.ToolBar(obj)
    value = vrsfunc('GetCanvasProperty', obj.canvas.NativeCanvas, 'ToolBar');
  end

  function value = get.Transparency(obj)
    value = obj.canvas.Transparency;
  end

  function value = get.Viewpoint(obj)
    value = obj.canvas.Viewpoint;
  end

  function value = get.WindowCommand(~)
    value = '';
  end

  function value = get.Wireframe(obj)
    value = obj.canvas.Wireframe;
  end

  function value = get.World(obj)
    value = obj.canvas.World;
  end

  function value = get.ZoomFactor(obj)
    value = obj.canvas.ZoomFactor;
  end
end % end of getters

methods % setters
  function set.Antialiasing(obj, arg)
    obj.canvas.Antialiasing = arg;
  end

  function set.CameraBound(obj, arg)
    obj.canvas.CameraBound = arg;
    updateStatusBar(obj); %;!!
  end

  function set.CameraDirection(obj, arg)
    obj.canvas.CameraDirection = arg;
  end
  
  function set.CameraDirectionAbs(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Figure property ''CameraDirectionAbs'' is read-only.'));
  end

  function set.CameraPosition(obj, arg)
    obj.canvas.CameraPosition = arg;
  end
  
  function set.CameraPositionAbs(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Figure property ''CameraPositionAbs'' is read-only.'));
  end  

  function set.CameraUpVector(obj, arg)
    obj.canvas.CameraUpVector = arg;
  end

  function set.CameraUpVectorAbs(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Figure property ''CameraUpVectorAbs'' is read-only.'));
  end   
  
  function set.CaptureFileName(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'CaptureFileName', arg);
    obj.canvas.JCanvas.requestRedraw();  
  end

  function set.CaptureFileFormat(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'CaptureFileFormat', arg);
    obj.canvas.JCanvas.requestRedraw();                             
  end

  function set.DeleteFcn(obj, arg)
    if ~ischar(arg) && ~isa(arg, 'function_handle')
      throwAsCaller(MException('VR:invalidfn', 'Input argument ''DeleteFcn'' must be of type ''char'' or ''function handle''.'));
    else
      obj.DeleteFcn = arg;
    end
  end

  function set.Fullscreen(obj, arg)
    if obj.Videopreview
      return;
    end
    if java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().isFullScreenSupported()
      vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'Fullscreen', arg);
      obj.canvas.JCanvas.changeFullScreen(arg);
      if strcmpi(arg, 'on')  
        set(obj.mfigure, 'Visible', 'off');
        % workaround canvas visibility issue
        setJCanvasVisible(obj.canvas);
      end
      if strcmpi(arg, 'off')
        % Fullscreen invalidated hg container, create new one 
        set(obj.mfigure, 'Visible', 'on');
        createNewCanvasContainer(obj.canvas, obj);
      end
      obj.canvas.JCanvas.requestRedraw(); 
    else
      warning('VR:fullscreennotsupported', 'Currently used graphic device does not support fullscreen mode'); 
    end
  end

  function set.Headlight(obj, arg)
    obj.canvas.Headlight = arg;
  end

  function set.Lighting(obj, arg)
    obj.canvas.Lighting = arg;
  end

  function set.MaxTextureSize(obj, arg)
    obj.canvas.MaxTextureSize = arg;
  end

  function set.Name(obj, arg)
    obj.canvas.Name = arg;
    set(obj.mfigure, 'Name', arg); %;!!
  end

  function set.NavPanel(obj, arg)
    if obj.Videopreview
      arg = 'none';
    end
    obj.canvas.NavPanel = arg;
  end

  function set.NavMode(obj, arg)
    obj.canvas.NavMode = arg;
  end

  function set.NavSpeed(obj, arg)
    obj.canvas.NavSpeed = arg;
  end

  function set.NavZones(obj, arg)
    obj.canvas.NavZones = arg;
  end

  function set.PlaneClipMethod(obj, arg)
    obj.canvas.PlaneClipMethod = arg;
  end

  function set.Position(obj, arg)
    scrunits = get(0, 'Units');
    set(0, 'Units', 'pixels');
    scrpos = get(0, 'ScreenSize');
    set(0, 'Units', scrunits);
    % recompute position, reference point is top-left corner.
    arg(2) = scrpos(4) - arg(2) - arg(4);
    statusbargap = zeros(1,4);
    if strcmpi(obj.StatusBar, 'on')
      statusbargap = [0 -obj.StatusBarGap 0 obj.StatusBarGap];
    end
    gap = vr.canvas.getNavPanelReservedHeight(obj.NavPanel);
    pos = arg + [0 -gap 0 gap] + statusbargap;
    set(obj.mfigure, 'Position', pos);
    
    % handle required size smaller than the smallest possible window
    newpos = get(obj.mfigure, 'Position');
    if ~isequal(newpos(3:4), pos(3:4))
      set(obj.canvas, 'Position', [0 0 pos(3:4)]);
    end
    % drawnow commits the position change
    drawnow;
  end

  function set.Record2D(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'Record2D', arg);
    updateRecGUI(obj);
    obj.canvas.JCanvas.requestRedraw();                               
  end

  function set.Record2DFileName(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DFileName', arg);
    obj.canvas.JCanvas.requestRedraw();                              
  end

  function set.Record2DCompressMethod(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DCompressMethod', arg);
    obj.canvas.JCanvas.requestRedraw();  
  end

  function set.Record2DCompressQuality(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DCompressQuality', arg);
    obj.canvas.JCanvas.requestRedraw();                                  
  end

  function set.Record2DFPS(obj, arg)
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'Record2DFPS', arg);
    obj.canvas.JCanvas.requestRedraw();                                      
  end

  function set.SimStatus(obj, arg)
    obj.SimStatus = arg;
    plpaubutton = findobj(obj.mfigure, 'Tag', 'VRSimPlayPause');
    stopbutton = findobj(obj.mfigure, 'Tag', 'VRSimStop');
    plpaumenu = findobj(obj.mfigure, 'Tag', 'VRSimPlayPauseMenu');
    stopmenu = findobj(obj.mfigure, 'Tag', 'VRSimStopMenu');
    simmenu = findobj(obj.mfigure, 'Tag', 'VRSimMenu');

    switch lower(arg)
      case { 'stopped', 'initializing', 'updating', 'terminating' }
        if ~obj.Videopreview
          set(plpaubutton, 'Enable', 'on');
          set(plpaubutton, 'TooltipString', 'Start Simulation');
          set(plpaubutton, 'CData', getappdata(plpaubutton, 'StartIcon'));
          set(stopbutton, 'Enable', 'off');
        end
        set(plpaumenu, 'Enable', 'on');
        set(plpaumenu, 'Label', 'Start');
        set(stopmenu, 'Enable', 'off');
        set(simmenu, 'Enable', 'on');

      case 'running'
        if ~obj.Videopreview
          set(plpaubutton, 'Enable', 'on');
          set(plpaubutton, 'TooltipString', 'Pause Simulation');
          set(plpaubutton, 'CData', getappdata(plpaubutton, 'PauseIcon'));
          set(stopbutton, 'Enable', 'on');
        end
        set(plpaumenu, 'Enable', 'on');
        set(plpaumenu, 'Label', 'Pause');
        set(stopmenu, 'Enable', 'on');

      case 'paused'
        if ~obj.Videopreview
          set(plpaubutton, 'Enable', 'on');
          set(plpaubutton, 'TooltipString', 'Continue Simulation');
          set(plpaubutton, 'CData', getappdata(plpaubutton, 'StartIcon'));
          set(stopbutton, 'Enable', 'on');
        end
        set(plpaumenu, 'Enable', 'on');
        set(plpaumenu, 'Label', 'Continue');
        set(stopmenu, 'Enable', 'on');        
    end

    if ~strcmpi(arg, 'disabled')
      if ~obj.Videopreview
        blpar = findobj(obj.mfigure, 'Tag', 'VRBlockParams');
        set(blpar, 'Enable', 'on');
      end
      blparmenu = findobj(obj.mfigure, 'Tag', 'VRBlockParamsMenu');
      set(blparmenu, 'Enable', 'on');
    end

    % commit menu and toolbar changes
    drawnow;
  end

  function set.SimStopFcn(obj, arg)
    obj.SimStopFcn = arg;  
  end

  function set.StatusBar(obj, arg)
    if obj.Videopreview  % video preview never has the status bar
      arg = 'off';
    end
    oldstatusbar = obj.StatusBar;
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'StatusBar', arg);
    obj.canvas.JCanvas.setStatusBarVisible(arg);
    mfigpos = get(obj.mfigure, 'Position');
    if strcmpi(arg, 'on') && strcmpi(oldstatusbar, 'off')
      set(obj.mfigure, 'Position', mfigpos + [0 -obj.StatusBarGap 0 obj.StatusBarGap]);
    end
    if strcmpi(arg, 'off') && strcmpi(oldstatusbar, 'on')
      set(obj.mfigure, 'Position', mfigpos + [0 obj.StatusBarGap 0 -obj.StatusBarGap]);
    end
    statusbar = getappdata(obj.mfigure, 'VRFigureStatusBarHGComponents');
    if ~isempty(statusbar)
      set(statusbar, 'Visible', arg);
    end
    obj.canvas.JCanvas.requestRedraw();   

    % drawnow commits the statusbar
    drawnow;
  end

  function set.Textures(obj, arg)
    obj.canvas.Textures = arg;
  end

  function set.ToolBar(obj, arg)
    if obj.Videopreview  % video preview never has the toolbar
      arg = 'off';
    end
    vrsfunc('SetCanvasProperty', obj.canvas.NativeCanvas, 'ToolBar', arg);
    set(findobj(obj.mfigure, 'Tag', 'VRToolbar'), 'Visible', arg);
    obj.canvas.JCanvas.requestRedraw();

    % drawnow commits the toolbar
    drawnow;
  end

  function set.Transparency(obj, arg)
    obj.canvas.Transparency = arg;
  end

  function set.Viewpoint(obj, arg)
    obj.canvas.Viewpoint = arg;
    if strcmp(obj.StatusBar, 'on')
      updateStatusBar(obj);
    end  
  end

  function set.WindowCommand(obj, arg)
    switch lower(arg)
      case 'raise'
        set(obj.mfigure, 'Visible', 'on');
      case 'dock'
        set(obj.mfigure, 'WindowStyle', 'docked');
      case 'undock'
        set(obj.mfigure, 'WindowStyle', 'normal');
      otherwise
        throwAsCaller(MException('VR:badpropval', 'Unrecognized value for ''WindowCommand''.'));
    end
  end

  function set.Wireframe(obj, arg)
    obj.canvas.Wireframe = arg;
  end

  function set.World(~, ~)
    throwAsCaller(MException('VR:propreadonly', 'Figure property ''World'' is read-only.'));
  end

  function set.ZoomFactor(obj, arg)
    obj.canvas.ZoomFactor = arg;
  end
end % end of setters

methods % other public methods
  function value = capture(obj)
    value = capture(obj.canvas);
  end
end % end of other public methods

methods (Hidden)
  function requestClose(~, ~, obj)
    if obj.Videopreview && strcmp(obj.SimStatus, 'running')
      return;
    end
    close(obj);
  end  
  
  function updateStatusBar(obj)    
        
    % set Viewpoint's string
    vpstring = get(obj, 'Viewpoint');
    if strcmp(vpstring,'')
      vpstring = 'No Viewpoint';    
    end
    set(findobj(obj.mfigure, 'Tag', 'VRStatusBarViewpoint'), 'String', vpstring);
    
    % set NavMode string
    navmodestring =  get(obj, 'NavMode');
    set(findobj(obj.mfigure, 'Tag', 'VRStatusBarNavMode'), 'String', [upper(navmodestring(1)),navmodestring(2:end)]);  
    
    % update time and position with direction
    time = get(obj.World, 'Time');
    position = obj.CameraPositionAbs;
    direction = obj.CameraDirectionAbs;
    statusbartime = findobj(obj.mfigure, 'Tag', 'VRStatusBarTime');
    set(statusbartime, 'String', sprintf('T=%.2f', time));
    
    statusbarposanddir = findobj(obj.mfigure, 'Tag', 'VRStatusBarPosAndDir');
    set(statusbarposanddir, 'String', sprintf('Pos:[%.2f %.2f %.2f] Dir:[%.2f %.2f %.2f]',...
                                               position(1), position(2), position(3),...
                                               direction(1), direction(2), direction(3)));
  end

  function updateRecGUI(obj)
    rec3d = get(obj.World, 'Record3D');
    rec2d = obj.Record2D;
    if strcmpi(rec2d, 'on') || strcmpi(rec3d, 'on')
      onoff = 'on';
    else
      onoff = 'off';
    end
    toggleb = findobj(obj.mfigure, 'Tag', 'VRREC_toggleb');
    set(toggleb, 'Enable', onoff);

    state = get(obj.World, 'Recording');
    set(toggleb, 'State', state);

    recmenu = findobj(obj.mfigure, 'Tag', 'VRRecMenu');
    recstart = findobj(recmenu, 'Tag', 'VRRecStart');
    recstop = findobj(recmenu, 'Tag', 'VRRecStop');
    recparams = findobj(recmenu, 'Tag', 'VRRecParams');
    if strcmpi(state, 'on')
      set(recstart, 'Enable', 'off');
      set(recstop, 'Enable', 'on');
      set(recparams, 'Enable', 'off');
    else
      if strcmpi(onoff, 'on')
        set(recstart, 'Enable', 'on');
      end
      set(recstop, 'Enable', 'off');
      appset = vr.appdependent;
      set(recparams, 'Enable', appset.capture);
    end
  end

  function setOnOffProperty(obj, propname)
    onoff = get(obj, propname); 
    if strcmpi(onoff, 'on')
      set(obj, propname, 'off');  
    else
      set(obj, propname, 'on');
    end
  end

  % snap the whole figure including window decorations to RGB image
  function u = snap(obj)
    % bring the container figure to front and let it render
    figure(obj.mfigure);
    drawnow;

    % print the container window into Java BufferedImage
    jf = javax.swing.SwingUtilities.getWindowAncestor(obj.canvas.JCanvas);
    w = jf.getWidth;
    h = jf.getHeight;
    bi = java.awt.image.BufferedImage(w, h, java.awt.image.BufferedImage.TYPE_3BYTE_BGR);
    javaMethodEDT('printAll', jf, bi.createGraphics);
    
    % read the BufferedImage and convert it to an RGB array
    u = permute(reshape(typecast(bi.getData.getDataElements(0, 0, w, h, []), 'uint8'), 3, w, h), [3 2 1]);
  end


end % end of hidden methods

methods(Access=private)
  function createuimenu(f, videopreview)
    appset = vr.appdependent;
    % file menu
    if ~videopreview
      filemenu = uimenu(f.mfigure, 'Label', '&File');
      uimenu(filemenu, 'Label', 'New &Window', 'Callback', {@createCopyOfThisFigureCallback, f});
      uimenu(filemenu, 'Label', 'Open in &Editor', 'Enable', appset.filesave, 'Separator', 'on', 'Callback', {@vr.callbacks, f.canvas, 'startEditor'});
      uimenu(filemenu, 'Label', '&Reload', 'Separator', 'on', 'Callback', {@vr.callbacks, f.canvas, 'onFileReload'});
      uimenu(filemenu, 'Label', 'Save &As...', 'Enable', appset.filesave, 'Callback', {@vr.callbacks, f.canvas, 'onFileSave'});
      uimenu(filemenu, 'Label', '&Close', 'Separator', 'on', 'Callback', {@requestClose, f});
    end
    % view menu
    viewmenu = uimenu(f.mfigure, 'Label', '&View', 'Tag', 'VR_ViewMenu', 'Callback', {@vr.callbacks, f.canvas, 'updateUIViewMenu'});
    
    if ~videopreview
      % toolbar menu
      uimenu(viewmenu, 'Label', '&Toolbar', 'Tag', 'VR_toolbarmenu', 'Callback', {@vrfigcallbacks, 'ToolBar'});
      % status bar menu
      uimenu(viewmenu, 'Label', '&Status Bar', 'Tag', 'VR_statusbarmenu', 'Callback', {@vrfigcallbacks, 'StatusBar'});
    end
    % navigation zones
    uimenu(viewmenu, 'Label', 'Navigation &Zones', 'Tag', 'VR_navzonesmenu', 'Callback', {@vr.callbacks, f.canvas, 'NavZones'});
    
    if ~videopreview
      % navigation panel menu
      navPanelModeMenu = uimenu(viewmenu, 'Label', 'Navigation &Panel', 'Separator', 'on');
      uimenu(navPanelModeMenu, 'Label', '&None', 'UserData', 'none', 'Tag', 'VR_navpanelmenu', 'Checked', 'off', 'Callback', {@vr.callbacks, f.canvas, 'NavPanel'});
      uimenu(navPanelModeMenu, 'Label', 'Opa&que', 'UserData', 'opaque', 'Tag', 'VR_navpanelmenu', 'Checked', 'off', 'Callback', {@vr.callbacks, f.canvas, 'NavPanel'});
      uimenu(navPanelModeMenu, 'Label', '&Translucent', 'UserData', 'translucent', 'Tag', 'VR_navpanelmenu', 'Checked', 'off', 'Callback', {@vr.callbacks, f.canvas, 'NavPanel'});
      uimenu(navPanelModeMenu, 'Label', '&Halfbar', 'UserData', 'halfbar', 'Tag', 'VR_navpanelmenu', 'Checked', 'off', 'Checked', 'off', 'Callback', {@vr.callbacks, f.canvas, 'NavPanel'});
      uimenu(navPanelModeMenu, 'Label', '&Bar', 'UserData', 'bar', 'Tag', 'VR_navpanelmenu', 'Checked', 'off', 'Callback', {@vr.callbacks, f.canvas, 'NavPanel'});
    end

    % zooming
    uimenu(viewmenu, 'Label', 'Zoom &In', 'Separator', 'on', 'Callback', {@vr.callbacks, f.canvas, 'zoomIn'});
    uimenu(viewmenu, 'Label', 'Zoom &Out', 'Callback', {@vr.callbacks, f.canvas, 'zoomOut'});
    uimenu(viewmenu, 'Label', '&Normal (100%)', 'Callback', {@vr.callbacks, f.canvas, 'viewNormal'});
    
    if ~videopreview
      % fullscreen
      uimenu(viewmenu, 'Label', '&Fullscreen Mode', 'Tag', 'VRFullscreen', 'Separator', 'on', 'Callback', {@vrfigcallbacks, 'Fullscreen'});
    end

    % viewpoints menu
    viewpointsmenu = uimenu(f.mfigure, 'Label', 'View&points', 'Tag', 'VR_ViewpointsMenu', 'Callback', {@vr.callbacks, f.canvas, 'updateUIViewpointsMenu'});
    setappdata(f.mfigure, 'vpmenu', viewpointsmenu);
    uimenu(viewpointsmenu, 'Label', '&Previous Viewpoint', 'Callback', {@vr.callbacks, f.canvas,'gotoPrevViewpoint'});
    uimenu(viewpointsmenu, 'Label', '&Next Viewpoint', 'Callback', {@vr.callbacks, f.canvas, 'gotoNextViewpoint'});
    uimenu(viewpointsmenu, 'Label', '&Return to Viewpoint', 'Callback', {@vr.callbacks, f.canvas, 'navGoHome'});
    uimenu(viewpointsmenu, 'Label', 'Go to &Default Viewpoint', 'Callback', {@vr.callbacks, f.canvas, 'gotoDefaultViewpoint'});
    uimenu(viewpointsmenu, 'Label', '&Create Viewpoint...', 'Separator', 'on', 'Callback', {@vr.callbacks, f.canvas, 'createViewpoint'});
    uimenu(viewpointsmenu, 'Label', 'Re&move Current Viewpoint', 'Tag', 'VR_RemoveCurrentViewpoint', ...
                           'Callback', {@vr.callbacks, f.canvas, 'removeViewpoint'});
    updateViewpointsComboBox(f.canvas);
    
    % navigation menu
    navigationmenu = uimenu(f.mfigure, 'Label', '&Navigation', 'Tag', 'VR_NavigationMenu', 'Callback', {@vr.callbacks, f.canvas, 'updateUINavigationMenu'});
    methodmenu = uimenu(navigationmenu, 'Label', '&Method');
    uimenu(methodmenu, 'Label', '&Walk', 'UserData', 'walk', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, f.canvas, 'NavMode'});
    uimenu(methodmenu, 'Label', '&Examine', 'UserData', 'examine', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, f.canvas, 'NavMode'});
    uimenu(methodmenu, 'Label', '&Fly', 'UserData', 'fly', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, f.canvas, 'NavMode'});
    uimenu(methodmenu, 'Label', '&None', 'UserData', 'none', 'Tag', 'VR_navmodemenu', 'Callback', {@vr.callbacks, f.canvas, 'NavMode'});

    % speedmenu
    speedmenu = uimenu(navigationmenu, 'Label', '&Speed');
    uimenu(speedmenu, 'Label', 'Very S&low', 'UserData', 'veryslow', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, f.canvas, 'NavSpeed'});
    uimenu(speedmenu, 'Label', '&Slow' , 'UserData', 'slow', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, f.canvas, 'NavSpeed'});
    uimenu(speedmenu, 'Label', '&Normal' , 'UserData', 'normal', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, f.canvas, 'NavSpeed'});
    uimenu(speedmenu, 'Label', '&Fast' , 'UserData', 'fast', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, f.canvas, 'NavSpeed'});
    uimenu(speedmenu, 'Label', 'Very F&ast' , 'UserData', 'veryfast', 'Tag', 'VR_navspeedmenu', 'Callback', {@vr.callbacks, f.canvas, 'NavSpeed'});

    uimenu(navigationmenu, 'Label', 'Straighten &Up', 'Separator', 'on', 'Callback', {@vr.callbacks, f.canvas, 'navStraighten'});
    uimenu(navigationmenu, 'Label', 'Un&do Move', 'Callback', {@vr.callbacks, f.canvas, 'navUndoMove'});
    uimenu(navigationmenu, 'Label', 'Camera &Bound to Viewpoint', 'Tag', 'VR_cameraboundmenu', 'Separator', 'on', 'Callback', {@vr.callbacks, f.canvas, 'CameraBound'});

    % rendering menu
    renderingmenu = uimenu(f.mfigure, 'Label', '&Rendering', 'Tag', 'VR_RenderingMenu', 'Callback', {@vr.callbacks, f.canvas, 'updateUIRenderingMenu'});
    uimenu(renderingmenu, 'Label', '&Antialiasing', 'Tag', 'VR_antialiasingmenu', 'Callback', {@vr.callbacks, f.canvas, 'Antialiasing'});
    uimenu(renderingmenu, 'Label', '&Headlight', 'Tag', 'VR_headlightmenu', 'Callback', {@vr.callbacks, f.canvas, 'Headlight'});
    uimenu(renderingmenu, 'Label', '&Lighting', 'Tag', 'VR_lightingmenu', 'Callback', {@vr.callbacks, f.canvas, 'Lighting'});
    uimenu(renderingmenu, 'Label', '&Textures', 'Tag', 'VR_texturesmenu', 'Callback', {@vr.callbacks, f.canvas, 'Textures'});
    
    % texture size menu
    maxtextmenu = uimenu(renderingmenu, 'Label', '&Maximum Texture Size', 'Tag', 'VRMaxTextureSize');
    uimenu(maxtextmenu, 'Label', '&Auto', 'UserData', 'auto', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '&32', 'UserData', '32', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '&64', 'UserData', '64', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '12&8', 'UserData', '128', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '&256', 'UserData', '256', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '&512', 'UserData', '512', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '&1024', 'UserData', '1024', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    uimenu(maxtextmenu, 'Label', '2&048', 'UserData', '2048', 'Tag', 'VR_textsizemenu', 'Callback', {@vr.callbacks, f.canvas, 'MaxTextureSize'});
    
    % transparency
    uimenu(renderingmenu, 'Label', 'T&ransparency', 'Tag', 'VR_transparencymenu', 'Callback', {@vr.callbacks, f.canvas, 'Transparency'});
    
    % wireframe
    uimenu(renderingmenu, 'Label', '&Wireframe', 'Tag', 'VR_wireframemenu', 'Callback', {@vr.callbacks, f.canvas, 'Wireframe'});

    % simulation menu
    if appset.simulation
      simulationmenu = uimenu(f.mfigure, 'Label', '&Simulation', 'Tag', 'VRSimMenu', 'Enable', 'off'); 
      uimenu(simulationmenu, 'Label', '&Start', 'Tag', 'VRSimPlayPauseMenu', 'Enable', 'off', 'Callback', {@vr.callbacks, f.canvas, 'playpauseSim'});
      uimenu(simulationmenu, 'Label', 'Sto&p', 'Tag', 'VRSimStopMenu', 'Enable', 'off', 'Callback', {@vr.callbacks, f.canvas, 'stopSim'});
      uimenu(simulationmenu,... 
                               'Label', '&Block parameters...',...
                               'Separator', 'on',...
                               'Enable', 'off',...
                               'Tag', 'VRBlockParamsMenu',...
                               'Callback', @blockParamsCallback);
    end
    if ~videopreview
      % recording menu
      rec2denabled = get(f, 'Record2D');
      rec3denabled = get(get(f.canvas, 'World'), 'Record3D');
      recenabled = 'off';
      if strcmpi(rec2denabled, 'on') || strcmpi(rec3denabled, 'on')
        recenabled = appset.recording;
      end
      recordingmenu = uimenu(f.mfigure, 'Label', 'R&ecording', 'Tag', 'VRRecMenu'); 
      if appset.showrecording
        uimenu(recordingmenu, 'Label', '&Start Recording',...
                              'Enable', recenabled,...
                              'Tag', 'VRRecStart',...
                              'Callback', {@vr.callbacks, f.canvas, 'startstopRecording'});
        uimenu(recordingmenu, 'Label', 'Sto&p Recording',...
                              'Enable', 'off',...
                              'Tag', 'VRRecStop',...
                              'Callback', {@vr.callbacks, f.canvas, 'startstopRecording'});
      end
      offon = {'off', 'on'};
      uimenu(recordingmenu, 'Label', '&Capture Frame', 'Separator', offon{1+appset.showrecording}, ...
             'Enable', appset.capture, 'Callback', {@vr.callbacks, f.canvas, 'capture'});
      uimenu(recordingmenu, 'Label', 'Capture and Recording P&arameters...',...
                            'Separator', 'on',...
                            'Enable', appset.capture, ...
                            'Tag', 'VRRecParams',...
                            'Callback', {@recParamsCallback, f});

      % help menu
      if appset.helpmenu
        helpmenu = uimenu(f.mfigure, 'Label', '&Help');
        uimenu(helpmenu, 'Label', '&Browse Help', 'Callback', 'vrmfunc(''FnHelpTopic'', ''vr_viewer'')');
      end
    end
  end

  function createuitoolbar(f)
    appset = vr.appdependent;
    toolbar = uitoolbar(f.mfigure, 'Tag', 'VRToolbar');
    % drawing commits the component, allowing to get its java container
    drawnow;
    jcont = get(toolbar, 'JavaContainer');
    [position,viewpoints] = getViewpointList(f.canvas);
    if ~isempty(viewpoints)
      jc = javaObjectEDT('com.mathworks.mwswing.MJComboBox', viewpoints);
    else
      jc = javaObjectEDT('com.mathworks.mwswing.MJComboBox');    
    end
    jc.setName('vr.figure_Viewpoints_ComboBox');
    jc.setMaximumSize(java.awt.Dimension(jc.getPreferredSize().getWidth()+100, jc.getPreferredSize().getHeight()));
    jcont.add(jc);
    jc.setSelectedItem(position-1);
    jc.addActionListener(com.mathworks.toolbox.sl3d.vrcanvas.UIToolBarComboBoxListener(f.canvas.JCanvas, 0));
    setappdata(f.mfigure, 'VRViewpointsComboBox', jc);

    pathToIcons = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'icons');
    uipushtool(toolbar, 'TooltipString', 'Return to Viewpoint', ...
                                   'ClickedCallback', {@vr.callbacks, f.canvas, 'navGoHome'}, ...
                                   'CData', imread(fullfile(pathToIcons, 'BackToViewpointIcon.png')));
    uipushtool(toolbar, 'TooltipString', ...
                                 'Create Viewpoint', 'ClickedCallback', {@vr.callbacks, f.canvas, 'createViewpoint'}, ...
                                 'CData', imread(fullfile(pathToIcons, 'CreateViewpointIcon.png'))); 
    uipushtool(toolbar, 'TooltipString', 'Straighten Up', ...
                              'Separator', 'on', ...
                              'ClickedCallback', {@vr.callbacks, f.canvas, 'navStraighten'} , ...
                              'CData', imread(fullfile(pathToIcons, 'StraightenUpIcon.png')));
    navmodes = {'Walk', 'Examine', 'Fly', 'None'};
    jc = javaObjectEDT('com.mathworks.mwswing.MJComboBox', navmodes);
    jc.setName('vr.figure_NavModes_ComboBox');
    jc.setMaximumSize(jc.getPreferredSize());
    jcont.add(jc);
    jc.setSelectedIndex(find(strcmpi(get(f.canvas,'NavMode'), navmodes))-1);
    jc.addActionListener(com.mathworks.toolbox.sl3d.vrcanvas.UIToolBarComboBoxListener(f.canvas.JCanvas, 1));
    setappdata(f.mfigure, 'VRNavMethodComboBox', jc);

    uipushtool(toolbar, 'TooltipString', 'Undo Move', ...
                        'ClickedCallback', {@vr.callbacks, f.canvas, 'navUndoMove'}, ...
                        'CData', imread(fullfile(pathToIcons, 'UndoMoveIcon.png'))); 
    uipushtool(toolbar, 'TooltipString', 'Zoom In', ...
                        'Separator', 'on', ...
                        'ClickedCallback', {@vr.callbacks f.canvas, 'zoomIn'}, ...
                        'CData', imread(fullfile(pathToIcons, 'ZoomInIcon.png')));
    uipushtool(toolbar, 'TooltipString', 'Zoom Out', ...
                        'ClickedCallback', {@vr.callbacks, f.canvas, 'zoomOut'}, ...
                        'CData', imread(fullfile(pathToIcons, 'ZoomOutIcon.png')));
    
    if appset.showrecording
      rec2denabled = get(f, 'Record2D');
      rec3denabled = get(get(f.canvas, 'World'), 'Record3D');
      recbenabled = 'off';
      if strcmpi(rec2denabled, 'on') || strcmpi(rec3denabled, 'on')
        recbenabled = appset.recording;
      end
      uitoggletool(toolbar, 'TooltipString', 'Start/stop recording', ...
                            'Separator', 'on', ...
                            'Enable', recbenabled, ...
                            'CData', imread(fullfile(pathToIcons, 'RecordingIcon.png')),...
                            'Tag', 'VRREC_toggleb',...
                            'ClickedCallback', {@vr.callbacks, f.canvas, 'startstopRecording'});
    end
    if appset.simulation
      uipushtool(toolbar, 'TooltipString', 'Block Parameters', ...
                                 'Separator', 'on', ...
                                 'Tag', 'VRBlockParams',...
                                 'CData', imread(fullfile(pathToIcons, 'BlockParametersIcon.png')),...
                                 'Enable', 'off',...
                                 'ClickedCallback', @blockParamsCallback);
    end
    uipushtool(toolbar, 'TooltipString', 'Capture a frame screenshot', ...
                         'Enable', appset.capture, ...
                         'Separator', 'on', ...
                         'CData', imread(fullfile(pathToIcons, 'CameraIcon.png')),...
                         'ClickedCallback', {@vr.callbacks, f.canvas, 'capture'});

    if appset.simulation
      playpause = uipushtool(toolbar, 'TooltipString', 'Start Simulation', ...
                             'Tag', 'VRSimPlayPause', ...
                             'Enable', 'off', ...
                             'Separator', 'on', ...
                             'ClickedCallback', {@vr.callbacks, f.canvas, 'playpauseSim'});
      setappdata(playpause, 'StartIcon', imread(fullfile(pathToIcons, 'StartIcon.png')));
      setappdata(playpause, 'PauseIcon', imread(fullfile(pathToIcons, 'PauseIcon.png')));
      set(playpause, 'CData', getappdata(playpause, 'StartIcon'));

      uipushtool(toolbar, 'TooltipString', 'Stop Simulation', ...
                          'Tag', 'VRSimStop',...
                          'Enable', 'off', ...
                          'CData', imread(fullfile(pathToIcons, 'StopIcon.png')),...
                          'ClickedCallback', {@vr.callbacks, f.canvas, 'stopSim'});
    end
  end 

  function createuistatusbar(f) 
    figpos = get(f.mfigure, 'Position');
    bordertype = 'beveledin';
    borderwidth = 2;
    horizontalalign = 'left';
    fulfillpos = [0 0 1 1];
    statusbar = uipanel(f.mfigure,...
              'Tag', 'VRStatusBarPanel',...
              'BorderType', bordertype,...
              'Units', 'pixels',...
              'FontSize', 12,...
              'Visible', 'off',...
              'Position', [0, 0, figpos(3), f.StatusBarGap-1]);
    viewpointpan = uipanel(statusbar, 'BorderWidth', borderwidth, 'BorderType', bordertype, 'Visible', 'off', 'Position', [0 0 0.28 1]);
    bckgcolor = get(statusbar, 'BackgroundColor');
    H.viewpoint = uicontrol(viewpointpan,... 
              'Tag', 'VRStatusBarViewpoint',...
              'Style', 'text',...
              'BackgroundColor', bckgcolor,...
              'HorizontalAlignment', horizontalalign,...
              'Units', 'normalized',...
              'String', 'No viewpoint',...
              'Visible', 'off',...
              'Position', fulfillpos);
    timepan = uipanel(statusbar, 'BorderWidth', borderwidth, 'BorderType', bordertype, 'Visible', 'off', 'Position', [0.28 0 0.14 1]);
    H.time = uicontrol(timepan,...
              'Tag', 'VRStatusBarTime',...
              'Style', 'text',...
              'BackgroundColor', bckgcolor,...
              'HorizontalAlignment', horizontalalign,...
              'Units', 'normalized',...
              'Visible', 'off',...
              'Position', fulfillpos);
    navmodepan = uipanel(statusbar, 'BorderWidth', borderwidth, 'BorderType', bordertype, 'Visible', 'off', 'Position', [0.42 0 0.14 1]);
    H.navmode = uicontrol(navmodepan,...
              'Tag', 'VRStatusBarNavMode',...
              'Style', 'text',...
              'BackgroundColor', bckgcolor,...
              'HorizontalAlignment', horizontalalign,...
              'Units', 'normalized',...
              'Visible', 'off',...
              'Position', fulfillpos);
    posanddirpan = uipanel(statusbar, 'BorderWidth', borderwidth, 'BorderType', bordertype, 'Visible', 'off', 'Position', [0.56 0 0.44 1]);
    H.posanddir = uicontrol(posanddirpan,...
              'Tag', 'VRStatusBarPosAndDir',...
              'Style', 'text',...
              'BackgroundColor', bckgcolor,...
              'HorizontalAlignment', horizontalalign,...
              'Units', 'normalized',...
              'Visible', 'off',...
              'Position', fulfillpos);
    setappdata(f.mfigure, 'VRFigureStatusBarHGComponents', [statusbar, viewpointpan, H.viewpoint, timepan, H.time, navmodepan, H.navmode, posanddirpan, H.posanddir]);
    setappdata(f.mfigure, 'VRFigureStatusBarHandles', H);
    updateStatusBar(f);
  end
end
  
end % end classdef

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF CLASS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% MATLAB CALLBACKS %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function createCopyOfThisFigureCallback(~, ~, vrfig)
  try  
    evalin('base', get(vrfig, 'CreateFigureFcn'));
  catch ME  
    warning('VR:callbackerror', 'Error evaluating vr.figure ''CreateFigureFcn'' callback: "%s"', ME.message); 
  end
end

function blockParamsCallback(~, ~)
  try
    if vr.appdependent('blockParamsCallback')
      evalin('base', get(getappdata(gcbf, 'vrfigure'), 'BlockParametersFcn'));
    end
  catch ME  
    warning('VR:callbackerror', 'Error evaluating vr.figure ''BlockParametersFcn'' callback: "%s"', ME.message); 
  end
end

function  recParamsCallback(~, ~, f)

  % open existing dialog if any
  parentfig = gcbf;
  recdlg = getappdata(parentfig, 'RecordingDialog');
  if ishandle(recdlg)
    figure(recdlg);
    return;
  end

  % create new dialog and associate it with parent vr.figure
  scrSize = get(0, 'ScreenSize');
  recdlg = dialog('Name', 'Capture and Recording Parameters', ...
                  'WindowStyle', 'normal');
  set(recdlg, 'Position', [(scrSize(3)-620)/2 (scrSize(4)-330)/2 620 330]);
  setappdata(parentfig, 'RecordingDialog', recdlg);
  setappdata(recdlg, 'ParentFigure', parentfig);

  world = get(f.canvas, 'World');
  rec3d = get(world, 'Record3D');
  rec2d = get(f,'Record2D');

  capturepan = uipanel(recdlg, 'Title', 'Frame Capture', 'Units', 'pixels', 'Position', [10 260 600 60]);
  uicontrol('Parent', capturepan, ...
           'Style', 'text', 'HorizontalAlignment', 'right', ...
           'String', 'File: ', 'Position', [10 14 30 15] );
  capturefilename = uicontrol('Parent', capturepan,...
                          'Style', 'edit',...
                          'Position', [42 12 290 20],...
                          'HorizontalAlignment', 'left',... 
                          'BackgroundColor', 'white',...
                          'String', get(f, 'CaptureFileName'),...
                          'Tag', 'VRREC_capturefilename');

  uicontrol('Parent', capturepan, 'Style', 'text', 'HorizontalAlignment', 'right', ...
            'String', 'File Format: ', 'Position', [360 14 80 15]);
  uicontrol('Parent', capturepan,...
                      'Style', 'popupmenu',...
                      'String', {'tif', 'png'},...
                      'Position', [442 12 60 20],...
                      'Enable', 'on',... 
                      'BackgroundColor', 'white',...
                      'Value', strcmpi(get(f, 'CaptureFileFormat'),'png')+1,...
                      'Min', 1,...
                      'Max', 1,...
                      'Callback', {@selectCaptureFileFormatCallback,capturefilename},...
                      'Tag', 'VRREC_capturepicformat');

  uicontrol('Parent', capturepan,...
                    'Style', 'pushbutton',...
                    'String', 'Browse...',...
                    'Position', [520 12 70 20],...
                    'Callback', {@selectFileNameCallback, capturepan, 'tif'});
  
  recpan = uipanel(recdlg, 'Title', 'Recording', 'Units', 'pixels', 'Position', [10 40 600 200]);
  appset = vr.appdependent;
  uicontrol('Parent', recpan,...
                     'Style', 'checkbox',...
                     'String', 'Record to VRML',...
                     'Enable', appset.recording,... 
                     'Value', strcmpi(rec3d,'on'),...
                     'Position', [10 150 150 20],...
                     'Callback', {@toVrmlCallback,recpan},...
                     'Tag', 'VRREC_tovrml');

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'File: ',...
                   'Position', [150 150 30 16],...
                   'Enable', rec3d,...
                   'Tag', 'VRREC_rec3dlab');

  uicontrol('Parent', recpan,...
                    'Style', 'edit',...
                    'Position', [182 150 310 20],...
                    'BackgroundColor', 'white',...
                    'HorizontalAlignment', 'left',...
                    'Enable', rec3d,...
                    'String', get(world, 'Record3DFileName'),...
                    'Tag', 'VRREC_rec3dfilename');

  uicontrol('Parent', recpan,...
                    'Style', 'pushbutton',...
                    'String', 'Browse...',...
                    'Position', [520 150 70 20],...
                    'Enable', rec3d,...
                    'Tag', 'VRREC_rec3dbrws',...
                    'Callback', {@selectFileNameCallback, recpan, 'wrl'});

  uicontrol('Parent', recpan,...
                    'Style', 'checkbox',...
                    'String', 'Record to AVI',...
                    'Enable', appset.recording,...
                    'Value', strcmpi(rec2d,'on'),...
                    'Position', [10 120 150 20],...
                    'Callback', {@toAviCallback, recpan},...
                    'Tag', 'VRREC_toavi');

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'File: ',...
                   'Enable', rec2d,...
                   'Position', [150 120 30 16],...
                   'Tag', 'VRREC_rec2dlab');

  uicontrol('Parent', recpan,...
                    'Style', 'edit',...
                    'Position', [182 120 310 20],...
                    'BackgroundColor', 'white',...
                    'HorizontalAlignment', 'left',...
                    'Enable', rec2d,...
                    'String', get(f, 'Record2DFileName'),...
                    'Tag', 'VRREC_rec2dfilename');

  uicontrol('Parent', recpan,...
                    'Style', 'pushbutton',...
                    'String', 'Browse...',...
                    'Position', [520 120 70 20],...
                    'Enable', rec2d,...
                    'Tag', 'VRREC_rec2dbrws',...
                    'Callback', {@selectFileNameCallback, recpan, 'avi'});

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'FPS: ',...
                   'Position', [10 70 40 16],...
                   'Enable', rec2d,...
                   'Tag', 'VRREC_rec2dfpslab');

  uicontrol('Parent', recpan,...
                    'Style', 'edit',...
                    'Position', [52 70 50 20],...
                    'BackgroundColor', 'white',...
                    'Enable', rec2d,...
                    'String', get(f, 'Record2DFPS'),...
                    'Tag', 'VRREC_rec2dfps');

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'Compression:',...
                   'Position', [115 70 88 16],...
                   'Enable', rec2d,...
                   'Tag', 'VRREC_rec2dcompresslab');

  cmprsmeth = get(f, 'Record2DCompressMethod');
  cmprsmethindex = 1;
  cmprscodec = '';
  qualityvisible = 'off';
  codecvisible = 'off';
  switch cmprsmeth
    case 'none'
      % do nothing
    case 'auto'
      qualityvisible = 'on';
      cmprsmethindex = 2;
    case 'lossless'
      cmprsmethindex = 3;  
    otherwise
      qualityvisible = 'on';
      codecvisible = 'on';
      cmprsmethindex = 4;
      cmprscodec = cmprsmeth;
  end

  uicontrol('Parent', recpan,...
                      'Style', 'popupmenu',...
                      'String', {'None', 'Autoselect', 'Lossless', 'User Defined'},...
                      'Position', [207 70 130 20],...
                      'Value', cmprsmethindex,...
                      'Enable', rec2d,...
                      'BackgroundColor', 'white',...
                      'Min', 1,...
                      'Max', 1,...
                      'Tag', 'VRREC_rec2dcompress',...
                      'Callback', {@setAviParamsVisibility, recpan});

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'Quality: ',...
                   'Position', [355 70 55 16],...
                   'Enable', rec2d,...
                   'Visible', qualityvisible,...
                   'Tag', 'VRREC_rec2dqualitylab');

  uicontrol('Parent', recpan,...
                      'Style', 'popupmenu',...
                      'String', 0:1:100,...
                      'Value', get(f, 'Record2DCompressQuality')+1,...
                      'Position', [407 70 70 20],...
                      'Enable', rec2d,...
                      'Visible', qualityvisible,...
                      'BackgroundColor', 'white',...
                      'Min', 1,...
                      'Max', 1,...
                      'Tag', 'VRREC_rec2dquality');

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'Codec: ',...
                   'Position', [487 70 50 16],...
                   'Enable', rec2d,...
                   'Visible', codecvisible,...
                   'Tag', 'VRREC_rec2dcodeclab');

  uicontrol('Parent', recpan,...
                    'Style', 'edit',...
                    'Position', [539 70 50 20],...
                    'BackgroundColor', 'white',...
                    'String', cmprscodec,...
                    'Enable', rec2d,...
                    'Visible', codecvisible,...
                    'Tag', 'VRREC_rec2dcodec');

  uicontrol('Parent', recpan,...
                   'Style', 'text',...
                   'HorizontalAlignment', 'right', ...
                   'String', 'Record mode: ',...
                   'Position', [10 20 90 16],...
                   'Tag', 'VRREC_recmodelab');

  recmodenable = 'off';
  if strcmpi(rec2d,'on') || strcmpi(rec3d,'on')
    recmodenable = 'on'; 
  end
  recmodval = 1;
  if strcmpi(get(world, 'RecordMode'), 'scheduled')
    recmodval = 2;
  end

  uicontrol('Parent', recpan,...
                      'Style', 'popupmenu',...
                      'String', {'Manual', 'Scheduled'},...
                      'Value', recmodval,...
                      'Position', [102 20 110 20],...
                      'Enable', recmodenable,... 
                      'BackgroundColor', 'white',...
                      'Min', 1,...
                      'Max', 1,...
                      'Tag', 'VRREC_recmode',...
                      'Callback', {@recModeCallback, recpan});
  rectimeenable = 'off';
  if strcmpi(recmodenable,'on') && strcmpi(get(world, 'RecordMode'), 'scheduled')
    rectimeenable = 'on';
  end
  recint = get(world, 'RecordInterval');

  uicontrol('Parent', recpan,...
                    'Style', 'text',...
                    'HorizontalAlignment', 'right', ...
                    'String', 'Start time: ',...
                    'Position', [240 20 70 16],...
                    'Tag', 'VRREC_recstarttimelab',...
                    'Enable', rectimeenable);

  uicontrol('Parent', recpan,...
                    'Style', 'edit',...
                    'Position', [312 20 70 20],...
                    'BackgroundColor', 'white',...
                    'String', num2str(recint(1)),...
                    'Tag', 'VRREC_recstarttime',...
                    'Enable', rectimeenable);

  uicontrol('Parent', recpan,...
                    'Style', 'text',...
                    'HorizontalAlignment', 'right', ...
                    'String', 'Stop time: ',...
                    'Position', [390 20 70 16],...
                    'Tag', 'VRREC_recstoptimelab',...
                    'Enable', rectimeenable);

  uicontrol('Parent', recpan,...
                    'Style', 'edit',...
                    'Position', [462 20 70 20],...
                    'BackgroundColor', 'white',...
                    'String', num2str(recint(2)),...
                    'Tag', 'VRREC_recstoptime',...
                    'Enable', rectimeenable);

  uicontrol('Parent', recdlg,...
                 'Style', 'pushbutton',...
                 'String', 'OK',...
                 'Position', [340 10 60 20],...
                 'Callback', {@onRecDlgOK, f, capturepan, recpan});

  uicontrol('Parent', recdlg,...
                     'Style', 'pushbutton',...
                     'String', 'Cancel',...
                     'Position', [410 10 60 20],...
                     'Callback', @onRecDlgCancel);

  uicontrol('Parent', recdlg,...
                   'Style', 'pushbutton',...
                   'String', 'Help',...
                   'Position', [480 10 60 20],...
                   'Callback', @onRecDlgHelp);

  uicontrol('Parent', recdlg,...
                 'Style', 'pushbutton',...
                 'String', 'Apply',...
                 'Position', [550 10 60 20],...
                 'Callback', {@onRecDlgApply, f, capturepan, recpan});
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Callbacks for Recording Dialog %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectCaptureFileFormatCallback(this, ~, capturefilename)
  % replace filename extension with selected one
  [p, n] = fileparts(get(capturefilename, 'String'));
  ftype = get(this, 'String');
  set(capturefilename, 'String', fullfile(p, [n '.' ftype{get(this, 'Value')}]));
end

function selectFileNameCallback(~, ~, recpan, frmt)
  % select file name control
  switch frmt
    case 'wrl'
      recfilename = findobj(recpan, 'Tag', 'VRREC_rec3dfilename');
      rectype = 'VRML';
      caption = [rectype ' Recording'];
    case 'avi'
      recfilename = findobj(recpan, 'Tag', 'VRREC_rec2dfilename');
      rectype = 'AVI';
      caption = [rectype ' Recording'];
    case 'tif'
      recfilename = findobj(recpan, 'Tag', 'VRREC_capturefilename');
      rectype = {'TIFF', 'PNG'};
      caption = 'Frame Capture';
      rectype = rectype{get(findobj(recpan, 'Tag', 'VRREC_capturepicformat'), 'Value')};
      frmt = lower(rectype(1:3)); 
    otherwise
      return;
  end

  % display path selection dialog
  [p, n] = fileparts(get(recfilename, 'String'));
  [fname, fpath] = uiputfile({['*.', frmt], sprintf('%s files (*.%s)', rectype, frmt)}, ...
                             sprintf('Set %s to File:', caption), ...
                             fullfile(p, n));
 
  % set the filename relative to working directory if possible
  if fname 
    wd = [pwd filesep];
    if strfind(fpath, wd)==1
      fpath = fpath(length(wd)+1:end);
    end
    set(recfilename, 'String', fullfile(fpath, fname));
  end
end

function toVrmlCallback(this, ~, recpan)
  if get(this,'Value')
    enable = 'on';
  else
    enable = 'off';
  end
  set(findobj(recpan, 'Tag', 'VRREC_rec3dlab'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec3dfilename'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec3dbrws'), 'Enable', enable);

  recmodenable = 'off';
  if get(findobj(recpan, 'Tag', 'VRREC_toavi'), 'Value') || get(this,'Value')
  recmodenable = 'on';
  end
  set(findobj(recpan, 'Tag', 'VRREC_recmodelab'), 'Enable', recmodenable);
  set(findobj(recpan, 'Tag', 'VRREC_recmode'), 'Enable', recmodenable);
  
  rectimeenable = 'off';
  recmode = findobj(recpan, 'Tag', 'VRREC_recmode');
  str = get(recmode, 'String');
  if strcmpi(recmodenable, 'on') && strcmpi(str{get(recmode, 'Value')}, 'scheduled')
    rectimeenable = 'on';   
  end
  set(findobj(recpan, 'Tag', 'VRREC_recstarttimelab'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstarttime'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstoptimelab'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstoptime'), 'Enable', rectimeenable);
end

function toAviCallback(this, ~, recpan)
  if get(this,'Value')
    enable = 'on';
  else
    enable = 'off';
  end
  set(findobj(recpan, 'Tag', 'VRREC_rec2dlab'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dfilename'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dbrws'), 'Enable', enable);

  set(findobj(recpan, 'Tag', 'VRREC_rec2dfpslab'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dfps'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dcompresslab'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dcompress'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dqualitylab'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dquality'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dcodeclab'), 'Enable', enable);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dcodec'), 'Enable', enable);

  recmodenable = 'off';
  if get(findobj(recpan, 'Tag', 'VRREC_tovrml'), 'Value') || get(this,'Value')
    recmodenable = 'on';
  end
  set(findobj(recpan, 'Tag', 'VRREC_recmodelab'), 'Enable', recmodenable);
  set(findobj(recpan, 'Tag', 'VRREC_recmode'), 'Enable', recmodenable);
  
  rectimeenable = 'off';
  recmode = findobj(recpan, 'Tag', 'VRREC_recmode');
  str = get(recmode, 'String');
  if strcmpi(recmodenable, 'on') && strcmpi(str{get(recmode, 'Value')}, 'scheduled')
    rectimeenable = 'on';   
  end
  set(findobj(recpan, 'Tag', 'VRREC_recstarttimelab'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstarttime'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstoptimelab'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstoptime'), 'Enable', rectimeenable);
end

function recModeCallback(this, ~, recpan)
  str = get(this,'String');
  val = get(this,'Value');
  rectimeenable = 'off';
  if strcmpi(str{val}, 'scheduled')        
    rectimeenable = 'on';    
  end
  set(findobj(recpan, 'Tag', 'VRREC_recstarttimelab'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstarttime'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstoptimelab'), 'Enable', rectimeenable);
  set(findobj(recpan, 'Tag', 'VRREC_recstoptime'), 'Enable', rectimeenable);
end

function setAviParamsVisibility(~, ~, recpan)
  rec2dcompressval = get(findobj(recpan, 'Tag', 'VRREC_rec2dcompress'), 'Value');  
  qualityvisible = 'off';
  codecvisible = 'off';
  switch rec2dcompressval
    case 2
      qualityvisible = 'on';         
    case 4
      qualityvisible = 'on';
      codecvisible = 'on';        
  end
  set(findobj(recpan, 'Tag', 'VRREC_rec2dqualitylab'), 'Visible', qualityvisible);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dquality'), 'Visible', qualityvisible);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dcodeclab'), 'Visible', codecvisible);
  set(findobj(recpan, 'Tag', 'VRREC_rec2dcodec'), 'Visible', codecvisible);  
end

function onRecDlgApply(~, ~, f, capturepan, recpan)
  canvas = f.canvas;
  capturepicformat = findobj(capturepan, 'Tag', 'VRREC_capturepicformat');
  capturepicformatstr = get(capturepicformat, 'String');
  set(f, 'CaptureFileName', get(findobj(capturepan, 'Tag', 'VRREC_capturefilename'), 'String'));
  set(f, 'CaptureFileFormat', capturepicformatstr{get(capturepicformat, 'Value')});

  world = get(canvas, 'World');

  tovrml = findobj(recpan, 'Tag', 'VRREC_tovrml');
  toavi = findobj(recpan, 'Tag', 'VRREC_toavi');
  recb = findobj(findobj(f.mfigure, 'Tag', 'VRToolbar'), 'Tag', 'VRREC_toggleb');
  startrecmenu = findobj(findobj(f.mfigure, 'Tag', 'VRRecMenu'), 'Tag', 'VRRecStart');
  set(recb, 'Enable', 'off');
  set(startrecmenu, 'Enable', 'off');
  if get(tovrml, 'Value')
    set(world, 'Record3D', 'on');
    set(recb, 'Enable', 'on');
    set(startrecmenu, 'Enable', 'on');
  else
    set(world, 'Record3D', 'off');
  end
  if get(toavi, 'Value')
    set(f, 'Record2D', 'on');
    set(recb, 'Enable', 'on');
    set(startrecmenu, 'Enable', 'on');
  else
    set(f, 'Record2D', 'off');
  end
  
  rec3dfilename = findobj(recpan, 'Tag', 'VRREC_rec3dfilename');
  set(world, 'Record3DFileName', get(rec3dfilename, 'String'));  
  
  recmode = findobj(recpan, 'Tag', 'VRREC_recmode');
  if get(recmode, 'Value')==1
    set(world, 'RecordMode', 'manual');
  else
    set(world, 'RecordMode', 'scheduled');
  end  
  
  int1 = get(findobj(recpan, 'Tag', 'VRREC_recstarttime'), 'String');
  int2 = get(findobj(recpan, 'Tag', 'VRREC_recstoptime'), 'String');
  int1d = str2double(int1);
  int2d = str2double(int2);
  if isnan(int1d)
    uiwait(warndlg(sprintf('Start time value "%s" must be a number.', int1), 'Invalid parameter value', 'modal'));
    return;
  elseif isnan(int2d)
    uiwait(warndlg(sprintf('Stop time value "%s" must be a number.', int2), 'Invalid parameter value', 'modal')); 
    return;
  else
    set(world, 'RecordInterval', [int1d int2d]);    
  end
  
  rec3dfilename = findobj(recpan, 'Tag', 'VRREC_rec3dfilename');
  set(world, 'Record3DFileName', get(rec3dfilename, 'String'));  

  rec2dfilename = findobj(recpan, 'Tag', 'VRREC_rec2dfilename');
  set(f, 'Record2DFileName', get(rec2dfilename, 'String'));  

  rec2dfps = findobj(recpan, 'Tag', 'VRREC_rec2dfps');
  fpsval = get(rec2dfps, 'String');
  try
    set(f, 'Record2DFPS', str2double(fpsval));
  catch ME  %#ok<NASGU>
    uiwait(warndlg(sprintf('FPS value "%s" must be a positive number.', fpsval), 'Invalid parameter value', 'modal')); 
    return;
  end

  rec2dquality = findobj(recpan, 'Tag', 'VRREC_rec2dquality');
  set(f, 'Record2DCompressQuality', get(rec2dquality, 'Value')-1);
                     
  rec2dcompress = findobj(recpan, 'Tag', 'VRREC_rec2dcompress');
  cmprsmeth = get(rec2dcompress, 'String');
  cmprsmethval = get(rec2dcompress, 'Value');
  cmprsmeth = cmprsmeth(cmprsmethval);
  if strcmpi(cmprsmeth, 'none')
    set(f, 'Record2DCompressMethod', 'none');
  elseif strcmpi(cmprsmeth, 'autoselect')
    set(f, 'Record2DCompressMethod', 'auto');  
  elseif strcmpi(cmprsmeth, 'lossless')    
    set(f, 'Record2DCompressMethod', 'lossless');  
  else
    rec2dcodec = findobj(recpan, 'Tag', 'VRREC_rec2dcodec');
    set(f, 'Record2DCompressMethod', get(rec2dcodec, 'String'));
  end
end

function onRecDlgCancel(~, ~)
  parentfig = getappdata(gcbf, 'ParentFigure');
  if ishandle(parentfig)
    setappdata(parentfig, 'RecordingDialog', []); 
  end
  delete(gcbf);
end

function onRecDlgOK(this, evt, f, capturepan, recpan)
  % apply the changes
  onRecDlgApply(this, evt, f, capturepan, recpan);
  % close the dialog the same way as if Cancel was pressed
  onRecDlgCancel(this, evt);
end

function onRecDlgHelp(~, ~)
  vrmfunc('FnHelpTopic', 'vr_recordprm');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Callbacks for Recording Dialog %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vrfigcallbacks(~, ~, arg)
  vrfig = getappdata(gcbf, 'vrfigure');
  switch arg
    case {'ToolBar', 'StatusBar', 'Fullscreen'}
      setOnOffProperty(vrfig,arg);
  end
end

% Resize callback for container MATLAB figure
function resizeFigureFcn(this, ~)
  pos = get(this, 'Position');  % we are in vrfigure mode, position is always in pixels
  canvas = getappdata(this, 'canvas');
  vrfigure = getappdata(this, 'vrfigure');
  statusbargap = zeros(1,4);
  if strcmpi(vrfigure.StatusBar, 'on')
    statusbargap =  [0 vrfigure.StatusBarGap 0 -vrfigure.StatusBarGap];
  end
  canvaspos = [0 0 pos(3:4)] + statusbargap;
  if ~any(canvaspos(1:2) < 0) && ~any(canvaspos(3:4) <= 0)
    setPositionCallback(canvas, canvaspos);
    statusbar = findobj(this, 'Tag', 'VRStatusBarPanel');
    if ~isempty(statusbar)
      statbarpos = get(statusbar, 'Position');
      set(statusbar, 'Position', [statbarpos(1:2) pos(3) statbarpos(4)]);
    end
  end
end
