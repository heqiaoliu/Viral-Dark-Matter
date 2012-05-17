function validFreqConstraints = getValidFreqConstraints(this)
%GETVALIDFREQCONSTRAINTS   Get the validFreqConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/02 19:03:53 $

validFreqConstraints = set(this, 'FrequencyConstraints')';

if strcmpi(this.ImpulseResponse, 'fir')
    validFreqConstraints = validFreqConstraints([1 4]);
else
    if isfdtbxdlg(this)
        validFreqConstraints = validFreqConstraints([1:3 5:7]);
    else
        validFreqConstraints = validFreqConstraints([2 3 5]);
    end
end


% [EOF]
