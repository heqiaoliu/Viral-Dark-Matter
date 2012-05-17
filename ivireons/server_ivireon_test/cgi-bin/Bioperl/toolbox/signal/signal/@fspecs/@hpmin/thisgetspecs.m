function specs = thisgetspecs(this)
%THISGETSPECS   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:01:25 $

specs.Fstop = this.Fstop;
specs.Fpass = this.Fpass;
specs.Astop = this.Astop;
specs.Apass = this.Apass;

% specs.stopband.frequency = [0 this.Fstop];
% specs.stopband.astop     = this.Astop;
% 
% specs.passband.frequency = [this.Fpass 1];
% specs.passband.apass     = this.Apass;

% [EOF]
