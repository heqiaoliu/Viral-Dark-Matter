function callbacks(this, evt, obj, strarg1)
%VR.CALLBACKS VR callbacks function.
%   Called from Java and MATLAB to handle vr.figure and vr.canvas callbacks.
%
%   Not to be used directly.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/03/22 04:24:56 $  $Author: batserve $


% callbacks can be called from MATLAB or Java or native code
matlabcallback = ~(ischar(this) && (strcmpi(this, 'JavaCallback') || strcmpi(this, 'NativeCallback')));

% called from Java or native code - convert native canvas pointer to vr.canvas
% also reshuffle arguments to match MATLAB calling convention
if ~matlabcallback
  if nargin>2
    if strcmpi(this, 'JavaCallback')
      obj = typecast(obj, 'uint64');
    end

    list = getappdata(0, 'SL3D_vrcanvas_List');
    if isempty(list) || ~list.isKey(obj)   % vr.canvas object not found - exit immediately
      return;
    end
    obj = list(obj);
  end
  if nargin>3
    arg = strarg1;
  end
  strarg1 = evt;
end

% execute callback based on its name
switch strarg1

  case 'updateUIContextMenu'
    hghandle=get(obj.MCanvasContainer, 'UIContextMenu');
    updateUIViewMenu(findobj(hghandle, 'Tag', 'VR_ViewMenu'),obj);
    updateUIViewpointsMenu(findobj(hghandle, 'Tag', 'VR_ViewpointsMenu'),obj);
    updateUINavigationMenu(findobj(hghandle, 'Tag', 'VR_NavigationMenu'),obj);
    updateUIRenderingMenu(findobj(hghandle, 'Tag', 'VR_RenderingMenu'),obj);

  case 'updateUIViewMenu'
    updateUIViewMenu(this,obj);

  case 'updateUIViewpointsMenu'
    updateUIViewpointsMenu(this,obj);

  case 'updateUINavigationMenu'
    updateUINavigationMenu(this,obj);

  case 'updateUIRenderingMenu'
    updateUIRenderingMenu(this,obj);

  case 'startEditor'
    edit(obj.World);

  case 'onFileReload'
    reload(obj.World);

  case 'onFileSave'
    [filename, pathname] = uiputfile({'*.wrl', 'VRML Files (*.wrl)'},'Save VRML World As...');
    if ~isequal(filename,0) && ~isequal(pathname,0)
      save(obj.World,  fullfile(pathname,filename));
    end

  case 'NavMode'
    if matlabcallback
      arg = lower(get(this, 'UserData'));
    end
    set(obj, strarg1, arg);

  case {'NavPanel', 'NavSpeed', 'MaxTextureSize'}
    if matlabcallback
      arg = get(this, 'UserData');
    end
    set(obj, strarg1, arg);

  case {'NavZones', 'CameraBound', 'Antialiasing', 'Headlight', 'Lighting', 'Textures', 'Transparency', 'Wireframe'}
    setOnOffProperty(obj, strarg1);

  case 'createViewpoint'

    % open existing dialog if any
    parentc = obj.MCanvasContainer;
    dlg = getappdata(parentc, 'CreateViewpointDialog');
    if ishandle(dlg)
      figure(dlg);
      return;
    end
          
    % create new dialog and associate it with parent vr.canvas
    scrSize = get(0, 'ScreenSize');
    placementOnOff = getCreateViewpointPlacementOnOff(obj);
    dlg = dialog('Name', 'Create new viewpoint', ...
                 'WindowStyle', 'normal', ...
                 'Position', [(scrSize(3)-270)/2 (scrSize(4)-140)/2 270 140]);
    setappdata(obj.MCanvasContainer, 'CreateViewpointDialog', dlg);
    setappdata(dlg, 'ParentContainer', obj.MCanvasContainer);

    namelabel = uicontrol('Parent', dlg, 'Style', 'text', 'String', 'Name:', 'Position', [10 110 75 15]);
    name = uicontrol('Parent', dlg, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Position', [90 110 175 20]);
    set(name, 'BackgroundColor', 'white');
    set(namelabel, 'HorizontalAlignment', 'left');
    placementlabel = uicontrol('Parent', dlg, 'Style', 'text', 'String', 'Placement:', 'Position', [10 80 75 20]);
    placement = uicontrol('Parent', dlg,...
                        'Style', 'popup',...
                        'String', {'Child of the root', 'Sibling of the current viewpoint'},...
                        'Position', [90 70 175 30],...
                        'Enable', placementOnOff,... 
                        'Min', 1,...
                        'Max', 1);
    set(placement, 'BackgroundColor', 'white');
    set(placementlabel, 'HorizontalAlignment', 'left');
    jump = uicontrol('Parent', dlg, 'Style', 'checkbox', 'String', 'Jump to new viewpoint immediately', 'Value', 1, 'Position', [10 45 250 20]);
    uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', 'OK', 'Position', [15 10 53 20], 'Callback', {@onCreateViewpointOK, dlg, obj, name, placement, jump});
    uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', 'Cancel', 'Position', [78 10 53 20], 'Callback', {@onCreateViewpointCancel, dlg});
    uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', 'Help', 'Position', [144 10 53 20], 'Callback', @onViewpointDialogHelp);
    uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', 'Apply', 'Position', [207 10 53 20], 'Callback', {@onCreateViewpointApply, dlg, obj, name, placement, jump});

  case {'zoomIn', 'zoomOut', 'viewNormal', 'navStraighten', 'navUndoMove',...
        'gotoPrevViewpoint', 'gotoNextViewpoint', 'navGoHome', 'gotoDefaultViewpoint', 'removeViewpoint'}
    if strcmp(strarg1, 'removeViewpoint')
      choice = questdlg('Do you want to remove the current viewpoint?', ...
        'Confirm viewpoint removal', ...
        'Yes', 'No', 'Yes');
      if ~strcmp(choice, 'Yes')
        return;
      end
    end
    feval(strarg1, obj);

  case 'gotoViewpoint'
    if matlabcallback
      arg = get(this, 'Label'); 
    end
    set(obj, 'Viewpoint', arg);

  case 'updateStatusBar'
    if strcmp(obj.mode, 'vrfigure')  
      updateStatusBar(getappdata(obj.mfigure, 'vrfigure'));
    end

  case 'updateViewpointsComboBox'
    updateViewpointsComboBox(obj);

  case 'updateNavModeComboBox'
    updateNavModeComboBox(obj, arg);

  case 'invokeHelpCallback'
    vrmfunc('FnHelpTopic', 'vr_viewer');

  case {'playpauseSim', 'playstopSim', 'stopSim'}
    if ~strcmp(obj.mode, 'vrfigure')
      return;
    end
    vrfigure = getappdata(obj.mfigure, 'vrfigure');
    simstatus = get(vrfigure, 'SimStatus');
    if strcmp(strarg1, 'playpauseSim')
      if strcmpi(simstatus, 'running')
        fcn = get(vrfigure, 'SimPauseFcn');
      elseif strcmpi(simstatus, 'paused')
        fcn = get(vrfigure, 'SimContinueFcn');
      else
        fcn = get(vrfigure, 'SimStartFcn');
      end
    elseif strcmp(strarg1, 'playstopSim')
      if strcmpi(simstatus, 'stopped')
        fcn = get(vrfigure, 'SimStartFcn');
      else
        fcn = get(vrfigure, 'SimStopFcn');
      end
    else
      fcn = get(vrfigure, 'SimStopFcn');
    end
    try
      evalin('base', fcn);
    catch ME  
      warning('VR:callbackerror', 'Error evaluating vr.figure callback for controlling simulation: "%s"', ME.message); 
    end

  case 'startstopRecording'
    world = get(obj, 'World');
    vrfigure = getappdata(obj.mfigure, 'vrfigure');
    if strcmp(get(world, 'Record3D'), 'off') && ( isempty(vrfigure) || strcmp(get(vrfigure, 'Record2D'), 'off'))
      return;
    end
    state = get(world, 'Recording');
    if strcmp(state, 'off')
      set(world, 'Recording', 'on');
    else
      set(world, 'Recording', 'off');
    end

  case 'capture' 
    if strcmp(obj.mode, 'vrfigure')
      vrcapturecallback(getappdata(obj.mfigure, 'vrfigure'));
    end

  case 'updateRecGUI'
    if strcmp(obj.mode, 'vrfigure')
      updateRecGUI(getappdata(obj.mfigure, 'vrfigure'));
    end

end % end of switch

end % end of function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateUIViewMenu(this,obj)
  if strcmp(obj.mode, 'vrfigure')
    vrfigure = getappdata(obj.mfigure, 'vrfigure');
    
    menuitem = findobj(obj.mfigure, 'Tag', 'VR_toolbarmenu');
    set(menuitem, 'Checked', get(vrfigure, 'ToolBar'));
    menuitem = findobj(obj.mfigure, 'Tag', 'VR_statusbarmenu');
    set(menuitem, 'Checked', get(vrfigure, 'StatusBar'));
    menuitem = findobj(obj.mfigure, 'Tag', 'VRFullscreen');
    set(menuitem, 'Checked', get(vrfigure, 'Fullscreen'));
  end

  menuitems = findobj(this, 'Tag', 'VR_navzonesmenu');
  set(menuitems, 'Checked', get(obj, 'NavZones'));

  menuitems = findobj(this, 'Tag', 'VR_navpanelmenu');
  set(menuitems, 'Checked', 'off');
  menuitem = findobj(this, 'Tag', 'VR_navpanelmenu', 'UserData', lower(obj.NavPanel));
  set(menuitem, 'Checked', 'on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateUIViewpointsMenu(this,obj)
  vmenu = findobj(this, '-regexp', 'Tag', 'VRViewpoint_');
  % delete all viewpoints from menu
  delete(vmenu);
  % load current menu items with one item to be selected
  [position,viewpoints] = getViewpointList(obj);

  % disable removing viewpoint if there's no current viewpoint
  onoff = {'on', 'off'};
  set(findobj(this, 'Tag', 'VR_RemoveCurrentViewpoint'), 'Enable', onoff{(position<0)+1});

  % create new menu items
  for i=1:numel(viewpoints)
    separator = 'off';
    if i==1
      separator = 'on';
    end
    checked = 'off';
    if i == position + 1
      checked = 'on';
    end
    uimenu(this, 'Label', char(viewpoints(i)), 'Tag', ['VRViewpoint_', num2str(i)], 'Separator', separator, 'Checked', checked, ...
        'Callback', {@vr.callbacks, obj, 'gotoViewpoint'}); %;!!
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateUINavigationMenu(this,obj)
  menuitems = findobj(this, 'Tag', 'VR_cameraboundmenu');
  set(menuitems, 'Checked', get(obj, 'CameraBound'));

  menuitems = findobj(this, 'Tag', 'VR_navmodemenu');
  set(menuitems, 'Checked', 'off');
  menuitem = findobj(this, 'Tag', 'VR_navmodemenu', 'UserData', obj.NavMode);
  set(menuitem, 'Checked', 'on');

  menuitems = findobj(this, 'Tag', 'VR_navspeedmenu');
  set(menuitems, 'Checked', 'off');        
  menuitem = findobj(this, 'Tag', 'VR_navspeedmenu', 'UserData', obj.NavSpeed);
  set(menuitem, 'Checked', 'on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateUIRenderingMenu(this,obj)
  props = {
         'Antialiasing',...
         'Headlight',...
         'Lighting',...
         'Textures',...
         'Transparency',...
         'Wireframe'};
  for i=1:numel(props)
    prop = props{i};
    menuitems = findobj(this, 'Tag', sprintf('VR_%smenu', lower(prop)));
    set(menuitems, 'Checked', get(obj, props{i}));
  end
  
  automenuitem = findobj(this, 'Tag', 'VR_textsizemenu', 'UserData', 'auto');
  autochecked = get(automenuitem, 'Checked');
  menuitems = findobj(this, 'Tag', 'VR_textsizemenu');
  set(menuitems, 'Checked', 'off');  
  if strcmp(autochecked, 'off')    
    menuitem = findobj(this, 'Tag', 'VR_textsizemenu', 'UserData', num2str(obj.MaxTextureSize)); 
    set(menuitem, 'Checked', 'on');
  else
    set(automenuitem, 'Checked', 'on');  
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function done = onCreateViewpointApply(~, ~, ~, canvas, name, placement, jump)
  desc = get(name, 'String');
  if isempty(desc)
    errordlg('You have to enter the name of the viewpoint.', 'Viewpoint name empty', 'modal');
    done = false;
    return;
  end
  done = createViewpoint(canvas, desc, get(placement, 'Value')-1, logical(get(jump, 'Value')));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onCreateViewpointCancel(~, ~, dlg)
  parentc = getappdata(dlg, 'ParentContainer');
  if ishandle(parentc)
    setappdata(parentc, 'CreateViewpointDialog', []); 
  end
  delete(dlg);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onCreateViewpointOK(this, evt, dlg, canvas, name, placement, jump)
  % if Apply succeeds, close dialog as if Cancel was pressed
  if onCreateViewpointApply(this, evt, dlg, canvas, name, placement, jump)
    onCreateViewpointCancel(this, evt, dlg);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onViewpointDialogHelp(~,~)
  vrmfunc('FnHelpTopic', 'vr_createvp');
end
