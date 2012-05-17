function updateScaling(this)
%UPDATESCALING Update the scaling information for the axes and image.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/18 02:13:51 $

% user-specified range of values to map?
if this.UserRange
    % Scaled pixel interpretation
    clim = [this.UserRangeMin this.UserRangeMax];
    if ~isempty(this.conversionFcn),
        clim = double(this.conversionFcn(clim));
    end
    % Protect against invalid limits: is min >= max?
    if clim(2) <= clim(1)
        clim(2) = clim(1)+1;
    end
    cdm = 'scaled';
else
    % No user-range specified
    [clim, cdm] = getScaledDataRange(this);
end

hImage = this.Visual.Image;
hAxes  = this.Visual.Axes;
set(hImage, 'CDataMapping', cdm);
set(hAxes,  'CLim',         clim);
if ~isempty(hAxes)
    refresh(ancestor(hAxes, 'figure'));
end

% Send an event so that data can be reformatted if it needs to be by any
% data sources.
send(this, 'ScalingChanged');

% -------------------------------------------------------------------------
function [rng,cdm] = getScaledDataRange(this)

% Only used for Intensity mode, no user scaling
switch this.DisplayDataType
    case {'logical','boolean'}
        rng = [0 1];
        cdm = 'scaled';
    case {'double','single'}
        rng = [0 255];  % ignored for 'direct'
        cdm = 'direct';
    case 'uint16'
        rng = [0 65535];
        cdm = 'scaled';
    case 'uint8'
        rng = [0 255];
        cdm = 'direct';
    case {'int8','int16','int32','uint32'}
        rng = [0 255];
        cdm = 'scaled';
    otherwise
        % fixed-point, etc
        % treat as doubles, since this is what it comes in as
        rng = [0 255];
        cdm = 'direct';
end

% [EOF]
