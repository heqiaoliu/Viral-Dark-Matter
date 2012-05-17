function [Hd, same] = design(this)
%DESIGN   Design using the last applied state.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/16 06:38:36 $

Hd = get(this, 'LastAppliedFilter');

same = false;

if ~isempty(Hd),
    same = true;
    applySettings(this.FixedPoint, Hd);
    return;
end

% Design based on the last applied state of the dialog, not its current
% state.  This is done because many of the widgets rendered by DDG need
% their mode set to "true" which updates them before we hit apply.
laState = get(this, 'LastAppliedState');

specs    = getSpecs(this, laState);
oldSpecs = get(this, 'LastAppliedSpecs');
if isequal(specs, oldSpecs)
    same = true;
end

hfdesign = getFDesign(this, laState);

Hd = design(hfdesign);

applySettings(this.FixedPoint, Hd);

set(this, 'LastAppliedFilter', Hd, ...
    'LastAppliedSpecs', specs);

% [EOF]
