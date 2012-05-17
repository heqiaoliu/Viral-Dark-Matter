function nbf = iduiwnet(arg, fig)
%IDUIWNET: Wavenet interactive GUI for the choice of number of units.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/05/23 08:02:37 $

% Author(s): Qinghua Zhang

if nargout>0
    nbf = [];
else
    clear nbf
end
persistent persist_nwnet

if strcmp(arg,'open')
    V = fig; %not a figure really for arg='open'
    
    rootshh = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    delete(findall(get(0, 'child'),'flat', 'tag', 'sitb99', 'name', 'Wavenet Units Selection'));
    set(0, 'ShowHiddenHandles', rootshh);
    
    idlayoutscript
    butwh=[mStdButtonWidth mStdButtonHeight];
    butw=butwh(1);buth=butwh(2);
    ftb=mFrameToText;  % Frame to button
    bb = 4; % between buttons
    etf = mEdgeToFrame;
    
    fig = SubIdbuildw;
    
    SubUdset(fig, 'V', V);
    SubUdset(fig, 'nbf', []);
    
    set(fig,'units','pixels');
    FigWH=get(fig,'pos');
    FigWH=FigWH(3:4);
    
    lev1=max(0,(FigWH(2)-9*buth-8*bb)/2);
    pos = iduilay1((butw+2*ftb),9,9,lev1,bb);
    pos=pos+[(FigWH(1)-pos(1,1)-pos(1,3)-etf)*ones(10,1),zeros(10,3)];
    
    uicontrol(fig,'pos',pos(1,:),'style','frame');
    uicontrol(fig,'Pos',pos(10,:),'style','push','callback',...
        'iduihelp(''selwnet.hlp'',''Help: Choice of number of units'');'...
        ,'string','Help', 'Tooltip','Help on the choice of number of units.');
    
    uicontrol(fig,'Pos',pos(8,:),'style','push','callback',...
        @(x,y)LocalCallbackOpen1(fig),'string','OK',...
        'Tooltip','Validate the current choice.');
    
    uicontrol(fig,'pos',pos(5,:).*[1 1 1 2],'style','text',...
        'string','Fit=','horizontalalignment','left', 'tag', 'UovFit');
    
    uicontrol(fig,'pos',pos(3,:),'style','edit',...
        'string','','backgroundcolor','w','Horizontalalignment','left',...
        'callback',@(x,y)LocalCallbackOpen3(fig),'tag','nupar', ...
        'Tooltip','Editable integer.');
    
    uicontrol(fig,'pos',pos(2,:),'style','text',...
        'string','# of units','HorizontalAlignment','left');
    
    handl=findobj(fig,'type','uicontrol');
    set(handl,'unit','norm')
    % End creation window
    
    % Plot data
    zvnorm = V.ssy;
    vv = V.sse;
    
    handax= SubUdget(fig, 'axes');
    set(handax,'vis','off')
    axes(handax)
    cla(handax)
    axis(handax,'auto')
    
    [dum,dum,dum,xx,yy]=makebars(1:length(vv), 100*vv/zvnorm);
    
    SubUdset(fig, 'xx', xx);
    SubUdset(fig, 'yy', yy);
    
    minv = min(vv(:));
    maxv = max(vv(:));
    barbottom=floor(10*(minv-0.05*(maxv-minv))/zvnorm)*10;
    % This is the firt estimation of barbottom
    
    zer=find(yy==0);
    yy(zer)=barbottom*ones(size(zer));
    
    % Get the auto ylim
    patemp = patch(xx, yy,'w','parent',handax);
    ym = ylim(handax);
    delete(patemp);
    barbottom = ym(1); % Set barbottom to the bottom of the axis.
    yy(zer)=barbottom*ones(size(zer));
    
    indgcv = V.indexgcv;
    
    % Bars at the left side of GCV bar
    if indgcv>1
        patch(xx(1:5*indgcv-3),yy(1:5*indgcv-3),'y','parent',handax);
    end
    
    % GCV bar
    patch(xx(5*indgcv-3:5*indgcv),yy(5*indgcv-3:5*indgcv),'b','parent',handax);
    
    % Bars at the right side of GCV bar
    patch(xx(5*indgcv:end),yy(5*indgcv:end),'y','parent',handax);
    
    set(handax,'vis','on')
    yl=get(handax,'ylim');ylen=length(vv);ym=max(vv(ceil(ylen/3):ylen)*100/zvnorm);
    
    if ym>yl(2)/1.3
        set(handax,'ylim',[yl(1) ym*1.3])
    end
    
    text(0.97,0.90,{'Blue: default choice', 'Red: current choice'},'units','norm','fontsize',10,...
        'Horizontalalignment','right','parent',handax)
    
    selbar = line(xx(5*indgcv-3:5*indgcv),yy(5*indgcv-3:5*indgcv),'color', 'red', 'LineWidth',2,'parent',handax);
    SubUdset(fig, 'selbar', selbar);
    
    set(fig,'vis','on')
    
    set(findobj(fig,'tag','nupar'),'string', int2str(indgcv));
    
    iduiwnet('comp',fig);
    set(fig,'handlevis','callback')
    axis(handax,'auto')
    
    uiwait(fig);
    nbf = persist_nwnet;
    
