function [fer err] = simEGPRS2Uplink(SNRVec, minPkt, minErr)
% simEGPRS2Uplink Simulate the EGPRS2 UBS7 channel
% FER = simEGPRS2Uplink(SNR, minPkt, minErr) simulates the system presented
% in the EGPRS Phase 2 Level B Uplink Simulation (UBS-7 Logical Channel)
% demo.  The simulation is run for SNR values and the frame error rate is
% returned. Each EbNo point is simulated until either minimum number of
% packets, minPkt, or minimum number of frame errors, minErr, is reached.
% To speed up the simulation, all the initializations are done outside the
% loop.
%
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/01/20 15:29:08 $

%% System parameters
Treduced = 1/325000;    % Reduced symbol duration in seconds
fc = 900e6;             % Carrier frequency
M = 16;                 % Number of symbols in the constellation
constellation = [...    % 16-QAM constellation
    1+1i, 1+3i, 3+1i, 3+3i, 1-1i, 1-3i, 3-1i, 3-3i, ...
    -1+1i, -1+3i, -3+1i, -3+3i, -1-1i, -1-3i, -3-1i, -3-3i];

% Number of bits in a packet
dataLen = 940;          % Number of data bits
headerLen = 40;         % Number of header bits
infoLen = 450;          % Number of informaiton bits in one part

% Burst structure
numTailSyms = 4;        % Number of tail symbols
numEncSyms = 69;        % Number of encrypted symbols per side
numTrainSyms = 31;      % Number of training symbols
numGuardSyms = 10;      % Integer number of guard symbols

% Convolutional code
G4 = 133;               % 1+D^2+D^3+D^5+D^6
G7 = 171;               % 1+D+D^2+D^3+D^6
G5 = 145;               % 1+D+D^4+D^6
constLen = 7;           % Constraint length
rateInv = 3;            % Inverse of code rate
tbLenHeader = headerLen + 8;    % Header traceback length
tbLenData = 5 * constLen;       % Data traceback length

% Interleaver parameters
NcHeader = 144; aHeader = 29;
NcData = 2056; aData = 403;

% Mapping parameters
j0 = 1:258;
j1 = 259:276;
j2 = 277:278;
j3 = 279:296;
j4 = 297:552;

% Bit swapping parameters
kSwap = [0 1 4 5 8 9 12 13 16 17 38 39 42 43 46 47 50 51 54 55] +1;

% Tail bits for the higher symbol rate burst (HB)
tailBits = [0,0,0,1,0,1,1,0,0,1,1,0,1,1,0,1]';

% TSC 0 for the higher symbol rate burst (HB)
trainingBits = [...
    0,0,1,1,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,0,0,1,1,0,0,1,1,0,0,1,1,...
    1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
    1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,...
    1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1]';

% Pulse shaping
Nsamp = 4;              % Number of samples per symbol
c0 = commEGPRSWidePulse(Nsamp);         % Filter coefficients
sigPow = 10*log10((sum(c0.^2)*...       % Signal power
    mean(abs(constellation).^2))/Nsamp);
filtDelay = (length(c0) - 1)/2;         % Filter delay

% Equalizer parameters
Nff = 10;               % Number of feedforward taps
Nfb = 6;                % Number of feedback taps
lambda = 0.9;           % Forgetting factor for RLS algorithm
eqDelay = 4;            % Delay to position the desired symbol in equalizer

%% Initialization
% CRC generator and detector for header
headerCRCGen = crc.generator('Polynomial', [1 0 1 0 0 1 0 0 1], ...
    'FinalXOR', [1 1 1 1 1 1 1 1]);
headerCRCDec = crc.detector(headerCRCGen);

% CRC generator and detector for data
dataCRCGen = crc.generator('Polynomial', [1 1 1 0 1 0 0 1 1 0 0 0 1], ...
    'FinalXOR', [1 1 1 1 1 1 1 1 1 1 1 1]);
dataCRCDec = crc.detector(dataCRCGen);

% Convolutional code for both header and data
headerConvCode = poly2trellis(constLen, [G4 G7 G5]);

% Puncturing pattern for data
puncPat = ones(1404,1);
j=[4 8 10 14 20 23 25 29 30];
for k=0:41
    puncPat(33*k+j +1) = 0;
end
puncPat(33*42+[4 8 10 14] +1) = 0;
puncPat(33*[6 12 18 24 30 36]+20 +1) = 1;

% Interleaver indices for header and data
headerIntrlvVec = genInterleaver(NcHeader, aHeader);
dataIntrlvVec = genInterleaver(NcData, aData);

