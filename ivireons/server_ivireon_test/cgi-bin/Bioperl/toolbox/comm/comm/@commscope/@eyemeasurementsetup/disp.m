function disp(this)
%   DISP(H) displays properties of an eye diagram measurement setup object H.
%
%   EXAMPLES:
%   
%   % Create an eye diagram measurement setup object
%   h = commscope.eyemeasurementsetup;
%   % Display object properties
%   disp(h);
%   h
%
%   See also COMMSCOPE, COMMSCOPE.EYEMEASUREMENTSETUP,
%   COMMSCOPE.EYEMEASUREMENTSETUP/COPY, COMMSCOPE.EYEMEASUREMENTSETUP/RESET.

%   @commscope/@eyemeasurementsetup
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:17:58 $

% Define the fields to be displayed in order
fieldNames = {'Type', ...
    'EyeLevelBoundary', ...
    'ReferenceAmplitude', ...
    'CrossingBandWidth', ...
    'BERThreshold', ...
    'AmplitudeThreshold', ...
    'JitterHysteresis'};

excludedFieldNames = {};
baseDisp(this, fieldNames, excludedFieldNames);

%-------------------------------------------------------------------------------
% [EOF]