elseif strcmp(arg,'comp')
    figure(fig)
    V=SubUdget(fig, 'V');
    
    pp = str2num(get(findobj(fig,'tag','nupar'),'string'));
    
    if isempty(pp) || ~isscalar(pp) || pp~=round(pp)
        SubIduistat('Invalid value for number of units.', fig);
        
    else
        if pp<=0 || pp>length(V.sse)
            uovfit='';
            SubIduistat('This number of units is not available.', fig);
        else
            
            ind = pp;
            xx = SubUdget(fig, 'xx');
            yy = SubUdget(fig, 'yy');
            selbar = SubUdget(fig, 'selbar');
            selyd = get(selbar, 'ydata');
            set(selbar, 'xdata', xx(5*ind-3:5*ind), 'ydata', [selyd(1); yy(5*ind-2:5*ind-1); selyd(1)]);
            
            uov = sprintf('UOV = %0.4g%%', (V.sse(ind)/V.ssy)*100);
            sfit = sprintf('Fit = %0.4g%%', (1-sqrt(V.sse(ind)/V.ssy))*100);
            uovfit = {uov,sfit};
            
            SubIduistat('Inspect models by clicking bars or press OK.', fig);
            
        end
        set(findobj(fig,'tag','UovFit'),'string',uovfit);
    end
    
elseif strcmp(arg,'down')
    figure(fig)
    V = SubUdget(fig, 'V');
    
    pt=get(gca,'currentpoint');
    pp=round(pt(1,1));
    pp = max(1, pp); pp=min(length(V.sse), pp);
    ind = pp;
    xx = SubUdget(fig, 'xx');
    yy = SubUdget(fig, 'yy');
    selbar = SubUdget(fig, 'selbar');
    selyd = get(selbar, 'ydata');
    set(selbar, 'xdata', xx(5*ind-3:5*ind), 'ydata', [selyd(1); yy(5*ind-2:5*ind-1); selyd(1)]);
    
    if isempty(ind),
        uovfit='';
        spp='';
    else
        uov = sprintf('UOV = %0.4g%%', (V.sse(ind)/V.ssy)*100);
        sfit = sprintf('Fit = %0.4g%%', (1-sqrt(V.sse(ind)/V.ssy))*100);
        uovfit = {uov,sfit};
        spp=int2str(pp);
    end
    set(findobj(fig,'tag','UovFit'),'string',uovfit);
    
    set(findobj(fig,'tag','nupar'),'string',spp);
    
    SubIduistat('Click other bar or press OK.',fig);
    
elseif strcmp(arg,'insert_NG')
    pp = str2num(get(findobj(fig,'tag','nupar'),'string'));
    
    V = SubUdget(fig, 'V');
    
    if isempty(pp) || ~isscalar(pp) || pp~=round(pp)
        SubIduistat('Invalid value for number of units.', fig);
        return
    elseif pp<=0 || pp>length(V.sse)
        SubIduistat('This number of units is not available.', fig);
        return
    end
    
    persist_nwnet = pp;
    
    iduiwnet('close_NG',fig);
    
elseif strcmp(arg,'close_NG')
    delete(fig);
    
elseif strcmp(arg,'setzoom')
    SubIduimbcb('setzoom',fig);
    
elseif strcmp(arg,'mbcbdef')
    SubIduimbcb('def',fig);
    
    
elseif strcmp(arg,'grid')
    SubGrid(fig);
    
elseif strcmp(arg,'copyfigure')
    SubIdunlink(fig)
    
end

%==== Sub Functions ================================

function hw=SubIdbuildw
%IDBUILDW This function handles the creation of all the ident VIEW windows.
%       Twelve different windows are handled, with names corresponding to
%       the input argument NUMBER according to the table in idlaytab.

number = 9; %Window number (sitb9) to call some functions in linear SITB

s1='iduipoin(1);';
s3='iduipoin(2);';
fonts = idlayout('fonts',number);
fz=fonts{1}; % Fontsize for axes,title and labels
fw=fonts{2}; % Fontweight for ditto

