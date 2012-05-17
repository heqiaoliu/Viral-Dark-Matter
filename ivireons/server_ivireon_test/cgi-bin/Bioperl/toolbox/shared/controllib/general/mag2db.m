function ydb = mag2db(y)
%MAG2DB  Magnitude to dB conversion.
%
%   YDB = MAG2DB(Y) converts magnitude data Y into dB values.
%   Negative values of Y are mapped to NaN.
%
%   See also DB2MAG.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/22 04:19:26 $
y(y<0) = NaN;
ydb = 20*log10(y);
