function updateColorMap(this, hEye)
%UPDATECOLORMAP Update the color map of the eye diagram figure

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:41 $

% If plot type is not 2D line, update the color map
if strcmp(hEye.PlotType, '2D Color')
    % First set the current color map to default color map
    set(this.Parent, 'Colormap', hot(64));

    % Get the current setting
    pdfRange = hEye.PlotPDFRange;

    % Set to the same value to force update of the color map
    hEye.PlotPDFRange = pdfRange;
end

%-------------------------------------------------------------------------------
% [EOF]
