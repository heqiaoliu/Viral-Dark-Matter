function hw = buildNLHWGUIFigureWindow(this)
% build a GUI window for idnlhw plot (based loosely on idbuildw)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/01/29 15:34:10 $

s1 = 'iduipoin(1);'; s2='iduipoin(1);iduistat(''Compiling ...'');';
s3 = 'iduipoin(2);';
title = idlaytab('figname',44);
iduistat(['Opening ',title,' window ...'])

hw = figure('Name',title,'Visible','on', 'NumberTitle','off','tag','nlsitbfig_nlhwGUI',...
    'IntegerHandle','off','visible','off','HandleVisibility','callback',...
    'DockControls','off','menubar','none','PaperPositionMode','auto');

set(hw,'CloseRequestFcn',@(es,ed)localFigureDeleteFunction(hw));

% File menu
uFile = uimenu(hw,'Label','&File');
uimenu(uFile,'Label','Copy &figure','callback',@(es,ed)localCopyFigure(this));
uimenu(uFile,'Label','&Print','callback',[s1,'printdlg;',s3]);
uimenu(uFile,'Label','&Close','Accelerator','W','callback',@(es,ed)localCloseCallback(hw));

% Options menu
uOption = uimenu(hw,'Label','&Options');
uA = uimenu(uOption,'Label','&Autorange','Accelerator','A');
uM = uimenu(uOption,'Label','Set axes &limits...','Accelerator','M'); 
uNLR = uimenu(uOption,'Label','Set input &range...','separator','on'); 
uTR = uimenu(uOption,'Label','Time &span...','enable','off'); 
uFR = uimenu(uOption,'Label','Frequency &range...','enable','off');
set(uA,'callback',@(es,ed)localAutoRange(this));
set(uM,'callback',@(es,ed)localSetAxesLimits(this));
set(uNLR,'callback',@(es,ed)nlutilspack.rangedlg('nonlinear',this));
set(uTR,'callback',@(es,ed)nlutilspack.rangedlg('time',this));
set(uFR,'callback',@(es,ed)nlutilspack.rangedlg('frequency',this));
set(uOption,'Callback',@(es,ed)localSetOptionsEnabled(this,uNLR,uTR,uFR));

% Style menu
%TimeStyle = uimenu(hw,'Label','&Style','visible','off'); 
%FrequencyStyle = uimenu(hw,'Label','&Style','visible','off'); 
NLStyle = uimenu(hw,'Label','&Style'); 
%localSetCommonStyleItems(this,[TimeStyle,FrequencyStyle,NLStyle]);
localSetCommonStyleItems(this,NLStyle);
%localAddTimeStyleItems(this,TimeStyle);


% Help menu
uHelp = uimenu(hw,'Label','&Help');
uimenu(uHelp,'Label','&View explanation','callback',...
    'iduihelp(''nlhwplotgeneral.htm'',''Help: Hammerstein-Wiener Model Plot'');');
uimenu(uHelp,'Label','&General menu help','callback',...
    'iduihelp(''idgview.hlp'',''Help: General Menu Items'');');

% there seems to be no need of special options
% uimenu(uHelp,'Label','&Special options','Callback',...
%     'iduihelp(''nlhwnavigation.hlp'',''Help: IDNLARX Model Plot Navigation Options'');');

iduistat('done',1);
%--------------------------------------------------------------------------
function localCopyFigure(this)
% copy view to a new independent figure

models = get(this.ModelData,{'Model'});
v = {};
if ~isempty(this.Time)
    v = [v,'Time',this.Time];
end

if ~isempty(this.Frequency)
    v = [v,'Frequency',this.Frequency];
end

if ~isempty(this.Range.Input)
    v = [v,'uRange',this.Range.Input];
end

if ~isempty(this.Range.Output)
    v = [v,'yRange',this.Range.Output];
end

plot(models{:},v{:});

%--------------------------------------------------------------------------
function localSetOptionsEnabled(this,uNLR,uTR,uFR)
% set which "range editor" should be enabled

if any(strcmpi(this.Current.Block,{'input','output'}))
    set(uNLR,'enable','on')
    set([uTR,uFR],'enable','off')
else
    set(uNLR,'enable','off')
    Type = this.Current.LinearPlotTypeComboValue;
    if (Type==1) || (Type==3)
        set(uFR,'enable','off')
        set(uTR,'enable','on')
    elseif (Type==2)
        set(uFR,'enable','on')
        set(uTR,'enable','off')
    else
        set([uTR,uFR],'enable','off')
    end
end


%--------------------------------------------------------------------------
function localSetCommonStyleItems(this,uStyles)
% set common uisubmenus - grid, zoom, pan

for k = 1:length(uStyles)
    uStyle = uStyles(k);
    uimenu(uStyle,'Label','&Grid','Accelerator','G','checked','off',...
        'callback',@(es,ed)localToggleGrid(es,this));
    uL = uimenu(uStyle,'Label','&Legend','checked','on');
    uZ = uimenu(uStyle,'Label','&Zoom','Separator','on');
    uP = uimenu(uStyle,'Label','&Pan');

    set(uL,'callback',@(es,ed)localToggleLegend(es,this));
    set(uZ,'callback',@(es,ed)localToggleZoom(es,uP,this));
    set(uP,'callback',@(es,ed)localTogglePan(es,uZ,this));
