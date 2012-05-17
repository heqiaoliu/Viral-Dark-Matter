function [TxCorrelationMatrix, RxCorrelationMatrix] ...
    = calculateCorrMatrix(Nt, Nr, pdb1, pdb2, TxSpacing, RxSpacing, ...
                                AS_Tx_C1, AS_Tx_C2, AoD_C1, AoD_C2, ...
                                AS_Rx_C1, AS_Rx_C2, AoA_C1, AoA_C2)
% Calculates the Tx and Rx correlation matrices for a multipath MIMO
% channel, according to a procedure similar to that in [1], [2].
%
% References:
%   [1] IEEE P802.11 Wireless LANs, "TGn Channel Models", IEEE
%   802.11-03/940r4, 2004-05-10.
%   [2] L. Schumacher, K. I. Pedersen, and P. E. Mogensen, "From antenna
%   spacings to theoretical capacities - Guidelines for simulating MIMO
%   systems", Proc. PIMRC Conf., vol. 2, Sep. 2002, pp. 587-592.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/04 22:16:41 $

Np = length(pdb1);  % Number of paths

% Concatenated clusters for each path
AS_Tx = [AS_Tx_C1; AS_Tx_C2];
AoD = [AoD_C1; AoD_C2];
AS_Rx = [AS_Rx_C1; AS_Rx_C2];
AoA = [AoA_C1; AoA_C2];

MaxNcTx = size(AS_Tx, 1);   % Maximum number of Tx clusters across all paths
MaxNcRx = size(AS_Rx, 1);   % Maximum number of Rx clusters across all paths

% Non-null clusters for each path
validClustersTx = ~isinf(AS_Tx);
validClustersRx = ~isinf(AS_Rx);

NcTx = sum(validClustersTx, 1); % Actual number of Tx clusters for each path
NcRx = sum(validClustersRx, 1); % Actual number of Rx clusters for each path

% Initialize Tx and Rx correlation matrices
TxCorrelationMatrix = zeros(Nt, Nt, Np);
RxCorrelationMatrix = zeros(Nr, Nr, Np);

% Loop over number of paths
for ip = 1:Np
 
    % Calculation of Tx correlation matrices
    Rt_XX = zeros(1, Nt);
    Rt_XY = zeros(1, Nt);
    
    phi0Tx = AoD(:,ip) * pi/180;
    sigmaTx = AS_Tx(:, ip) * pi/180;
    delta_theta = 180 * pi/180;
    
    % Calculation of approximate normalization coefficient(s)
    QTx = calculateQ(NcTx(ip), pdb1(ip), pdb2(ip), sigmaTx, delta_theta);

    for ic = 1:MaxNcTx
        if validClustersTx(ic, ip) == 1  % Check if valid cluster
            if NcTx(ip) == 1
                iq = 1;
            else    
                iq = ic;
            end    
            Rt_XX = Rt_XX + QTx(iq) * calculateR_XX(Nt, TxSpacing, ...
                                sigmaTx(ic), phi0Tx(ic), delta_theta);
            Rt_XY = Rt_XY + QTx(iq) * calculateR_XY(Nt, TxSpacing, ...
                                sigmaTx(ic), phi0Tx(ic), delta_theta);
        end
    end
    TxCorrelationMatrix(:,:,ip) = toeplitz(Rt_XX + sqrt(-1)* Rt_XY); 
    for it = 1:Nt
        TxCorrelationMatrix(it,it,ip) = 1;    % Ensures diagonal elements 
                                              % are exactly 1
    end    
    
    % Calculation of Rx correlation matrices
    Rr_XX = zeros(1, Nr);
    Rr_XY = zeros(1, Nr);
    
    phi0Rx = AoA(:, ip) * pi/180;
    sigmaRx = AS_Rx(:, ip) * pi/180;
            
    % Calculation of approximate normalization coefficient(s)
    QRx = calculateQ(NcRx(ip), pdb1(ip), pdb2(ip), sigmaRx, delta_theta);

    for ic = 1:MaxNcRx
        if validClustersRx(ic, ip) == 1  % Check if valid cluster
            if NcRx(ip) == 1
                iq = 1;
            else    
                iq = ic;
            end
            Rr_XX = Rr_XX + QRx(iq) * calculateR_XX(Nt, RxSpacing, ...
                                    sigmaRx(ic), phi0Rx(ic), delta_theta);
            Rr_XY = Rr_XY + QRx(iq) * calculateR_XY(Nt, RxSpacing, ...
                                    sigmaRx(ic), phi0Rx(ic), delta_theta);
        end
    end
    RxCorrelationMatrix(:,:,ip) = toeplitz(Rr_XX + sqrt(-1)* Rr_XY);
    for ir = 1:Nr
        RxCorrelationMatrix(ir,ir,ip) = 1;    % Ensures diagonal elements 
                                              % are exactly 1
    end    
