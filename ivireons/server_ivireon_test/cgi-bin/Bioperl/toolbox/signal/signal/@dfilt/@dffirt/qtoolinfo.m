function info = qtoolinfo(this)
%QTOOLINFO   Returns information for the QTool.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:04:53 $

% The first coefficient is the Word Length string. The second is the
% fractional length string.
info.normalize = 'numerator';

info.coeff.setops  = {'Name', 'Numerator', 'FracLabels', {'Numerator'}};
info.coeff.syncops = {'Num'};

info.product.setops  = {'FracLabels', {'Product'}};
info.product.syncops = {'Product'}; % Syncs the defaults.

info.accum.setops  = {'FracLabels', {'Accum.'}};
info.accum.syncops = {'Accum'};

info.output.setops = {'AutoScaleAvailable', 'Off'};

% info.state.setops  = {'FracLabels', {'State'}, 'AutoScaleAvailable', 'On'};
% info.state.syncops = {'State'};

info.filterinternals = true;

% There is no state, multiplicand, stage input, or stage output.

% [EOF]
