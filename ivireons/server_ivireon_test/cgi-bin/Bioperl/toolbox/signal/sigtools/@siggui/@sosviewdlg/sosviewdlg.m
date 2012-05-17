function this = sosviewdlg
%SOSVIEWDLG   Construct a SOSVIEWDLG object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/12/26 22:22:19 $

this = siggui.sosviewdlg;

hs = siggui.selector(xlate('View'), set(this, 'ViewType'), ...
    {xlate('Overall filter'), xlate('Individual sections'), xlate('Cumulative sections'), ...
    xlate('User defined')});

addcomponent(this, hs);

l = [ ...
    handle.listener(hs, 'NewSelection', @usermodified_listener); ...
    handle.listener(this, [this.findprop('SecondaryScaling') this.findprop('Custom')], ...
    'PropertyPostSet', @usermodified_listener); ...
    ];
set(l, 'CAllbackTarget', this);
set(this, 'UserModifiedListener', l);

set(this, 'isapplied', true);

% [EOF]
