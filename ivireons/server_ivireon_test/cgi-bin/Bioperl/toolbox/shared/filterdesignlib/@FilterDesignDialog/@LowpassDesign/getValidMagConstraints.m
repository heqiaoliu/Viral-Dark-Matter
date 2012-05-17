function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/02 19:04:10 $

if isminorder(this)
    availableconstraints = {'Passband ripple and stopband attenuation'};
    return;
end

if nargin < 2
    fconstraints = get(this, 'FrequencyConstraints');
end

switch lower(fconstraints)
    case 'passband edge and stopband edge'
        if isfir(this)
            if isfdtbxdlg(this)
                availableconstraints = {'Passband ripple', ...
                    'Stopband attenuation', 'Unconstrained'};
            else
                availableconstraints = {'Unconstrained'};
            end
        else
            if isfdtbxdlg(this)
                availableconstraints = {'Passband ripple', ...
                    'Unconstrained'};
            else
                availableconstraints = {'Unconstrained'};
            end
        end
    case 'passband edge'
        if isfir(this)
            availableconstraints = {'Passband ripple and stopband attenuation'};
        else
            availableconstraints = {'Passband ripple', ...
                'Passband ripple and stopband attenuation'};
        end
    case 'stopband edge'
        if isfir(this)
            availableconstraints = {'Passband ripple and stopband attenuation'};
        else
            availableconstraints = {'Stopband attenuation'};
        end
    case '6db point'
        availableconstraints = {'Passband ripple and stopband attenuation', 'Unconstrained'};
    case '3db point'
        if isfir(this)
            availableconstraints = {'Unconstrained'};
        else
            if isfdtbxdlg(this)
                availableconstraints = {'Passband ripple', 'Stopband attenuation', ...
                    'Passband ripple and stopband attenuation', 'Unconstrained'};
            else
                availableconstraints = {'Unconstrained'};
            end
        end
    case '3db point and stopband edge'
        availableconstraints = {'Unconstrained'};
    case 'passband edge and 3db point'
        availableconstraints = {'Unconstrained'};
end

% [EOF]
