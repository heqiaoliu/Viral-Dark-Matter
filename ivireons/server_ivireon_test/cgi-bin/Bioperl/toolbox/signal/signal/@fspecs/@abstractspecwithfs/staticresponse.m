function staticresponse(this, hax, magunits)
%STATICRESPONSE   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:11:14 $

if this.NormalizedFrequency,
    frequnits = 'normalized (0 to 1)';
else
    frequnits = 'Hz';
end

staticrespengine('setupaxis', hax, frequnits, magunits);

% Allow subclasses to add annotations.
thisstaticresponse(this, hax);

% [EOF]