end

function Q = calculateQ(Nc, pdb1, pdb2, sigma, delta_theta)
% Note: the truncated Laplacian power azimuth spectrum is treated as a
% probability distribution function. This approximation can result in
% slightly different values than those obtained in the reference software
% of [1], for paths with multiple clusters.

% Solve Eq. (13) of [2], taking into account the standard deviation and
% power of each cluster.
if Nc == 1
    Q = 1/(1-exp(-sqrt(2)*delta_theta/sigma(sigma>-Inf)));
elseif Nc == 2
    Q = zeros(1, 2);
    Q(1) = 1/( 1-exp(-sqrt(2)*delta_theta/sigma(1)) ...
        + (sigma(2)*10^(pdb2/10))/(sigma(1)*10^(pdb1/10)) ...
        * (1-exp(-sqrt(2)*delta_theta/sigma(2))) );
    Q(2) = Q(1) * (sigma(2)*10^(pdb2/10))/(sigma(1)*10^(pdb1/10));
end

function R_XX = calculateR_XX(N, spacing, sigma, phi0, delta_theta)
% Eq. (14) of [2]

R_XX = zeros(1, N);
R_XX(1,1) = 1;

for n = 2:N
    D = (n-1) * 2*pi* spacing;
    R_XX(1, n) = besselj(0,D);
    mInf = 100;
    sum_m = 0;
    for m = 1:mInf
        sum_m = sum_m + besselj(2*m,D)* 1/((sqrt(2)/sigma)^2+(2*m)^2) * ...
            cos(2*m*phi0).* ( sqrt(2)/sigma + exp(-sqrt(2)/sigma*delta_theta) ...
            * (-sqrt(2)/sigma*cos(2*m*delta_theta) + 2*m*sin(2*m*delta_theta) ) );
    end
    R_XX(1, n) = R_XX(1, n) + sum_m * 4/(sqrt(2)*sigma);
end

function R_XY = calculateR_XY(N, spacing, sigma, phi0, delta_theta)
% Eq. (15) of [2] (with some typos corrected: the minus before the
% exponential is a plus, and the plus before the cosine is a minus)

R_XY = zeros(1, N);
R_XY(1,1) = 0;

for n = 2:N
    D = (n-1) * 2*pi* spacing;
    R_XY(1, n) = 0;
    mInf = 100;
    sum_m = 0;
    for m = 0:mInf
        sum_m = sum_m + besselj(2*m+1,D)* 1/((sqrt(2)/sigma)^2+(2*m+1)^2) ...
            * sin((2*m+1)*phi0) .* ( sqrt(2)/sigma + exp(-sqrt(2)/sigma*delta_theta) ...
            * (-sqrt(2)/sigma*cos((2*m+1)*delta_theta) + (2*m+1)*sin((2*m+1)*delta_theta) ) );
    end
    R_XY(1, n) = R_XY(1, n) + sum_m * 4/(sqrt(2)*sigma);
end

% [EOF]
