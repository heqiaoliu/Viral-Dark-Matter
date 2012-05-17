function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/10/02 19:03:54 $

if isminorder(this)
    availableconstraints = {'Passband ripples and stopband attenuation'};
    return;
end

if nargin < 2
    fconstraints = get(this, 'FrequencyConstraints');
end

switch lower(fconstraints)
    case 'passband and stopband edges'
        if isfir(this)
            availableconstraints = {'Unconstrained'};
        else
            availableconstraints = {'Passband ripple', ...
                'Unconstrained'};
        end
    case 'passband edges'
        % IIR only.
        availableconstraints = {'Passband ripple', ...
            'Passband ripples and stopband attenuation'};
    case 'stopband edges'
        % IIR only.
        availableconstraints = {'Stopband attenuation'};
    case '6db points'
        availableconstraints = {'Unconstrained',...
            'Passband ripples and stopband attenuation'};
    case '3db points'
        if isfdtbxdlg(this)
            availableconstraints = {'Passband ripple', 'Stopband attenuation', ...
                'Passband ripples and stopband attenuation', 'Unconstrained'};
        else
            availableconstraints = {'Unconstrained'};
        end
    case {'3db points and stopband width', '3db points and passband width'}
        availableconstraints = {'Unconstrained'};
end

% [EOF]
