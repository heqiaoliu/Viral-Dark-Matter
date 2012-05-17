function BER4m = ostbc4m(M, frLen, numPackets, EbNo)
%OSTBC4M  Orthogonal space-time block coding for 4xM antenna configurations.
%
%   BER4M = OSTBC4M(M, FRLEN, NUMPACKETS, EBNOVEC) computes the bit-error rate 
%   estimates via simulation for an orthogonal space-time block coded 
%	configuration using four transmit antennas and M receive antennas, where 
%	the frame length, number of packets simulated and the Eb/No range of values 
%	are given by FRLEN, NUMPACKETS, and EBNOVEC parameters respectively.
%
%   The simulation uses a half-rate orthogonal STBC encoding scheme with QPSK 
%   modulated symbols to achieve a 1 bit/sec/Hz throughput for the channel. 
%   Appropriate combining is performed at the receiver to account for the 
%   multiple transmitter antennas.
%
%   Suggested parameter values:
%       M = 1 to 4; FRLEN = 100; NUMPACKETS = 1000; EBNOVEC = 0:2:20;
%
%   Example:
%       ber42 = ostbc4m(2, 100, 1000, 0:2:20);
%
%   See also MRC1M, OSTBC2M.

%   References:
%   [1] S. M. Alamouti, "A simple transmit diversity technique for wireless 
%       communications", IEEE Journal on Selected Areas in Communications, 
%       Vol. 16, No. 8, Oct. 1998, pp. 1451-1458.
%
%   [2] V. Tarokh, H. Jafarkhami, and A.R. Calderbank, "Space-time block codes
%       from orthogonal designs", IEEE Transactions on Information Theory, 
%       Vol. 45, No. 5, Jul. 1999, pp. 1456-1467.
%
%   [3] V. Tarokh, H. Jafarkhami, and A.R. Calderbank, "Space-time block codes
%       for wireless communications: Performance results", IEEE Journal on 
%       Selected Areas in Communications, Vol. 17,  No. 3, Mar. 1999, 
%       pp. 451-460.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/01/05 17:46:05 $

%% Simulation parameters
N = 4;              % Number of transmit antennas
rate = 0.5; inc = N/rate; repFactor = 8;
 
% Create QPSK mod-demod objects
numBits = 2; 
P = 4; 		% modulation order
qpskmod = modem.pskmod('M', P, 'SymbolOrder', 'Gray', 'InputType', 'Integer');
qpskdemod = modem.pskdemod(qpskmod);

%% Pre-allocate variables for speed
txEnc = zeros(frLen/rate, N); r = zeros(frLen/rate, M);
H  = zeros(frLen/rate, N, M);
z = zeros(frLen, M); z1 = zeros(frLen/N, M); z2 = z1; z3 = z1; z4 = z1;
error4m = zeros(1, numPackets); error4mb = error4m;
SER4m = zeros(1, length(EbNo)); BER4m = SER4m;

h = waitbar(0, 'Percentage Completed');
set(h, 'name', 'Please wait...');
wb = 100/length(EbNo);

