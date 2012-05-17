function analyze(this, varargin)
%ANALYZE  Execute eye diagram measurements
%   ANALYZE(H, HEYE) executes the eye diagram measurements on the collected data
%   of the eye diagram scope object HEYE, where H is the Measurements property
%   of HEYE.
%
%   Use the ANALYZE method of the EYEDIAGRAM object, which calls this method in
%   a proper way, instead of using this method directly.  For a complete list of
%   available measurements, type 'help commscope.eyediagram/analyze'.
%
%   See also COMMSCOPE.EYEMEASUREMENTS, COMMSCOPE.EYEMEASUREMENTS/DISP,
%   COMMSCOPE.EYEMEASUREMENTS/RESET, COMMSCOPE.EYEDIAGRAM/ANALYZE.

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/09/23 13:57:28 $

% Error checking
if nargin < 2
    error([this.getErrorId ':NotEnoughInputArgs'], ['Not enough '...
        'input arguments.']);
end    

if isa(varargin{1}, 'commscope.eyediagram')
    eyeDiagram = varargin{1};

    % The horizontal histogram is a sparse representation of the horizontal
    % histograms at several amplitude values defined in the PrivRefAmpLevels.
    % At the beginning of the simulation, these values are just for reference
    % amplitude levels.  After the eye levels become stable (PrivEyeLevelStable
    % == 1), the first 2*(size(EyeLevel, 2)-1) rows collect data for rise and
    % fall times.
    horHistRe = eyeDiagram.PrivHorHistRe;
    horHistIm = eyeDiagram.PrivHorHistIm;
    if eyeDiagram.Measurements.PrivEyeLevelStable
        numEyeLevels = size(eyeDiagram.Measurements.EyeLevel, 2);
    else
        numEyeLevels = 1;
    end
    horHistJRe = horHistRe(2*(numEyeLevels-1)+1:end, :);
    horHistRFRe = horHistRe(1:2*(numEyeLevels-1), :);
    if ~isempty(horHistIm)
        horHistJIm = horHistIm(2*(numEyeLevels-1)+1:end, :);
        horHistRFIm = horHistIm(1:2*(numEyeLevels-1), :);
    else
        horHistJIm = [];
        horHistRFIm = [];
    end
    clear horHistRe horHistIm

    verHistRe = eyeDiagram.PrivVerHistRe;
    verHistIm = eyeDiagram.PrivVerHistIm;
    symbolsPerTrace = eyeDiagram.SymbolsPerTrace;
    Fs = eyeDiagram.SamplingFrequency;
    minAmp = eyeDiagram.MinimumAmplitude;
    ampRes = eyeDiagram.AmplitudeResolution;
    setup = eyeDiagram.MeasurementSetup;
    SamplesPerSymbol = eyeDiagram.SamplesPerSymbol;
else
    error([this.getErrorId ':InvalidInput'], ['The input to the analyze '...
        'method must be a commscope.eyediagram object.']);
end

% Check if SymbolsPerTrace is 2
if ( eyeDiagram.SymbolsPerTrace ~= 2 )
    error([this.getErrorId ':InvalidSymbolsPerTrace'], ['The eye diagram '...
        'measurements can only be performed when SymbolsPerTrace is 2.']);
end

% Check if there are enough samples to process
maxNumHitsRe = min([max(verHistRe) max(horHistJRe, [], 2)']);
if ( maxNumHitsRe < 10 )
    warning([this.getErrorId ':NotEnoughData'], ['The eye diagram '...
        'does not have enough data. Analysis results may not be\naccurate. '...
        'To improve accuracy, enter more data using the UPDATE method.']);
end

maxNumHitsIm = min([max(verHistIm) max(horHistJIm, [], 2)']);
if ( maxNumHitsIm < 10 )
    warning([this.getErrorId ':NotEnoughData'], ['The quadrature eye diagram '...
        'does not have enough data. Analysis results may not be\naccurate. '...
        'To improve accuracy, enter more data using the UPDATE method.']);
end

resetMeasurements(this, horHistJIm)

% Perform calculations
calcEyeCrossingTime(this,...
    horHistJRe, horHistJIm, symbolsPerTrace, Fs, SamplesPerSymbol);

calcEyeCrossingAmp(this, verHistRe, verHistIm, minAmp, ampRes);

calcEyeDelay(this, Fs);

calcEyeLevel(this, verHistRe, verHistIm, ...
    minAmp, ampRes, setup.EyeLevelBoundary, setup.ReferenceAmplitude);

calcEyeAmplitude(this);

calcEyeCrossingPercentage(this);

calcEyeHeight(this);

calcEyeSNR(this);

calcEyeWidth(this);

calcJitterRJDJTJ(this, horHistJRe, horHistJIm, Fs, setup.BERThreshold);

calcJitterRMSP2P(this, horHistJRe, horHistJIm, Fs);

Tsym = size(horHistJRe, 2) / symbolsPerTrace / Fs;
calcEyeOpeningHor(this, Tsym);

calcEyeOpeningVer(this, verHistRe, verHistIm, ampRes, setup.BERThreshold);

calcEyeRiseFallTime(this, horHistRFRe, horHistRFIm, symbolsPerTrace, Fs);

calcQualityFactor(this);
end

%-------------------------------------------------------------------------------
function resetMeasurements(this, horHistQ)
    if isempty(horHistQ)
        m = 1;
    else
        m = 2;
    end
    
    this.EyeCrossingTime = NaN(m,2);
    this.EyeCrossingAmp = NaN(m,2);
    this.EyeDelay = NaN(m,1);
    this.EyeLevel = NaN(m,2);
    this.EyeAmplitude = NaN(m,1);
    this.EyeCrossingPercentage = NaN(m,1);
    this.EyeHeight = NaN(m,1);
    this.EyeSNR = NaN(m,1);
    this.EyeWidth = NaN(m,1);
    this.JitterRandom = NaN(m,1);
    this.JitterDeterministic = NaN(m,1);
    this.JitterTotal = NaN(m,1);
    this.JitterRMS = NaN(m,1);
	this.JitterPeakToPeak = NaN(m,1);
    this.EyeOpeningHor = NaN(m,1);
    this.EyeOpeningVer = NaN(m,1);
    this.EyeRiseTime = NaN(m,1);
    this.EyeFallTime = NaN(m,1);
    this.QualityFactor = NaN(m,1);
end
%-------------------------------------------------------------------------------
% [EOF]
