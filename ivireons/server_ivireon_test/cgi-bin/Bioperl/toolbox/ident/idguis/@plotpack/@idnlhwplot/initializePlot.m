function initializePlot(this)
% Initialize and layout the idnlhw plot widgets.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:51:04 $

% toolbox\matlab\timeseries\@tsguis\@viewcontainer\addplot.m 
% 'color',map(rem(kd,20)+1,:)

fname = 'Hammerstein-Wiener Model Plot';
if (this.isGUI)
    f = plotpack.buildNLHWGUIFigureWindow(this);
else
    f = figure('Name',fname,'Visible','off', 'NumberTitle','off','tag','nlsitbfig_nlhw',...
        'IntegerHandle','off','PaperPositionMode','auto');
end
fpos = get(f,'pos');
fposchar = hgconvertunits(f,fpos,get(f,'units'),'char',0);

% diagram panel
u1 = uipanel('parent',f,'units','norm','pos',[0 ,0.75,1,0.25]);
a = axes('parent',u1,'units','nor','vis','off'); 

localDisableInteraction(f,a);

bw = 0.2; % Block width
bh = 0.3; % Block height
offset = bh; 
CenterPos = [0.2 0.5];
b1 = plotpack.createblock('u_{NL}',CenterPos,bw,bh,'g',a);

CenterPos = b1.Position + [offset,0];
b2 = plotpack.createblock('Linear Block',CenterPos,bw,bh,'w',a);

CenterPos = b2.Position + [offset,0];
b3 = plotpack.createblock('y_{NL}',CenterPos,bw,bh,'w',a);

% draw I/O and connecting arrows
loc = plotpack.getpos(b1,'L');
plotpack.drawconnectarrow(loc-[0.1,0],loc,a); 
plotpack.drawconnectarrow(plotpack.getpos(b1,'R'),plotpack.getpos(b2,'L'),a);
plotpack.drawconnectarrow(plotpack.getpos(b1,'R'),plotpack.getpos(b2,'L'),a);
plotpack.drawconnectarrow(plotpack.getpos(b2,'R'),plotpack.getpos(b3,'L'),a);
plotpack.drawconnectarrow(plotpack.getpos(b3,'R'),plotpack.getpos(b3,'R')+[0.1,0],a);

TopText = uicontrol('parent',u1,'style','text','units','char',...
    'string','Click on a block to view its plot:','pos',[0.5 6 fposchar(3)-5 1],...
    'HorizontalAlignment','left','fontsize',8);

IOtext = uicontrol('parent',u1,'style','text','string','Select nonlinearity at channel:','units','char');
set(IOtext,'pos',[0.5 0.5 32 1.54],'HorizontalAlignment','left');
InputCombo = uicontrol('parent',u1,'style','popup','String',this.getInputComboString,'units','char',...
    'Tag','input','BackgroundColor','w');
set(InputCombo,'pos',[34 0.82 20 1.54],'callback',@(es,ed)localSelectChannel(es,this,'input'));
OutputCombo = uicontrol('parent',u1,'style','popup','String',this.getOutputComboString,'units','char',...
    'Tag','output','BackgroundColor','w');
set(OutputCombo,'pos',[32 0.82 20 1.54],'callback',@(es,ed)localSelectChannel(es,this,'output'),'vis','off');

[linstr, linstags] = this.getLinearComboString;
LinearCombo = uicontrol('parent',u1,'style','popup','String',linstr,'userd',linstags,...
    'units','char','vis','off','Tag','linear','BackgroundColor','w');
set(LinearCombo,'pos',[18 0.82 30 1.54],...
    'callback',@(es,ed)localSelectChannel(es,this,'linear'));

PlotTypeText = uicontrol('parent',u1,'style','text','string','Choose plot type:',...
    'units','char','vis','off');
set(PlotTypeText,'pos',[fposchar(3)-22-20 0.5 23 1.54],'HorizontalAlignment','left',...
    'tag','Choose plot type:');
