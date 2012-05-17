function updateMagConstraints(this)
%UPDATEMAGCONSTRAINTS   Update the magnitude constraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/10/02 19:03:35 $

validMagConstraints = getValidMagConstraints(this);

% If the current MagnitudeConstraints do not make sense for the new
% FrequencyConstraints, set the MagnitudeConstraints to the first valid.
if ~any(strcmpi(this.MagnitudeConstraints, validMagConstraints)) && ...
        ~any(strcmpi(this.privMagnitudeConstraints, validMagConstraints))
    set(this, 'MagnitudeConstraints', validMagConstraints{1});
else
    updateMethod(this);
end

% [EOF]