% 16-QAM modulator and demodulator
hMod = modem.genqammod('Constellation', constellation, 'InputType', 'Bit');
hDemod = modem.genqamdemod(hMod);
hDemod.DecisionType = 'Approximate LLR';

% Determine number of symbols in a burst
numBurstSyms = (numTailSyms + numEncSyms + numTrainSyms + numEncSyms ...
    + numTailSyms + numGuardSyms);

% Create a pulse shaping filter and normalize maximum response to 1
hPulseShape = dfilt.dffir(c0/max(c0));

% Create a typical urban channel model for 50 kmph speed
fd = (50e3/3600)*fc/3e8;
hChan = stdchan(Treduced/Nsamp, fd, 'gsmTUx6c1');

% Determine number of rcv samples to pass to the next stage
numRcvSyms = (numTailSyms + numEncSyms + numTrainSyms + numEncSyms ...
    + numTailSyms + 4);
numRcvSamps = numRcvSyms * Nsamp;

% Create a DFE filter with RLS adaptive algorithm
hAlg = rls(lambda);
hEq = dfe(Nff, Nfb, hAlg, hMod.Constellation);

% Determine the boundaries of the payload for equalization
part1Start = numTailSyms+numEncSyms+numTrainSyms;
part1End = 1;
part2Start = numTailSyms+numEncSyms+1;
part2End = part2Start+numTrainSyms+numEncSyms+numTailSyms-1;

% Reset the default stream
reset(RandStream.getDefaultStream);

% Preallocate variables
diR = zeros(940,1);
e = zeros(552,4);
eR = zeros(552, 4);
hiR = zeros(40,1);
q = zeros(8,1);
qR = zeros(8,1);
r = zeros(numBurstSyms*Nsamp,4);
fer = zeros(size(SNRVec));
err = zeros(size(SNRVec));

