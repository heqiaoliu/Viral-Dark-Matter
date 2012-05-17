function onNewData(this, source)
%ONNEWDATA

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:35 $

% source = this.Application.Source;

newData = this.DataObject;
rawData = getRawData(source, 1);
if isempty(rawData)
    this.screenMsg(uiscopes.message('emptyHistogramDataMessage'));
    update(this.HistogramInfo);
    return;
end

newData.FrameData = rawData;

% Get the histogram data.
this.HistData = histogramAnalysis(newData);
this.Counter = this.Counter+1;
this.MinBin = this.HistData.BinMin;
this.MaxBin = this.HistData.BinMax;

if (newData.isScaledDouble || newData.isFixedPoint)
    % we can flag the overflows and underflows in this case.
    % account for 0th bit
    this.MaxBin = newData.dataTypeObject.WordLength - newData.dataTypeObject.FractionLength - 1;
    this.MinBin = -newData.dataTypeObject.FractionLength;
end

min_bin = min(this.MinBin, this.HistData.BinMin);
max_bin = max(this.MaxBin, this.HistData.BinMax);

% if either bin values are NaN, return without doing anything.
if isnan(min_bin) || isnan(max_bin)
    this.screenMsg(uiscopes.message('emptyHistogramDataMessage'));
    return;
end
range = min_bin:max_bin;
% If min_bin > max_bin, return without updating the visual.
if isempty(range);
    this.screenMsg(uiscopes.message('emptyHistogramDataMessage'));
    return;
end

x = range;
% Capture the calculated histogram data into a ydata vector
% The X vector may be much longer than bimin-1:bmax+1. The data type
% of the variable can alter the range of x.
start_idx = find(x == this.HistData.BinMin);
ending_idx = find(x == this.HistData.BinMax);
if ~isempty(this.HistData.hist)
    % If the length of the bins is 1, we add a bin to the right and
    % left of it in HistogramData.histogramAnalysis() to get the
    % correct distribution from the hist() command. We need to account
    % for that here.
    if length(this.HistData.hist) > length(start_idx:ending_idx)
        % Since we have 3 co-ordinates to create a patch.
        y_re(start_idx:ending_idx) = this.HistData.hist(2);
    else
        y_re(start_idx:ending_idx) = this.HistData.hist;
    end
end

% Set axes X & Y limits
setupAxesLimits(this, range);

if this.Counter == 1
    % Indicate underflow
    [y_re_underflow, y_re_inrange] =  getUnderflowDataLine(this, x, y_re); %#ok
    
    % indicate overflow
    [y_re_overflow, y_re_inrange] =  getOverflowDataLine(this, x, y_re);
    
    [xdata_inrange, y_inrange] = getXYDataForPatch(x, y_re_inrange);
    [xdata_underflow, y_underflow] = getXYDataForPatch(x, y_re_underflow);
    [xdata_overflow,y_overflow] = getXYDataForPatch(x, y_re_overflow);
    
    % Plot data that is in range
    this.LineHandleRe(1) = patch('Parent',this.Axes,...
        'xdata',xdata_inrange,'ydata',y_inrange(:),...
        'FaceColor','b','Tag','WithinRangeGroup',...
        'visible','off');
    hold(this.Axes,'on');
    
    %Plot the underflow
    this.LineHandleRe(2) = patch('Parent',this.Axes,...
        'xdata',xdata_underflow,'ydata',y_underflow(:),...
        'FaceColor',[1 0.5 0],'Tag','UnderflowGroup',...
        'visible','off');
    
    %Plot the overflow
    this.LineHandleRe(3) = patch('Parent',this.Axes,...
        'xdata',xdata_overflow,'ydata',y_overflow(:),...
        'FaceColor','r','Tag','OverflowGroup',...
        'visible','off');
    
    %Set the title of the scope.
    title(this.Axes,getTitle(this),'Interpreter','none');
    
    set(this.Axes,'Visible','on');
    set(this.XTicktextObj(:),'Visible','On');
    set(this.xLabelTextObj,'Visible','On');
    set(this.LineHandleRe,'Visible','on');
    % Enable the ShowLegend widget in the View menu.
    hUI = this.Application.getGUI;
    set(hUI.findchild('Base/Menus/View/ShowLegend'),'Enable','On');
