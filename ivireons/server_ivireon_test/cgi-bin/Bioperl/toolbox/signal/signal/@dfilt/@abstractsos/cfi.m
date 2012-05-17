function fi = cfi(this)
%CFI   Return the information for 

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:54:21 $

fi.Structure = get(this, 'FilterStructure');
fi.Order     = sprintf('%d', order(this));
fi.Sections  = sprintf('%d', nsections(this));

% [EOF]
