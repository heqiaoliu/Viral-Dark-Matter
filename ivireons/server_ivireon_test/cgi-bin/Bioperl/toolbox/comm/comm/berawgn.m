function [ber, ser] = berawgn(EbNo, modType, varargin)
%BERAWGN Bit error rate (BER) and symbol error rate (SER) for uncoded AWGN channels.
%   BER = BERAWGN(EbNo, MODTYPE, M) returns the BER for PAM or QAM over an
%   uncoded AWGN channel with coherent demodulation.
%   EbNo -- bit energy to noise power spectral density ratio (in dB)
%   MODTYPE -- modulation type, either 'pam' or 'qam'
%   M -- alphabet size, must be a positive integer power of 2
%
%   BER = BERAWGN(EbNo, 'psk', M, DATAENC) returns the BER for coherently
%   detected PSK over an uncoded AWGN channel.
%   DATAENC -- 'diff' for differential data encoding,
%              'nondiff' for nondifferential data encoding
%
%   BER = BERAWGN(EbNo, 'oqpsk', DATAENC) returns the BER of coherently
%   detected offset-QPSK over an uncoded AWGN channel.
%
%   BER = BERAWGN(EbNo, 'dpsk', M) returns the BER for DPSK over an uncoded
%   AWGN channel.
%
%   BER = BERAWGN(EbNo, 'fsk', M, COHERENCE) returns the BER for orthogonal
%   FSK over an uncoded AWGN channel.
%   COHERENCE -- 'coherent' for coherent detection
%                'noncoherent' for noncoherent detection
%
%   BER = BERAWGN(EbNo, 'fsk', 2, COHERENCE, RHO) returns the BER for 
%   binary non-orthogonal FSK over an uncoded AWGN channel.
%   RHO -- complex correlation coefficient
%
%   BER = BERAWGN(EbNo, 'msk', PRECODING) returns the BER of coherently detected
%   MSK over an uncoded AWGN channel.  Selecting PRECODING as 'off' returns BER
%   for conventional MSK, while selecting PRECODING as 'on' returns BER for
%   precoded MSK. 
%
%   BER = BERAWGN(EbNo, 'msk', PRECODING, COHERENCE) specifies whether the
%   detection is coherent or noncoherent.
%
%   BERLB = BERAWGN(EbNo, 'cpfsk', M, MODINDEX, KMIN) returns a lower bound
%   on the BER of CPFSK over an uncoded AWGN channel.
%   MODINDEX -- modulation index
%   KMIN -- number of paths having the minimum distance
%
%   [BER, SER] = BERAWGN(EbNo, ...) returns both the BER and SER.
%
%   See also BERCODING, BERFADING, BERSYNC, BERTOOL.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2007/11/28 17:44:27 $

if (nargin < 3)
    error('comm:berawgn:numArgs', 'BERAWGN requires at least 3 arguments.');
