%% Introduction to MIMO Systems
% This demo introduces Multiple-Input-Multiple-Output (MIMO) systems, which
% use multiple antennas at the transmitter and receiver ends of a wireless
% communication system. MIMO systems are increasingly being adopted in 
% communication systems for the potential gains in capacity they realize when
% using multiple antennas. Multiple antennas use the spatial dimension in
% addition to the time and frequency ones, without changing the bandwidth 
% requirements of the system.
%
% For a generic communications link, this demo focuses on transmit diversity
% in lieu of traditional receive diversity. Using the flat-fading Rayleigh
% channel, it illustrates the concept of Orthogonal Space-Time Block Coding,
% which is employable when multiple transmitter antennas are used. It is 
% assumed here that the channel undergoes independent fading between the 
% multiple transmit-receive antenna pairs.
%
% For a chosen system, it also provides a measure of the performance
% degradation when the channel is imperfectly estimated at the receiver, 
% compared to the case of perfect channel knowledge at the receiver.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/01/05 17:46:01 $


%% PART 1: Transmit Diversity vs. Receive Diversity
%
% Using diversity reception is a well-known technique to mitigate the effects
% of fading over a communications link. However, it has mostly been relegated
% to the receiver end. In [1], Alamouti proposes a transmit diversity scheme 
% that offers similar diversity gains, using multiple antennas at the 
% transmitter. This was conceived to be more practical as, for example, it 
% would only require multiple antennas at the base station in comparison to 
% multiple antennas for every mobile in a cellular communications system.
%
% This section highlights this comparison of transmit vs. receive diversity
% by simulating coherent binary phase-shift keying (BPSK) modulation over
% flat-fading Rayleigh channels. For transmit diversity, we use two transmit    
% antennas and one receive antenna (2x1 notationally), while for receive 
% diversity we employ one transmit antenna and two receive antennas 
% (1x2 notationally). 
%
% The simulation covers an end-to-end system showing the encoded and/or 
% transmitted signal, channel model, and reception and demodulation of the 
% received signal. It also provides the no-diversity link (single transmit-
% receive antenna case) and theoretical performance of second-order diversity 
% link for comparison. It is assumed here that the channel is known perfectly 
% at the receiver for all systems. We run the simulation over a range of Eb/No 
% points to generate BER results that allow us to compare the different systems.

%%
% We start by defining some common simulation parameters
frmLen = 100;       % frame length
numPackets = 1000;  % number of packets
EbNo = 0:2:20;      % Eb/No varying to 20 dB
N = 2;              % maximum number of Tx antennas
M = 2;              % maximum number of Rx antennas

%%
% and set up the simulation.

% Create a local random stream to be used by random number generators for
% repeatability.
hStr = RandStream('mt19937ar', 'Seed', 55408);

% Create BPSK mod-demod objects
P = 2;				% modulation order
bpskmod = modem.pskmod('M', P, 'SymbolOrder', 'Gray');
bpskdemod = modem.pskdemod(bpskmod);

% Pre-allocate variables for speed
tx2 = zeros(frmLen, N); H  = zeros(frmLen, N, M);
r21 = zeros(frmLen, 1); r12  = zeros(frmLen, 2);
z21 = zeros(frmLen, 1); z21_1 = zeros(frmLen/N, 1); z21_2 = z21_1;
z12 = zeros(frmLen, M);
error11 = zeros(1, numPackets); BER11 = zeros(1, length(EbNo));
error21 = error11; BER21 = BER11; error12 = error11; BER12 = BER11; BERthy2 = BER11;

%%

% Set up a figure for visualizing BER results
h = gcf; grid on; hold on;
set(gca, 'yscale', 'log', 'xlim', [EbNo(1), EbNo(end)], 'ylim', [1e-4 1]);
xlabel('Eb/No (dB)'); ylabel('BER'); set(h,'NumberTitle','off');
set(h, 'renderer', 'zbuffer'); set(h,'Name','Transmit vs. Receive Diversity');
title('Transmit vs. Receive Diversity');