end

%--------------------------------------------------------------------------
function localToggleGrid(es,this)

onoff = get(es,'Checked');
allaxes = this.getAllAxes;
%allaxes = findall(this.MainPanels,'type','axes');
if strcmpi(onoff,'on')
    set(es,'Checked','off');
    set(allaxes,'xgrid','off','ygrid','off','zgrid','off');
else
    set(es,'Checked','on');
    set(allaxes,'xgrid','on','ygrid','on','zgrid','on');
end

%--------------------------------------------------------------------------
function localToggleLegend(es,this)
% toggle legend

onoff = get(es,'Checked');
ax = this.getAllAxes;

if strcmpi(onoff,'on')
    set(es,'Checked','off');
    this.showLegend = false;
    for k = 1:length(ax)
        legend(ax(k),'hide');
    end
else
    set(es,'Checked','on');
    this.showLegend = true;
    for k = 1:length(ax)
        legend(ax(k),'show');
    end
end

%--------------------------------------------------------------------------
function localToggleZoom(es,h,this)

onoff = get(es,'Checked');
if strcmpi(onoff,'on')
    zoom(this.Figure,'off');
    set(es,'Checked','off');
    
    set(this.UIs.TopText,'string','Click on a block to view its plot:',...
        'FontWeight','normal','ForegroundColor',get(0,'defaultTextColor'));
    
else
    zoom(this.Figure,'on');
    pan(this.Figure,'off'); set(h,'Checked','off');
    set(es,'Checked','on');
    
    set(this.UIs.TopText,'string','Turn off zoom to click on blocks.',...
        'FontWeight','b','ForegroundColor','r');
end

%--------------------------------------------------------------------------
function localTogglePan(es,h,this)

onoff = get(es,'Checked');
if strcmpi(onoff,'on')
    pan(this.Figure,'off');
    set(es,'Checked','off');
    
    set(this.UIs.TopText,'string','Click on a block to view its plot:',...
        'FontWeight','normal','ForegroundColor',get(0,'defaultTextColor'));
    
else
    pan(this.Figure,'on');
    zoom(this.Figure,'off'); set(h,'Checked','off');
    set(es,'Checked','on');
    
    set(this.UIs.TopText,'string','Turn off pan mode to click on blocks.',...
        'FontWeight','b','ForegroundColor','r'); 
end

%--------------------------------------------------------------------------
function localFigureDeleteFunction(f0)
% figure close request callback

localCloseCallback(f0)
h = get(f0,'UserData');
delete(h.Listeners);
delete(f0)

%--------------------------------------------------------------------------
function localCloseCallback(f0)

f = getIdentGUIFigure;
c = findall(f,'style','checkbox','tag','idnlhw');
set(c,'Value',0);

set(f0,'vis','off')

%--------------------------------------------------------------------------
function localAutoRange(this)

ax = this.getCurrentAxes;
%zoom(this.Figure,'out')
%axis(ax,'auto')
for i = 1:length(ax)
    zoom(ax(i),'out')
end

%--------------------------------------------------------------------------
function localSetAxesLimits(this)
% set limits for plots

ax = this.getCurrentAxes;
blk = this.Current.Block;

switch lower(blk)
    case {'input','output'}
        dlgname = 'Axis Limits';
        Prompt = str2mat('Input to nonlinear block (x axis):','Nonlinearity value (y axis):');
        xyz = ['x';'y'];
        Axhand = [ax,NaN,ax];
    case 'linear'
        Type = this.Current.LinearPlotTypeComboValue;
        switch Type
            case {1,3}
               dlgname = 'Limits for Transient Response';
               str1 = get(get(ax,'xlabel'),'string'); 
               str2 = get(get(ax,'ylabel'),'string');
               Prompt = str2mat(str1,str2);
               xyz = ['x';'y'];
               Axhand = [ax,NaN,ax];
            case 2
                dlgname = 'Limits for Bode Response';
                str1 = get(get(ax(2),'xlabel'),'string');
                str2 = get(get(ax(1),'ylabel'),'string');
                str3 = get(get(ax(2),'ylabel'),'string');
                Prompt = str2mat(str1,str2,str3);
                xyz = ['x';'y';'y'];
                Axhand = [ax(1),ax(2),NaN,ax(1),NaN,ax(2)];
            case 4
               dlgname = 'Limits for Pole-Zero Map';
               Prompt = str2mat('Real-axis (x)','Imag-axis (y)');
               xyz = ['x';'y'];
               Axhand = [ax,NaN,ax];
        end
end

fig = idaxlimdlg(dlgname,[1 0],Prompt,Axhand,xyz);
set(fig,'tag','sitb');  % Just to clear when exiting ident