PlotTypeCombo = uicontrol('parent',u1,'style','popup',...
    'String',{'Step','Bode','Impulse','Pole-Zero Map'},'units','char','BackgroundColor','w');
set(PlotTypeCombo,'pos',[fposchar(3)-22 0.82 20 1.54],'callback',...
    @(es,ed)localSelectPlotType(es,this),'vis','off');

cb = uicontrol('parent',f,'style','pushbutton','string','>>','fontsize',8,...
    'HorizontalAlignment','center','fontweight','bold','units','char');

set(cb,'callback',@(es,ed)localCollapseButtonCallback(es,this),'pos',...
    [fposchar(3)-4.7,fposchar(4)-1.7,4,1.5]);

% store handles 
this.Figure = f;
this.TopPanel = u1;
%this.MainPanels = []; %u2;
this.PatchHandles = [b1.PHandle,b2.PHandle,b3.PHandle];
this.UIs.InputCombo = InputCombo;
this.UIs.OutputCombo = OutputCombo;
this.UIs.LinearPlotTypeCombo = PlotTypeCombo;
this.UIs.LinearPlotTypeText = PlotTypeText;
this.UIs.LinearCombo = LinearCombo;
this.UIs.CollapseButton = cb;
this.UIs.TopText = TopText;

% set position and block button down functions
if ~this.isGUI
    set(f,'toolbar','figure');
else
    this.attachListeners; % model related event handling
end

set(f,'pos',[fpos(1),fpos(2)-105,fpos(3),fpos(4)+105]);
set(b1.PHandle,'ButtonDownFcn',@(es,ed)localBlockBtnDownFcn(es,this,IOtext),'tag','input');
set(b3.PHandle,'ButtonDownFcn',@(es,ed)localBlockBtnDownFcn(es,this,IOtext),'tag','output');
set(b2.PHandle,'ButtonDownFcn',@(es,ed)localBlockBtnDownFcn(es,this,IOtext),...
    'tag','linear');

%----------------------------------------------------------------
function localDisableInteraction(f,a)

setAllowAxesZoom(zoom(f),a,false);
setAllowAxesPan(pan(f),a,false);
setAllowAxesRotate(rotate3d(f),a,false);

%{
% turn off legends
c1 = findall(a,'type','line');
c2 = findall(a,'type','patch');
c = [c1;c2];
for k = 1:length(c)
    hasbehavior(c(k),'legend',false); 
end
%}

set(a,'HandleVisibility','off');

%----------------------------------------------------------------
function localBlockBtnDownFcn(es,this,Label)

this.blockBtnDownFcn(es,Label);

%----------------------------------------------------------------
function localSelectChannel(es,this,type)

selindex = get(es,'Value');

switch type
    case 'input'
        if isequal(selindex, this.Current.InputComboValue)
            return
        end
        this.Current.InputComboValue = selindex;
    case 'output'
        if isequal(selindex, this.Current.OutputComboValue)
            return
        end
        this.Current.OutputComboValue = selindex;
    case 'linear'
        if isequal(selindex, this.Current.LinearComboValue)
            return
        end
        this.Current.LinearComboValue = selindex;
    otherwise
        ctrlMsgUtils.error('Ident:idguis:idnlhwPlot2')
end

this.showPlot;

%--------------------------------------------------------------
function localSelectPlotType(es,this)
%linear plot type callback

selindex = get(es,'Value');
if (this.Current.LinearPlotTypeComboValue==selindex)
    return;
end

this.Current.LinearPlotTypeComboValue = selindex;
%type = get(this.PlotTypeCombo,'string');
%type = type{selindex};

this.showPlot;

%--------------------------------------------------------------
function localCollapseButtonCallback(es,this)

str = get(es,'String');
if strcmp(str,'>>')
    str = '<<';
    set(this.TopPanel,'vis','off');
else
    str = '>>';
    set(this.TopPanel,'vis','on');
end

set(es,'String',str);
this.executeResizeFcn;
