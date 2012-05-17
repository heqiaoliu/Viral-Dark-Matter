function [hfdesign, b, msg] = getFDesign(this, laState)
%GETFDESIGN Get the FDesign.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/27 21:27:22 $

if ~isfdtbxinstalled
    hfdesign = [];
    b = true;
    msg = '';
    return;
end

if nargin < 2
    laState = get(this, 'LastAppliedState');
end

% Switch between peak and notch depending on the 'ResponseType'
switch lower(laState.ResponseType)
    case 'notch'
        hfdesign = fdesign.notch;
    case 'peak'
        hfdesign = fdesign.peak;
end

set(this, 'FDesign', hfdesign);

% Sync the contained FDesign object with the settings from this object.
[b, msg] = setupFDesign(this, laState);

% [EOF]
