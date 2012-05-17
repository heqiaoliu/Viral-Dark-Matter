function this = PeakNotchDesign(varargin)
%PEAKNOTCHDESIGN Construct a PEAKNOTCHDESIGN object

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:53 $

this = FilterDesignDialog.PeakNotchDesign;

set(this, 'VariableName', uiservices.getVariableName('Hpn'), ...
    'Order', '6', ...
    'ImpulseResponse', 'IIR', ...
    'OrderMode', 'specify', varargin{:});

this.Enabled = isfdtbxinstalled;

if isfdtbxinstalled
    set(this, 'FDesign', fdesign.peak);
    updateMethod(this);
else
    % Setup defaults when we cannot read them from the FDESIGN because 
    % filterdesign is not installed
    set(this, 'DesignMethod', 'Butterworth', 'Structure', 'Direct-form II, Second-order sections');
end

defSpecs = struct('FrequencyUnits', 'normalized (0 to 1)', ...
    'InputSampleRate', 2, ...
    'Order', 6, ...
    'F0', 0.5, ...
    'Q', 2.5);

defOpts = cell(1, 0);

set(this, ...
    'LastAppliedState', getState(this), ...
    'LastAppliedSpecs', defSpecs, ...
    'LastAppliedDesignOpts',  defOpts);

% [EOF]