elseif (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
    error('comm:berawgn:EbNo', 'EbNo must be a real vector.');
end

EbNoLin = 10.^(EbNo/10);    % converting EbNo from dB to linear scale
modType = lower(modType);

switch modType
    case {'psk', 'dpsk', 'pam', 'qam', 'fsk', 'cpfsk'}
        M = varargin{1};
        if ~is(M, 'scalar')
            error('comm:berawgn:scalarM', 'M must be a scalar.');
        end
        if M > 1
            k = log2(M);
        else
            k = 0.5;
        end
        if (~is(M, 'positive') || ceil(k)~=k)
            error('comm:berawgn:intM', ...
                'M must be a positive integer power of 2.');
        end
        if (strcmpi(modType, 'qam') && (M == 2))
            error('comm:berawgn:minM', 'M must be at least 4 for QAM.');
        end
end

switch modType
    case 'psk'
        if (nargin < 4)
            error('comm:berawgn:numArgsPSK', ...
                'BERAWGN requires 4 arguments for PSK.');
        end
        dataEnc = varargin{2};
        if ( ~strncmpi(dataEnc, 'n', 1) && ~strncmpi(dataEnc, 'd', 1) )
            error('comm:berawgn:dataEnc', ...
                'DATAENC must be either ''diff'' or ''nondiff''.');
        end    
    case 'oqpsk'
        dataEnc = varargin{1};
        if ( ~strncmpi(dataEnc, 'n', 1) && ~strncmpi(dataEnc, 'd', 1) )
            error('comm:berawgn:dataEnc', ...
                'DATAENC must be either ''diff'' or ''nondiff''.');
        end
    case 'fsk'
        if (nargin < 4)
            error('comm:berawgn:numArgsFSK', ...
                'BERAWGN requires at least 4 arguments for FSK.');
        end
        coherence = varargin{2};
        if (~strncmpi(coherence, 'c', 1) && ~strncmpi(coherence, 'n', 1))
            error('comm:berawgn:coherence', ...
                'COHERENCE must be either ''coherent'' or ''noncoherent''.');
        end
        rho = 0;    % Default
        if (nargin >= 5)
            rho = varargin{3};
            if ischar(rho)
                rho = str2double(rho);
            end
            if (~isnumeric(rho)) || (~isscalar(rho)) || (isnan(rho)) || (abs(rho) > 1)
                error('comm:berawgn:rho', ...
                    'RHO must be a numeric scalar with a magnitude smaller than or equal to 1.');
            end
        end
    case 'msk'
        precoding = varargin{1};
        if ( ~strncmpi(precoding, 'on', 2) && ~strncmpi(precoding, 'off', 2) )
            % It is not precoding, check if it is dataenc ('diff', 'nondiff')
            if strncmpi(precoding, 'nondiff', 1)
                warning('comm:berawgn:mskDataEncNonDiff', ...
                    ['DATAENC ''nondiff'' is equivalent to PRECODING ''on''. '...
                    'DATAENC is an obsolete option.\nPlease use PRECODING '...
                    'instead.']);
                precoding = 'on';
            elseif strncmpi(precoding, 'diff', 1)
                warning('comm:berawgn:mskDataEncDiff', ...
                    ['DATAENC ''diff'' is equivalent to PRECODING ''off''. '...
                    'DATAENC is an obsolete option.\nPlease use PRECODING '...
                    'instead.']);
                precoding = 'off';
            else
                % It is not dataenc either
                error('comm:berawgn:mskPrecoding', ...
                    'PRECODING must be either ''on'' or ''off''.');
            end
        end
        coherence = 'coherent'; % Default
        if (nargin >= 4)
            coherence = varargin{2};
            if (~strncmpi(coherence, 'c', 1) && ~strncmpi(coherence, 'n', 1))
                error('comm:berawgn:coherence', ...
                    'COHERENCE must be either ''coherent'' or ''noncoherent''.');
            end
        end
    case 'cpfsk'
        if (nargin < 5)
            error('comm:berawgn:numArgsCPFSK', ...
                'BERAWGN requires 5 arguments for CPFSK.');
        end
        modIndex = varargin{2};
        Kmin = varargin{3};
        if (~is(modIndex, 'positive') || ~is(modIndex, 'scalar'))
            error('comm:berawgn:modIndex', 'MODINDEX must be a positive number.');
        elseif (~is(Kmin, 'positive integer') || ~is(Kmin, 'scalar'))
            error('comm:berawgn:Kmin', 'KMIN must be a positive integer.');
        end
end
% end of error checking


switch modType
    case 'psk'
        if strncmpi(dataEnc, 'n', 1)
            if (M == 2)
                ser = qfunc(sqrt(2*EbNoLin));
                ber = ser;
            elseif (M == 4)
                q = qfunc(sqrt(2*EbNoLin));
                ser = 2 * q .* (1-q/2);
                ber = qfunc(sqrt(2*EbNoLin));
            else
                ser = zeros(size(EbNoLin));
                tol = 1e-4 ./ EbNoLin.^5;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                for i = 1:length(EbNoLin)
                    ser(i) = 1/pi * quad(@int_psk_1, 10e-6, pi*(1-1/M), tol(i), [], EbNoLin(i), M, k, 1);
                end
                ber = zeros(size(EbNoLin));
                PP = zeros(M/2,length(EbNoLin));
                w = gen_weights_psk(M);
                for i = 1:length(EbNoLin)
                    for j=1:M/2
                        PP(j,i) = 1 / (2*pi) * (  quad(@int_psk_1, 10e-6, pi*(1-(2*j-1)/M), tol(i), [], EbNoLin(i), M, k, j) ...
                            - quad(@int_psk_2, 10e-6, pi*(1-(2*j+1)/M), tol(i), [], EbNoLin(i), M, k, j) );
                    end
                    ber(i) = sum(w .* PP(:,i));
                end
            end
        elseif strncmpi(dataEnc, 'd', 1)
            switch M
                case 2
                    t = erfc(sqrt(EbNoLin));
                    ber = t .* (1 - t/2);
                    ser = ber;
                case 4
                    t = qfunc(sqrt(2*EbNoLin));
                    ser = 4 * (t - 2*t.^2 + 2*t.^3 - t.^4);
                    ber = 2 * (t - t.^2);
                otherwise
                    error('comm:berawgn:diffPSK', ...
                       'No results for coherent detection of differentially encoded PSK with M > 4.');
            end
        end
    case 'oqpsk'
        if strncmpi(dataEnc, 'n', 1)
            [ber ser] = berawgn(EbNo, 'psk', 4, 'nondiff');
        elseif strncmpi(dataEnc, 'd', 1)
            [ber ser] = berawgn(EbNo, 'psk', 4, 'diff');
        end
    case 'dpsk'
        ser = zeros(size(EbNoLin));
        tol = 1e-4 ./ EbNoLin.^5;
        tol(tol>1e-4) = 1e-4;
        tol(tol<eps) = eps;
        for i = 1:length(EbNoLin)
            ser(i) = 1/pi * quad(@int_dpsk, 10e-6, pi*(1-1/M), tol(i), [], EbNoLin(i), M, k);
        end
        switch M
            case 2
                ber = exp(-EbNoLin) / 2;
            case 4
                ber = zeros(size(EbNoLin));
                for i = 1:length(EbNoLin)
                    ber(i) = quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 5*pi/4) ...
                           - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, pi/4);
                end
            case 8
                ber = zeros(size(EbNoLin));
                for i = 1:length(EbNoLin)
                    ber(i) = 2/3 * ( quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 13*pi/8) ...
                           - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, pi/8) );
                end
            case 16
                ber = zeros(size(EbNoLin));
                for i = 1:length(EbNoLin)
                    ber(i) = 1/2 * ( quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 13*pi/16) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 9*pi/16) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 3*pi/16) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, pi/16) );
                end
            case 32
                ber = zeros(size(EbNoLin));
                for i = 1:length(EbNoLin)
                    ber(i) = 2/5 * ( quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 29*pi/32) ...
                            + quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 23*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 19*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 17*pi/32) ...
                            + quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 13*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 9*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, 3*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k, pi/32) );
                end
            otherwise
                ber = zeros(size(EbNoLin));
                w = gen_weights_psk(M);
                PP = zeros(M/2,length(EbNoLin));
                for i = 1:length(EbNoLin)
                    for j=1:M/2
                       PP(j,i) = quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k,(2*j+1)*pi/M) ...
                                -quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], EbNoLin(i), k,(2*j-1)*pi/M);
                    end
                    ber(i) = sum(w .* PP(:,i));
                end   
        end
    case 'pam'
        ser = 2 * (M-1)/M * qfunc(sqrt(6*k/(M^2-1)*EbNoLin));
        if (M == 2)
            ber = qfunc(sqrt(2*EbNoLin));
        elseif (M == 4)
            ber = 3/4*qfunc(sqrt(4/5*EbNoLin)) ...
                + 1/2*qfunc(3*sqrt(4/5*EbNoLin)) ...
                - 1/4*qfunc(5*sqrt(4/5*EbNoLin));
        elseif (M == 8)
            ber = 7/12*qfunc(sqrt(2/7*EbNoLin)) ...
                + 1/2*qfunc(3*sqrt(2/7*EbNoLin)) ...
                - 1/12*qfunc(5*sqrt(2/7*EbNoLin)) ...
                + 1/12*qfunc(9*sqrt(2/7*EbNoLin)) ...
                - 1/12*qfunc(13*sqrt(2/7*EbNoLin));
        else
            ber = zeros(size(EbNoLin));
            for i = 1:k
                berk = zeros(size(EbNoLin));
                for j=0:(1-2^(-i))*M - 1
                    berk = berk + (-1)^(floor(j*2^(i-1)/M)) * (2^(i-1) - floor(j*2^(i-1)/M+1/2)) ...
                        * qfunc((2*j+1)*sqrt(6*k*EbNoLin/(M^2-1)));
                end
                berk = berk*2/M;
                ber = ber + berk;
            end
            ber = ber/k;
        end    
    case 'qam'
        if (ceil(k/2) == k/2)   % k is even - square QAM
            ser = 4*(sqrt(M)-1)/sqrt(M)*qfunc(sqrt(3*k/(M-1)*EbNoLin)) ...
                 - 4*((sqrt(M)-1)/sqrt(M))^2*(qfunc(sqrt(3*k/(M-1)*EbNoLin))).^2;
            if (M == 4)
                ber = qfunc(sqrt(2*EbNoLin));
            elseif (M == 16)
                ber = 3/4*qfunc(sqrt(4/5*EbNoLin)) ...
                    + 1/2*qfunc(3*sqrt(4/5*EbNoLin)) ...
                    - 1/4*qfunc(5*sqrt(4/5*EbNoLin));
            elseif (M == 64)
                ber = 7/12*qfunc(sqrt(2/7*EbNoLin)) ...
                    + 1/2*qfunc(3*sqrt(2/7*EbNoLin)) ...
                    - 1/12*qfunc(5*sqrt(2/7*EbNoLin)) ...
                    + 1/12*qfunc(9*sqrt(2/7*EbNoLin)) ...
                    - 1/12*qfunc(13*sqrt(2/7*EbNoLin));
            else
                ber = zeros(size(EbNoLin));
                for i = 1:log2(sqrt(M))
                    berk = zeros(size(EbNoLin));
                    for j=0:(1-2^(-i))*sqrt(M) - 1
                        berk = berk + (-1)^(floor(j*2^(i-1)/sqrt(M))) * (2^(i-1) - floor(j*2^(i-1)/sqrt(M)+1/2)) ...
                            * qfunc((2*j+1)*sqrt(6*k*EbNoLin/(2*(M-1)))); 
                    end    
                    berk = berk*2/sqrt(M);
                    ber = ber + berk;
                end    
                ber = ber/log2(sqrt(M));
            end
        else    % k is odd - rectangular QAM
            I = 2^(ceil(log2(M)/2));
            J = 2^(floor(log2(M)/2));
            if (M == 8)
                ser = 5/2*qfunc(sqrt(k*EbNoLin/3)) - 3/2*(qfunc(sqrt(k*EbNoLin/3))).^2;
            else
                ser = (4*I*J-2*I-2*J)/M * qfunc(sqrt(6*log2(I*J)*EbNoLin/((I^2+J^2-2)))) ...
                        - 4/M*(1+I*J-I-J) * (qfunc(sqrt(6*log2(I*J)*EbNoLin/((I^2+J^2-2))))).^2 ;
            end
            berI = zeros(size(EbNoLin));
            berJ = zeros(size(EbNoLin));
            for i = 1:log2(I)
                berk = zeros(size(EbNoLin));
                for j=0:(1-2^(-i))*I - 1
                    berk = berk + (-1)^(floor(j*2^(i-1)/I)) * (2^(i-1) - floor(j*2^(i-1)/I+1/2)) ...
                        * qfunc((2*j+1)*sqrt(6*log2(I*J)*EbNoLin/(I^2+J^2-2)));
                end
                berk = berk*2/I;
                berI = berI + berk;
            end
            for i = 1:log2(J)
                berk = zeros(size(EbNoLin));
                for j=0:(1-2^(-i))*J - 1
                    berk = berk + (-1)^(floor(j*2^(i-1)/J)) * (2^(i-1) - floor(j*2^(i-1)/J+1/2)) ...
                        * qfunc((2*j+1)*sqrt(6*log2(I*J)*EbNoLin/(I^2+J^2-2)));
                end
                berk = berk*2/J;
                berJ = berJ + berk;
            end
            ber = (berI+berJ)/log2(I*J);
        end
    case 'fsk'
        if (rho == 0)
            % Orthogonal FSK
            if strncmpi(coherence, 'c', 1)
                ser = zeros(size(EbNoLin));
                tol = 1e-4 ./ EbNoLin.^6;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                for i = 1:length(EbNoLin)
                    ser(i) = quad(@fskc, -5, 15, tol(i), [], EbNoLin(i), M, k) / sqrt(2*pi);
                end
                ber = ser .* M./(2*(M-1));
            elseif strncmpi(coherence, 'n', 1)
                if M > 64
                    % numerical problems
                    error('comm:berawgn:FSK', ...
                        'No results for noncoherent FSK with M > 64.');
                else
                    s = warning('off', 'MATLAB:nchoosek:LargeCoefficient');
                    ser = 0;
                    for n = 1:M-1
                        ser = ser + (-1)^(n+1) * nchoosek(M-1,n) / (n+1) ...
                            .* exp(-EbNoLin*n*k/(n+1));
                    end
                    ber = ser .* M./(2*(M-1));
                    warning(s.state, s.identifier);     % recover warning state
                end
            end
        else
            % Non-orthogonal FSK
            if (M == 2)
                if strncmpi(coherence, 'c', 1)
                    ser = qfunc(sqrt(EbNoLin*(1-real(rho))));
                    ber = ser;
                elseif strncmpi(coherence, 'n', 1)
                    a = EbNoLin/2*(1-sqrt(1-(abs(rho))^2));
                    b = EbNoLin/2*(1+sqrt(1-(abs(rho))^2));
                    ser = marcumq(sqrt(a),sqrt(b)) - 1/2*exp(-(a+b)/2) .* besseli(0,sqrt(a.*b));
                    ber = ser;
                end
            else
                error('comm:berawgn:fskNonorthogonal', ...
                    'No results for coherent detection of nonorthogonal FSK with M > 2.');
            end
        end
    case 'msk'
        if strncmpi(coherence, 'c', 1)
            if strncmpi(precoding, 'on', 2)
                ber = berawgn(EbNo, 'psk', 2, 'nondiff');
                ser = ber;
            elseif strncmpi(precoding, 'off', 2)
                ber = berawgn(EbNo, 'psk', 2, 'diff');
                ser = ber;
            end
        elseif strncmpi(coherence, 'n', 1)  % upper bound
            if strncmpi(precoding, 'on', 2)
                a1 = sqrt(EbNoLin*(1-sqrt((3-4/pi^2)/4)));
                b1 = sqrt(EbNoLin*(1+sqrt((3-4/pi^2)/4)));
                a4 = sqrt(EbNoLin*(1-sqrt(1-4/pi^2)));
                b4 = sqrt(EbNoLin*(1+sqrt(1-4/pi^2)));
                ber = 1/2 * (1-marcumq(b1,a1)+marcumq(a1,b1)) ...
                    + 1/4 * (1-marcumq(b4,a4)+marcumq(a4,b4)) ...
                    + 1/2 * exp(-EbNoLin);
                ber(ber>0.5) = 0.5;
                ser = ber;
            elseif strncmpi(precoding, 'off', 2)
                error('comm:berawgn:mskPrecodingOff', ...
                    'No results available for noncoherent detection of conventional MSK.');
            end
        end
    case 'cpfsk'
        dmin2 = min((1-sinc(2 * (1:(M-1)) * modIndex)) * 2*k);  % tight upper bound
        ser = Kmin * qfunc(sqrt(EbNoLin * dmin2)); % tight lower bound
        ber = ser / k;      % converting SER lower bound to BER lower bound
    otherwise
        error('comm:berawgn:modType', 'Invalid modulation type.');
