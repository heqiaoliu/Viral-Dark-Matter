function info = qtoolinfo(this)
%QTOOLINFO   Return the information for the qtool.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:03:51 $

info = iir_qtoolinfo(this);

info.output.setops  = {'AutoscaleAvailable', 'Off'};
info.output.syncops = [];

info.state.setops  = {'FracLabels', {'State'}, 'AutoScaleAvailable', 'On'};
info.state.syncops = [];

% [EOF]
