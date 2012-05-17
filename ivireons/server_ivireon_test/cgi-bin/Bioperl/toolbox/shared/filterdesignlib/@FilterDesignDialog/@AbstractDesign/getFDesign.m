function [hfdesign, b, msg] = getFDesign(this, laState)
%GETFDESIGN   Get the FDesign.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/02/13 15:13:16 $

if nargin < 2
    laState = get(this, 'LastAppliedState');
end

% Design the filter.
hfdesign = get(this, 'FDesign');
if isempty(hfdesign) % FDTbx not installed.
    b   = true;
    msg = '';
    return;
end

% Sync the contained FDesign object with the settings from this object.
[b, msg] = setupFDesign(this, laState);
hfdesign = get(this, 'FDesign');

if ~isempty(laState)
    factor       = laState.Factor;
    ftype        = laState.FilterType;
    
    % If 'SecondFactor' is not a field, laState has been loaded from a
    % release without that field (before SRC), which means the SecondFactor
    % was implicitly 1.
    if isfield(laState, 'SecondFactor')
        secondfactor = laState.SecondFactor;
    else
        secondfactor = '1';
    end
else
    factor       = this.Factor;
    secondfactor = this.SecondFactor;
    ftype        = this.FilterType;
end

% Convert the FDesign to the appropriate multirate object.
hfdesign = createMultiRateVersion(this, hfdesign, ftype, ...
    evaluatevars(factor), evaluatevars(secondfactor));

% [EOF]
