function minfo = measureinfo(this)
%MEASUREINFO   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:28:30 $

minfo.Fstop1 = [];
minfo.Fcutoff1 = this.F3db1;
minfo.Fpass1 = [];
minfo.Fpass2 = [];
minfo.Fcutoff2 = this.F3db2;
minfo.Fstop2 = [];
minfo.Astop1 = this.Astop1;
minfo.Apass  = this.Apass;
minfo.Astop2 = this.Astop2;

% [EOF]
