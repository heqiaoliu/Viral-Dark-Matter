function this = designpanel(allowplugins)
%DESIGNPANEL Construct a design panel object

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.6.4.6 $  $Date: 2005/12/22 19:04:08 $

this = siggui.designpanel;

if nargin < 1
    allowplugins = true;
end

if allowplugins
    addplugins(this);
end
types = get(this, 'AvailableTypes');

if length(types.hp) > 1,
    hp  = [{'hp'}, {types.hp.tag}];
    hpn = {types.hp.name};
else
    hp  = types.hp.tag;
    hpn = types.hp.name;
end

if length(types.bp) > 1,
    bp  = [{'bp'}, {types.bp.tag}];
    bpn = {types.bp.name};
else
    bp  = types.bp.tag;
    bpn = types.bp.name;
end

if length(types.bs) > 1,
    bs  = [{'bs'}, {types.bs.tag}];
    bsn = {types.bs.name};
else
    bs  = types.bs.tag;
    bsn = types.bs.name;
end

hfts = siggui.selector('Response Type', ...
    {[{'lp'}, {types.lp.tag}], hp,  bp,  bs,  [{'other'}, {types.other.tag}]}, ...
    {{types.lp.name},          hpn, bpn, bsn, {types.other.name}}, 'lp', 'lp');

hdms = siggui.selector('Design Method', ...
    {{'iir', types.lp(1).iir.tag},  {'fir', types.lp(1).fir.tag}}, ...
    {{'IIR', types.lp(1).iir.name}, {'FIR', types.lp(1).fir.name}}, ...
    'fir', 'filtdes.remez');

addcomponent(this, [hfts hdms]);

set(this, 'Version', 1);
settag(this);

% [EOF]