map = idlayout('plotcol',number); % The colors associated with the plots
col = map(1,:); % frame around the axes
ftcol = map(2,:); % Titles and labels
fticol = map(3,:); % Color for tickmarks
AxesColor = map(4,:); % Axes color

title = 'Wavenet Units Selection';

posfig=[];

if isempty(posfig)
    pos1=get(0,'Screensize');
    
    posWH=min(pos1(3:4)*1/2,[360 300]);
    
    posXY=max(pos1(3:4)-posWH-(number-1)*[40 40]-[0,40],[0 0]);
    posfig=[posXY posWH];
end

tag = 'sitb99';

posWH=posfig(3:4);

hw=figure('pos',posfig,'NumberTitle','off','name',title,...
    'HandleVisibility','callback','Visible','off','tag',tag,...
    'color',col, 'Integerhandle','off');
set(hw,'menubar','none','CloseRequestFcn',@(x,y)iduiwnet('insert_NG',hw));

% Main menu items:
defaults=idlayout('figdefs');
defaults=defaults(:, 9);

label = '&Options';
ho=uimenu(hw,'Label',label);
label = '&Style';
ha=uimenu(hw,'Label',label);

label = '&Autorange';
uimenu(ho,'Label',label, ...
    'callback',[s1,'axis auto;',s3]);
label = 'Set axes &limits...';
uimenu(ho,'Label',label, ...
    'callback',[s1,'iduiaxis(''open'',gcbf);',s3]);

idvmenus(number,ho,'options');

label = '&Grid';
h1=uimenu(ha,'Label',label,'separator','off',...
    'callback',@(x,y)iduiwnet('grid',hw),'tag','grid');

if defaults(4)==0,set(h1,'checked','on'),end % will be toggled later

label = '&Zoom';
hz=uimenu(ha,'Label',label,'separator','off','callback',...
    @(x,y)LocalSubIdbuildwCallback3(hw),'tag','zoom');
if defaults(6)==0
    set(hz,'checked','on') % Will be toggled later
else
    set(hz,'checked','off')
end

% Now follows the basic AXES settings, with the axes handles
% made userdata (3-- rd item) of the figure

pos = idlayout('axes', 9);
xax(1,1)=axes('parent',hw,'position',pos(1,:),'box','on',...
    'drawmode','fast','tag','axis1','color',AxesColor,...
    'xcolor',fticol,'ycolor',fticol,'fontsize',fz);
