function Fs = set_fs(h,Fs)
%SETFS   

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:01:10 $
   
h.privFs = Fs;

% Unset NormalizedFrequency
h.NormalizedFrequency = false;

% Make Fs empty to not duplicate storage
Fs = [];

% [EOF]
