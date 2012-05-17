function Fs = setfs(h,Fs)
%SETFS   

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:11:11 $

if Fs == 0,
    error(generatemsgid('invalidSpec'),'Sampling frequency cannot be zero.');
end

if h.NormalizedFrequency,
    error(...
        generatemsgid('readonly'),...
        sprintf('Changing the ''Fs'' property when NormalizedFrequency is true is not allowed.\n Use normalizefreq(h,false,Fs) which updates other properties accordingly.'));        
end

h.privFs = Fs;

% Make Fs empty to not duplicate storage
Fs = [];

% [EOF]
