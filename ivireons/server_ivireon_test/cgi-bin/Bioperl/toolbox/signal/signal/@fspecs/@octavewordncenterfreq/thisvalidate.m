function [isvalid, errmsg, msgid] = thisvalidate(this)
%VALIDATE   Validate the specs

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:45:20 $

isvalid = true;
errmsg  = '';
msgid   = '';

F0 = this.F0;
Fs = this.Fs;

if this.NormalizedFrequency,
     msg = sprintf('%s\n%s',...
         'When the ''NormalizedFrequency'' property is true, a sampling frequency of 48kHz is assumed.',...
         'Use the ''normalizefreq'' method to control the value of the sampling frequency.');
     warning(generatemsgid('NormalizedFrequency'), msg);
    Fs = 48000;
    F0 = F0*Fs/2;
end

validFreq = this.getvalidcenterfrequencies;
if isempty(find(F0 == validFreq)),
    [dummy, idx] = min(abs(F0-validFreq));
    if this.NormalizedFrequency,
        F0 = validFreq(idx)/Fs*2;
        validfstr = num2str(validFreq/Fs*2);
    else
        F0 = validFreq(idx);
        validfstr = num2str(round(100*validFreq)/100);
    end
    this.F0 = F0;
    msg = sprintf('%s\n%s\n%s','Valid values for the ''F0'' property are :', ...
       validfstr, ...
       ['The ''F0'' value is rounded to ', num2str(F0), '.']);
    warning(generatemsgid('InvalidF0'), msg);
end    
% [EOF]
