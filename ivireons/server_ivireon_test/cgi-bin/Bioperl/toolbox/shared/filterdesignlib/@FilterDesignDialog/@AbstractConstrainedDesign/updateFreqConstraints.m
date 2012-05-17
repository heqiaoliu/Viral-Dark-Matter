function updateFreqConstraints(this)
%UPDATEFREQCONSTRAINTS 

%   Author(s): J. Schickler
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/10/02 19:03:34 $

validConstraints = getValidFreqConstraints(this);

% Check both FreqConst and privFreqCons, this is because during passing
% dfilt object into filterbuilder and fdtbx unavailable. The default value 
% of FreqConst could be invaild.
if ~any(strcmpi(this.FrequencyConstraints, validConstraints)) && ...
        ~any(strcmpi(this.privFrequencyConstraints, validConstraints))
    set(this, 'FrequencyConstraints', validConstraints{1});
else
    updateMagConstraints(this);
end

% [EOF]
