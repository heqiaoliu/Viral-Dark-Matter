function Fs = set_fs(h,Fs)
%SETFS   

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:20:32 $
   
h.privFs = Fs;

% Unset NormalizedFrequency
h.NormalizedFrequency = false;

% Make Fs empty to not duplicate storage
Fs = [];

% [EOF]
