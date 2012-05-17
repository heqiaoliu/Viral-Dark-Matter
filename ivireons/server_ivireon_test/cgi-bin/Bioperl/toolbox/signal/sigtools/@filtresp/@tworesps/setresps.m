function out = setresps(this, out)
%SETRESPS

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2004/12/26 22:19:03 $

set(out, 'Filters', this.Filters, ...
    'PolyphaseView', this.PolyphaseView, ...
    'ShowReference', this.ShowReference, ...
    'SOSViewOpts',   this.SOSViewOpts);

out = twoanalyses_setresps(this, out);

% [EOF]
