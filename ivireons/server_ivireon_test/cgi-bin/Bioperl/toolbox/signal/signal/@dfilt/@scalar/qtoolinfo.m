function info = qtoolinfo(this)
%QTOOLINFO   Return the information for the qtool.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/28 04:37:17 $

info.coeff.setops = {'Name', 'Coefficient', 'FracLabels', {'Coefficient'}};
info.coeff.syncops = {'Coeff'};

info.accum   = [];
info.product = [];

% [EOF]
