function plotdiffinfigure(this, arg)
%PLOTDIFFINFIGURE plot RESULTS signals and the difference between them

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2010/05/20 02:18:13 $

isupdating = false;
% make the active and reference variables persistent to improve performance.
persistent active;
persistent reference;
if(isa(arg, 'fxptui.abstractresult'))
  that = arg;
else
  that = handle(this.propertybag.get('that'));
  isupdating = arg;
end
results = [this that];
if(isempty(this.Signal) || isempty(that.Signal))
  hfig = this.figures.remove('plotdiffinfigure');
  hfig = that.figures.remove('plotdiffinfigure');
  delete(handle(hfig));
  return;
end
%get figure handle
hfig = this.figures.get('plotdiffinfigure');
hfig = handle(hfig);

if(isempty(hfig)) || ~ishghandle(hfig)
  hfig = createfig(this);
  this.figures.put('plotdiffinfigure', double(hfig));
  this.propertybag.put('that', that);
  that.figures.put('plotdiffinfigure', double(hfig));
  that.propertybag.put('that', this);
elseif isempty(that.figures.get('plotdiffinfigure'))
    that.figures.put('plotdiffinfigure', double(hfig));
end

%try to plot difference. if an error occurs show errordlg
try
    %plot active and reference on top axes. Create the right hand axis first, so that it is below the 
    % left axis on which the data is plotted. This enables the zoom & other tools to work correctly.
    haxes1R = subplot(2,1,1,'Parent', hfig,'YAxisLocation','Right');
    haxes1L = axes('Position',get(haxes1R,'Position'),'Parent',get(haxes1R,'Parent'));
    %plot the selected signals
    cla(haxes1L);
    ts1 = this.Signal;
    ts2 = that.Signal;
    % Set the Events to [] to prevent them from being plotted along with
    % the data. A change has been introduce in plotting to plot any event
    % data. Since we do not want this, set the Event to []. The unified
    % data logging will not populate this field in the future and the below
    % code can be removed at that point.
    ts1.Events = [];
    ts2.Events =  [];
    %timeseries seems to reset the ColorOrder between calls to plot
    plot(ts1,'LineStyle','-','Parent',haxes1L);
    hold(haxes1L, 'on');
    numlines = numel(get(haxes1L, 'Children'));
    thislegend = {};
    if isempty(active)
        active = DAStudio.message('FixedPoint:fixedPointTool:labelActive');
    end
    if isempty(reference)
        reference = DAStudio.message('FixedPoint:fixedPointTool:labelReference');
    end
    defaultlegend = {active, reference};
    if(numlines == 1)
        thislegend = defaultlegend;
    end
    %index the legend if there is more than one line
    if(numlines > 1)
        for r = 1:numel(defaultlegend)
            for i = 1:numlines
                thisString = [defaultlegend{r} num2str(i)];
                thislegend = [thislegend thisString];
            end
        end
    end
    plot(ts2,'LineStyle',':','Parent',haxes1L);
    %add legend
    legend(haxes1L,thislegend, 'Location', 'Best', 'Tag', 'legend');
    set(haxes1L, ...
        'HitTest', 'on', ...
        'Box','on',...
        'Tag', 'axes1L');
    set(haxes1R, ...
        'XTickLabel', [], ...
        'YTickLabelMode', 'manual', ...
        'Tag', 'axes1R');

    addlistener(haxes1L, 'YTick', 'PostSet', @(s,ed)updateaxes(haxes1L, haxes1R, results));
    link1 = linkprop([haxes1L,haxes1R],{'Position','YLim','CameraUpVector'});
    % Save the link so that it doesn't go out of scope when the function
    % returns. If the link goes out of scope it destroys the link.
    setappdata(hfig,'linkprop1',link1);
    %add title
    plottitle = this.getplottitle;
    htitle = get(haxes1L, 'Title');
    set(htitle, ...
        'Interpreter', 'none', ...
        'Tag', 'title1', ...
        'String', plottitle);
    %leave a space at the end so xlate sees 1 word
    xlbl = DAStudio.message('FixedPoint:fixedPointTool:xlabelTime');
    ylbl = DAStudio.message('FixedPoint:fixedPointTool:ylabelRealWorldValue');
    if(isfield(ts1.DataInfo.UserData, 'isindexed') && ts1.DataInfo.UserData.isindexed)
        %leave a space at the end so xlate sees 1 word
        xlbl = DAStudio.message('FixedPoint:fixedPointTool:xlabelIndex');
    end
    hxlabel = get(haxes1L, 'XLabel');
    set(hxlabel, 'String', xlbl, 'Tag', 'xlabel1');
    hylabel = get(haxes1L, 'YLabel');
    set(hylabel, 'String', ylbl, 'Tag', 'ylabel1L');
    hylabel = get(haxes1R, 'YLabel');
    set(hylabel, 'Tag', 'ylabel1R');

    %synchronize the timeseries if they are of different length prior to
    %taking the difference. use the ts.Value method to return copy of the
    %timeseries. otherwise the originals will be modified (merged onto the
    %same time axis
    [ts1_,ts2_] = synchronize(ts1.tsValue, ts2.tsValue, 'union');
    tsdiff = ts1_- ts2_;
    %Multi-D data
    if(ndims(tsdiff.Data) > 2)
        %make time the first dimension
        tsdiff = tsdiff';
        %flatten the remaining dimensions into one
        tsdiff.Data = tsdiff.Data(:,:);
    end
    %plot difference on bottom axes. Create the right hand axis first, so that it is below the 
    % left axis on which the data is plotted. This enables the zoom & other tools to work correctly
    haxes2R = subplot(2,1,2,'Parent', hfig,'YAxisLocation','Right');
    haxes2L = axes('Position',get(haxes2R,'Position'),...
                   'Parent',get(haxes2R,'Parent'));
    % make haxes2L the current axes on the figure.
    set(hfig,'CurrentAxes',haxes2L);
    % clear current axes
    cla(haxes2L);
    %plot the difference
    plot(tsdiff.Time, tsdiff.Data,'Parent',haxes2L); 
    
    thislegend = {};
    %add a legend if there is more than one line
    if(numlines > 1)
        for i = 1:numlines
            thisString = ['Difference' num2str(i)];
            thislegend = [thislegend thisString];
        end
        legend(haxes2L,thislegend, 'Location', 'Best');
    end
    set(haxes2L, ...
        'HitTest', 'on', ...
        'Tag', 'axes2L'...
        );
    set(haxes2R, ...
        'XTickLabel', [], ...
        'YTickLabelMode', 'manual', ...
        'Tag', 'axes2R');
    addlistener(haxes2L, 'YTick', 'PostSet', @(s,ed)updateaxes(haxes2L, haxes2R, results));
    link2 = linkprop([haxes2L,haxes2R],{'Position','YLim','CameraUpVector'});
    % Save the link so that it doesn't go out of scope when the function
    % returns. If the link goes out of scope it destroys the link.
    setappdata(hfig,'linkprop2',link2);

    % Link all axes together for synchronized zooming.
    linkaxes([haxes1L haxes1R haxes2L haxes2R],'x');
    
    hxlabel = get(haxes2L, 'XLabel');
    set(hxlabel, 'String', xlbl, 'Tag', 'xlabel2');
    hylabel = get(haxes2L, 'YLabel');
    set(hylabel, 'String', ylbl, 'Tag', 'ylabel2L');
    hylabel = get(haxes2R, 'YLabel');
    set(hylabel, 'Tag', 'ylabel2R');
    
    %add title
    htitle = get(haxes2L, 'Title');
    title =   DAStudio.message('FixedPoint:fixedPointTool:labelDifferencePlot');
    set(htitle, ...
        'Interpreter', 'none', ...
        'Tag', 'title2', ...
        'String', title);
    set(hfig, 'Visible', 'on');
    drawnow;
catch e
    hfig = this.figures.remove('fxptui.cb_plotdiffinfigure');
    delete(hfig);
    fxptui.showdialog('diffploterror');
    return;
end

if(~isupdating)
    set(hfig, 'Visible', 'on')
end
set(hfig, 'HandleVisibility', 'callback');

%--------------------------------------------------------------------------
function hfig = createfig(this)
scrsz = get(0,'ScreenSize');
pos = [0.5*scrsz(3) 0.5*scrsz(4) 0.5*scrsz(3)-50 0.5*scrsz(4)-50];
hfig = figure( ...
    'Visible', 'off', ...
    'Name',  DAStudio.message('FixedPoint:fixedPointTool:plotTitleTimeSeriesDiff'), ...
    'IntegerHandle', 'off', ...
    'NumberTitle', 'off', ...
    'ActivePositionProperty','OuterPosition',...
    'OuterPosition', pos , ...
    'HandleVisibility','callback',...
    'Tag','FixedPointToolTSPlotFig');
set(hfig,'CloseRequestFcn', @(s,e)fxptui.figureclose(s,e,hfig));

%--------------------------------------------------------------------------
function updateaxes(haxesL, haxesR, results)
%make sure we have valid axes handles
if(~ishandle(haxesL) || ~ishandle(haxesR)); return; end
%get right ylabel and fraction length from results
[right_ylbl, fl] = getrightylabel_and_fl(results);
%label right yaxis
hylabel = get(haxesR, 'YLabel');
set(hylabel, 'String', right_ylbl);
ytickL = get(haxesL, 'YTick');
if(isempty(ytickL) || isempty(fl)); return; end
ytickR = ytickL./2^-fl;
ytick_R(1:length(ytickR)) = {''};
for i = 1:length(ytickR)
    ytick_R{i} = sprintf('%4.3g',ytickR(i));
end
set(haxesR, 'YTickLabel', ytick_R);

%--------------------------------------------------------------------------
function [lbl, fl] = getrightylabel_and_fl(results)

lbl =  DAStudio.message('FixedPoint:fixedPointTool:ylabelIndeterminate');
fl = [];
fl1 = getfractionlength(results(1));
if(numel(results) > 1)
    fl2 = getfractionlength(results(2));
else
    fl2 = [];
end
%one result has a fixdt
if(~isempty(fl1) && isempty(fl2))
    fl = fl1;
end
%one result has a fixdt
if(~isempty(fl2) && isempty(fl1))
    fl = fl2;
end
%both results have fixdt and they are equal
if(~isempty(fl2) && ~isempty(fl1))
    if(isequal(fl1, fl2))
        fl = fl1;
    end
end
%a use-able fraction length was obtained
if(~isempty(fl))
    lbl = DAStudio.message('FixedPoint:fixedPointTool:ylabelIntegerValue');
end

%--------------------------------------------------------------------------
function fl = getfractionlength(result)
fl = [];
dtstr = java.lang.String(result.SimDT);
idx = dtstr.lastIndexOf('fixdt');
if(idx >= 0)
    dtstr = char(dtstr.substring(idx));
    dt = eval(dtstr);
    fl = dt.FractionLength;
end

%--------------------------------------------------------------------------
% [EOF]
