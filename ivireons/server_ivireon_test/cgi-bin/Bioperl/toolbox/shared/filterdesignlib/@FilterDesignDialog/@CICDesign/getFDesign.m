function hfdesign = getFDesign(this, laState)
%GETFDESIGN   Get the fDesign.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:08 $

if nargin < 2
    laState = get(this, 'LastAppliedState');
end

% Sync the contained FDesign object with the settings from this object.
setupFDesign(this, laState);

% Design the filter.
hfdesign = get(this, 'FDesign');

% [EOF]
