function minfo = measureinfo(this)
%MEASUREINFO   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:36:27 $

minfo.Fstop1 = [];
minfo.Fcutoff1 = this.Fcutoff1;
minfo.Fpass1 = [];
minfo.Fpass2 = [];
minfo.Fcutoff2 = this.Fcutoff2;
minfo.Fstop2 = [];
minfo.Astop1 = this.Astop1;
minfo.Apass  = this.Apass;
minfo.Astop2 = this.Astop2;

% [EOF]
