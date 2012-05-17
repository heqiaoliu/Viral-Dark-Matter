function commeye_generateEyeMeasureDemoData
% Generate the eye diagram objects used in the Eye Diagram Measurements
% demonstration.  This function runs several simulations where the random
% jitter standard deviation is increased from 300 ps to 550 ps in 50 ps steps,
% and then decreased from 500 to 300 ps in 100 ps steps.  The result of
% each simulation is stored in a separate eye diagram object and saved in
% an MAT file called eyeMeasureDemoData.mat.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:12:00 $

% Set system parameters
Fs = 10e9;
Rs = 100e6;
nSamps = Fs/Rs;
Trise = 2e-9;
Tfall = 2e-9;

% Create a pattern generator object
srcObj = commsrc.pattern( ...
    'SamplingFrequency', Fs, ...
    'SamplesPerSymbol', nSamps, ...
    'DataPattern', 'PRBS31', ...
    'RiseTime', Trise, ...
    'FallTime', Tfall);
srcObj.Jitter.RandomJitter = 'on';
srcObj.Jitter.DiracJitter = 'on';
srcObj.Jitter.DiracDelta = [-1e-9 1e-9];

% Create an eye diagram object
eyeObj = commscope.eyediagram(...
    'SamplingFrequency', Fs, ...
    'SamplesPerSymbol', nSamps, ...
    'MinimumAmplitude', -1.75, ...
    'MaximumAmplitude', 1.75, ...
    'ColorScale', 'log', ...
    'MeasurementDelay', 6e-9, ...
    'RefreshPlot', 'off');

% Set the range of standard deviation for the random jitter
stdVec = [300:50:550 500:-100:300]*1e-12;

% Set simulation parameters
frameLen = 1000;
numFrames = 1000;
saveArgs = '''eyeMeasureDemoData.mat''';
cnt = 1;

% Main loop
for randStd = stdVec
    % Set the random jitter standard deviation and reset the eye diagram
    % object
    srcObj.Jitter.RandomStd = randStd;
    reset(eyeObj);
    
    % Update the eye diagram object with the jittered and noisy source
    for p=1:numFrames
        x = generate(srcObj, frameLen);
        r = awgn(x, 50);
        update(eyeObj, r);
    end
    
    % Make sure that we processed enough samples
    numSamps = numFrames*frameLen*eyeObj.SamplesPerSymbol - eyeObj.SamplesProcessed;
    x = generate(srcObj, frameLen);
    r = awgn(x, 50);
    update(eyeObj, r(1:numSamps));
    
    % Adjust the eye center to the middle of the time axis
    analyze(eyeObj);
    timeOffsetSamps = eyeObj.SamplesPerSymbol - Fs*eyeObj.Measurements.EyeDelay;
    eyeObj.PlotTimeOffset = round(timeOffsetSamps)/Fs;
    
    % Rename the eye object and update the save list
    eval(sprintf('eyeObj%d = copy(eyeObj);', cnt));
    saveArgs = sprintf('%s, ''eyeObj%d''', saveArgs, cnt);
    cnt = cnt + 1;
end

% Save the eye diagram objects
eval(sprintf('save(%s)', saveArgs));

% [EOF]