function this = eyemeasurementsetup(varargin)
%EYEMEASUREMENTSETUP Construct an EYEMEASUREMENTSETUP object
%
%   H = COMMSCOPE.EYEMEASUREMENTSETUP constructs a default eye diagram
%   measurements setup object H. 
%
%   H = COMMSCOPE.EYEMEASUREMENTSETUP(PROPERTY1, VALUE1, ...) constructs an eye
%   diagram measurement setup object H with properties as specified by
%   PROPERTY/VALUE pairs. 
%
%   An eye diagram measurement setup object has the following properties. All
%   the properties are writable except for the ones explicitly noted otherwise.
%
%   Type                 - Type of the object ('Eye Diagram Measurement Setup').
%                          This property is not writable.
%   EyeLevelBoundary     - The left and right boundaries of the band used for
%                          eye level measurements.
%   ReferenceAmplitude   - The amplitude value used to calculate the crossing
%                          times and jitter of the eye diagram.  Reference value 
%                          is stored in a 2x1 vector, where the first and second
%                          elements are the reference amplitudes for the
%                          real (in-phase) and imaginary (quadrature) signals,
%                          respectively. 
%   CrossingBandWidth    - Upper and lower boundaries of the band used to
%                          calculate crossing time values.
%   BERThreshold         - Bit error rate threshold used to calculate random
%                          jitter, and eye opening values.
%   AmplitudeThreshold   - Upper and lower edge values used to calculate rise
%                          and fall time values.
%   JitterHysteresis     - Hysteresis value used to decide if the input signal
%                          crossed a ReferenceAmplitude level.
%
%   H = COMMSCOPE.EYEMEASUREMENTSETUP constructs an eye diagram measurement
%   setup object H with default properties and is equivalent to:
%   H = COMMSCOPE.EYEMEASUREMENTSETUP('EyeLevelBoundary', [40 60], ...
%                                     'ReferenceAmplitude', [0; 0], ...
%                                     'CrossingBandWidth', 0.05, ...
%                                     'BERThreshold', 1e-12, ...
%                                     'AmplitudeThreshold', [10 90], ...
%                                     'JitterHysteresis', 0.01);
%
%   An eye diagram measurements object is equipped with two functions for
%   simulation, object management, and visualization.  
%
%   commscope.eyemeasurementsetup methods:
%     copy       - Create a copy of the eye measurement setup object
%     disp       - Display properties of an eye measurement setup object
%
%   To get detailed help on a method on the command line, type
%   "help commscope.eyemeasurementsetup/<METHOD>" , where
%   METHOD is one of the methods listed above. 
%
%   EXAMPLES:
%   % Construct an eye diagram measurement setup object to calculate total
%   % jitter, horizontal eye opening, and vertical eye opening at BER=1e-15
%   h = commscope.eyemeasurementsetup('BERThreshold', 1e-15)
%
%   % Construct an eye diagram measurement setup object to calculate eye levels
%   % of an RZ signal.
%   h = commscope.eyemeasurementsetup('EyeLevelBoundary', [47.5 52.5])
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEMEASUREMENTS.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:17:59 $

this = commscope.eyemeasurementsetup;

% Set default values
this.Type = 'Eye Diagram Measurement Setup'; 

% Setup listener
l = handle.listener(this, ...
    [this.findprop('EyeLEvelBoundary') this.findprop('ReferenceAmplitude') ...
    this.findprop('CrossingBandWidth') this.findprop('BERThreshold') ...
    this.findprop('AmplitudeThreshold') this.findprop('JitterHysteresis'), ...
    this.findprop('PrivRefAmpLevels')], ...
    'PropertyPostSet', @(hSrc, eData) localSendEvent(this, eData));
set(this, 'PrivPropertyListener', l);

% If there are arguments, initialize the object accordingly
if nargin ~= 0
    initPropValuePairs(this, varargin{:});
end

%-------------------------------------------------------------------------------
function localSendEvent(this, eData)

send(this, 'EyeMeasurementSetupPropertiesChanged', eData);

%-------------------------------------------------------------------------------
% [EOF]
