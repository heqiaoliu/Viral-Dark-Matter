function fi = cfi(this)
%CFI   Return the information for the CFI.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:07:47 $

fi.Structure = get(this, 'FilterStructure');

try
    fi.Order = sprintf('%d', order(this));
catch
    fi.Order = xlate('Unknown');
end

fi.Stages    = sprintf('%d', nstages(this));

% [EOF]
