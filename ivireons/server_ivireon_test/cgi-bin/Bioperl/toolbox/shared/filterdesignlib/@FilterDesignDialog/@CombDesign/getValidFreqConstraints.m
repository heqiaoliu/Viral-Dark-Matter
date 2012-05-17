function validFreqConstraints = getValidFreqConstraints(this)
%GETVALIDFREQCONSTRAINTS   Get the validFreqConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:42 $

if strcmp(this.OrderMode2, 'Order')
    validFreqConstraints = {'Quality Factor', 'Bandwidth'};
else
    validFreqConstraints = {'Bandwidth'};
end

% [EOF]