% Loop over several EbNo points
for idx = 1:length(EbNo)
    % Loop over the number of packets
    for packetIdx = 1:numPackets
        data = randi(hStr, [0 P-1], frmLen, 1);   % data vector per user 
                                                  % per channel
        tx = modulate(bpskmod, data);             % BPSK modulation

        % Alamouti Space-Time Block Encoder, G2, full rate
        %   G2 = [s1 s2; -s2* s1*]
        s1 = tx(1:N:end); s2 = tx(2:N:end);
        tx2(1:N:end, :) = [s1 s2];
        tx2(2:N:end, :) = [-conj(s2) conj(s1)];

        % Create the Rayleigh distributed channel response matrix
        %   for two transmit and two receive antennas
        H(1:N:end, :, :) = (randn(hStr, frmLen/2, N, M) + ...
                                1i*randn(hStr, frmLen/2, N, M))/sqrt(2);
        %   assume held constant for 2 symbol periods
        H(2:N:end, :, :) = H(1:N:end, :, :);

        % Received signals
        %   for uncoded 1x1 system
        r11 = awgn(H(:, 1, 1).*tx, EbNo(idx), 0, hStr);

        %   for G2-coded 2x1 system - with normalized Tx power, i.e., the
        %	total transmitted power is assumed constant
        r21 = awgn(sum(H(:, :, 1).*tx2, 2)/sqrt(N), EbNo(idx), 0, hStr);

        %   for Maximal-ratio combined 1x2 system
        for i = 1:M
            r12(:, i) = awgn(H(:, 1, i).*tx, EbNo(idx), 0, hStr);
        end

        % Front-end Combiners - assume channel response known at Rx
        %   for G2-coded 2x1 system
        hidx = 1:N:length(H);
        z21_1 = r21(1:N:end).* conj(H(hidx, 1, 1)) + ...
                conj(r21(2:N:end)).* H(hidx, 2, 1);

        z21_2 = r21(1:N:end).* conj(H(hidx, 2, 1)) - ...
                conj(r21(2:N:end)).* H(hidx, 1, 1);
        z21(1:N:end) = z21_1; z21(2:N:end) = z21_2;

        %   for Maximal-ratio combined 1x2 system
        for i = 1:M
            z12(:, i) = r12(:, i).* conj(H(:, 1, i));
        end

        % ML Detector (minimum Euclidean distance)
        demod11 = demodulate(bpskdemod, r11.*conj(H(:, 1, 1)));
        demod21 = demodulate(bpskdemod, z21);
        demod12 = demodulate(bpskdemod, sum(z12, 2));

        % Determine errors
        error11(packetIdx) = biterr(demod11, data);
        error21(packetIdx) = biterr(demod21, data);
        error12(packetIdx) = biterr(demod12, data);
    end % end of FOR loop for numPackets

    % Calculate BER for current idx
    %   for uncoded 1x1 system
    BER11(idx) = sum(error11)/(numPackets*frmLen);

    %   for G2 coded 2x1 system
    BER21(idx) = sum(error21)/(numPackets*frmLen);

    %   for Maximal-ratio combined 1x2 system
    BER12(idx) = sum(error12)/(numPackets*frmLen);

    %   for theoretical performance of second-order diversity
    BERthy2(idx) = berfading(EbNo(idx), 'psk', 2, 2);
    
    % Plot results
    semilogy(EbNo(1:idx), BER11(1:idx), 'r*', ...
             EbNo(1:idx), BER21(1:idx), 'go', ...
             EbNo(1:idx), BER12(1:idx), 'bs', ...
             EbNo(1:idx), BERthy2(1:idx), 'm');
    legend('No Diversity (1Tx, 1Rx)', 'Alamouti (2Tx, 1Rx)',...
           'Maximal-Ratio Combining (1Tx, 2Rx)', ...
           'Theoretical 2nd-Order Diversity');
    
    drawnow;
end  % end of for loop for EbNo

% Perform curve fitting and replot the results
fitBER11 = berfit(EbNo, BER11);
fitBER21 = berfit(EbNo, BER21);
fitBER12 = berfit(EbNo, BER12);
semilogy(EbNo, fitBER11, 'r', EbNo, fitBER21, 'g', EbNo, fitBER12, 'b');
hold off;

