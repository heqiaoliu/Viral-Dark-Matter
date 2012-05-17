function setstate(hConvert, state)
%SETSTATE Set the current state of the convert dialog
%   SETSTATE(hConvert,S) Set the current state of the convert dialog with the
%   structure S.  This structure S contains all the information necessary to
%   recreate a previous session of the convert dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/11/21 15:30:54 $

if ~isfield(state, 'struct') & isfield(state, 'dconvertto'),
    state.struct = state.dconvertto;
end

if isfield(state, 'filter'),
    hConvert.Filter = state.filter;
end

if isfield(state, 'struct'),
    set(hConvert,'TargetStructure',lclmap(state.struct));
end

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
    otherwise
        out = in;
end

% [EOF]
