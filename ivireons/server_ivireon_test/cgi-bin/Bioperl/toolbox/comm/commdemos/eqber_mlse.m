%% EQBER_MLSE - Simulation of MLSE equalizers with and without perfect channel knowledge
% This script runs a simulation loop for an MLSE equalizer with and without a
% perfect channel estimate.  It also dynamically plots the spectrum estimate for
% the imperfect MLSE equalizer, plots the burst error performance of the MLSE
% equalizers, generates and plots BER results over a range of Eb/No values, and
% fits a curve to the simulated BER points.
%
% The channel estimation technique uses a cyclic prefix prepended to the
% transmitted data.  The resulting augmented sequence then looks periodic to an
% FFT, so that FFT techniques can be used to accurately estimate the spectrum.
% Specifically, the FFT of the noisy, channel-filtered signal is divided by the
% FFT of the transmitted signal to give a noisy estimate of the channel
% frequency response. Although this technique is not ideal, and is highly
% dependent on the spectral characteristics of the data, it is a straightforward
% implementation of classic linear system theory.
%
% This script uses another script, <eqber_siggen.html eqber_siggen>, to
% generate a noisy, channel-filtered signal.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.12.3 $  $Date: 2009/01/05 17:45:57 $


firstEstPlot = true;   % for channel estimate plot
firstErrPlot = true;   % for burst error plot - reset for imperfect MLSE

% Main simulation loop
BER = zeros(size(EbNo));
for EbNoIdx = 1 : length(EbNo)
    
    % Initialize channel and error collection parameters
    chanState = [];
    numErrs = 0;
    numBits = 0;
    
    % Reset the equalizer initial data
    [mlseMetric, mlseStates, mlseInputs] = deal([]);
    
    % Preallocate a buffer for the MLSE
    lastMsg = zeros(tbLen, 1);
    
    firstBlk = true;       % counter for processing multiple data blocks
    
    while (numErrs < maxErrs && numBits < maxBits)
        
        eqber_siggen;  % generate a noisy, channel-filtered signal
        
        if (strcmp(mlseType,'imperfect'))
            
            % Set an initial channel estimate.
            chnlEst = [chnl; zeros(excessEst,1)];

            % Perform a channel estimate.  Prepend a cyclic prefix to the
            % transmitted signal, then run it through the noisy channel and
            % truncate it to the estimated length.  The estimated frequency
            % response is the FFT of the noisy signal divided by the FFT of the
            % transmitted signal.
            augTx = [txSig(end-prefixLen+1:end); txSig];   % create cyclic prefix
            augFilt = filter(chnl, 1, augTx);
            augFilt = awgn(augFilt, SNR, 'measured', hStream);
            augFilt = augFilt(prefixLen+1:end);
            HEstNum = fft(augFilt); HEstDen = fft(txSig);
            
            % Test to avoid dividing by zero.  If the test passes, perform the
            % division to generate the channel estimate.
            if (all(abs(real(HEstDen))>eps) && all(abs(imag(HEstDen))>eps))
                HEst = HEstNum ./ HEstDen;
                chnlEst = ifft(HEst);
                chnlEst = chnlEst(1:chnlLen+excessEst); % truncation w/error
            end
                
            % Plot the spectrum of the channel estimate
            hEstPlot = eqber_graphics('chnlest', chnlEst, chnlLen, ...
                excessEst, nBits, firstEstPlot, hEstPlot);
            firstEstPlot = false;
            
        end

        if (numErrs < maxErrs)
            
            % Equalize the signal with an MLSE equalizer and initialize the
            % equalizer states for the next block of data.
            [eqSig, mlseMetric mlseStates mlseInputs] = ...
                mlseeq(noisySig, chnlEst, const, tbLen, mlseMode, nSamp, ...
                       mlseMetric, mlseStates, mlseInputs);

            % Demodulate the signal
            demodSig = (1-sign(real(eqSig)))/2;

            % Update the error statistics.  Account for the delay in the
            % first block of processed data.
            currMsg = msg(1:end-tbLen);
            fullMsg = [lastMsg; currMsg];            
            [currErrs, ratio] = biterr(fullMsg, demodSig);
            numErrs = numErrs + currErrs;
            if (firstBlk)
                numBits = numBits + nBits - tbLen;
            else
                numBits = numBits + nBits;
            end
            BER(EbNoIdx) = numErrs / numBits;
            
            % Retain the end of the current message for the next block of
            % data
            lastMsg = msg(end-tbLen+1 : end);
            
            % Plot the error vector for this frame of data
            [hErrs, hText1, hText2] = eqber_graphics('bursterrors', eqType, ...
                mlseType, firstErrPlot, fullMsg, demodSig, nBits, hErrs, ...
                hText1, hText2);
            firstErrPlot = false;

        end
                
        % Update the BER plot
        [hBER, hLegend, legendString] = eqber_graphics('simber', eqType, ...
            mlseType, firstBlk, EbNoIdx, EbNo, BER, hBER, hLegend, ...
            legendString);
        firstBlk = false;  % done processing first data block
        
    end     % end of simulation while loop
    
    % Fit a plot to the new BER points
    hFit = eqber_graphics('fitber', eqType, mlseType, hFit, EbNoIdx, EbNo, BER);
    
end     % end of 'for EbNoIdx' loop