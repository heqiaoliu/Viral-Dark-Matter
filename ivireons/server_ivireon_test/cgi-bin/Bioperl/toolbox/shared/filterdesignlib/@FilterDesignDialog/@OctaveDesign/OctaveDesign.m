function this = OctaveDesign(varargin)
%OCTAVEDESIGN Construct an OCTAVEDESIGN object

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:51 $

this = FilterDesignDialog.OctaveDesign;

set(this, 'VariableName', uiservices.getVariableName('Hoct'), ...
    'FrequencyUnits', 'Hz', ...
    'InputSampleRate', '48000', ...
    'Order', '6', ...
    'ImpulseResponse', 'IIR', ...
    'OrderMode', 'specify', varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.octave);
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'Butterworth', 'Structure', 'Direct-form II, Second-order sections');
end

l = handle.listener(this, this.findprop('FrequencyUnits'), ...
    'PropertyPreSet', @(hSrc, eventData) fix_f0(this, eventData));
set(this, 'FrequencyUnitsListener', l);

% Cache the default states in "LastApplied".
set(this, ...
    'LastAppliedState',      getState(this), ...
    'LastAppliedSpecs',      getSpecs(this), ...
    'LastAppliedDesignOpts', getDesignOptions(this));

% -------------------------------------------------------------------------
function fix_f0(this, eventData)

oldF0 = get(this, 'F0');
oldFU = get(this, 'FrequencyUnits');
newFU = get(eventData, 'NewValue');
newF0 = convertfrequnits(oldF0, oldFU, newFU);

set(this, 'F0', newF0);

% [EOF]
