function attachListeners(this)
% attach listeners to all uicontrols and mouse btn events

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/03/13 17:24:05 $

% tab selection
set(this.Panels.Main,'SelectionChangeFcn',@(es,ed)LocalTabSelectionCallback(ed,this));

% i/o pair changes
set(this.UIs.uCombo,'callback',@(es,ed)LocalInputChanged(this));
set(this.UIs.yCombo,'callback',@(es,ed)LocalOutputChanged(this));

% context menu for multi-exp data
if this.Data.isMultiExp
    LocalAttachContextMenu(this)
end

% buttons
set(this.UIs.CloseBtn,'Callback',@(es,ed)close(this.Figure));
set(this.UIs.InsertBtn,'Callback',@(es,ed)LocalUpdateDelayInCaller(this));
set(this.UIs.HelpBtn,'Callback',@(es,ed)localHelpCallback);

% line 
LocalDragLocation(this);

%--------------------------------------------------------------------------
function LocalTabSelectionCallback(ed,this)

if ed.NewValue==1
    this.setCurrentAxes('Time');
    set(this.UIs.DelayLabel,'String',this.TimeInfo.DelayStr);
else
    this.setCurrentAxes('Impulse');
    set(this.UIs.DelayLabel,'String',this.ImpulseInfo.DelayStr);
end

% legtoolb = uigettoolbar(this.Figure,'Annotation.InsertLegend'); 
% set(legtoolb,'state','off','ClickedCallBack','','OnCallback','legend(gca,''show'')',...
%     'OffCallback','legend(gca,''hide'')'); 

%legend(this.getCurrentAxes,'hide');

%--------------------------------------------------------------------------
function LocalInputChanged(this)

val = get(this.UIs.uCombo,'Value');
if (val==this.Current.InputNumber)
    return;
end

this.Current.InputNumber = val;
this.draw;

%--------------------------------------------------------------------------
function LocalOutputChanged(this)

val = get(this.UIs.yCombo,'Value');
if (val==this.Current.OutputNumber)
    return;
end

this.Current.OutputNumber = val;
this.draw;

%--------------------------------------------------------------------------
function LocalDragLocation(this)

f = this.Figure;
set(f,'WindowButtonDownFcn',@(es,ed)LocalBtnDown(this));
set(f,'WindowButtonMotionFcn',@(es,ed)LocalBtnMotion(this));

%--------------------------------------------------------------------------
function LocalBtnDown(this)

f = this.Figure;

hoverobj = handle(hittest(f));
objtype = get(hoverobj,'type');
objtag  = get(hoverobj,'tag');

if strcmpi(objtype,'line') &&  strcmp(objtag,'mover')
    setptr(f,'lrdrag');
    z = this.Current.WorkingData;
    
    if strcmpi(this.Current.Mode,'Time')
        otherobj = this.TimeInfo.MoveLines(~(this.TimeInfo.MoveLines==hoverobj));
        otherval = get(otherobj,'Xdata');
        xmin = z.Tstart;
    else
        otherval = 0;
        xmin = 0;
    end
    set(f,'WindowButtonMotionFcn',@(es,ed)LocalDragFcn(this,hoverobj,otherval(1),z.Ts,xmin));
    set(f,'WindowButtonUpFcn',@(es,ed)LocalBtnUp(this));
else
    set(f,'WindowButtonUpFcn','');
end

%--------------------------------------------------------------------------
function LocalBtnMotion(this)

f = this.Figure; 
hoverobj = handle(hittest(f));
objtype = get(hoverobj,'type');
objtag  = get(hoverobj,'tag');

if strcmpi(objtype,'line') &&  strcmp(objtag,'mover')
    setptr(f,'lrdrag');
else
    setptr(f,'arrow');
end

%--------------------------------------------------------------------------
function LocalBtnUp(this)

f = this.Figure; 

hoverobj = handle(hittest(f));
objtype = get(hoverobj,'type');
objtag  = get(hoverobj,'tag');

if strcmpi(objtype,'line') &&  strcmp(objtag,'mover')
    setptr(f,'lrdrag');
else
    setptr(f,'arrow');
end

set(f,'WindowButtonMotionFcn',@(es,ed)LocalBtnMotion(this));

%--------------------------------------------------------------------------
function LocalDragFcn(this,L,ref,ts,xmin)

f = this.Figure; 
ax = this.getCurrentAxes;

pt = get(ax,'CurrentPoint');
if pt(1,1)<=xmin
    val = xmin;
else
    val = pt(1,1);
end

set(L,'Xdata',[val,val]);

Del = abs(val-ref);

% delstr = sprintf('Suggested delay from %s to %s: %2.5g %s (%d samples)',...
%     un,yn,Del, this.Data.TimeUnit, round(Del/ts));

%delstr = sprintf('%2.5g %s (%d samples)',Del, this.Data.TimeUnit, round(Del/ts));

this.updateDelayInfo(round(Del/ts),Del);

%--------------------------------------------------------------------------
function LocalAttachContextMenu(this)

ExpNames = get(this.Data.EstData,'ExperimentName');
cmenu = uicontextmenu('parent',this.Figure);
uimenu(cmenu,'Label','Choose Experiment');
for k = 1:size(this.Data.EstData,'ne')
    itemk = uimenu(cmenu, 'Label', ExpNames{k},'Callback',@(es,ed)LocalUISelectionCallback(es,this));
    if k==1
        set(itemk,'separator','on','checked','on');
    end
end

set(this.TimeInfo.Axes,'UIContextMenu',cmenu);

%--------------------------------------------------------------------------
function LocalUISelectionCallback(es,this)

if strcmpi(get(es,'checked'),'off')
    this.Current.ExpNumber = get(es,'Position')-1;
    this.draw;
    cmenu = get(this.TimeInfo.Axes,'UIContextMenu');
    set(get(cmenu,'children'),'checked','off')
    set(es,'checked','on')
end
%--------------------------------------------------------------------------
function LocalUpdateDelayInCaller(this)
% call caller's updateInputDelay method with shown delay

if strcmpi(this.Current.Mode,'Time')
    Del = this.TimeInfo.Delay;
else
    Del = this.ImpulseInfo.Delay;
end

this.Caller.updateInputDelay(Del,this.Current.InputNumber,this.Current.OutputNumber);

%--------------------------------------------------------------------------
function localHelpCallback

iduihelp('iddelayest.htm','Help: Determining Input Delay Graphically');
