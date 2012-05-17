function this = gridbaglayout(varargin)
%GRIDBAGLAYOUT   Construct a GRIDBAGLAYOUT object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:44 $

this = siglayout.gridbaglayout;

abstractlayout_construct(this, varargin{:});

l = handle.listener(this, [this.findprop('Grid') this.findprop('VerticalGap') ...
    this.findprop('VerticalWeights') this.findprop('HorizontalGap') ...
    this.findprop('HorizontalWeights')], 'PropertyPostSet', @lclupdate);

set(l, 'CallbackTarget', this);
set(this, 'UpdateListener', l);

% ----------------------------------------------------------
function lclupdate(this, eventData)

set(this, 'Invalid', true);

update(this);

% [EOF]
