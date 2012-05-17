function validFreqConstraints = getValidFreqConstraints(this)
%GETVALIDFREQCONSTRAINTS   Get the validFreqConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:24:57 $

% All of the frequency constraints are always valid.
validFreqConstraints = set(this, 'FrequencyConstraints')';

% [EOF]
