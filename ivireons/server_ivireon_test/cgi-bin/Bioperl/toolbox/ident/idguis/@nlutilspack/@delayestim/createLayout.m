function createLayout(this)
% layout the delay estimation window - everything minus axis contents
% (lines)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/03/31 18:22:40 $

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************


fName = 'Infer Input Delay';
this.Figure = figure('units','char','tag','ident:data:delayinspectiontool',...
    'NumberTitle','off','IntegerHandle','off','PaperPositionMode','auto',...
    'Name',fName,'menubar','none','toolbar','figure','vis','off','DockControls','off');
fpos = get(this.Figure,'pos');

if this.isDark
    lcol = 'green';
else
    lcol = 'red';
end

% assemble top panel
pct = 0.125;
tppos = [0,fpos(4)*(1-pct),fpos(3),fpos(4)*pct];
TopPanel = uipanel('parent',this.Figure,'units','char','pos',tppos);

toptxtpos = [0.1, tppos(4)-1.5, tppos(3)-20, 1];
toptext = uicontrol('parent',TopPanel,'style','text','units','char',...
    'string','Select input and output channels:',...
    'pos',toptxtpos,'horizontalalignment','left');

upos = [1, toptxtpos(2)-1.7, 6, 1];
uicontrol('parent',TopPanel,'style','text','units','char',...
    'string','Input:','pos',upos,'horizontalalignment','left');

ucombopos = [upos(1)+upos(3)+0.6,upos(2)-0.1,20,1.5];
this.UIs.uCombo = uicontrol('parent',TopPanel,'style','popup','units','char',...
    'pos',ucombopos,'horizontalalignment','left','BackgroundColor','w','string',{'a'},...
    'tag','delayest:InputCombo');

ypos = [ucombopos(1)+ucombopos(3)+5, upos(2), upos(3)+1.4,upos(4)];
uicontrol('parent',TopPanel,'style','text','units','char',...
    'string','Output:','pos',ypos,'horizontalalignment','left');

ycombopos = [ypos(1)+ypos(3)+0.6,ypos(2),20,1.5];
this.UIs.yCombo= uicontrol('parent',TopPanel,'style','popup','units','char',...
    'pos',ycombopos,'horizontalalignment','left','BackgroundColor','w','string',{'a'},...
    'tag','delayest:OutputCombo');

this.Panels.Top = TopPanel;

% assemble bottom panel
pct1 = 0.16;
bppos = [0,0,fpos(3),fpos(4)*pct1];
BottomPanel = uipanel('parent',this.Figure,'units','char','pos',bppos);

deltextpos = [0.2, 0.4+pct1*fpos(4)/2, fpos(3)-2, 1];
this.UIs.DelayLabel = uicontrol('parent',BottomPanel,'style','text','units','char',...
    'string','Delay:','pos',deltextpos,'horizontalalignment','left',...
    'tag','delayest:SuggestedDelayLabel');
% delaypos = [deltextpos(1)+deltextpos(3)+0.6,deltextpos(2),27,1.5];
% this.UIs.DelayLabel = uicontrol('parent',BottomPanel,'style','text','units','char',...
%     'string','0','pos',delaypos,'horizontalalignment','left',...
%     'fontweight','bold');

ht = 1.8; wid = 9; hm = 0.75; vm = 0.12;
helppos = [bppos(3)-1.4-wid, vm, wid, ht];
this.UIs.HelpBtn = uicontrol('parent',BottomPanel,'style','pushbutton','string','Help',...
    'units','char','pos',helppos,'tag','delayest:HelpButton');

closepos = [helppos(1)-hm-wid, vm, wid, ht];
this.UIs.CloseBtn = uicontrol('parent',BottomPanel,'style','pushbutton','string','Close',...
    'units','char', 'pos',closepos,'tag','delayest:CloseButton');

insertpos = [closepos(1)-hm-wid, vm, wid, ht];
this.UIs.InsertBtn = uicontrol('parent',BottomPanel,'style','pushbutton','string','Insert',...
    'units','char', 'pos',insertpos,'tag','delayest:InsertButton');

