function info = qtoolinfo(this)
%QTOOLINFO   Return the information needed by the qtool.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:53:48 $

info = iir_qtoolinfo(this);

info.output.setops  = {'AutoscaleAvailable', 'Off'};
info.output.syncops = [];

% [EOF]
