function updateHistBarPlot(ntx)
% Update histogram bars based on current histogram data
% Updates bar heights, x-tick labels, and sign line on bars

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1.2.1 $     $Date: 2010/07/06 14:39:19 $

% Create y-data for visualization of histogram bar as a patch
% Get bin counts for display
[posVal,negVal] = getBarData(ntx);

% Choose what to display in the histogram bars
% plot total (pos+neg) histogram
barVal = posVal+negVal;
N = numel(barVal);
yp = [zeros(1,N); barVal; barVal; zeros(1,N)];

% Create x-data
% No need to set cdata, since it gets overwritten in later call to
% updateBarThreshColor in this function.
[xp,zp,xl,zl] = embedded.ntxui.NTX.createXBarData(ntx.BinEdges,ntx.HistBarWidth, ntx.HistBarOffset);
set(ntx.hBar,'xdata',xp,'ydata',yp,'zdata',zp);

% Sign line data
% Show Neg bin counts
%
% Use NaN's to separate line segments, then put into a column vector
yl = [negVal;negVal;nan(1,N)];
set(ntx.hlSignLine,'vis','on', ...
    'xdata',xl,'ydata',yl(:),'zdata',zl);