this.Panels.Bottom = BottomPanel;

% assemble main panel
mpos = [0,bppos(4),fpos(3),fpos(4)*(1-pct-pct1)];
MainPanel = uitabgroup('parent',this.Figure,'units','char','pos',mpos); 

% time plot tab
timeplottab = uitab(MainPanel,'title','Time Plot','units','char',...
    'tag','delayest:TimeTab'); 
t1pos = mpos;  %t1pos(4) = mpos(4)-0; %get(timeplottab,'pos');

if this.Data.isMultiExp
    mexp = sprintf('\nRight-click to change the data experiment in view.');
else
    mexp = '';
end

instr = [sprintf('Drag one of the two %s line to mark the time when the input (black) changes significantly. ',lcol),...
    sprintf('Drag the other %s line to mark the time of first response to this input change. ',lcol),...
    sprintf('Inferred delay is below the graph.%s',mexp)];
ipos = [0.5, t1pos(4)-1.2, t1pos(3)-1.5, 3];
ilab = uicontrol('parent',timeplottab,'style','text','units','char',...
    'pos',ipos,'horizontalalignment','left','string',instr);
this.TimeInfo.Message = instr;
%str = textwrap(ilab,{instr}); set(ilab, 'string',str); 
this.TimeInfo.InstrLabel = ilab;

axpos = [12,3,t1pos(3)-14,t1pos(4)-4-ipos(4)];
ax = axes('parent',timeplottab,'tag','nlident:delayestim:timeplotaxes',...
    'box','on','Xgrid','on','Ygrid','on','XColor',[1 1 1]*0.5,...
    'GridLineStyle','-','YColor',[1 1 1]*0.5,'units','char','pos',axpos);
xlabel(ax,'Time');  ylabel(ax,'I/O Response');
setAllowAxesRotate(rotate3d(this.Figure),ax,false);
this.TimeInfo.Axes = ax;

% impulse response tab
impulseplottab = uitab(MainPanel,'title','Impulse Response','units','char','tag','delayest:ImpulseTab');  drawnow;
t2pos = mpos; %get(impulseplottab,'pos');

instr = [sprintf('Drag the %s line to mark the first positive time instant when response is outside the confidence interval. ',lcol),...
    sprintf('Inferred delay is below the graph.')];
this.ImpulseInfo.Message = instr;
ipos = [0.5, t2pos(4)-1.2, t2pos(3)-1.5, 2];
ilab = uicontrol('parent',impulseplottab,'style','text','units','char',...
    'pos',ipos,'horizontalalignment','left','string',instr);
%str = textwrap(ilab,{instr}); set(ilab, 'string',instr); 
this.ImpulseInfo.InstrLabel = ilab;

axpos1 = [12,3,t2pos(3)-14,t2pos(4)-4-ipos(4)];
ax1 = axes('parent',impulseplottab,'tag','nlident:delayestim:impulseeplotaxes',...
    'box','on','Xgrid','on','Ygrid','on','XColor',[1 1 1]*0.5,...
    'GridLineStyle','-','YColor',[1 1 1]*0.5,'units','char','pos',axpos1);
%xlabel(ax,'Time');  ylabel(ax,'I Response');
setAllowAxesRotate(rotate3d(this.Figure),ax1,false);
this.ImpulseInfo.Axes = ax1;

this.Panels.Main = MainPanel;

% resize function
set(this.Figure,'ResizeFcn',@(es,ed)this.resizeFunction);

% remove unnecessary toolbar buttons
delete(uigettoolbar(this.Figure,'Exploration.Rotate'));
delete(uigettoolbar(this.Figure,'Plottools.PlottoolsOn'));
delete(uigettoolbar(this.Figure,'Plottools.PlottoolsOff'));
delete(uigettoolbar(this.Figure,'Standard.EditPlot'));
delete(uigettoolbar(this.Figure,'Annotation.InsertColorbar'));

% make figure taller
fpos(2) = fpos(2)-0.1*fpos(4);
fpos(4) = 1.1*fpos(4);
set(this.Figure,'pos',fpos);
