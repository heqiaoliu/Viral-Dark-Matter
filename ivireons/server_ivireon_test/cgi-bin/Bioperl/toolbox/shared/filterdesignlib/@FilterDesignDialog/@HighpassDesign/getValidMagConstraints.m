function availableconstraints = getValidMagConstraints(this, fconstraints)
%GETVALIDMAGCONSTRAINTS   Get the validMagConstraints.

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/10/02 19:04:04 $

if isminorder(this)
    availableconstraints = {'Stopband attenuation and Passband ripple'};
    return;
end

if nargin < 2
    fconstraints = get(this, 'FrequencyConstraints');
end

switch lower(fconstraints)
    case 'stopband edge and passband edge'
        if isfir(this)
            if isfdtbxdlg(this)
                availableconstraints = {'Unconstrained', 'Passband ripple', ...
                    'Stopband attenuation'};
            else
                availableconstraints = {'Unconstrained'};
            end
        else
            availableconstraints = {'Unconstrained', 'Passband ripple'};
        end
    case 'passband edge'
        if isfir(this)
            availableconstraints = {'Stopband attenuation and passband ripple'};
        else
            availableconstraints = {'Passband ripple', ...
                'Stopband attenuation and passband ripple'};
        end
    case 'stopband edge'
        if isfir(this)
            availableconstraints = {'Stopband attenuation and passband ripple'};
        else
            availableconstraints = {'Stopband attenuation'};
        end
    case '6db point'
        availableconstraints = {'Stopband attenuation and passband ripple', ...
            'Unconstrained'};
    case '3db point'
        if isfir(this)
            availableconstraints = {'Unconstrained'};
        else
            if isfdtbxdlg(this)
                availableconstraints = {'Unconstrained', 'Passband ripple', ...
                    'Stopband attenuation', 'Stopband attenuation and passband ripple'};
            else
                availableconstraints = {'Unconstrained'};
            end
        end
    case 'stopband edge and 3db point'
        availableconstraints = {'Unconstrained'};
    case '3db point and passband edge'
        availableconstraints = {'Unconstrained'};
end

% [EOF]
