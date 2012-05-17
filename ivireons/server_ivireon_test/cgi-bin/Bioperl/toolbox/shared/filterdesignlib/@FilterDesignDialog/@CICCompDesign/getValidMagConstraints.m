function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:25:39 $

if isminorder(this)
    availableconstraints = {'Passband ripple and stopband attenuation'};
    return;
end

if nargin < 2
    fconstraints = get(this, 'FrequencyConstraints');
end

switch lower(fconstraints)
    case 'passband edge and stopband edge'
        availableconstraints = {'Unconstrained'};
    otherwise
        availableconstraints = {'Passband ripple and stopband attenuation'};
end

% [EOF]
