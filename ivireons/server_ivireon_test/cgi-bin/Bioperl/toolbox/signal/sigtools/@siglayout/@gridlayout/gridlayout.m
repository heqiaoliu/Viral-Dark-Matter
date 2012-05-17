function this = gridlayout(varargin)
%GRIDLAYOUT   Construct a GRIDLAYOUT object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:51 $

% Call the default constructor.
this = siglayout.gridlayout;

abstractlayout_construct(this, varargin{:});

l = [ ...
        handle.listener(this, [this.findprop('Grid') this.findprop('VerticalGap') ...
        this.findprop('HorizontalGap')], 'PropertyPostSet', @lclupdate); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'UpdateListener', l);

% ----------------------------------------------------------
function lclupdate(this, eventData)

set(this, 'Invalid', true);

update(this);

% [EOF]
