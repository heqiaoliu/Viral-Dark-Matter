function minfo = measureinfo(this)
%MEASUREINFO   Return a structure of information for the measurements.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:34:22 $

minfo.Fpass = this.Fpass;
minfo.Fstop = this.Fstop;
minfo.Apass = this.Apass;
minfo.Astop = this.Astop;

% [EOF]