set(get(xax(1,1),'title'),'fontsize',fz,'color',ftcol,'fontweight',fw);
set(get(xax(1,1),'xlabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);
set(get(xax(1,1),'ylabel'),'fontsize',fz,'color',ftcol,'fontweight',fw);

set(xax(:,1),'interruptible','On');
idlayoutscript
pos=[0.9*mStdButtonWidth,3*mStdButtonHeight];
uicontrol(hw,'pos',[0 0 pos],'vis','off','style','edit',...
    'max',2,'tag','infobox');

% XID.status(number)
sthd = uicontrol(hw,'Style','text','String','', ...
    'Position',[mEdgeToFrame mEdgeToFrame posWH(1)...
    0.8*mStdButtonHeight]);
set(sthd,'unit','norm')

SubUdset(hw, 'status', sthd);

set(hw,'interruptible','On','windowbuttonupfcn','1;');

iduiwnet('setzoom',hw);

SubGrid(hw);

SubIduital(hw);

% Double window width
set(xax, 'units', 'pixels');
axp = get(xax, 'pos');
wid0 = posfig(3);
posfig(1) = posfig(1)-wid0;
posfig(3) = wid0*2;
set(hw, 'position', posfig);
axp(3)=axp(3)+wid0;
set(xax, 'pos', axp);
set(xax, 'units', 'normalized');

SubUdset(hw, 'axes', xax);
set(hw, 'WindowButtonDownFcn',@(x,y)iduiwnet('down',hw));

set(hw,'vis','on');

%------------------------------------------------------------------
function SubIduimbcb(flag,fig)
%IDUIMBCB Handles the Mouse Button Callbacks for ident plot windows.
%   The WindowButtonDownFcn is set to iduimbcb in all plot windows.

if strcmp(flag,'setzoom')
    
    hmen=findobj(fig,'tag','zoom');
    if strcmp(get(hmen,'checked'),'off')
        set(hmen,'checked','on')
        set(fig,'windowbuttondownfcn', @(x,y)iduiwnet('mbcbdef',fig));
    else
        set(hmen,'checked','off')
        SubIduimbcb('reset_zoom',fig);
        
        set(fig,'windowbuttondownfcn',@(x,y)iduiwnet('down',fig))
        
    end
elseif strcmp(flag,'def')
    
    type=get(fig,'Selectiontype');
    if strcmp(type,'extend')
        
        iduiwnet('down',fig);
        
    else
        
        set(fig,'windowbuttonmotionfcn','')
        
        zoom('down')
        % The following is due to the unreliability of 'gca':
        axhand = SubUdget(fig,'axes');
        if length(axhand)>1
            if strcmp(get(axhand(2),'vis'),'on')
                pos=get(fig,'pos');
                x=get(fig,'currentpoint');
                if x(2)>0.5*pos(4),
                    curax=axhand(1);altax=axhand(2);
                else
                    curax=axhand(2);altax=axhand(1);
                end
                set(altax,'xlim',get(curax,'xlim'))
            end % strcmp
        end  % if length ...
        
    end
    
elseif strcmp(flag,'reset_zoom')
    usd=get(fig,'userdata');[rusd,cusd]=size(usd);
    
    xax=usd(3:rusd,1);
    try
        set(get(xax(1),'zlabel'),'user',[])
    end
    try
        set(get(xax(2),'zlabel'),'user',[])
    end
end

%-----------------------------------------------
function SubGrid(fh)

hm = findobj(fh,'tag', 'grid');
onoff=get(hm,'checked');
if strcmp(onoff,'off'),onoff1='on';else onoff1='off';end
kk = findobj(fh,'type', 'axes');
set(kk,'Xgrid',onoff1);
set(kk,'Ygrid',onoff1);
set(hm,'checked',onoff1);

%-----------------------------------------
function value = SubUdget(fig, pn)
ud = get(fig, 'userdata');
value = ud.(pn);

%-----------------------------------------
function SubUdset(fig, pn, value)
ud = get(fig, 'userdata');
ud.(pn) =  value;
set(fig, 'userdata', ud);

%-----------------------------------------------------
function SubIduital(fig)
%IDUITAL Callback for 'Title and Labels' menu item.
%   Toggles title off and on.

hax1=findobj(get(fig,'children'),'flat',...
    'tag','axis1','vis','on');
t1=get(hax1,'title');x1=get(hax1,'xlabel');y1=get(hax1,'ylabel');

set(t1,'string','Unexplained Output Variance (UOV) vs Number of Units', 'FontWeight', 'bold');
set(x1,'string','Number of Units')
set(y1,'string','Unexplained output variance (in %)')

%-------------------------------------------------------
function SubIduistat(string,fig)
%IDUISTAT Manages the status line in main ident window.

set(SubUdget(fig, 'status'), 'string', string);
%eval('set(XID.status(window),''string'',string)','')
drawnow

%--------------------------------------------------------
function SubIdunlink(fig)
%IDUNLINK Performs the unlinking of figure with no wino.

ax = SubUdget(fig,'axes');

figure;

subplot(111)

axn=gca;
set(axn,'xlim',get(ax,'xlim'),'ylim',get(ax,'ylim'),'box',get(ax,'box'),...
    'xscale',get(ax,'xscale'),'yscale',get(ax,'yscale'),...
    'xgrid',get(ax,'xgrid'),'ygrid',get(ax,'ygrid'),'color',get(ax,'color'))

xlo=get(ax,'xlabel');xln=get(axn,'xlabel');
set(xln,'string',get(xlo,'string'),'vis',get(xlo,'vis'))
xlo=get(ax,'ylabel');xln=get(axn,'ylabel');
set(xln,'string',get(xlo,'string'),'vis',get(xlo,'vis'))
xlo=get(ax,'title');xln=get(axn,'title');
set(xln,'string',get(xlo,'string'),'vis',get(xlo,'vis'))
lns=findobj(ax,'type','line','vis','on');
for ln=lns(:)'
    line('xdata',get(ln,'xdata'),'ydata',get(ln,'ydata'),'color',...
        get(ln,'color'),'linestyle',get(ln,'linestyle'),...
        'marker',get(ln,'marker'))
end

%--------------------------------------------------------------------------
function LocalCallbackOpen1(fig)

iduipoin(1);
iduiwnet('insert_NG',fig);
iduipoin(3);

%--------------------------------------------------------------------------
function LocalCallbackOpen3(fig)
iduipoin(1);
iduiwnet('comp',fig);
iduipoin(3);

%--------------------------------------------------------------------------
function LocalSubIdbuildwCallback3(fig)
iduipoin(1);
iduiwnet('setzoom',fig);
iduipoin(2);

% FILE END
