function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:31:30 $

TWn = this.TransitionWidth/2;
specs.Fstop = 1-TWn;
specs.Fpass = TWn;
specs.Apass = this.Apass;
specs.Astop = nan;

% [EOF]
