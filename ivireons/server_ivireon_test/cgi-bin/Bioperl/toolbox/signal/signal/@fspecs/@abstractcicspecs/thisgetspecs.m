function specs = thisgetspecs(this)
%THISGETSPECS   Get specifications.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:26:29 $

specs.Fpass  = this.Fpass;
specs.Fstop = nan;
specs.Apass = nan;
specs.Astop = this.Astop;

% [EOF]
