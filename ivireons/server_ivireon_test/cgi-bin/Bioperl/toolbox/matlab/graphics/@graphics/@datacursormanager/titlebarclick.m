function titlebarclick(hThis,obj,evd,hFrame,hMode)

% Copyright 2005-2007 The MathWorks, Inc.

%Check for multiple mouse-clicks
numDown = getappdata(hFrame,'ButtonsDown');
numDown = numDown + 1;
setappdata(hFrame,'ButtonsDown',numDown);
if numDown ~= 1
    return;
end

hFig = ancestor(hFrame,'figure');
appdata.wbm = get(hMode,'WindowButtonMotionFcn');
appdata.wbu = get(hMode,'WindowButtonUpFcn');
setappdata(hFrame,'figpanel',appdata);

set(hMode,'WindowButtonMotionFcn',{@local_motion,hFig,hFrame});
set(hMode,'WindowButtonUpFcn',{@local_up,hFig,hFrame,hMode});

setappdata(hFrame,'figpanel_frameposition',get(hFrame,'Position'));

%--------------------------------------------------------%
function local_motion(obj,evd,hFig,hFrame)

% If the frame handle is no longer valid, return early:
if isempty(hFrame) || ~ishandle(hFrame)
    return;
end

% Get current mouse location
cp = get(evd,'CurrentPoint');
fig_pos = get(hFig,'Position');
fig_pos = hgconvertunits(hFig,fig_pos,get(hFig,'Units'),'pixels',hFig);

orig_fp = getappdata(hFrame,'figpanel_frameposition');
orig_cp = getappdata(hFrame,'figpanel_mouseposition');
if isempty(orig_cp)
  setappdata(hFrame,'figpanel_mouseposition',cp);
else
  dp = orig_cp-cp;
  fp = get(hFrame,'Position');
  new_pos = [orig_fp(1)-dp(1),orig_fp(2)-dp(2),fp(3),fp(4)];
  if (cp(1) > 0) && ...
     (cp(1) < fig_pos(3)) && ...
     (cp(2) > 0) && ...
     (cp(2) < fig_pos(4))
        set(hFrame,'Position',new_pos);
  end
end

%--------------------------------------------------------%
function local_up(obj,evd,hFig,hFrame,hMode)

%Check for multiple mouse-clicks
numDown = getappdata(hFrame,'ButtonsDown');
numDown = numDown - 1;
setappdata(hFrame,'ButtonsDown',numDown);
if numDown ~= 0
    return;
end

appdata = getappdata(hFrame,'figpanel');
if isstruct(appdata) && ~isempty(appdata)
  set(hMode,'WindowButtonMotionFcn',appdata.wbm);
  set(hMode,'WindowButtonUpFcn',appdata.wbu);
end

% Clear out orig
setappdata(hFrame,'figpanel_mouseposition',[]);