function info = qtoolinfo(this)
%QTOOLINFO   Return the info for the qtool.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:05:14 $

info.coeff.setops = {'Name', 'Coefficients', ...
    'FracLabels', {'Lattice', 'Ladder'}};
info.coeff.syncops = {'Lattice', 'Ladder'};

info.state.setops  = {'FracLabels', {'State'}};
info.state.syncops = [];

info.product.setops  = {'FracLabels', {'Lattice', 'Ladder'}};
info.product.syncops = {'Lattice', 'Ladder'}; % Syncs the defaults.

info.accum.setops  = {'FracLabels', {'Lattice', 'Ladder'}};
info.accum.syncops = {'Lattice', 'Ladder'};

% [EOF]
