function this = eyediagram(varargin)
%EYEDIAGRAM Eye diagram scope
%
%   H = COMMSCOPE.EYEDIAGRAM constructs a default eye diagram scope object H.
%
%   H = COMMSCOPE.EYEDIAGRAM(PROPERTY1, VALUE1, ...) constructs an eye diagram
%         scope object H with properties as specified by PROPERTY/VALUE pairs.
%
%   An eye diagram scope object has the following properties. All the properties
%   are writable except for the ones explicitly noted otherwise.
%
%   Type                 - Type of scope object ('Eye Diagram'). This property
%                          is not writable.
%   SamplingFrequency    - Sampling frequency of the input signal in Hz.
%   SamplesPerSymbol     - Number of samples used to represent a symbol.
%   SymbolRate           - The symbol rate of the input signal. This property is 
%                          not writable and is automatically computed based on
%                          SamplingFrequency and SamplesPerSymbol.
%   SymbolsPerTrace      - The number of symbols spanned on the time axis of the
%                          eye diagram scope.
%   MinimumAmplitude     - Minimum amplitude of the input signal.  Signal values
%                          less then this value will be ignored both for
%                          plotting and for measurement computation.
%   MaximumAmplitude     - Maximum amplitude of the input signal.  Signal values
%                          greater then this value will be ignored both for
%                          plotting and for measurement computation.
%   AmplitudeResolution  - The resolution of the amplitude axis.  The amplitude
%                          axis will be created from MinimumAmplitude to
%                          MaximumAmplitude with AmplitudeResolution steps.
%   MeasurementDelay     - The time in seconds the scope will wait before
%                          starting to collect data.  
%   OperationMode        - The operation mode of the eye diagram scope.  The
%                          chioces are:
%                          'Real Signal'    - Only the real part of the input
%                                             signal is captured 
%                          'Complex Signal' - Both in-phase and quadrature
%                                             signals are captured 
%   PlotType             - Type of the eye diagram plot.  The choices are:
%                          '2D Color' - Two dimensional eye diagram where color
%                                       intensity represents the probability
%                                       density function values.
%                          '3D Color' - Three dimensional eye diagram where the
%                                       z-axis represents the probability
%                                       density function values.
%                          '2D Line'  - Two dimensional eye diagram where each
%                                       trace is represented by a line.
%   NumberOfStoredTraces - The number of traces stored.  These stored traces are
%                          used to display the eye diagram in '2D Line' mode.
%   PlotTimeOffset       - The offset value in seconds used to shift the eye
%                          diagram plot in time. 
%   RefreshPlot          - The switch that controls the plot refresh style.
%                          The choices are:
%                          'on'  - The eye diagram plot is refreshed every time
%                                  the update method is called.
%                          'off' - The eye diagram plot is not refreshed when the
%                                  update method is called. 
%   PlotPDFRange         - The range of the PDF values that will be displayed in
%                          the '2D Color' mode.  The PDF values outside the
%                          range are set to a constant mask color.
%   ColorScale           - The scale used to represent the color and/or z-axis.
%                          The choices are:
%                          'linear' - linear scale
%                          'log'    - base ten logarithmic scale
%   SamplesProcessed     - The number of samples processed by the eye diagram
%                          object.  This value does not include the discarded
%                          samples during the MeasurementDelay period.  This
%                          property is not writable.
%   Measurements         - Eye diagram measurements.  See <a href="matlab:help commscope/eyemeasurements">commscope/eyemeasurements</a>. 
%   MeasurementSetup     - Eye diagram measurement setup.  See <a href="matlab:help commscope/eyemeasurementsetup">commscope/eyemeasurementsetup</a>. 
%   
%   H = COMMSCOPE.EYEDIAGRAM constructs an eye diagram object H with default
%   properties and is equivalent to:
%   H = COMMSCOPE.EYEDIAGRAM('SamplingFrequency', 10000, ...
%                            'SamplesPerSymbol', 100, ...
%                            'SymbolsPerTrace', 2, ...
%                            'MinimumAmplitude', -1, ...
%                            'MaximumAmplitude', 1, ...
%                            'AmplitudeResolution', 0.0100, ...
%                            'MeasurementDelay', 0, ...
%                            'OperationMode', 'Real Signal', ...
%                            'PlotType', '2D Color', ...
%                            'PlotTimeOffset', 0, ...
%                            'PlotPDFRange', [0 1], ...
%                            'ColorScale', 'linear', ...
%                            'RefreshPlot', 'on');
%   An eye diagram object is equipped with eight functions for simulation,
%   object management, and visualization. To get detailed help on
%   these methods either click on the method name or type 
%   "help commscope.eyediagram/<METHOD>" on the command line, where
%   METHOD is one of the methods listed below.  
%
%   commscope.eyediagram methods:
%     analyze    - Execute eye diagram measurements
%     close      - Close the eye diagram figure
%     copy       - Create a copy of the eye diagram object
%     disp       - Display properties of an eye diagram object
%     exportdata - Export the eye diagram data
%     plot       - Display the eye diagram figure
%     reset      - Reset the eye diagram object
%     update     - Update the eye diagram data
%
%   EXAMPLES: 
%
%     % Construct an eye diagram object for signals in the range of [-3 3]
%     h = commscope.eyediagram('MinimumAmplitude', -3, 'MaximumAmplitude', 3)
%
%     % Construct an eye diagram object for a signal with 1e-3 seconds of
%     % transient time
%     h = commscope.eyediagram('MeasurementDelay', 1e-3)
%
%     % Construct an eye diagram object for '2D Line' plot type with 100 traces
%     % to display
%     h = commscope.eyediagram('PlotType', '2D Line', ...
%                              'NumberOfStoredTraces', 100)
%
%   See also COMMSCOPE, COMMSCOPE.EYEMEASUREMENTS,
%   COMMSCOPE.EYEMEASUREMENTSETUP.

%   @commscope/eyediagram
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/09/23 13:57:27 $

% Create the object
this = commscope.eyediagram;

% Set default prop values
this.Type = 'Eye Diagram';
this.PrivPlotFunction = @complexImage;
this.Measurements = commscope.eyemeasurements;
this.MeasurementSetup = commscope.eyemeasurementsetup;

% Make sure that the OperationMode is consistent with PrivOperationMode of
% abstractHist2D
if strcmp(this.OperationMode, 'Real Signal')
    this.PrivOperationMode = 0;
else
    this.PrivOperationMode = 1;
end

% Setup listeners
listener = handle.listener(this.MeasurementSetup, ...
    'EyeMeasurementSetupPropertiesChanged', ...
    @(hSrc, ed) processEvents(this, ed));
this.PrivListeners = listener;

% If there are arguments, initialize the object accordingly
if nargin ~= 0
    initPropValuePairs(this, varargin{:});
end
%-------------------------------------------------------------------------------
% [EOF]
