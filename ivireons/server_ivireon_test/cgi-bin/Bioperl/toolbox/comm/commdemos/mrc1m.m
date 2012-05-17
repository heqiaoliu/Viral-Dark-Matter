function BER1m = mrc1m(M, frLen, numPackets, EbNo)
%MRC1M  Maximal-Ratio Combining for 1xM antenna configurations.
%
%   BER1M = MRC1M(M, FRLEN, NUMPACKETS, EBNOVEC) computes the bit-error rate 
%   estimates via simulation for a Maximal-Ratio Combined configuration using 
%	one transmit antenna and M receive antennas, where the frame length, number
%   of packets simulated and the Eb/No range of values are given by FRLEN, 
%	NUMPACKETS, EBNOVEC parameters respectively.
%
%   The simulation uses BPSK modulated symbols with appropriate receiver 
%   combining.
%
%   Suggested parameter values:
%       M = 1 to 4; FRLEN = 100; NUMPACKETS = 1000; EBNOVEC = 0:2:20;
%
%   Example:
%       ber12 = mrc1m(2, 100, 1000, 0:2:20);
%
%   See also OSTBC2M, OSTBC4M.

%   References:
%   [1] J. G. Proakis, "Digital Communications", McGraw Hill, New York, 
%		4th Ed., 2000. 
%
%   [2] D. G. Brennan, "Linear Diversity Combining Techniques", Proceedings of 
%		the IRE, vol. 47, June 1959, pp. 1075-1102.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/01/05 17:46:02 $

%% Simulation parameters
% Create BPSK mod-demod objects
P = 2; % modulation order
bpskmod = modem.pskmod('M', P, 'SymbolOrder', 'Gray', 'InputType', 'Integer');
bpskdemod = modem.pskdemod(bpskmod);

%%  Pre-allocate variables for speed
z = zeros(frLen, M);
error1m = zeros(1, numPackets); BER1m = zeros(1, length(EbNo));

h = waitbar(0, 'Percentage Completed');
set(h, 'name', 'Please wait...');
wb = 100/length(EbNo);

%% Loop over EbNo points
for idx = 1:length(EbNo)
    % Loop over the number of packets
    for packetIdx = 1:numPackets
        data = randi([0 P-1], frLen, 1);     % data vector per user/channel
        tx = modulate(bpskmod, data);        % BPSK modulation

        % Repeat for all Rx antennas
        tx_M = tx(:, ones(1,M));
                                                    
        % Create the Rayleigh channel response matrix
        H = (randn(frLen, M) + 1i*randn(frLen, M))/sqrt(2);

        % Received signal for each Rx antenna
        r = awgn(H.*tx_M, EbNo(idx));
        
        % Combiner - assume channel response known at Rx
        for i = 1:M
            z(:, i) = r(:, i).* conj(H(:, i));
        end

        % ML Detector (minimum Euclidean distance)
        demod1m = demodulate(bpskdemod, sum(z, 2)); % MR combined 

        % Determine bit errors
        error1m(packetIdx) = biterr(demod1m, data); 
    end % end of FOR loop for numPackets

    % Calculate BER for current idx
    BER1m(idx) = sum(error1m)/(numPackets*frLen);

    str_bar = [num2str(wb) '% Completed'];
    waitbar(wb/100, h, str_bar);
    wb = wb + 100/length(EbNo);
end  % end of for loop for EbNo

close(h);

% [EOF]
