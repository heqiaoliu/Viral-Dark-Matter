function Tb = emlGetBestPrecForMxArray(Bmx,Ta)
%emlGetBestPrecForMxArray  Get best-precision numerictype for builtin array input
%   emlGetBestPrecForMxArray(B,T) returns a numerictype object with
%   best-precision fraction length, keeping all other parameters of numerictype
%   object T the same.
%
%   Example:
%     T  = numerictype;
%     B  = magic(4);
%     Tb = emlGetBestPrecForMxArray(B,T)

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/10 02:20:57 $
error(nargchk(2,2,nargin,'struct'));
Tb = embedded.fi.GetBestPrecisionForMxArray(Bmx,Ta);