end


function out = fskc(y, EbNoLin, M, k)
% Integrand function for coherent FSK based on eq (5.2-21),
% Digital Communications (4th ed.) by Proakis, 2001.

out = (1 - (1-qfunc(y)).^(M-1)) .* exp(-.5*(y-sqrt(2*k*EbNoLin)).^2);


function out = int_psk_1(y, EbNoLin, M, k, i)
% Integrand function for PSK

out = exp(-k*EbNoLin*(sin((2*i-1)*pi/M))^2./(sin(y)).^2);


function out = int_psk_2(y, EbNoLin, M, k, i)
% Integrand function for PSK

out = exp(-k*EbNoLin*(sin((2*i+1)*pi/M))^2./(sin(y)).^2);


function out = int_dpsk(y, EbNoLin, M, k)
% Integrand function for DPSK: Simon and Alouini 2000, eq. 8.90 

out = exp( -k * EbNoLin * (sin(pi/M))^2 ./ ( 1 + sqrt ( 1- (sin(pi/M)).^2 ) .* cos(y) ) );


function out = int_dpsk_ber(y, EbNoLin, k, ksi)
% Integrand function for ber of DPSK: Simon and Alouini 2000, eq. 8.87

out = -sin(ksi)/(4*pi) * exp( -k * EbNoLin * (1-cos(ksi)*cos(y))) ./ ( 1 - cos(ksi)*cos(y) );


function weights = gen_weights_psk(M)

k = log2(M);
z = zeros(M,k);
[y,map] = bin2gray(de2bi(0:M-1,'left-msb'),'psk',M);
z(:,:) = y(map+1,:);
w = sum(z,2);
wsym = [ w(2:M/2) + flipud(w(M/2+2:M)) ; w(M/2+1) ];
weights = wsym/k;
