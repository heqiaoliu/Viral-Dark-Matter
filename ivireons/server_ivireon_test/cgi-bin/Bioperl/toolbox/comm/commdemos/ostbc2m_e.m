function BER2m_e = ostbc2m_e(M, frLen, numPackets, EbNo, pLen)
%OSTBC2M_E  Orthogonal space-time block coding with channel estimation for
%   2xM antenna configurations. 
%
%   BER2M_E = STBC2M_E(M, FRLEN, NUMPACKETS, EBNOVEC, PLEN) computes the 
%   bit-error rate estimates via simulation for an orthogonal space-time block 
%	coded configuration using two transmit antennas and M receive antennas, 
%	where the frame length, number of packets simulated, Eb/No range of values 
%	and the number of pilot symbols prepended per frame are given by FRLEN, 
%	NUMPACKETS, EBNOVEC and PLEN parameters respectively.
%
%   The simulation uses the full-rate Alamouti encoding scheme for BPSK 
%   modulated symbols with appropriate receiver combining. It uses the 
%   pilot-aided Minimum-Mean-Square-Error (MMSE) method for estimating the 
%   channel coefficients at the receiver. It is assumed the channel is slowly
%   fading (i.e. it remains constant for the whole frame of data and changes 
%   independently from one frame to the other).
%
%   Suggested parameter values:
%       M = 1 or 2; FRLEN = 100; NUMPACKETS = 1000; EBNOVEC = 0:2:20, PLEN = 8;
%
%   Example:
%       ber22_e = ostbc2m_e(2, 100, 1000, 0:2:20, 8);
%
%   See also OSTBC2M, OSTBC4M, MRC1M.

%   References:
%   [1] A.F. Naguib, V. Tarokh, N. Seshadri, and A.R. Calderbank, "Space-time
%       codes for high data rate wireless communication: Mismatch analysis", 
%       Proceedings of IEEE International Conf. on Communications, 
%       pp. 309-313, June 1997.        
%
%   [2] S. M. Alamouti, "A simple transmit diversity technique for wireless 
%       communications", IEEE Journal on Selected Areas in Communications, 
%       Vol. 16, No. 8, Oct. 1998, pp. 1451-1458.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/01/05 17:46:04 $

%% Simulation parameters
N = 2;              % Number of transmit antennas
rate = 1; inc = N/rate;

% Create BPSK mod-demod objects
P = 2; % modulation order
bpskmod = modem.pskmod('M', P, 'SymbolOrder', 'Gray', 'InputType', 'Integer');
bpskdemod = modem.pskdemod(bpskmod);

% Pilot sequences - orthogonal set over N
W = hadamard(pLen); % order gives the number of pilot symbols prepended/frame
pilots = W(:, 1:N); % Note, hadamard works for a BPSK modem directly.

%%  Pre-allocate variables for speed
txEnc = zeros(frLen/rate, N); r = zeros(pLen + frLen/rate, M);
H = zeros(pLen + frLen/rate, N, M); H_e = zeros(frLen/rate, N, M); 
z_e = zeros(frLen, M); z1_e = zeros(frLen/N, M); z2_e = z1_e;
error2m_e = zeros(1, numPackets); BER2m_e = zeros(1, length(EbNo)); 

h = waitbar(0, 'Percentage Completed');
set(h, 'name', 'Please wait...');
wb = 100/length(EbNo);

%% Loop over EbNo points
for idx = 1:length(EbNo)
    % Loop over the number of packets
    for packetIdx = 1:numPackets
        data = randi([0 P-1], frLen, 1);         % data vector per user/channel
        tx = modulate(bpskmod, data);        % BPSK modulation

        % Alamouti ST-Block Encoder, G2, full rate
        % G2 = [s1 s2; -s2* s1*]
        s1 = tx(1:N:end); s2 = tx(2:N:end);
        txEnc(1:inc:end, :) = [s1 s2];
        txEnc(2:inc:end, :) = [-conj(s2) conj(s1)];

        % Prepend pilot symbols for each frame
        transmit = [pilots; txEnc];

        % Create the Rayleigh channel response matrix
        H(1, :, :) = (randn(N, M) + 1i*randn(N, M))/sqrt(2);
        %   held constant for the whole frame and pilot sequence
        H = H(ones(pLen + frLen/rate, 1), :, :);
        
        % Received signal for each Rx antenna with pilot
        for i = 1:M
            % with power normalization
            r(:, i) = awgn(sum(H(:, :, i).*transmit, 2)/sqrt(N), EbNo(idx)); 
        end
     
        % Channel Estimation
        %   For each link => N*M estimates
        for n = 1:N
            H_e(1, n, :) = (r(1:pLen, :).' * pilots(:, n))./pLen;
        end
        %   held constant for the whole frame
        H_e = H_e(ones(frLen/rate, 1), :, :);
        
        % Combiner using channel estimates
        heidx = 1:inc:length(H_e);
        for i = 1:M
            z1_e(:, i) = r(pLen+1:inc:end, i).* conj(H_e(heidx, 1, i)) + ...
                       conj(r(pLen+2:inc:end, i)).* H_e(heidx, 2, i);

            z2_e(:, i) = r(pLen+1:inc:end, i).* conj(H_e(heidx, 2, i)) - ...
                       conj(r(pLen+2:inc:end, i)).* H_e(heidx, 1, i);
        end
        z_e(1:N:end, :) = z1_e; z_e(2:N:end, :) = z2_e;

        % ML Detector (minimum Euclidean distance)
        demod2m_e = demodulate(bpskdemod, sum(z_e, 2)); % estimated

        % Determine bit errors
        error2m_e(packetIdx) = biterr(demod2m_e, data);
    end % end of FOR loop for numPackets

    % Calculate BER for current idx
    BER2m_e(idx) = sum(error2m_e)/(numPackets*frLen); % G2 coded

    str_bar = [num2str(wb) '% Completed'];
    waitbar(wb/100, h, str_bar);
    wb = wb + 100/length(EbNo);
end  % end of for loop for EbNo

close(h);
    
% [EOF]
