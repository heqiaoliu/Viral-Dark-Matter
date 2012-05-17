function setstate(hObj, state)
%SETSTATE Set the state of the coefficient specifier

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2009/07/27 20:32:07 $

state.Coefficients = setstructfields(hObj.Coefficients, state.Coefficients);

if isfield(state, 'SelectedStructure')
    indx = findstr(state.SelectedStructure, ' (Second-order sections)');
    
    if ~isempty(indx),
        state.SelectedStructure(indx:end) = [];
        state.SOS = 'On';
    end
    state.SelectedStructure = lclmap(state.SelectedStructure);
end

siggui_setstate(hObj, state);

% -----------------------------------------------------------------------
function out = lclmap(in)

switch lower(in)
    case {'direct form i', 'direct form ii', 'direct form i transposed', ...
                'direct form ii transposed', 'direct form fir', ...
                'direct form fir transposed', 'direct form symmetric fir', ...
                'direct form antisymmetric fir'}
        out = in;
        out(7) = '-';
    case 'lattice ma min. phase'
        out = 'lattice moving-average (ma) for minimum phase';
    case 'lattice ma max. phase'
        out = 'lattice moving-average (ma) for maximum phase';
    case 'lattice arma'
        out = 'lattice autoregressive moving-average';
    case 'lattice coupled-allpass'
        out = 'coupled-allpass (ca) lattice';
    case 'lattice coupled-allpass power-complementary'
        out = 'coupled-allpass (ca) lattice with power complementary (pc) output';
    case {'discrete-time filter object (dfilt)', ...
            'discrete-time filter (dfilt object)'}
        out = 'filter object';
    case 'state-space'
        out = 'direct-form ii transposed';
    otherwise
        out = in;
end

% [EOF]
