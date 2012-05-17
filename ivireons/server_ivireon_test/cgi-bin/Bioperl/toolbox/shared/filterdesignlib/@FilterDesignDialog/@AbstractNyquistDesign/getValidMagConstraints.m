function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:24:58 $

if isminorder(this)
    availableconstraints = {'Stopband attenuation'};
    return;
end

if nargin < 2
    fconstraints = get(this, 'FrequencyConstraints');
end

switch lower(fconstraints)
    case 'unconstrained'
        availableconstraints = {'Unconstrained', 'Stopband attenuation'};
    case 'transition width'
        availableconstraints = {'Unconstrained'};
end

% [EOF]
