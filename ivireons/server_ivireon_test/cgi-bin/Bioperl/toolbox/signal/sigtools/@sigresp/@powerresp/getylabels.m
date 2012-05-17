function ylabels = getylabels(this, eventData)
% GETYLABELS Method to get the list of strings to be used for the ylabels.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2008/05/31 23:28:33 $

if isempty(this.Spectrum)
    dataunits = '';
else
    dataunits = sprintf(' (%s)', this.Spectrum.Metadata.DataUnits);
end

if nargin > 1,
    nf = getsettings(getparameter(this, 'freqmode'), eventData);
else
    nf = get(this, 'NormalizedFrequency');
end

if strcmpi(nf, 'On')
    frequ = 'rad/sample';
    dataunits = strrep(dataunits, 'Hz', frequ);
else
    frequ = 'Hz';
end

lblStr = xlate('Power/frequency');
ylabels = {...
        sprintf('%s%s', lblStr, dataunits),...       %linear /Hz
        sprintf('%s (dB/%s)', lblStr, frequ), ...    %dB/Hz
        sprintf('%s%s (normalized to 1 %s)', lblStr, dataunits, frequ),... %linear (normalized to 1Hz)
        sprintf('%s (dB/%s) (normalized to 1 %s)', lblStr,frequ, frequ)};  %linear dB

% [EOF]
