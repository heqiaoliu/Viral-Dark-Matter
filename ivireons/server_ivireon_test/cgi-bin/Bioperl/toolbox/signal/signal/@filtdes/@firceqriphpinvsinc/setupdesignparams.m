function args = setupdesignparams(h, d)
%SETUPDESIGNPARAMS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/11 14:56:12 $

args = firceqrip_setupdesignparams(h, d);

args = {args{:},'invsinc',...
        [get(d,'invSincFreqFactor'),get(d,'invSincPower')]};

% [EOF]
