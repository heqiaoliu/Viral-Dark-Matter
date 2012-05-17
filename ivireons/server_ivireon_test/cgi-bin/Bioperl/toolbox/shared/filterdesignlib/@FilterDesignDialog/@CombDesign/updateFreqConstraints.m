function updateFreqConstraints(this)
%UPDATEFREQCONSTRAINTS   Update the frequency constraints.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:48 $

validConstraints = getValidFreqConstraints(this);

% Check both FreqConst and privFreqCons, this is because during passing
% dfilt object into filterbuilder and fdtbx unavailable. The default value 
% of FreqConst could be invaild.
if ~any(strcmpi(this.FrequencyConstraints, validConstraints))
    set(this, 'FrequencyConstraints', validConstraints{1});
end

% [EOF]
