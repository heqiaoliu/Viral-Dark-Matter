function validFreqConstraints = getValidFreqConstraints(this)
%GETVALIDFREQCONSTRAINTS Get the validFreqConstraints.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:13:25 $

validFreqConstraints = set(this, 'FrequencyConstraints')';

if isminorder(this)
    validFreqConstraints = validFreqConstraints(1:2);
else
    validFreqConstraints = validFreqConstraints(3:7);
end

% [EOF]
