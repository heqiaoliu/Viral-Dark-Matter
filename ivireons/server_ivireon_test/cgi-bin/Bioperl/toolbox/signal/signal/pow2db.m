function ydB = pow2db(y)
%POW2DB   Power to dB conversion
%   YDB = POW2DB(Y) convert the data Y into its corresponding dB value YDB

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2008/02/20 01:23:11 $

if ~any(y<0)
    %ydB = 10*log10(y);
    ydB = db(y,'power');
else
    error(generatemsgid('InvalidInput'),'The power value must be non-negative');
end


% [EOF]
