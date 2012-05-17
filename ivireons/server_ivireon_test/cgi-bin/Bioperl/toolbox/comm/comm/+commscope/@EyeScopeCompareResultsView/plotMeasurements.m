function plotMeasurements(this, data, legendLabels, yLabels)
%plotMeasurements Plot the measurements comparison lines

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:52:10 $

hAxes = this.WidgetHandles.Axes;

[numObjs numLines] = size(data);
numLines = numLines - 1;

colors = lines(7);
numColors = size(colors, 1);
colorCnt = 0;

for p=2:numLines+1
    if strfind(legendLabels{p}, '(Q)')
        style.LineStyle = ':';
        % Make the I and Q same color
        colorCnt = colorCnt - 1;
    else
        style.LineStyle = '-';
    end
    style.Color = colors(mod(colorCnt,numColors)+1, :);
    addLine(hAxes, 1:numObjs, [data{:, p}], yLabels{p}, style, legendLabels{p});
    colorCnt = colorCnt + 1;
end
%-------------------------------------------------------------------------------
% [EOF]