else
    % Indicate underflow
    [y_re_underflow, y_re_inrange] =  getUnderflowDataLine(this, x, y_re); %#ok
    
    % indicate overflow
    [y_re_overflow, y_re_inrange] =  getOverflowDataLine(this, x, y_re);
    
    [xdata_inrange, y_inrange] = getXYDataForPatch( x, y_re_inrange);
    [xdata_underflow, y_underflow] = getXYDataForPatch(x, y_re_underflow);
    [xdata_overflow, y_overflow] = getXYDataForPatch(x, y_re_overflow);
    
    set(this.LineHandleRe(1),'XData',xdata_inrange,'YData',y_inrange(:));
    set(this.LineHandleRe(2),'XData',xdata_underflow,'YData',y_underflow(:));
    set(this.LineHandleRe(3),'XData',xdata_overflow,'YData',y_overflow(:));
end
% Delete the legend before calling drawnow since it causes a huge slowdown.
if ishghandle(this.Legend)
    this.findProp('ShowLegend').Value = false;
    delete(this.Legend);
end
% Update Histogram Info
update(this.HistogramInfo);
% Just update graphics objects. Do not allow callbacks to execute and
% do not process other events in the queue
drawnow expose;


%-------------------------------------------------
function [undrflw_line, inrange_line] = getUnderflowDataLine(this, x, y_re)

% indicate underflow. The underflow line is from the minimum bin returned
% by the histogram upto the minimum bin resulting from the selected data
% type.
inrange_line = y_re;
undrflw_line = zeros(1,length(y_re));
if (this.MinBin > this.HistData.BinMin)
    idx_min_start = find(x==this.HistData.BinMin);
    idx_min_end = find(x==this.MinBin);
    idx_max_start = find(x==this.MaxBin);
    idx_max_end = find(x==this.HistData.BinMax);
    undrflw_line(idx_min_start(1):idx_min_end(1)-1) = y_re(idx_min_start(1):idx_min_end(1)-1);
    inrange_line = y_re;
    inrange_line(idx_min_start(1):idx_min_end(1)-1) = 0;
    inrange_line(idx_max_start(end)+1:idx_max_end(end)) = 0;
end
% calculate the percentage of underflows.
this.HistData.uflw = sum(undrflw_line);

%--------------------------------------------------
function [ovrflw_line, inrange_line] = getOverflowDataLine(this, x, y_re)

% indicate overflow. The overflow line is data from the maximum bin
% resulting from the selected data type upto the maximum bin returned by
% the histogram.
inrange_line = y_re;
ovrflw_line = zeros(1,length(y_re));
if (this.MaxBin < this.HistData.BinMax)
    idx_min_start = find(x==this.HistData.BinMin);
    idx_min_end = find(x==this.MinBin);
    idx_max_start = find(x==this.MaxBin);
    idx_max_end = find(x==this.HistData.BinMax);
    ovrflw_line(idx_max_start(end)+1:idx_max_end(end)) = y_re(idx_max_start(end)+1:idx_max_end(end));
    inrange_line = y_re;
    inrange_line(idx_min_start(1):idx_min_end(1)-1) = 0;
    inrange_line(idx_max_start(end)+1:idx_max_end(end)) = 0;
end
% calculate the percentage of overflows.
this.HistData.ovfl = sum(ovrflw_line);

%------------------------------------------------
function setupAxesLimits(this, range)

visualRange = [range(1)-0.5 range(1):range(end) range(end)+0.5];
set(this.Axes,'XLim',[visualRange(1) visualRange(end)]);

%-----------------------------------------------
function [xdata, ydata] = getXYDataForPatch(x, y)

binWidthForDisplay = 0.5;
halfBinWidthForDisplay = binWidthForDisplay/2;
xdata = zeros(4,length(x));
ydata = zeros(size(xdata));
for i=1:length(x)
    xdata(:,i) = x(i) + [-halfBinWidthForDisplay; -halfBinWidthForDisplay;...
        halfBinWidthForDisplay;halfBinWidthForDisplay];
end
% Initialize ydata vector
%ydata = zeros(size(xdata));
for i = 1:length(y)
    ydata([1 4],i) = 0;
    ydata([2 3],i) = y(i);
end

% [EOF]
