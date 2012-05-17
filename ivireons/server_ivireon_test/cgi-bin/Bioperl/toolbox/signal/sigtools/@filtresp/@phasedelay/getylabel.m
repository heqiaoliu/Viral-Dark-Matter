function str = getylabel(this)
%GETYLABEL Returns the string to be used on the Y Label

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:20:42 $

units = lower(get(this, 'PhaseUnits'));

if strcmpi(this.NormalizedFrequency, 'On')
    if strcmpi(units, 'degrees')
        units = sprintf('%s/(radians per sample)', units);
%         units = '{\times\pi}/180 samples';
    else % must be radians
        units = 'samples';
    end
else
    units = sprintf('%s/Hz', xlate(units));
%     units = sprintf('%s/%s', xlate(units), this.FrequencyUnits);
end

str = sprintf('Phase Delay (%s)', units);

% [EOF]