%%
% The transmit diversity system has a computation complexity very similar to 
% that of the receive diversity system.
%
% The resulting simulation results show that using two transmit antennas and 
% one receive antenna provides the same diversity order as the maximal-ratio
% combined (MRC) system of one transmit antenna and two receive antennas. 
%
% Also observe that transmit diversity has a 3 dB disadvantage when compared
% to MRC receive diversity. This is because we modelled the total transmitted 
% power to be the same in both cases. If we calibrate the transmitted power
% such that the received power for these two cases is the same, then the
% performance would be identical. The theoretical performance of second-order 
% diversity link matches the transmit diversity system as it normalizes the 
% total power across all the diversity branches.
%
% The accompanying functional scripts, MRC1M.m and OSTBC2M.m aid further 
% exploration for the interested users.


%% PART 2: Space-Time Block Coding with Channel Estimation
%
% Building on the theory of orthogonal designs, Tarokh et al. [2] generalized  
% Alamouti's transmit diversity scheme to an arbitrary number of transmitter
% antennas, leading to the concept of Space-Time Block Codes. For complex 
% signal constellations, they showed that Alamouti's scheme is the only
% full-rate scheme for two transmit antennas.
%
% In this section, we study the performance of such a scheme with two receive
% antennas (i.e., a 2x2 system) with and without channel estimation. In the 
% realistic scenario where the channel state information is not known at the 
% receiver, this has to be extracted from the received signal. We assume that 
% the channel estimator performs this using orthogonal pilot signals that are 
% prepended to every packet [3]. It is assumed that the channel remains 
% unchanged for the length of the packet (i.e., it undergoes slow fading).
%
% A simulation similar to the one described in the previous section is employed
% here, which leads us to estimate the BER performance for a space-time block 
% coded system using two transmit and two receive antennas.

%%
% Again we start by defining the common simulation parameters
frmLen = 100;           % frame length
maxNumErrs = 300;       % maximum number of errors
maxNumPackets = 3000;   % maximum number of packets
EbNo = 0:2:12;          % Eb/No varying to 12 dB
N = 2;                  % number of Tx antennas
M = 2;                  % number of Rx antennas
pLen = 8;               % number of pilot symbols per frame
W = hadamard(pLen);
pilots = W(:, 1:N);     % orthogonal set per transmit antenna

%%
% and set up the simulation.

% Reset the local stream
reset(hStr)

% Pre-allocate variables for speed
tx2 = zeros(frmLen, N); r = zeros(pLen + frmLen, M);
H = zeros(pLen + frmLen, N, M); H_e = zeros(frmLen, N, M);
z_e = zeros(frmLen, M); z1_e = zeros(frmLen/N, M); z2_e = z1_e;
z = z_e; z1 = z1_e; z2 = z2_e;
BER22_e = zeros(1, length(EbNo)); BER22 = BER22_e;

%%

% Set up a figure for visualizing BER results
clf(h); grid on; hold on;
set(gca,'yscale','log','xlim',[EbNo(1), EbNo(end)],'ylim',[1e-4 1]);
xlabel('Eb/No (dB)'); ylabel('BER'); set(h,'NumberTitle','off');
set(h,'Name','Orthogonal Space-Time Block Coding');
set(h, 'renderer', 'zbuffer');  title('G2-coded 2x2 System');

