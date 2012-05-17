function xLim = calculateXLim(this)
%CALCULATEXLIM Calculate the XLimits for 'auto display'.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:41:14 $

nBuffers = this.DisplayBuffer;

% Use the cached SamplesPerFrame to determine the size of the buffers.
% This is set whenever the source changes.
lBuffer = this.SamplesPerFrame;

nSamples = nBuffers*lBuffer;

% We need to calculate what will happen based on the frame rate.  This math
% is already done in calculateXData.
xData = calculateXData(this, nSamples);
switch numel(xData)
    case 0
        xLim = [0 1];
    case 1
        xLim = xData + [-1 1];
    otherwise
        xLim = [xData(1) xData(end)];
end

% If the visual uses engineering units perform the conversion.
if any(isnan(xLim))
    xLim = [0 1];
    m = 1;
    u = '';
elseif this.UsesEngineeringUnits
    [xLim, m, u] = engunits(xLim);
else
    m = 1;
    u = '';
end

this.Units = u;

oldMultiplier = this.Multiplier;
this.Multiplier = m;

% If we are going to a new multiplier, update any existing lines.
if oldMultiplier ~= m
    % Change the XData
    convertAmount = m/oldMultiplier;
    for indx = 1:numel(this.Lines)
        set(this.Lines(indx), 'XData', convertAmount*get(this.Lines(indx), 'XData'));
    end
end


% [EOF]
