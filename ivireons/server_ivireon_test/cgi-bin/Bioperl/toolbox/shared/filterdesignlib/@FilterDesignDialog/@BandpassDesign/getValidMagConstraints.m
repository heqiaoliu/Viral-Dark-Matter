function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/02/17 18:58:27 $

if isminorder(this)
    availableconstraints = {'Passband ripple and stopband attenuations'};
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
            if isfdtbxdlg(this)
                availableconstraints = {'Passband ripple', ...
                    'Unconstrained'};
            else
                availableconstraints = {'Unconstrained'};
            end
        end
    case 'passband edges'
        % IIR only.
        availableconstraints = {'Passband ripple', ...
            'Passband ripple and stopband attenuations'};
    case 'stopband edges'
        % IIR only.
        availableconstraints = {'Stopband attenuation'};
    case '6db points'
        availableconstraints = {'Unconstrained',...
            'Passband ripple and stopband attenuations'};
    case '3db points'
        if isfdtbxdlg(this)
            availableconstraints = {'Passband ripple', 'Stopband attenuation', ...
                'Passband ripple and stopband attenuations', 'Unconstrained'};
        else
            availableconstraints = {'Unconstrained'};
        end
    case {'3db points and stopband width', '3db points and passband width'}
        availableconstraints = {'Unconstrained'};
end

% [EOF]
