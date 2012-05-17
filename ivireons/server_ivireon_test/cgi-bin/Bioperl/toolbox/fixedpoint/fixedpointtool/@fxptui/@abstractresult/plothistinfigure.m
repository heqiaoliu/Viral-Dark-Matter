function plothistinfigure(h, varargin)
%PLOTHISTINFIGURE create and plot histogram for this results signal

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/05/20 02:18:14 $

isupdating = false;
if(nargin > 1)
	isupdating = varargin{1};
end

hfig = h.figures.get('plothistinfigure');
hfig = handle(hfig);
if(isempty(hfig))
  hfig = createfig(h);
  h.figures.put('plothistinfigure', double(hfig));
end

try
  figure(hfig);
  set(hfig, 'HandleVisibility', 'on');
  plothistogram(hfig, h);
  drawnow;
catch e %#ok
  hfig = h.figures.remove('plothistinfigure');
  delete(handle(hfig));
  fxptui.showdialog('histploterror');
  return;
end
if(~isupdating)
  set(hfig, 'Visible', 'on');
end
set(hfig, 'HandleVisibility', 'callback');

%--------------------------------------------------------------------------
function hfig = createfig(h)
scrsz = get(0,'ScreenSize');
hfig = figure( ...
  'Visible', 'off', ...
  'Position', [.64*scrsz(3) .58*scrsz(4) .25*scrsz(3) .25*scrsz(4)], ...
  'Name',  DAStudio.message('FixedPoint:fixedPointTool:plotTitleHistogram'), ...
  'IntegerHandle', 'off', ...
  'NumberTitle', 'off', ...
  'CloseRequestFcn', @(s,e)figureclose(s,e), ...
  'HandleVisibility','callback',...
  'Tag','FixedPointToolTSPlotFig');
set(hfig,'CloseRequestFcn', @(s,e)fxptui.figureclose(s,e,hfig));

%--------------------------------------------------------------------------
function plothistogram(hfig, h)
%cast raw data as double so embedded.fi won't error with log2
rawdata = double(h.Signal.Data(:));
numsamples = numel(rawdata);
%get the log2(rawdata) handling warnings
[log2data numzeros] = getlog2data(rawdata);
percentzeros = 100*numzeros/numsamples;
%get axes, xlabels, ylabels
haxes = getaxes(hfig, h, numsamples);
if(percentzeros < 100)
  %get the xdata and the xata3(used to plot a line that looks like a bar)
  [xdata, xdata3] = getxdata(log2data);
  %get the normalized histogram
  histdata = hist(log2data, xdata)/numel(log2data);
  %get ydata and yscaling data (hack to scale the data without hardcoding YLim)
  [ydata, yscale] = getydata(xdata3, histdata);
  semilogy(haxes, xdata3, ydata, 'LineWidth', 3, 'XLimInclude', 'off', 'YLimInclude', 'off');
  line('XData', xdata3, 'YData', yscale, 'LineStyle', 'none');
end
setannotation(hfig, percentzeros);
zoom reset;


%--------------------------------------------------------------------------
function haxes = getaxes(hfig, h, numsamples, numzeros)
%get axes
haxes = findall(hfig,'Tag','axes');
if(isempty(haxes))
  haxes = axes('Parent', hfig, 'NextPlot', 'add', 'Tag', 'axes');
end
%clear axes
cla(haxes);
%add title
htitle = get(haxes, 'Title');
set(htitle, 'Interpreter', 'none', 'fontweight','b', 'Tag', 'title');
plottitle = h.getplottitle;
set(htitle, 'String', [plottitle ' (' h.Run ')']);
%set axes labels and tags (for testing)
hxlabel = get(haxes, 'XLabel');
xlabeltxt = DAStudio.message('FixedPoint:fixedPointTool:xlabelHistogram');
set(hxlabel, 'String', xlabeltxt, 'Tag', 'xlabel');
hylabel = get(haxes, 'YLabel');
set(hylabel, 'String', DAStudio.message('FixedPoint:fixedPointTool:ylabelOccurrences', num2str(numsamples)), 'Tag', 'ylabel');
set(haxes, 'YScale', 'log');
%add ytick listener for (change the labels when zooming/panning)
addlistener(haxes, 'YTick', 'PostSet', @(s,ed)updateaxes(haxes));

%--------------------------------------------------------------------------
function [xdata, xdata3] = getxdata(log2data)
%when we took the log all zeros were converted to -Inf
mindata = log2data(find(log2data ~= -Inf, 1));
maxdata = log2data(end);
if(isempty(mindata))
  mindata = 0;
end
if(isequal(maxdata, -Inf))
  maxdata = 0;
end
xdata = mindata-5:maxdata+5;
xdata3 = [xdata; xdata; xdata];
xdata3 = xdata3(:).';

%--------------------------------------------------------------------------
function [ydata, yscale] = getydata(xdata3, histdata)
ydata = eps(ones(1, length(xdata3)));
ydata(2:3:end) = histdata;
yscale = ones(1, length(xdata3));
msk = histdata ~= 0;
ymin = min(histdata(msk));
yscale(1) = ymin; yscale(end) = 1;

%--------------------------------------------------------------------------
function setannotation(hfig, numzeros)
%find annotation if it already exists and toss it
hanno = findall(hfig,'Tag','annotation');
if(ishandle(hanno))
  delete(hanno);
end
%don't display any text if there are no zeros
if(numzeros==0); return; end
str = DAStudio.message('FixedPoint:fixedPointTool:labelExactZeros',...
  sprintf('%0.3g', numzeros));
hanno = text( ....
  .025, .895, str,...
  'String', str, ...
  'BackgroundColor', 'white', ...
  'Margin',5, ...
  'EdgeColor', 'black', ...
  'Units', 'normalized', ...
  'Tag', 'annotation' ...
  );

%--------------------------------------------------------------------------
function updateaxes(haxes)
%make sure we have valid axes handles
if(~ishandle(haxes)); return; end
ytick = get(haxes, 'YTick');
if(isempty(ytick)); return; end
yticklabel = ytick*100;
set(haxes, 'YTickLabel', yticklabel);

%--------------------------------------------------------------------------
function [log2data numzeros] = getlog2data(rawdata)
withzeros = numel(rawdata);
%scale the data by log2
rawdata(rawdata==0) = [];
withoutzeros = numel(rawdata);
numzeros = withzeros - withoutzeros;
log2data = sort(ceil(log2(abs(rawdata))));

% [EOF]
