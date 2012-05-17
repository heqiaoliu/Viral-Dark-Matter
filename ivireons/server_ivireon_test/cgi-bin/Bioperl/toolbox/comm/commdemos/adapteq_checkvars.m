function adapteq_checkvars
% Check that variables exist for equalization demo (Part II script).

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2009/01/05 17:45:48 $

if evalin('caller', 'exist(''M'')') && ...
   evalin('caller', 'exist(''nPayload'')') && ...
   evalin('caller', 'exist(''pskmodObj'')') && ...
   evalin('caller', 'exist(''xTrain'')') && ...
   evalin('caller', 'exist(''xTail'')') && ...
   evalin('caller', 'exist(''txFilt'')') && ...
   evalin('caller', 'exist(''rxFilt'')') && ...
   evalin('caller', 'exist(''chan'')') && ...
   evalin('caller', 'exist(''snrdB'')') && ...
   evalin('caller', 'exist(''eqObj'')') && ...
   evalin('caller', 'exist(''simName'')') && ...
   evalin('caller', 'exist(''hStream'')') && ...
   evalin('caller', 'exist(''block'')')

   % If first block, display channel and equalizer objects.
   block = evalin('caller', 'block');
   if (block==1)
       chan = evalin('caller', 'chan');
       eqObj = evalin('caller', 'eqObj');
       chan, eqObj
   end
   
   return
   
end

% Set up variables for frequency-flat fading.

T = 1e-6; % Symbol period (s); used for setting channel parameters.
bitsPerSymbol = 2;  % Number of bits per PSK symbol
M = 2.^bitsPerSymbol;  % Number of modulation levels
nPayload = 400;  % Number of payload symbols
nTrain = 100;  % Number of training symbols
nTail = 20; % Number of tail symbols
pskmodObj = modem.pskmod(M); % modulator object
hStream = RandStream('mt19937ar', 'Seed', 12345); % Local random number stream
% Training sequence symbols
xTrainSym = randi(hStream, [0 M-1], 1, nTrain);
% Modulated training sequence
xTrain = modulate(pskmodObj, xTrainSym);
% Tail sequence symbols
xTailSym = randi(hStream, [0 M-1], 1, nTail);
% Modulated tail sequence
xTail = modulate(pskmodObj, xTailSym);

nSymFilt = 8;  % Number of symbol periods spanned by each filter
osfFilt = 2;  % Oversampling factor for filter (samples per symbol)
rolloff = 0.5;  % Rolloff factor
Ts = T/osfFilt; % TX signal sample period (s)
cutoffFreq = 1/(2*T);  % Cutoff frequency (half Nyquist bandwidth)
orderFilt = nSymFilt*osfFilt;  % Filter order (number of taps - 1)
sqrtrcCoeff = firrcos(orderFilt, cutoffFreq, rolloff, 1/Ts, 'rolloff', 'sqrt');
txFilt = adapteq_buildfilter(osfFilt*sqrtrcCoeff, osfFilt, 1);
rxFilt = adapteq_buildfilter(sqrtrcCoeff, 1, osfFilt);

EsNodB = 20;  % Ratio of symbol energy to noise power spectral density (dB)
snrdB = EsNodB - 10*log10(osfFilt);  % Signal-to-noise ratio per sample (dB)

simName = 'Frequency-flat fading';
fd = 20;  % Maximum Doppler shift (Hz)
chan = rayleighchan(Ts, fd);
chan.ResetBeforeFiltering = 0;
nWeights = 1;  % Number of feedforward equalizer taps/weights
stepSize = 0.03;  % LMS step size
alg = lms(stepSize);
eqObj = lineareq(nWeights, alg, pskmodObj.Constellation);

block = 1;

% Assign variables to caller workspace.
assignin('caller', 'M', M);
assignin('caller', 'nPayload', nPayload);
assignin('caller', 'pskmodObj', pskmodObj);
assignin('caller', 'xTrain', xTrain);
assignin('caller', 'xTail', xTail);
assignin('caller', 'txFilt', txFilt);
assignin('caller', 'rxFilt', rxFilt);
assignin('caller', 'chan', chan);
assignin('caller', 'snrdB', snrdB);
assignin('caller', 'eqObj', eqObj);
assignin('caller', 'simName', simName);
assignin('caller', 'block', block);
assignin('caller', 'hStream', hStream);

% Display channel and equalizer objects.
chan, eqObj