%% Main loop
for cnt = 1:length(SNRVec)
    SNR = SNRVec(cnt);
    
    % Initialize counters
    headerError = 0;        % Header error counter
    dataError = 0;          % Data error counter
    pktCnt = 0;             % Packet counter
    
    while (pktCnt < minPkt) && (dataError < minErr)
        
        % Generate header and data bits
        d = randi([0 1], dataLen, 1);
        h = d(1:headerLen);                     % Header
        i1 = d(headerLen+1:headerLen+infoLen);  % Information part 1
        i2 = d(headerLen+infoLen+1:dataLen);    % Information part 2
        
        % Add CRC to the header
        bHeader = generate(headerCRCGen, h);
        % First append last 6 bits to the beginning.
        c = [bHeader(end-(constLen-2):end); bHeader];
        % Encode the appended block with a regular convolutional encoder
        C = convenc(c, headerConvCode);
        % Discard the encoded bits resulted from the first 6 appended bits
        pc = C((constLen-1)*rateInv+1:end);
        
        % Add parity bits to the first part
        b1 = generate(dataCRCGen, i1);
        % Convolutionally encode the first part
        c = [b1; zeros(6,1)];
        c1 = convenc(c, headerConvCode, puncPat);
        
        % Add parity bits to the second part
        b2 = generate(dataCRCGen, i2);
        % Convolutionally encode the first part
        c = [b2; zeros(6,1)];
        c2 = convenc(c, headerConvCode, puncPat);
        
        % Interleave coded header bits
        hi = deintrlv(pc, headerIntrlvVec);
        % Interleave coded data bits
        dc = [c1; c2];
        di = deintrlv(dc, dataIntrlvVec);
        
        % Straightforward mapping.  Each column represents a burst.  Note that,
        % MATLAB arrays start with index 1.
        for B=0:3
            e(j0, B +1) = di(514*B+j0);
            e(j1, B +1) = hi(36*B+j1-258);
            e(j2, B +1) = q(2*B+j2-276);
            e(j3, B +1) = hi(36*B+j3-260);
            e(j4, B +1) = di(514*B+j4-38);
        end
        
        % Bit swapping
        dummy = e(240+kSwap, :);
        e(240+kSwap, :) = e(258+kSwap, :);
        e(258+kSwap, :) = dummy;
        
        % Create four bursts.  Each column represents a burst.
        bursts = [repmat(tailBits, 1, 4); ...
            e(1:276, :); ...
            repmat(trainingBits, 1, 4); ...
            e(277:552, :); ...
            repmat(tailBits, 1, 4); zeros(10*log2(M), 4)];
        
        % Map bits to symbols
        s = modulate(hMod, bursts);
        
        % Rotate the symbols pi/4 degrees continuously
        sHat = s .* exp(1i*repmat((0:numBurstSyms-1)', 1, 4)*pi/4);
        
        % Upsample and filter
        y = filter(hPulseShape, upsample(sHat, Nsamp));
        
        % Channel
        for B=0:3
            yCh = filter(hChan, y(:,B +1));
            r(:, B +1) = awgn(yCh, SNR, sigPow);
        end
        
        % Match filter and down sample
        yR = filter(hPulseShape, r);
        sHatR = yR(2*filtDelay+1:Nsamp:numRcvSamps+2*filtDelay, :);
        
        % Remove phase rotation
        sR = sHatR .* exp(-1i*repmat((0:numRcvSyms-1)', 1, 4)*pi/4);
        
        for B=0:3
            % First part.  Start by resetting the equalizer
            reset(hEq)
            % Equalize from middle to start
            [sModR dummy er] = equalize(hEq, sR(part1Start-eqDelay:-1:part1End, B +1), ...
                s(part1Start:-1:part1Start-31+1, B +1));
            % Estimate noise at the output of the equalizer
            hDemod.NoiseVariance = var(er(numTrainSyms+1:numTrainSyms+numEncSyms));
            % Soft demodulate
            eR(1:276, B +1) = demodulate(hDemod, ...
                sModR(numTrainSyms+numEncSyms:-1:numTrainSyms+1));
            
            % Second part.  Start by resetting the equalizer
            reset(hEq)
            % Equalize from middle to start
            [sModR a er] = equalize(hEq, sR(part2Start+eqDelay:part2End+eqDelay, B +1), ...
                s(part2Start:part2Start+31, B +1));
            % Estimate noise at the output of the equalizer
            hDemod.NoiseVariance = var(er(numTrainSyms+1:numTrainSyms+numEncSyms));
            % Soft demodulate
            eR(277:552, B +1) = demodulate(hDemod, ...
                sModR(numTrainSyms+1:numTrainSyms+numEncSyms));
        end
        
        % Bit unswapping
        dummy = eR(240+kSwap, :);
        eR(240+kSwap, :) = eR(258+kSwap, :);
        eR(258+kSwap, :) = dummy;
        
        % Straightforward demapping
        for B=0:3
            diR(514*B+j0) = eR(j0, B +1);
            hiR(36*B+j1-258) = eR(j1, B +1);
            qR(2*B+j2-276) = eR(j2, B +1);
            hiR(36*B+j3-260) = eR(j3, B +1);
            diR(514*B+j4-38) = eR(j4, B +1);
        end
        
        % Deinterleaving
        pcR = intrlv(hiR, headerIntrlvVec);
        dcR = intrlv(diR, dataIntrlvVec);
        
        % Decode header
        % Determine the final state, which is the same as initial state
        [cR metric states inputs] = vitdec(pcR, headerConvCode, tbLenHeader, ...
            'cont', 'unquant');
        % Decode using the determined initial state
        cR = vitdec([pcR; zeros(tbLenHeader*rateInv,1)], headerConvCode, ...
            tbLenHeader, 'cont', 'unquant', metric, states, inputs);
        cR = cR(tbLenHeader+1:end, 1);
        
        % Detect if there was an error using the CRC
        [bR errorFlag] = detect(headerCRCDec, cR);
        % Check for errors
        if errorFlag
            headerError = headerError + 1;
        end
        
        % Decode data
        if ~errorFlag
            % Get part 1 and 2 of the data
            c1R = dcR(1:1028, 1);
            c2R = dcR(1029:end, 1);
            % Convolutional decoding for first part
            b1R = vitdec(c1R, headerConvCode, tbLenData, ...
                'term', 'unquant', puncPat);
            % Parity bits for first part
            [i1R errorFlag1] = detect(dataCRCDec, b1R(1:462));

            % Convolutional decoding for second part
            b2R = vitdec(c2R, headerConvCode, tbLenData, ...
                'term', 'unquant', puncPat);
            % Parity bits for second part
            [i2R errorFlag2] = detect(dataCRCDec, b2R(1:462));
        else
            errorFlag1 = 1;
            errorFlag2 = 1;
        end
        
        if errorFlag1 || errorFlag2
            dataError = dataError + 1;
        end
        
        pktCnt = pktCnt + 1;
    end
    err(cnt) = dataError;
    fer(cnt) = dataError / pktCnt;
end

function intrlvVec = genInterleaver(Nc, a)
% Generate interleaver indices
B = @(k)(2*mod(k,2)+floor(mod(k,4)/2));
k = 0:Nc-1;
j = Nc*B(k)/4 + mod((floor(k/4) + floor(Nc/16)*B(k))*a, Nc/4);
intrlvVec(j +1) = k +1;
