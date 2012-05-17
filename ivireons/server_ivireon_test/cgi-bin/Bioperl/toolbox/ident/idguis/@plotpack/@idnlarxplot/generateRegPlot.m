function generateRegPlot(this,isNew,retainRegNames)
% Generate a new regressor plot or update data for existing one.
% Do so only for currently selected output.
% retainRegNames: try to retain (default) or not selections in reg combo
% boxes 

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/10/16 04:56:21 $

if nargin<3
    retainRegNames = true;
end

%disp('CALLED')
set(this.Figure,'units','char'); %g334994
if isNew
    this.createNewPlotPanel; %create a new panel
    this.refreshControlPanel(retainRegNames);
end

thisy = this.getCurrentOutput;
Ind = this.Current.OutputComboValue;

if isNew
    panel = this.MainPanels(end);
    if Ind==1 && ~this.isGUI
        % multiple plots
        %localGeneratePlots(this,this.OutputNames,panel,isNew);
        ynames = this.OutputNames;
        n = length(ynames);
        ncol = round(sqrt(n));
        nrow = ceil(n/ncol);

        for k = 1:n
            axk = subplot(nrow,ncol,min(nrow*ncol,k),'parent',panel);
            robjk = find(this.RegressorData,'OutputName',ynames{k});
            localFillPlot(this,axk,robjk);
            set(axk,'ButtonDownFcn',@(es,ed)localAxesButtonDownFcn(this,ynames{k}));
            localDecorateAxes(axk,panel,robjk,this);
            if n>1
               legend(axk,'off');
            end
        end
    else
        % generate plot for current output only
        ax = subplot(1,1,1,'parent',panel);
        robj = find(this.RegressorData,'OutputName',thisy);
        localFillPlot(this,ax,robj);
        localDecorateAxes(ax,panel,robj,this);
    end
else
    % update existing plot (such as "apply" button callback)
    multitag = 'fake';
    if ~this.isGUI
        % plot may exist on two panels for current output
        strs = this.getOutputComboString;
        multitag = sprintf('%s:multi',strs{1});
        panels = findobj(this.MainPanels,'type','uipanel','tag',multitag);
        singlepanel = findobj(this.MainPanels,'type','uipanel','tag',thisy);
        if ~isempty(singlepanel) && ishandle(singlepanel)
            panels(2) = singlepanel;
        end
    else
        % in gui, there will be one panel only
        panels = findobj(this.MainPanels,'type','uipanel','tag',thisy);
    end
    robj = find(this.RegressorData,'OutputName',thisy);
    ax = findobj(panels,'type','axes','tag',thisy);
   
    localFillPlot(this,ax,robj);
    localDecorateAxes(ax,panels,robj,this);
    
    if strcmp(get(panels(1),'tag'),multitag)
        set(ax(1),'ButtonDownFcn',@(es,ed)localAxesButtonDownFcn(this,thisy));
        legend(ax(1),'off');
    end
    %get(get(ax(1),'parent'),'tag')
end
localSetGridZoomRotateModes(this);

%--------------------------------------------------------------------------
function  localFillPlot(this,ax,robj)
% create plots for outputs ynames

for k = 1:length(ax)
    sz = get(ax(k),'pos'); %G573460
    delete(allchild(ax(k)))
    set(ax(k),'pos',sz);
    %hold(ax(k),'off')
    %set(ax(k),'nextplot','replacechildren')
end

%yname = robj.OutputName;
availablemodels = robj.ModelNames;
for i = 1:length(availablemodels)
    h = find(this.ModelData,'ModelName',availablemodels{i});
    st = this.utPlot(ax,h,robj);
    if ~st
        continue;
    end
    for k = 1:length(ax)
        hold(ax(k),'on')
        %set(ax(k),'nextplot','add')
    end
end %i (models)

for k = 1:length(ax)
    hold(ax(k),'off')
    %set(ax(k),'nextplot','add')
end

%{
for k = 1:length(ax)
    if isempty(findobj(get(ax(k),'children'),'vis','on'))
        x1 = get(ax(k),'xlim');
        y1 = get(ax(k),'ylim');
        z1 = get(ax(k),'zlim');
        text('parent',ax(k),'pos',[x1(1),y1(2),mean(z1)],...
            'string','  No active models for selected regressors.','tag','idnlarxplot:noactivemodelstag');
    else
        delete(findobj(ax(k),'type','text','tag','idnlarxplot:noactivemodelstag'))
    end
end
%}

%--------------------------------------------------------------------------
function localAxesButtonDownFcn(this,str)
% axis button down only when showing multiple axes

if strcmp(this.Current.MultiOutputAxesTag,str)
    return;
else
    this.Current.MultiOutputAxesTag = str;
    retainRegNames = false;
    this.refreshControlPanel(retainRegNames);
    %this.showPlot;
end

%--------------------------------------------------------------------------
function localSetGridZoomRotateModes(this)
% set zoom, rotate3D and zoom modes based upon the file menu selections in
% the GUI

if ~this.isGUI
    return;
end

allaxes = this.getAllAxes;
%allaxes = findall(this.MainPanels,'type','axes');
ui = findall(this.Figure,'type','uimenu','label','&Style');

onoff = get(findobj(get(ui,'Children'),'label','&Grid'),'checked');
set(allaxes,'xgrid',onoff,'ygrid',onoff,'zgrid',onoff);

onoff = get(findobj(get(ui,'Children'),'label','&Zoom'),'checked');
zoom(this.Figure,onoff);

onoff = get(findobj(get(ui,'Children'),'label','&Rotate 3D'),'checked');
rotate3d(this.Figure,onoff);

%--------------------------------------------------------------------------
function localDecorateAxes(ax,parent,robj,this)

yname = robj.OutputName;
for k = 1:length(ax)
    axk = ax(k);
    xlabel(axk,'Reg 1')
    title(axk,sprintf('Output:%s',yname))

    if ~robj.is2D
        ylabel(axk,'Reg 2')
        zlabel(axk,'Nonlin')
        setAllowAxesRotate(rotate3d(this.Figure),axk,true);
    else
        ylabel(axk,'Nonlin')
        setAllowAxesRotate(rotate3d(this.Figure),axk,false);
    end

    set(axk,'parent',parent(k),'tag',yname);
    this.addLegend(axk,robj.is2D); 
end

