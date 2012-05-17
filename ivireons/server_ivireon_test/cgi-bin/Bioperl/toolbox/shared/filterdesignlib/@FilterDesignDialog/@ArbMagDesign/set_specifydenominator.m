function specifydenominator = set_specifydenominator(this, specifydenominator)
%SET_SPECIFYDENOMINATOR   PreSet function for the 'specifydenominator'
%property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:41 $

set(this, 'privSpecifyDenominator', specifydenominator);

updateMethod(this);

% [EOF]
