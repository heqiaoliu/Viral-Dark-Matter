function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:26:02 $

if isminorder(this)
    availableconstraints = {'Passband ripple and stopband attenuation'};
else
    availableconstraints = {'Unconstrained'};
end

% [EOF]
