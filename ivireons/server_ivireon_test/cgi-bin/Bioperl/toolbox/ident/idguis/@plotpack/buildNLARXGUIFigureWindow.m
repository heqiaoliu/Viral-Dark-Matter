function hw = buildNLARXGUIFigureWindow(this)
% build a GUI window for idnlarx plot (based loosely on idbuildw)

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:22:02 $

s1 = 'iduipoin(1);'; s2='iduipoin(1);iduistat(''Compiling ...'');';
s3 = 'iduipoin(2);';
title = idlaytab('figname',43);
iduistat(['Opening ',title,' window ...'])

hw = figure('Name',title,'Visible','on', 'NumberTitle','off','tag','nlsitbfig_nlarxGUI',...
    'IntegerHandle','off','units','char','visible','off',...
    'renderer','zbuffer','HandleVisibility','callback','DockControls','off','menubar','none',...
    'PaperPositionMode','auto');

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
uNum = uimenu(uOption,'Label','Set number of &samples...','separator','on'); 

set(uA,'callback',@(es,ed)localAutoRange(this));
set(uM,'callback',@(es,ed)localSetAxesLimits(this));
set(uNum,'callback',@(es,ed)nlutilspack.rangedlg('samples',this));

% Style menu
uStyle = uimenu(hw,'Label','&Style');
uimenu(uStyle,'Label','&Grid','Accelerator','G','checked','on',...
    'callback',@(es,ed)localToggleGrid(es,this));
uL = uimenu(uStyle,'Label','&Legend','checked','on');
uZ = uimenu(uStyle,'Label','&Zoom','separator','on');
uR = uimenu(uStyle,'Label','&Rotate 3D');

set(uL,'callback',@(es,ed)localToggleLegend(es,this));
set(uZ,'callback',@(es,ed)localToggleZoom(es,uR,this));
set(uR,'callback',@(es,ed)localToggle3DRotate(es,uZ,this));
set(uStyle,'Callback',@(es,ed)localSetStylesEnabled(this,uZ,uR));

% Help menu
uHelp = uimenu(hw,'Label','&Help');
uimenu(uHelp,'Label','&View explanation','callback',...
    'iduihelp(''nlarxplotgeneral.htm'',''Help: Nonlinear ARX Model Plot'');');
uimenu(uHelp,'Label','&General menu help','callback',...
    'iduihelp(''idgview.hlp'',''Help: General Menu Items'');');
uimenu(uHelp,'Label','&Special options','Callback',...
    'iduihelp(''nlarxplotspecial.htm'',''Help: Special Options for Nonlinear ARX Model Plots'');');

iduistat('done',1);
%--------------------------------------------------------------------------
function localCopyFigure(this)

v = cell(1,length(this.ModelData)*2);
for k = 1:length(this.ModelData)
    v{2*k-1} = this.ModelData(k).Model;
    v{2*k} = this.ModelData(k).Color;
end

%models = get(this.ModelData,{'Model'}); plot(models{:});
plot(v{:});

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
else
    zoom(this.Figure,'on');
    rotate3d(this.Figure,'off'); set(h,'Checked','off');
    set(es,'Checked','on');
end


%--------------------------------------------------------------------------
function localToggle3DRotate(es,h,this)

onoff = get(es,'Checked');
if strcmpi(onoff,'on')
    rotate3d(this.Figure,'off');
    set(es,'Checked','off');
else
    rotate3d(this.Figure,'on');
    zoom(this.Figure,'off'); set(h,'Checked','off');
    set(es,'Checked','on');
end

%--------------------------------------------------------------------------
function localFigureDeleteFunction(f0)
% figure close request callback

localCloseCallback(f0)
h = get(f0,'UserData');
delete(h.Listener);
delete(f0)

%--------------------------------------------------------------------------
function localCloseCallback(f0)

f = getIdentGUIFigure;
c = findall(f,'style','checkbox','tag','idnlarx');
set(c,'Value',0);

set(f0,'vis','off')

%--------------------------------------------------------------------------
function localAutoRange(this)

y = this.getCurrentOutput;
robj = find(this.RegressorData,'OutputName',y);
ax = this.getCurrentAxes;
if robj.is2D
    axis(ax,'auto');
else
    view(ax,3);
end
%--------------------------------------------------------------------------
function localSetAxesLimits(this)
% set limits for plots

ax = this.getCurrentAxes;
dlgname = 'Axis Limits';
Prompt = str2mat('Regressor 1','Regressor 2','Nonlinearity Value');
xyz = ['x';'y';'z'];
Axhand = [ax,NaN,ax,NaN,ax];

fig = idaxlimdlg(dlgname,[1 0],Prompt,Axhand,xyz);
set(fig,'tag','sitb');  % Just to clear when exiting ident

%--------------------------------------------------------------------------
function localSetStylesEnabled(this,uZ,uR)
% enable/disable zoom/rotoate options

% find out if current axes is 2d or 3d
y = this.getCurrentOutput;
robj = find(this.RegressorData,'OutputName',y);

if robj.is2D
    set(uZ,'enable','on');
    set(uR,'enable','off');
else
    set(uZ,'enable','off');
    set(uR,'enable','on');
end


