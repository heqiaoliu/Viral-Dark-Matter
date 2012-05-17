function datainputs = getdatainputs(this)
%GETDATAINPUTS   Returns the inputs to GETDATA

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/08/24 15:07:42 $

datainputs{1} = false;  % Is density selected in ylabel?
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
datainputs{5} = centerdc; 

% [EOF]
