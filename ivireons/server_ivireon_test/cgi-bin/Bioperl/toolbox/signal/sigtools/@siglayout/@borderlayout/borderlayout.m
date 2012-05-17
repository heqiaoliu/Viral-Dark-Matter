function this = borderlayout(varargin)
%BORDERLAYOUT   Construct a BORDERLAYOUT object.
%   BORDERLAYOUT(H)  Construct a BORDERLAYOUT object on the uipanel or
%   figure in handle H.
%
%   BORDERLAYOUT(H, PROP1, VAL1, etc.) Construct an object and set its
%   parameter value pairs.
%
%   See also SIGLAYOUT/GRIDLAYOUT, SIGLAYOUT/BOXLAYOUT and
%   SIGLAYOUT/CARDLAYOUT.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:35 $

this = siglayout.borderlayout;

abstractlayout_construct(this, varargin{:});

l = handle.listener(this, [this.findprop('North') this.findprop('South') ...
    this.findprop('West') this.findprop('East') this.findprop('Center') ...
    this.findprop('HorizontalGap') this.findprop('VerticalGap')], ...
    'PropertyPostSet', @lclupdate_listener);

set(l, 'CallbackTarget', this);
set(this, 'UpdateListener', l);

% -------------------------------------------------------------------------
function lclupdate_listener(this, eventData)

set(this, 'Invalid', true);

update(this);

% [EOF]
