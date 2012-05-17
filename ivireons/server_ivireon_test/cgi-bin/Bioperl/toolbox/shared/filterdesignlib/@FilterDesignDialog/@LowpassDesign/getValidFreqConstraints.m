function validFreqConstraints = getValidFreqConstraints(this)
%GETVALIDFREQCONSTRAINTS   Get the validFreqConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/10/02 19:04:09 $

validFreqConstraints = set(this, 'FrequencyConstraints')';

if strcmpi(this.ImpulseResponse, 'fir')
    if isfdtbxdlg(this)
        validFreqConstraints = validFreqConstraints([1 2 4 5 6]);
    else
        validFreqConstraints = validFreqConstraints([1 5 6]);
    end
else
    if isfdtbxdlg(this)
        validFreqConstraints = validFreqConstraints([1:4 6:7]);
    else
        validFreqConstraints = validFreqConstraints([2 4 6]);
    end
end


% [EOF]
