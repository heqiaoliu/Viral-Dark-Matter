function datainputs = getdatainputs(this)
%GETDATAINPUTS   Returns the inputs to GETDATA

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/08/24 15:07:43 $

datainputs{1} = isempty(strfind(this.MagnitudeDisplay, 'normalized '));
datainputs{2} = ~isempty(strfind(this.MagnitudeDisplay, 'dB'));
datainputs{3} = strcmpi(this.NormalizedFrequency, 'on');

freqopts = lower(getfreqrangeopts(this));

centerdc = false;
switch lower(this.FrequencyRange)
    case freqopts{1}
        datainputs{4} = 'half';
    
    case freqopts{2}
        datainputs{4} = 'whole';

    case freqopts{3}
        datainputs{4} = 'whole';
        centerdc = true;
end
datainputs{5} = true; % centerdc
        
% [EOF]
