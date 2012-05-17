function this = masklinedlg
%MASKLINEDLG   Construct a MASKLINEDLG object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:21:38 $

this = siggui.masklinedlg;

% Set this object with the default maskline object.
setmaskline(this, dspdata.maskline);
l = handle.listener(this, [this.findprop('FrequencyVector') ...
    this.findprop('MagnitudeVector') this.findprop('MagnitudeUnits') ...
    this.findprop('EnableMask') this.findprop('NormalizedFrequency')], ...
    'PropertyPostSet', @propmod_listener);
set(l, 'CallbackTarget', this);
set(this, 'Listener', l);

% [EOF]