% Loop over several EbNo points
for idx = 1:length(EbNo)
    numPackets = 0; totNumErr22 = 0; totNumErr22_e = 0;

    % Loop till the number of errors exceed 'maxNumErrs'
    % or the maximum number of packets have been simulated
    while (totNumErr22 < maxNumErrs) && (totNumErr22_e < maxNumErrs) && ...
          (numPackets < maxNumPackets)
        data = randi(hStr, [0 P-1], frmLen, 1);  % data vector per user 
                                                 % per channel
        tx = modulate(bpskmod, data);            % BPSK modulation

        % Alamouti Space-Time Block Encoder, G2, full rate
        % G2 = [s1 s2; -s2* s1*]
        s1 = tx(1:N:end); s2 = tx(2:N:end);
        tx2(1:N:end, :) = [s1 s2];
        tx2(2:N:end, :) = [-conj(s2) conj(s1)];

        % Prepend pilot symbols for each frame
        transmit = [pilots; tx2];

        % Create the Rayleigh distributed channel response matrix
        H(1, :, :) = (randn(hStr, N, M) + 1i*randn(hStr, N, M))/sqrt(2);
        %   assume held constant for the whole frame and pilot symbols
        H = H(ones(pLen + frmLen, 1), :, :);

        % Received signal for each Rx antenna
        %   with pilot symbols transmitted
        for i = 1:M
            % with normalized Tx power
            r(:, i) = awgn(sum(H(:, :, i).*transmit, 2)/sqrt(N), ...
                EbNo(idx), 0, hStr);
        end

        % Channel Estimation
        %   For each link => N*M estimates
        for n = 1:N
            H_e(1, n, :) = (r(1:pLen, :).' * pilots(:, n))./pLen;
        end
        %   assume held constant for the whole frame
        H_e = H_e(ones(frmLen, 1), :, :);

        % Combiner using estimated channel
        heidx = 1:N:length(H_e);
        for i = 1:M
            z1_e(:, i) = r(pLen+1:N:end, i).* conj(H_e(heidx, 1, i)) + ...
                         conj(r(pLen+2:N:end, i)).* H_e(heidx, 2, i);

            z2_e(:, i) = r(pLen+1:N:end, i).* conj(H_e(heidx, 2, i)) - ...
                         conj(r(pLen+2:N:end, i)).* H_e(heidx, 1, i);
        end
        z_e(1:N:end, :) = z1_e; z_e(2:N:end, :) = z2_e;

        % Combiner using known channel
        hidx = pLen+1:N:length(H);
        for i = 1:M
            z1(:, i) = r(pLen+1:N:end, i).* conj(H(hidx, 1, i)) + ...
                       conj(r(pLen+2:N:end, i)).* H(hidx, 2, i);

            z2(:, i) = r(pLen+1:N:end, i).* conj(H(hidx, 2, i)) - ...
                       conj(r(pLen+2:N:end, i)).* H(hidx, 1, i);
        end
        z(1:N:end, :) = z1; z(2:N:end, :) = z2;

        % ML Detector (minimum Euclidean distance)
        demod22_e = demodulate(bpskdemod, sum(z_e, 2)); % estimated
        demod22   = demodulate(bpskdemod, sum(z, 2));   % known

        % Determine errors
        numPackets = numPackets + 1;
        totNumErr22_e = totNumErr22_e + biterr(demod22_e, data);
        totNumErr22   = totNumErr22 + biterr(demod22, data);
    end % end of FOR loop for numPackets

    % Calculate BER for current idx
    %   for estimated channel
    BER22_e(idx) = totNumErr22_e/(numPackets*frmLen);

    %   for known channel
    BER22(idx) = totNumErr22/(numPackets*frmLen);

    % Plot results
    semilogy(EbNo(1:idx), BER22_e(1:idx), 'ro');
    semilogy(EbNo(1:idx), BER22(1:idx),   'g*');
    legend(['Channel estimated with ' num2str(pLen) ' pilot symbols/frame'],...
           'Known channel');
    drawnow;
end  % end of for loop for EbNo

% Perform curve fitting and replot the results
fitBER22_e = berfit(EbNo, BER22_e);
fitBER22 = berfit(EbNo, BER22);
semilogy(EbNo, fitBER22_e, 'r', EbNo, fitBER22, 'g'); hold off;

%%
% For the 2x2 simulated system, the diversity order is different than that seen
% for either 1x2 or 2x1 systems in the previous section. 
%
% Note that with 8 pilot symbols for each 100 symbols of data, channel 
% estimation causes about a 1 dB degradation in performance for the selected 
% Eb/No range. This improves with an increase in the number of pilot symbols
% per frame but adds to the overhead of the link. In this comparison, we 
% keep the transmitted SNR per symbol to be the same in both cases.
%
% The accompanying functional script, OSTBC2M_E.m aids further experimentation
% for the interested users.


%% PART 3: Orthogonal Space-Time Block Coding and Further Explorations
%
% In this final section, we present some performance results for orthogonal
% space-time block coding using four transmit antennas (4x1 system) using a  
% half-rate code, G4, as per [4].
%
% We expect the system to offer a diversity order of 4 and will compare it with
% 1x4 and 2x2 systems, which have the same diversity order also. To allow for a
% fair comparison, we use quaternary PSK with the half-rate G4 code to achieve
% the same transmission rate of 1 bit/sec/Hz.
%
% Since these results take some time to generate, we load the results from a
% prior simulation. The functional script OSTBC4M.m is included, which, along 
% with MRC1M.m and OSTBC2M.m, was used to generate these results. The user is 
% urged to use these scripts as a starting point to study other codes and 
% systems.

load ostbcRes.mat;

% Set up a figure for visualizing BER results
clf(h); grid on; hold on; set(h, 'renderer', 'zbuffer');
set(gca, 'yscale', 'log', 'xlim', [EbNo(1), EbNo(end)], 'ylim', [1e-5 1]);
xlabel('Eb/No (dB)'); ylabel('BER'); set(h,'NumberTitle','off');
set(h,'Name','Orthogonal Space-Time Block Coding(2)');
title('G4-coded 4x1 System and Other Comparisons');

% Theoretical performance of fourth-order diversity for QPSK
BERthy4 = berfading(EbNo, 'psk', 4, 4);

% Plot results
semilogy(EbNo, ber11, 'r*', EbNo, ber41, 'ms', EbNo, ber22, 'c^', ...
         EbNo, ber14, 'ko', EbNo, BERthy4, 'g');
legend('No Diversity (1Tx, 1Rx), BPSK', 'OSTBC (4Tx, 1Rx), QPSK', ...
       'Alamouti (2Tx, 2Rx), BPSK', 'Maximal-Ratio Combining (1Tx, 4Rx), BPSK', ...
       'Theoretical 4th-Order Diversity, QPSK');

% Perform curve fitting
fitBER11 = berfit(EbNo, ber11);
fitBER41 = berfit(EbNo(1:9), ber41(1:9));
fitBER22 = berfit(EbNo(1:8), ber22(1:8));
fitBER14 = berfit(EbNo(1:7), ber14(1:7));
semilogy(EbNo, fitBER11, 'r', EbNo(1:9), fitBER41, 'm', ...
         EbNo(1:8), fitBER22, 'c', EbNo(1:7), fitBER14, 'k'); hold off;

%% 
% As expected, the similar slopes of the BER curves for the 4x1, 2x2 and 1x4
% systems indicate an identical diversity order for each system. 
%
% Also observe the 3 dB penalty for the 4x1 system that can be attributed 
% to the same total transmitted power assumption made for each of the three
% systems. If we calibrate the transmitted power such that the received power 
% for each of these systems is the same, then the three systems would perform
% identically. Again, the theoretical performance matches the simulation 
% performance of the 4x1 system as the total power is normalized across the
% diversity branches.
   

%%
% References:
%
%   [1] S. M. Alamouti, "A simple transmit diversity technique for wireless 
%       communications", IEEE(R) Journal on Selected Areas in Communications, 
%       Vol. 16, No. 8, Oct. 1998, pp. 1451-1458.
%
%   [2] V. Tarokh, H. Jafarkhami, and A.R. Calderbank, "Space-time block codes
%       from orthogonal designs", IEEE Transactions on Information Theory, 
%       Vol. 45, No. 5, Jul. 1999, pp. 1456-1467.
%
%   [3] A.F. Naguib, V. Tarokh, N. Seshadri, and A.R. Calderbank, "Space-time
%       codes for high data rate wireless communication: Mismatch analysis", 
%       Proceedings of IEEE International Conf. on Communications, 
%       pp. 309-313, June 1997.        
%
%   [4] V. Tarokh, H. Jafarkhami, and A.R. Calderbank, "Space-time block codes
%       for wireless communications: Performance results", IEEE Journal on 
%       Selected Areas in Communications, Vol. 17,  No. 3, Mar. 1999, 
%       pp. 451-460.

displayEndOfDemoMessage(mfilename)