%% Loop over EbNo points
for idx = 1:length(EbNo)
    % Loop over the number of packets
    for packetIdx = 1:numPackets
        data = randi([0 P-1], frLen, 1);     % data vector per user/channel
        tx = modulate(qpskmod, data);        % QPSK modulation

        % Space-Time Block Encoder - G4, 1/2 rate
        %   G4Half = [s1 s2 s3 s4;-s2 s1 -s4 s3;-s3 s4 s1 -s2;-s4 -s3 s2 s1];
        %   G4 = [G4Half; conj(G4Half)];
        s1 = tx(1:N:end); s2 = tx(2:N:end); s3 = tx(3:N:end); s4 = tx(4:N:end);
        txEnc(1:inc:end, :) = [ s1  s2  s3  s4];
        txEnc(2:inc:end, :) = [-s2  s1 -s4  s3];
        txEnc(3:inc:end, :) = [-s3  s4  s1 -s2];
        txEnc(4:inc:end, :) = [-s4 -s3  s2  s1];
        for i = 1:4
            txEnc(i+4:inc:end, :) = conj(txEnc(i:inc:end, :));
        end
             
        % Create the Rayleigh channel response matrix
        H(1:inc:end, :, :) = (randn(frLen/rate/repFactor, N, M) + ...
                                1i*randn(frLen/rate/repFactor, N, M))/sqrt(2);
        %   held constant for repFactor symbol periods
        for i = 2:repFactor
            H(i:inc:end, :, :) = H(1:inc:end, :, :); 
        end

        % Received signal for each Rx antenna
        for i = 1:M
            % with power normalization
            r(:, i) = awgn(sum(H(:, :, i).*txEnc, 2)/sqrt(N), EbNo(idx));
        end

        % Combiner - assume channel response known at Rx
        hidx = 1:inc:length(H);
        for i = 1:M
            z1(:, i) = r(1:inc:end, i).* conj(H(hidx, 1, i)) + ...
                       r(2:inc:end, i).* conj(H(hidx, 2, i)) + ...
                       r(3:inc:end, i).* conj(H(hidx, 3, i)) + ...
                       r(4:inc:end, i).* conj(H(hidx, 4, i)) + ...
                       conj(r(5:inc:end, i)).* H(hidx, 1, i) + ...
                       conj(r(6:inc:end, i)).* H(hidx, 2, i) + ...
                       conj(r(7:inc:end, i)).* H(hidx, 3, i) + ...
                       conj(r(8:inc:end, i)).* H(hidx, 4, i);
    
            z2(:, i) = r(1:inc:end, i).* conj(H(hidx, 2, i)) - ...
                       r(2:inc:end, i).* conj(H(hidx, 1, i)) - ...
                       r(3:inc:end, i).* conj(H(hidx, 4, i)) + ...
                       r(4:inc:end, i).* conj(H(hidx, 3, i)) + ...
                       conj(r(5:inc:end, i)).* H(hidx, 2, i) - ...
                       conj(r(6:inc:end, i)).* H(hidx, 1, i) - ...
                       conj(r(7:inc:end, i)).* H(hidx, 4, i) + ...
                       conj(r(8:inc:end, i)).* H(hidx, 3, i);
    
            z3(:, i) = r(1:inc:end, i).* conj(H(hidx, 3, i)) + ...
                       r(2:inc:end, i).* conj(H(hidx, 4, i)) - ...
                       r(3:inc:end, i).* conj(H(hidx, 1, i)) - ...
                       r(4:inc:end, i).* conj(H(hidx, 2, i)) + ...
                       conj(r(5:inc:end, i)).* H(hidx, 3, i) + ...
                       conj(r(6:inc:end, i)).* H(hidx, 4, i) - ...
                       conj(r(7:inc:end, i)).* H(hidx, 1, i) - ...
                       conj(r(8:inc:end, i)).* H(hidx, 2, i);
    
            z4(:, i) = r(1:inc:end, i).* conj(H(hidx, 4, i)) - ...
                       r(2:inc:end, i).* conj(H(hidx, 3, i)) + ...
                       r(3:inc:end, i).* conj(H(hidx, 2, i)) - ...
                       r(4:inc:end, i).* conj(H(hidx, 1, i)) + ... 
                       conj(r(5:inc:end, i)).* H(hidx, 4, i) - ...
                       conj(r(6:inc:end, i)).* H(hidx, 3, i) + ...
                       conj(r(7:inc:end, i)).* H(hidx, 2, i) - ...
                       conj(r(8:inc:end, i)).* H(hidx, 1, i);
        end
        z(1:N:end, :) = z1; z(2:N:end, :) = z2;
        z(3:N:end, :) = z3; z(4:N:end, :) = z4;

        % ML Detector (minimum Euclidean distance)
        demod4m = demodulate(qpskdemod, sum(z, 2));

        % Determine symbol errors
        error4m(packetIdx) = symerr(demod4m, data); % for G4 coded

        % Determine bit errors
        error4mb(packetIdx) = biterr(de2bi(demod4m, numBits), ...
        							 de2bi(data, numBits)); 
    end % end of FOR loop for numPackets

    % Calculate SER and BER for current idx
    SER4m(idx) = sum(error4m)/(numPackets*frLen); % G4 coded
    BER4m(idx) = sum(error4mb)/(numPackets*frLen*numBits);

    str_bar = [num2str(wb) '% Completed'];
    waitbar(wb/100, h, str_bar);
    wb = wb + 100/length(EbNo);
end  % end of for loop for EbNo

close(h);

% [EOF]
