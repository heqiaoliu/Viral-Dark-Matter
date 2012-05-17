function minfo = measureinfo(this)
%MEASUREINFO   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:28:36 $

minfo.Fstop1 = [];
minfo.Fcutoff1 = this.F3dB1;
minfo.Fpass1 = [];
minfo.Fpass2 = [];
minfo.Fcutoff2 = this.F3dB2;
minfo.Fstop2 = [];
minfo.Astop1 = this.Astop;
minfo.Apass  = [];
minfo.Astop2 = this.Astop;

% [EOF]
