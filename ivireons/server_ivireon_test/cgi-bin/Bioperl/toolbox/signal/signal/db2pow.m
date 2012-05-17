function y = db2pow(ydB)
%DB2POW   dB to Power conversion
%   Y = DB2POW(YDB) converts dB to its corresponding power value such that
%   10*log10(Y)=YDB

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2007/11/17 22:43:56 $

y = 10.^(ydB/10);

% [EOF]