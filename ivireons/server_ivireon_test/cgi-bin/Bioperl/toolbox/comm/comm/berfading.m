function [ber ser] = berfading(EbNo, modType, varargin)
%BERFADING Bit error rate (BER) for Rayleigh and Rician fading channels.
%   BER = BERFADING(EbNo, MODTYPE, M, DIVORDER) returns the BER for PAM or
%   QAM over an uncoded Rayleigh fading channel with coherent demodulation.
%   EbNo -- bit energy to noise power spectral density ratio (in dB)
%   MODTYPE -- modulation type, either 'pam' or 'qam' 
%   M -- alphabet size, must be a positive integer power of 2 
%   DIVORDER -- diversity order
%
%   BER = BERFADING(EbNo, 'psk', M, DIVORDER) returns the BER for coherently
%   detected PSK over an uncoded Rayleigh fading channel.
%
%   BER = BERFADING(EbNo, 'depsk', M, DIVORDER) returns the BER for
%   coherently detected PSK with differential data encoding over an uncoded
%   Rayleigh fading channel.
%
%   BER = BERFADING(EbNo, 'oqpsk', DIVORDER) returns the BER of coherently
%   detected offset-QPSK over an uncoded Rayleigh fading channel.
%
%   BER = BERFADING(EbNo, 'dpsk', M, DIVORDER) returns the BER for DPSK
%   over an uncoded Rayleigh fading channel.
%
%   BER = BERFADING(EbNo, 'fsk', M, DIVORDER, COHERENCE) returns the BER
%   for orthogonal FSK over an uncoded Rayleigh fading channel.
%   COHERENCE -- 'coherent' for coherent detection
%                'noncoherent' for noncoherent detection
%
%   BER = BERFADING(EbNo, 'fsk', 2, DIVORDER, COHERENCE, RHO) returns the
%   BER for binary non-orthogonal FSK over an uncoded Rayleigh fading
%   channel.
%   RHO -- complex correlation coefficient
%
%   BER = BERFADING(EbNo, ..., K) returns the BER over an uncoded Rician
%   fading channel.
%   K -- ratio of specular to diffuse energy (in linear scale)
%
%   BER = BERFADING(EbNo, 'psk', 2, 1, K, PHASERR) returns the BER of BPSK
%   over an uncoded Rician fading channel with imperfect phase
%   synchronization.
%   PHASERR -- standard deviation of the reference carrier phase error
%              (in rad)
%
%   [BER, SER] = BERFADING(EbNo, ...) returns both the BER and SER.
%
%   See also BERAWGN, BERCODING, BERSYNC.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2006/12/27 20:27:36 $

if (nargin < 3)
    error('comm:berfading:minArgs', ...
        'BERFADING requires at least 3 input arguments.');
elseif (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
    error('comm:berfading:EbNo', 'EbNo must be a real vector.');
end

EbNoLin = 10.^(EbNo/10);    % converting EbNo from dB to linear scale
modType = lower(modType);


kFactor = 0.0;  % Default
divOrder = 1;   % Default

switch modType
    case {'psk', 'depsk', 'dpsk', 'pam', 'qam', 'fsk'}
        switch modType
            case {'fsk'}
                if (nargin < 5)
                    error('comm:berfading:minArgs5', ...
                        ['BERFADING requires at least 5 input arguments for ', ...
                        upper(modType) ,'.']);
                end
            otherwise
                if (nargin < 4)
                    error('comm:berfading:minArgs4', ...
                      ['BERFADING requires at least 4 input arguments for ', ...
                        upper(modType) ,'.']);
                end
        end
        M = varargin{1};
        if ~is(M, 'scalar')
            error('comm:berfading:scalarM', 'M must be a scalar.');
        end
        if M > 1
            k = log2(M);
        else
            k = 0.5;
        end
        if (~is(M, 'positive') || ceil(k)~=k)
            error('comm:berfading:intM', ...
                'M must be a positive integer power of 2.');
        end
        if (strcmpi(modType, 'qam') && (M == 2))
            error('comm:berfading:minM', 'M must be at least 4 for QAM.');
        end
        
        divOrder = varargin{2};
        
        switch modType
            case {'depsk', 'dpsk', 'pam', 'qam'}
                if (nargin >= 5)
                    kFactor = varargin{3};
                    if ischar(kFactor)
                        kFactor = str2double(kFactor);
                    end
                end
            case {'psk'}
                phaserr = 0;
                if (nargin >= 5)
                    kFactor = varargin{3};
                    if ischar(kFactor)
                        kFactor = str2double(kFactor);
                    end
                    phaserr = 0;    % Default
                    if (nargin >= 6)
                        phaserr = varargin{4};
                        if (~is(phaserr, 'scalar') || ~is(phaserr, 'nonnegative'))
                            error('comm:berfading:phaserr', ...
                                'PHASERR must be a nonnegative number.');
                        end
                    end
                end
            case {'fsk'}
                coherence = varargin{3};
                if (~strncmpi(coherence, 'c', 1) && ~strncmpi(coherence, 'n', 1))
                    error('comm:berfading:coherence', ...
                    'COHERENCE must be either ''coherent'' or ''noncoherent''.');
                end
                rho = 0;    % Default
                if (nargin >= 6)
                    rho = varargin{4};
                    if ischar(rho)
                        rho = str2double(rho);
                    end
                    if (~isnumeric(rho)) || (~isscalar(rho)) || ...
                            (isnan(rho)) || (abs(rho) > 1)
                        error('comm:berfading:rho', ...
                           ['RHO must be a numeric scalar with a magnitude ' ...
                            'smaller than or equal to 1.']);
                    end
                    if (nargin >= 7)
                        kFactor = varargin{5};
                        if ischar(kFactor)
                            kFactor = str2double(kFactor);
                        end
                    end
                end
        end
        
    case {'oqpsk'}
        M = 4;
        k = 2;
        phaserr = 0;
        divOrder = varargin{1};
        if (nargin >= 4)
            kFactor = varargin{2};
            if ischar(kFactor)
                kFactor = str2double(kFactor);
            end
        end 
        
    otherwise
        error('comm:berfading:modType', 'Invalid modulation type.');
end


% Test kFactor (applies to all modulation schemes)
if ~isnumeric(kFactor) || ~isscalar(kFactor) || isnan(kFactor) ...
        || isinf(kFactor) || (kFactor<0) || ~isreal(kFactor)
    error('comm:berfading:kFactor', ...
        'K factor must be a nonnegative real scalar.');
end

% Test divOrder (applies to all modulation schemes)
if (~is(divOrder, 'scalar') || ~is(divOrder, 'positive integer'))
    error('comm:berfading:divOrder', ...
        'DIVORDER must be a positive integer.');
end


gamma_c = EbNoLin * k / divOrder;  % average SNR per diversity channel

mgf_rayleigh_handle = @(s,gamma) 1./(1-s.*gamma);

mgf_rician_handle = @(s,gamma,kFactor) (1+kFactor)./(1+kFactor-s.*gamma) ...
                                .* exp(kFactor*s.*gamma./(1+kFactor-s.*gamma));


if (kFactor == 0)   % Rayleigh fading
    switch modType
        case 'psk'
            if (phaserr == 0)
                if (divOrder == 1)
                    sin_pi_M_2 = (sin(pi/M))^2;
                    ser = (M-1)/M * ( 1 - sqrt(sin_pi_M_2*gamma_c./(1+sin_pi_M_2*gamma_c)) ...
                        * M/((M-1)*pi) .* (pi/2 + atan(sqrt(sin_pi_M_2*gamma_c./(1+sin_pi_M_2*gamma_c))*cot(pi/M))) );
                    if (M == 2)
                        mu = sqrt(gamma_c ./ (1+gamma_c));
                        ber = pskf(mu, divOrder);
                    elseif (M == 4)
                        tol = 1e-4 ./ EbNoLin.^4;
                        tol(tol>1e-4) = 1e-4;
                        tol(tol<eps) = eps;
                        ber = zeros(size(EbNoLin));
                        PP = zeros(3,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:3
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 1/2 * ( PP(1,j) +  2*PP(2,j) + PP(3,j) );
                        end                        
                    elseif (M == 8)
                        tol = 1e-4 ./ EbNoLin.^4;
                        tol(tol>1e-4) = 1e-4;
                        tol(tol<eps) = eps;
                        ber = zeros(size(EbNoLin));
                        PP = zeros(7,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:7
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 1/3 * ( PP(1,j) +  2*PP(2,j) + PP(3,j) + 2*PP(4,j) ...
                                + 3*PP(5,j) + 2*PP(6,j) + PP(7,j) );
                        end
                    elseif (M == 16)
                        tol = 1e-4 ./ EbNoLin.^4;
                        tol(tol>1e-4) = 1e-4;
                        tol(tol<eps) = eps;
                        ber = zeros(size(EbNoLin));
                        PP = zeros(8,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:8
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 1/2 * ( PP(1,j) +  2*PP(2,j) + 2*PP(3,j) + 2*PP(4,j) ...
                                + 3*PP(5,j) + 3*PP(6,j) + 2*PP(7,j) + PP(8,j) );
                        end
                    elseif (M == 32)
                        tol = 1e-4 ./ EbNoLin.^4;
                        tol(tol>1e-4) = 1e-4;
                        tol(tol<eps) = eps;
                        ber = zeros(size(EbNoLin));
                        PP = zeros(16,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:16
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 2/5 * ( PP(1,j) + 2*PP(2,j) + 2*PP(3,j) + 2*PP(4,j) ...
                                + 3*PP(5,j) + 3*PP(6,j) + 2*PP(7,j) + 2*PP(8,j) ...
                                + 3*PP(9,j) + 4*PP(10,j) + 4*PP(11,j) + 3*PP(12,j) ...
                                + 3*PP(13,j) + 3*PP(14,j) + 2*PP(15,j) + PP(16,j) );
                        end
                    else
                        tol = 1e-4 ./ EbNoLin.^5;
                        tol(tol>1e-4) = 1e-4;
                        tol(tol<eps) = eps;
                        ber = zeros(size(EbNoLin));
                        PP = zeros(M/2,length(EbNoLin));
                        w = gen_weights_psk(M);
                        for j = 1:length(EbNoLin)
                            for i=1:M/2
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = sum(w .* PP(:,j));
                        end
                    end
                else
                    ser = zeros(size(EbNoLin));
                    tol = 1e-4 ./ EbNoLin.^4;
                    tol(tol>1e-4) = 1e-4;
                    tol(tol<eps) = eps;
                    f_theta = @(theta,M) - (sin(pi/M))^2./(sin(theta)).^2;
                    int_theta = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta(theta,M),gamma)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ser(i) = 1/pi * quad(@(theta)int_theta(theta,M,gamma_c(i)), 1e-6, pi*(M-1)/M, tol(i), []);
                    end
                    if (M == 2)
                        mu = sqrt(gamma_c ./ (1+gamma_c));
                        ber = pskf(mu, divOrder);
                        ser = ber;
                    elseif (M == 4)
                        ber = zeros(size(EbNoLin));
                        PP = zeros(3,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:3
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 1/2 * ( PP(1,j) +  2*PP(2,j) + PP(3,j) );
                        end
                    elseif (M == 8)
                        ber = zeros(size(EbNoLin));
                        PP = zeros(7,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:7
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 1/3 * ( PP(1,j) +  2*PP(2,j) + PP(3,j) + 2*PP(4,j) ...
                                + 3*PP(5,j) + 2*PP(6,j) + PP(7,j) );
                        end
                    elseif (M == 16)
                        ber = zeros(size(EbNoLin));
                        PP = zeros(8,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:8
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 1/2 * ( PP(1,j) +  2*PP(2,j) + 2*PP(3,j) + 2*PP(4,j) ...
                                + 3*PP(5,j) + 3*PP(6,j) + 2*PP(7,j) + PP(8,j) );
                        end
                    elseif (M == 32)
                        ber = zeros(size(EbNoLin));
                        PP = zeros(16,length(EbNoLin));
                        for j = 1:length(EbNoLin)
                            for i=1:16
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = 2/5 * ( PP(1,j) + 2*PP(2,j) + 2*PP(3,j) + 2*PP(4,j) ...
                                + 3*PP(5,j) + 3*PP(6,j) + 2*PP(7,j) + 2*PP(8,j) ...
                                + 3*PP(9,j) + 4*PP(10,j) + 4*PP(11,j) + 3*PP(12,j) ...
                                + 3*PP(13,j) + 3*PP(14,j) + 2*PP(15,j) + PP(16,j) );
                        end
                    else
                        ber = zeros(size(EbNoLin));
                        PP = zeros(M/2,length(EbNoLin));
                        w = gen_weights_psk(M);
                        for j = 1:length(EbNoLin)
                            for i=1:M/2
                                f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                                int_theta1 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta1(theta,M),gamma)).^divOrder;
                                f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                                int_theta2 = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta2(theta,M),gamma)).^divOrder;
                                PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                    - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j)), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                            end
                            ber(j) = sum(w .* PP(:,j));
                        end
                    end                    
                end 
            else
                if (M == 2) && (divOrder == 1)
                    if (kFactor > 300)   % considered AWGN due to limited numerical precision
                        ber = bersync(EbNo, phaserr, 'carrier');
                        ser = ber;
                    else
                        if (phaserr < 0.1)
                            phaserr = 0.1;  % due to limited numerical precision
                        end
                        % optimize tolerance for integration precision and speed
                        scale = exp(-kFactor) / pi;
                        tol = 1e-5 ./ EbNoLin.^((1 + 10*(1-exp(-kFactor/40))) * ...
                            max(0, 1 - sqrt(phaserr*kFactor/300)));
                        tul = 1e-4;
                        tol(tol>tul) = tul;   % upper limit of tolerance
                        tll = 10^(30*phaserr-21);
                        if (tll > 1e-6)
                            tll = 1e-6;
                        end
                        tol(tol<tll) = tll;   % lower limit of tolerance
                        tol = tol / scale;
                        % optimize upper limit of integration interval
                        ul = min(2*kFactor+40, kFactor+100);
                        ber = zeros(size(EbNoLin));
                        for i = 1:length(EbNoLin)
                            ber(i) = dblquad(@rician, 0, pi, 0, ul, tol(i), [], EbNoLin(i), kFactor, phaserr);
                        end
                        ber = ber * scale;
                        ser = ber;
                    end
                else
                    error('comm:berfading:PSK_phaseerr', ...
                        'No theoretical results for PSK in Rayleigh fading with phase error if M > 2 or L > 1.');
                end
            end
        case 'depsk'
            if (M == 2)
                tol = 1e-4 ./ EbNoLin.^5;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                ser = zeros(size(EbNoLin));
                f_theta = @(theta) -1./(sin(theta)).^2;
                int_theta = @(theta,gamma) (mgf_rayleigh_handle(f_theta(theta),gamma)).^divOrder;
                for i = 1:length(EbNoLin)
                    ser(i) = quad(@(theta)int_theta(theta,gamma_c(i)), 10e-6, pi/2, tol(i), []) ...
                        -quad(@(theta)int_theta(theta,gamma_c(i)), 10e-6, pi/4, tol(i), []);
                end
                ser = 2/pi * ser;
                ber = ser;
            else
                error('comm:berfading:DEPSK', ...
                    'No theoretical results for DEPSK if M > 2.');
            end
        case 'oqpsk'
            [ber ser] = berfading(EbNo,'psk',4,divOrder,0,0);
        case 'dpsk'
            if (divOrder == 1)
                struct_warning = warning('off', 'MATLAB:quad:MaxFcnCount');
                ser = zeros(size(EbNoLin));
                tol = 1e-4 ./ EbNoLin.^5;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                for i = 1:length(EbNoLin)
                    ser(i) = sin(pi/M)/(2*pi) * quad(@int_dpsk, -pi/2, pi/2, tol(i), [], gamma_c(i), M);
                end
                if (M == 2)
                    mu = gamma_c ./ (1+gamma_c);
                    ber = pskf(mu, divOrder);
                elseif (M == 4)
                    mu = gamma_c ./ (1+gamma_c);
                    rho_dpsk = mu ./ sqrt(2-mu.^2);
                    ber = pskf(rho_dpsk, divOrder);
                elseif (M == 8)
                    ber = zeros(size(EbNoLin));
                    for i = 1:length(EbNoLin)
                        ber(i) = 2/3 * ( quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 13*pi/8) ...
                           - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), pi/8) );
                    end
                elseif (M == 16)
                    ber = zeros(size(EbNoLin));
                    for i = 1:length(EbNoLin)
                        ber(i) = 1/2 * ( quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 13*pi/16) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 9*pi/16) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 3*pi/16) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), pi/16) );
                    end
                elseif (M == 32)
                    ber = zeros(size(EbNoLin));
                    for i = 1:length(EbNoLin)
                        ber(i) = 2/5 * ( quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 29*pi/32) ...
                            + quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 23*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 19*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 17*pi/32) ...
                            + quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 13*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 9*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), 3*pi/32) ...
                            - quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), pi/32) );
                    end
                else
                    ber = zeros(size(EbNoLin));
                    w = gen_weights_psk(M);
                    PP = zeros(M/2,length(EbNoLin));
                    for i = 1:length(EbNoLin)
                        for j=1:M/2
                            PP(j,i) = quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), (2*j+1)*pi/M) ...
                                     -quad(@int_dpsk_ber, -pi/2, pi/2, tol(i), [], gamma_c(i), (2*j-1)*pi/M);
                        end
                        ber(i) = sum(w .* PP(:,i));
                    end
                end
                warning(struct_warning.state, struct_warning.identifier);     % recover warning state
            else
                struct_warning = warning('off', 'MATLAB:quad:MaxFcnCount');
                ser = zeros(size(EbNoLin));
                tol = 1e-4 ./ EbNoLin.^8;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                f_theta = @(theta,M) - (1-cos(pi/M)*cos(theta));
                int_theta = @(theta,M,gamma) 1./(1-cos(pi/M)*cos(theta)) ...
                    .* (mgf_rayleigh_handle(f_theta(theta,M),gamma)).^divOrder;
                for i = 1:length(EbNoLin)
                    ser(i) = sin(pi/M)/(2*pi) * quad(@(theta)int_theta(theta,M,gamma_c(i)), -pi/2, pi/2, tol(i), []);
                end
                ber = zeros(size(EbNoLin));
                f_theta = @(theta,ksi) - (1-cos(ksi)*cos(theta));
                int_theta = @(theta,ksi,gamma) 1./(1-cos(ksi)*cos(theta)) ...
                    .* (mgf_rayleigh_handle(f_theta(theta,ksi),gamma)).^divOrder;
                if (M == 2)
                    for i = 1:length(EbNoLin)
                        ber(i) = 2*(sin(pi/2)/(4*pi)) * quad(@(theta)int_theta(theta,(pi/2),gamma_c(i)), -pi/2, pi/2, tol(i), []);
                    end
                elseif (M == 4)
                    for i = 1:length(EbNoLin)
                        ber(i) = (-sin(5*pi/4)/(4*pi)) * quad(@(theta)int_theta(theta,(5*pi/4),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                                - (-sin(pi/4)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/4),gamma_c(i)), -pi/2, pi/2, tol(i), []);
                    end
                elseif (M == 8)
                    for i = 1:length(EbNoLin)
                        ber(i) = 2/3 * ( (-sin(13*pi/8)/(4*pi)) * quad(@(theta)int_theta(theta,(13*pi/8),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                                        - (-sin(pi/8)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/8),gamma_c(i)), -pi/2, pi/2, tol(i), []) ) ;
                    end
                elseif (M == 16)
                    for i = 1:length(EbNoLin)
                        ber(i) = 1/2 * ( (-sin(13*pi/16)/(4*pi)) * quad(@(theta)int_theta(theta,(13*pi/16),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                                        - (-sin(9*pi/16)/(4*pi)) *  quad(@(theta)int_theta(theta,(9*pi/16),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                                        - (-sin(3*pi/16)/(4*pi)) *  quad(@(theta)int_theta(theta,(3*pi/16),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                                        - (-sin(pi/16)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/16),gamma_c(i)), -pi/2, pi/2, tol(i), []) ) ;
                    end
                elseif (M == 32)                 
                    for i = 1:length(EbNoLin)
                        ber(i) = 2/5 * ( (-sin(29*pi/32)/(4*pi)) * quad(@(theta)int_theta(theta,(29*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            + (-sin(23*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(23*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            - (-sin(19*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(19*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            - (-sin(17*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(17*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            + (-sin(13*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(13*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            - (-sin(9*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(9*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            - (-sin(3*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(3*pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                            - (-sin(pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/32),gamma_c(i)), -pi/2, pi/2, tol(i), []) ) ;
                    end
                else
                    w = gen_weights_psk(M);
                    PP = zeros(M/2,length(EbNoLin));
                    for i = 1:length(EbNoLin)
                        for j=1:M/2
                            PP(j,i) = (-sin((2*j+1)*pi/M)/(4*pi)) * quad(@(theta)int_theta(theta,(2*j+1)*pi/M,gamma_c(i)), -pi/2, pi/2, tol(i), []) ...
                                    - (-sin((2*j-1)*pi/M)/(4*pi)) * quad(@(theta)int_theta(theta,(2*j-1)*pi/M,gamma_c(i)), -pi/2, pi/2, tol(i), []) ;
                        end
                        ber(i) = sum(w .* PP(:,i));
                    end
                end  
                warning(struct_warning.state, struct_warning.identifier);     % recover warning state
            end
        case 'pam'
            if (divOrder == 1)
                ser = (M-1)/M * ( 1 - sqrt(3*gamma_c./(M^2-1+3*gamma_c)) );
                if (M == 2)
                    ber = 1/2 * ( 1 - sqrt(gamma_c./(1+gamma_c)) );
                elseif (M == 4)
                    ber = 3/8 * ( 1 - sqrt(2/5*gamma_c/k./(1+2/5*gamma_c/k)) ) ...
                        + 1/4 * ( 1 - sqrt(18/5*gamma_c/k./(1+18/5*gamma_c/k)) ) ...
                        - 1/8 * ( 1 - sqrt(10*gamma_c/k./(1+10*gamma_c/k)) );
                elseif (M == 8)
                    ber = 7/24 * ( 1 - sqrt(1/7*gamma_c/k./(1+1/7*gamma_c/k)) ) ...
                        + 1/4 * ( 1 - sqrt(9/7*gamma_c/k./(1+9/7*gamma_c/k)) ) ...
                        - 1/24 * ( 1 - sqrt(25/7*gamma_c/k./(1+25/7*gamma_c/k)) ) ...
                        + 1/24 * ( 1 - sqrt(81/7*gamma_c/k./(1+81/7*gamma_c/k)) ) ...
                        - 1/24 * ( 1 - sqrt(169/7*gamma_c/k./(1+169/7*gamma_c/k)) );
                else
                    ber = zeros(size(EbNoLin));
                    for i = 1:k
                        berk = zeros(size(EbNoLin));
                        for j=0:(1-2^(-i))*M - 1
                            berk = berk + (-1)^(floor(j*2^(i-1)/M)) * (2^(i-1) - floor(j*2^(i-1)/M+1/2)) ...
                                * 1/2 * ( 1 - sqrt((2*j+1)^2*3*gamma_c./(M^2-1+(2*j+1)^2*3*gamma_c)) );
                        end
                        berk = berk*2/M;
                        ber = ber + berk;
                    end
                    ber = ber/k;              
                end
            else
                ser = zeros(size(EbNoLin));
                tol = 1e-4 ./ EbNoLin.^4;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                f_theta = @(theta,M) - 3/(M^2-1)./(sin(theta)).^2;
                int_theta = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta(theta,M),gamma)).^divOrder;
                for i = 1:length(EbNoLin)
                    ser(i) = (M-1)/M * 2/pi * quad(@(theta)int_theta(theta,M,gamma_c(i)), 1e-6, pi/2, tol(i), []);
                end
                ber = zeros(size(EbNoLin));
                if (M == 2)
                    f_theta = @(theta) - 1./(sin(theta)).^2;
                    int_theta = @(theta,gamma) (mgf_rayleigh_handle(f_theta(theta),gamma)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ber(i) = 1/pi * quad(@(theta)int_theta(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []);
                    end
                elseif (M == 4)
                    f_theta1 = @(theta) - (2/5)./(sin(theta)).^2;
                    f_theta2 = @(theta) - (18/5)./(sin(theta)).^2;
                    f_theta3 = @(theta) - 10./(sin(theta)).^2;
                    int_theta1 = @(theta,gamma) (mgf_rayleigh_handle(f_theta1(theta),gamma)).^divOrder;
                    int_theta2 = @(theta,gamma) (mgf_rayleigh_handle(f_theta2(theta),gamma)).^divOrder;
                    int_theta3 = @(theta,gamma) (mgf_rayleigh_handle(f_theta3(theta),gamma)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ber(i) = 3/4 * 1/pi * quad(@(theta)int_theta1(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                +1/2 * 1/pi * quad(@(theta)int_theta2(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                -1/4 * 1/pi * quad(@(theta)int_theta3(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []);
                    end
                elseif (M == 8)
                    f_theta1 = @(theta) - (1/7)./(sin(theta)).^2;
                    f_theta2 = @(theta) - (9/7)./(sin(theta)).^2;
                    f_theta3 = @(theta) - (25/7)./(sin(theta)).^2;
                    f_theta4 = @(theta) - (81/7)./(sin(theta)).^2;
                    f_theta5 = @(theta) - (169/7)./(sin(theta)).^2;
                    int_theta1 = @(theta,gamma) (mgf_rayleigh_handle(f_theta1(theta),gamma)).^divOrder;
                    int_theta2 = @(theta,gamma) (mgf_rayleigh_handle(f_theta2(theta),gamma)).^divOrder;
                    int_theta3 = @(theta,gamma) (mgf_rayleigh_handle(f_theta3(theta),gamma)).^divOrder;
                    int_theta4 = @(theta,gamma) (mgf_rayleigh_handle(f_theta4(theta),gamma)).^divOrder;
                    int_theta5 = @(theta,gamma) (mgf_rayleigh_handle(f_theta5(theta),gamma)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ber(i) = 7/12 * 1/pi * quad(@(theta)int_theta1(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                +1/2 * 1/pi * quad(@(theta)int_theta2(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                -1/12 * 1/pi * quad(@(theta)int_theta3(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                +1/12 * 1/pi * quad(@(theta)int_theta4(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                -1/12 * 1/pi * quad(@(theta)int_theta5(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []);
                    end
                else
                    ber = zeros(size(EbNoLin));
                    for l=1:length(EbNoLin)
                        for i = 1:k
                            berk = 0;
                            for j=0:(1-2^(-i))*M - 1
                                f_theta = @(theta,M) - (2*j+1)^2*3/(M^2-1)./(sin(theta)).^2;
                                int_theta = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta(theta,M),gamma)).^divOrder;
                                berk = berk + (-1)^(floor(j*2^(i-1)/M)) * (2^(i-1) - floor(j*2^(i-1)/M+1/2)) ...
                                    * 1/pi * quad(@(theta)int_theta(theta,M,gamma_c(l)), 1e-6, pi/2, tol(l), []);
                            end
                            berk = berk*2/M;
                            ber(l) = ber(l) + berk;
                        end
                    end
                    ber = ber/k;       
                end
            end
        case 'qam'
            if (divOrder == 1)
                if (ceil(k/2) == k/2)   % k is even
                    ser = 2*(sqrt(M)-1)/sqrt(M) * ( 1 - sqrt(1.5*gamma_c./(M-1+1.5*gamma_c)) ) ...
                        - ((sqrt(M)-1)/sqrt(M))^2 * ( 1 - sqrt(1.5*gamma_c./(M-1+1.5*gamma_c)).*(4/pi*atan(sqrt((M-1+1.5*gamma_c)./(1.5*gamma_c)))) );
                    ber = zeros(size(EbNoLin));
                    if (M == 4)
                        ber = 1/2 * ( 1 - sqrt(gamma_c/k./(1+gamma_c/k)) );
                    elseif (M == 16)
                        ber = 3/8 * ( 1 - sqrt(2/5*gamma_c/k./(1+2/5*gamma_c/k)) ) ...
                            + 1/4 * ( 1 - sqrt(18/5*gamma_c/k./(1+18/5*gamma_c/k)) ) ...
                            - 1/8 * ( 1 - sqrt(10*gamma_c/k./(1+10*gamma_c/k)) );
                    elseif (M == 64)
                        ber = 7/24 * ( 1 - sqrt(1/7*gamma_c/k./(1+1/7*gamma_c/k)) ) ...
                            + 1/4 * ( 1 - sqrt(9/7*gamma_c/k./(1+9/7*gamma_c/k)) ) ...
                            - 1/24 * ( 1 - sqrt(25/7*gamma_c/k./(1+25/7*gamma_c/k)) ) ...
                            + 1/24 * ( 1 - sqrt(81/7*gamma_c/k./(1+81/7*gamma_c/k)) ) ...
                            - 1/24 * ( 1 - sqrt(169/7*gamma_c/k./(1+169/7*gamma_c/k)) );
                    else
                        for i = 1:log2(sqrt(M))
                            berk = zeros(size(EbNoLin));
                            for j=0:(1-2^(-i))*sqrt(M) - 1
                                berk = berk + (-1)^(floor(j*2^(i-1)/sqrt(M))) * (2^(i-1) - floor(j*2^(i-1)/sqrt(M)+1/2)) ...
                                    * 1/2 * ( 1 - sqrt(1.5*(2*j+1)^2*gamma_c./(M-1+1.5*(2*j+1)^2*gamma_c)) );
                            end
                            berk = berk*2/sqrt(M);
                            ber = ber + berk;
                        end
                        ber = ber/log2(sqrt(M));
                    end
                else
                    I = 2^(ceil(log2(M)/2));
                    J = 2^(floor(log2(M)/2));
                    if (M == 8)
                        ser = 5/4 * ( 1 - sqrt(gamma_c/6./(1+gamma_c/6)) ) ...
                            - 3/8 * ( 1 - sqrt(gamma_c/6./(1+gamma_c/6)).*(4/pi*atan(sqrt((1+gamma_c/6)./(gamma_c/6)))) );
                    else
                        ser = (2*I*J-I-J)/M * ( 1 - sqrt(3*gamma_c/(I^2+J^2-2)./(1+3*gamma_c/(I^2+J^2-2))) ) ...
                            - (1+I*J-I-J)/M * ( 1 - sqrt(3*gamma_c/(I^2+J^2-2)./(1+3*gamma_c/(I^2+J^2-2))).*(4/pi*atan(sqrt((1+3*gamma_c/(I^2+J^2-2))./(3*gamma_c/(I^2+J^2-2))))) ) ;
                    end
                    berI = zeros(size(EbNoLin));
                    berJ = zeros(size(EbNoLin));
                    for i = 1:log2(I)
                        berk = zeros(size(EbNoLin));
                        for j=0:(1-2^(-i))*I - 1
                            berk = berk + (-1)^(floor(j*2^(i-1)/I)) * (2^(i-1) - floor(j*2^(i-1)/I+1/2)) ...
                                * 1/2 * ( 1 - sqrt(3*(2*j+1)^2*log2(I*J)*gamma_c/k./(I^2+J^2-2+3*(2*j+1)^2*log2(I*J)*gamma_c/k)) );
                        end
                        berk = berk*2/I;
                        berI = berI + berk;
                    end
                    for i = 1:log2(J)
                        berk = zeros(size(EbNoLin));
                        for j=0:(1-2^(-i))*J - 1
                            berk = berk + (-1)^(floor(j*2^(i-1)/J)) * (2^(i-1) - floor(j*2^(i-1)/J+1/2)) ...
                                * 1/2 * ( 1 - sqrt(3*(2*j+1)^2*log2(I*J)*gamma_c/k./(I^2+J^2-2+3*(2*j+1)^2*log2(I*J)*gamma_c/k)) );
                        end
                        berk = berk*2/J;
                        berJ = berJ + berk;
                    end
                    ber = (berI+berJ)/log2(I*J);
                end
            else
                if (ceil(k/2) == k/2)   % k is even
                    ser = zeros(size(EbNoLin));
                    tol = 1e-4 ./ EbNoLin.^4;
                    tol(tol>1e-4) = 1e-4;
                    tol(tol<eps) = eps;
                    f_theta = @(theta,M) - 3/(2*(M-1))./(sin(theta)).^2;
                    int_theta = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta(theta,M),gamma)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ser(i) = (sqrt(M)-1)/sqrt(M) * 4/pi * quad(@(theta)int_theta(theta,M,gamma_c(i)), 1e-6, pi/2, tol(i), []) ...
                            - ((sqrt(M)-1)/sqrt(M))^2 * 4/pi * quad(@(theta)int_theta(theta,M,gamma_c(i)), 1e-6, pi/4, tol(i), []);
                    end
                    ber = zeros(size(EbNoLin));
                    if (M == 4)
                        f_theta = @(theta) - 1./(sin(theta)).^2;
                        int_theta = @(theta,gamma) (mgf_rayleigh_handle(f_theta(theta),gamma)).^divOrder;
                        for i = 1:length(EbNoLin)
                            ber(i) = 1/pi * quad(@(theta)int_theta(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []);
                        end
                    elseif (M == 16)
                        f_theta1 = @(theta) - (2/5)./(sin(theta)).^2;
                        f_theta2 = @(theta) - (18/5)./(sin(theta)).^2;
                        f_theta3 = @(theta) - 10./(sin(theta)).^2;
                        int_theta1 = @(theta,gamma) (mgf_rayleigh_handle(f_theta1(theta),gamma)).^divOrder;
                        int_theta2 = @(theta,gamma) (mgf_rayleigh_handle(f_theta2(theta),gamma)).^divOrder;
                        int_theta3 = @(theta,gamma) (mgf_rayleigh_handle(f_theta3(theta),gamma)).^divOrder;
                        for i = 1:length(EbNoLin)
                            ber(i) = 3/4 * 1/pi * quad(@(theta)int_theta1(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                +1/2 * 1/pi * quad(@(theta)int_theta2(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                -1/4 * 1/pi * quad(@(theta)int_theta3(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []);
                        end
                    elseif (M == 64)
                        f_theta1 = @(theta) - (1/7)./(sin(theta)).^2;
                        f_theta2 = @(theta) - (9/7)./(sin(theta)).^2;
                        f_theta3 = @(theta) - (25/7)./(sin(theta)).^2;
                        f_theta4 = @(theta) - (81/7)./(sin(theta)).^2;
                        f_theta5 = @(theta) - (169/7)./(sin(theta)).^2;
                        int_theta1 = @(theta,gamma) (mgf_rayleigh_handle(f_theta1(theta),gamma)).^divOrder;
                        int_theta2 = @(theta,gamma) (mgf_rayleigh_handle(f_theta2(theta),gamma)).^divOrder;
                        int_theta3 = @(theta,gamma) (mgf_rayleigh_handle(f_theta3(theta),gamma)).^divOrder;
                        int_theta4 = @(theta,gamma) (mgf_rayleigh_handle(f_theta4(theta),gamma)).^divOrder;
                        int_theta5 = @(theta,gamma) (mgf_rayleigh_handle(f_theta5(theta),gamma)).^divOrder;
                        for i = 1:length(EbNoLin)
                            ber(i) = 7/12 * 1/pi * quad(@(theta)int_theta1(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                +1/2 * 1/pi * quad(@(theta)int_theta2(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                -1/12 * 1/pi * quad(@(theta)int_theta3(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                +1/12 * 1/pi * quad(@(theta)int_theta4(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []) ...
                                -1/12 * 1/pi * quad(@(theta)int_theta5(theta,gamma_c(i)/k), 1e-6, pi/2, tol(i), []);
                        end
                    else
                        ber = zeros(size(EbNoLin));
                        for l = 1:length(EbNoLin)
                            for i = 1:log2(sqrt(M))
                                berk = 0;
                                for j=0:(1-2^(-i))*sqrt(M) - 1
                                    f_theta = @(theta,M) - (2*j+1)^2*1.5/(M-1)./(sin(theta)).^2;
                                    int_theta = @(theta,M,gamma) (mgf_rayleigh_handle(f_theta(theta,M),gamma)).^divOrder;
                                    berk = berk + (-1)^(floor(j*2^(i-1)/sqrt(M))) * (2^(i-1) - floor(j*2^(i-1)/sqrt(M)+1/2)) ...
                                        * 1/pi * quad(@(theta)int_theta(theta,M,gamma_c(l)), 1e-6, pi/2, tol(l), []);
                                end
                                berk = berk*2/sqrt(M);
                                ber(l) = ber(l) + berk;
                            end
                        end
                        ber = ber/log2(sqrt(M));
                    end
                else
                    I = 2^(ceil(log2(M)/2));
                    J = 2^(floor(log2(M)/2));
                    ser = zeros(size(EbNoLin));
                    tol = 1e-4 ./ EbNoLin.^4;
                    tol(tol>1e-4) = 1e-4;
                    tol(tol<eps) = eps;
                    if (M == 8)
                        f_theta = @(theta) - 1/6./(sin(theta)).^2;
                        int_theta = @(theta,gamma) (mgf_rayleigh_handle(f_theta(theta),gamma)).^divOrder;
                        for i = 1:length(EbNoLin)
                            ser(i) = 5/(2*pi) * quad(@(theta)int_theta(theta,gamma_c(i)), 1e-6, pi/2, tol(i), []) ...
                                    - 3/(2*pi) * quad(@(theta)int_theta(theta,gamma_c(i)), 1e-6, pi/4, tol(i), []);
                        end
                    else
                        f_theta = @(theta) - 3/(I^2+J^2-2)./(sin(theta)).^2;
                        int_theta = @(theta,gamma) (mgf_rayleigh_handle(f_theta(theta),gamma)).^divOrder;
                        for i = 1:length(EbNoLin)
                            ser(i) = (4*I*J-2*I-2*J)/(M*pi) * quad(@(theta)int_theta(theta,gamma_c(i)), 1e-6, pi/2, tol(i), []) ...
                                    - 4/(M*pi)*(1+I*J-I-J) * quad(@(theta)int_theta(theta,gamma_c(i)), 1e-6, pi/4, tol(i), []);
                        end
                    end
                    berI = zeros(size(EbNoLin));
                    berJ = zeros(size(EbNoLin));
                    tol = 1e-4 ./ EbNoLin.^4;
                    tol(tol>1e-4) = 1e-4;
                    tol(tol<eps) = eps;
                    for l=1:length(EbNoLin)
                        for i = 1:log2(I)
                            berk = 0;
                            for j=0:(1-2^(-i))*I - 1
                                f_theta = @(theta,I,J) - (2*j+1)^2*3*log2(I*J)/(I^2+J^2-2)./(sin(theta)).^2;
                                int_theta = @(theta,I,J,gamma) (mgf_rayleigh_handle(f_theta(theta,I,J),gamma)).^divOrder;
                                berk = berk + (-1)^(floor(j*2^(i-1)/I)) * (2^(i-1) - floor(j*2^(i-1)/I+1/2)) ...
                                    * 1/pi * quad(@(theta)int_theta(theta,I,J,gamma_c(l)/k), 1e-6, pi/2, tol(l), []);
                            end
                            berk = berk*2/I;
                            berI(l) = berI(l) + berk;
                        end
                    end
                    for l=1:length(EbNoLin)
                        for i = 1:log2(J)
                            berk = 0;
                            for j=0:(1-2^(-i))*J - 1
                                f_theta = @(theta,I,J) - (2*j+1)^2*3*log2(I*J)/(I^2+J^2-2)./(sin(theta)).^2;
                                int_theta = @(theta,I,J,gamma) (mgf_rayleigh_handle(f_theta(theta,I,J),gamma)).^divOrder;
                                berk = berk + (-1)^(floor(j*2^(i-1)/J)) * (2^(i-1) - floor(j*2^(i-1)/J+1/2)) ...
                                    * 1/pi * quad(@(theta)int_theta(theta,I,J,gamma_c(l)/k), 1e-6, pi/2, tol(l), []);
                            end
                            berk = berk*2/J;
                            berJ(l) = berJ(l) + berk;
                        end
                    end
                    ber = (berI+berJ)/log2(I*J);
                end
            end
        case 'fsk'
            if (rho == 0)
                % Orthogonal FSK
                if strncmpi(coherence, 'c', 1)
                    if (M == 2)
                        mu = sqrt(gamma_c ./ (2 + gamma_c));
                        ber = zeros(size(EbNoLin));
                        for i = 1:length(EbNoLin)
                            for k = 0:divOrder-1
                                ber(i) = ber(i) + nchoosek(divOrder-1+k, k)* ...
                                    ((1+mu(i))/2).^k;
                            end
                        end
                        ber = ber .* ((1-mu)/2).^divOrder;
                        ser = ber;
                    else
                        error('comm:berfading:FSK', ...
                            'No theoretical results for coherent detection of orthogonal FSK with M > 2.');
                    end
                elseif strncmpi(coherence, 'n', 1)
                    ser = zeros(size(EbNoLin));
                    tol = 1e-4 ./ EbNoLin.^4;
                    tol(tol>1e-4) = 1e-4;
                    tol(tol<eps) = eps;
                    for i = 1:length(EbNoLin)
                        ser(i) = (1 - quad(@fskf, 0, max(gamma_c(i)*divOrder, 1)*15, ...
                            tol(i), [], gamma_c(i), M, divOrder));
                    end
                    ser(ser<0) = 0;
                    ber = ser * M/(2*(M-1));
                end
            else
                % Non-orthogonal FSK
                if M == 2
                    if strncmpi(coherence, 'c', 1)
                        if divOrder == 1
                            ber = 1/2 * ( 1 - sqrt(gamma_c*(1-real(rho))./(2+gamma_c*(1-real(rho)))) );
                            ser = ber;
                        else
                            tol = 1e-4 ./ EbNoLin.^5;
                            tol(tol>1e-4) = 1e-4;
                            tol(tol<eps) = eps;
                            ser = zeros(size(EbNoLin));
                            f_theta = @(theta) -((1-real(rho))/2)./(sin(theta)).^2;
                            int_theta = @(theta,gamma) (mgf_rayleigh_handle(f_theta(theta),gamma)).^divOrder;
                            for i = 1:length(EbNoLin)
                                ser(i) = quad(@(theta)int_theta(theta,gamma_c(i)), 10e-6, pi/2, tol(i), []);
                            end
                            ser = 1/pi * ser;
                            ber = ser;
                        end
                    elseif strncmpi(coherence, 'n', 1)
                        if divOrder == 1
                            if abs(rho) >= 0.999999
                                ber = 0.5*ones(size(EbNoLin));
                                ser = ber;
                            else
                                struct_warning = warning('off', 'MATLAB:quad:MaxFcnCount');
                                ber = zeros(size(EbNoLin));
                                tol = 1e-4 ./ EbNoLin.^4;
                                tol(tol>1e-4) = 1e-4;
                                tol(tol<eps) = eps;
                                xi = sqrt((1-sqrt(1-(abs(rho))^2))/(1+sqrt(1-(abs(rho))^2)));
                                f_theta = @(theta,rho,xi) -1/4 * (1+sqrt(1-(abs(rho))^2)) * (1+2*xi*sin(theta)+xi^2);
                                int_theta = @(theta,gamma,rho,xi) (1-xi^2)./(1+2*xi*sin(theta)+xi^2) ...
                                    .* mgf_rayleigh_handle(f_theta(theta,rho,xi),gamma);
                                for i = 1:length(EbNoLin)
                                    ber(i) = 1/(4*pi) * quad(@(theta)int_theta(theta,gamma_c(i),rho,xi), -pi, pi, tol(i), []);
                                end
                                ser = ber;
                                warning(struct_warning.state, struct_warning.identifier);     % recover warning state
                            end
                        else
                            error('comm:berfading:fskNonorthogonalNoncoherentDiversity', ...
                                'No results for noncoherent detection of nonorthogonal FSK with diversity.');
                        end
                    end
                else
                    error('comm:berfading:fskNonorthogonal', ...
                        'No results for nonorthogonal FSK with M > 2.');
                end
            end
    end
else    % Rician fading
    switch modType
        case 'psk'
            if (phaserr == 0)
                ser = zeros(size(EbNoLin));
                tol = 1e-4 ./ EbNoLin.^4;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                f_theta = @(theta,M) - (sin(pi/M))^2./(sin(theta)).^2;
                int_theta = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta(theta,M),gamma,kFactor)).^divOrder;
                for i = 1:length(EbNoLin)
                    ser(i) = 1/pi * quad(@(theta)int_theta(theta,M,gamma_c(i),kFactor), 1e-6, pi*(M-1)/M, tol(i), []);
                end
                if (M == 2)
                    ber = ser;
                elseif (M == 4)
                    ber = zeros(size(EbNoLin));
                    PP = zeros(3,length(EbNoLin));
                    for j = 1:length(EbNoLin)
                        for i=1:3
                            f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                            int_theta1 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta1(theta,M),gamma,kFactor)).^divOrder;
                            f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                            int_theta2 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta2(theta,M),gamma,kFactor)).^divOrder;
                            PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                        end
                        ber(j) = 1/2 * ( PP(1,j) +  2*PP(2,j) + PP(3,j) );
                    end
                elseif (M == 8)
                    ber = zeros(size(EbNoLin));
                    PP = zeros(7,length(EbNoLin));
                    for j = 1:length(EbNoLin)
                        for i=1:7
                            f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                            int_theta1 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta1(theta,M),gamma,kFactor)).^divOrder;
                            f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                            int_theta2 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta2(theta,M),gamma,kFactor)).^divOrder;
                            PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                        end
                        ber(j) = 1/3 * ( PP(1,j) +  2*PP(2,j) + PP(3,j) + 2*PP(4,j) ...
                            + 3*PP(5,j) + 2*PP(6,j) + PP(7,j) );
                    end
                elseif (M == 16)
                    ber = zeros(size(EbNoLin));
                    PP = zeros(8,length(EbNoLin));
                    for j = 1:length(EbNoLin)
                        for i=1:8
                            f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                            int_theta1 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta1(theta,M),gamma,kFactor)).^divOrder;
                            f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                            int_theta2 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta2(theta,M),gamma,kFactor)).^divOrder;
                            PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                        end
                        ber(j) = 1/2 * ( PP(1,j) +  2*PP(2,j) + 2*PP(3,j) + 2*PP(4,j) ...
                            + 3*PP(5,j) + 3*PP(6,j) + 2*PP(7,j) + PP(8,j) );
                    end
                elseif (M == 32)
                    ber = zeros(size(EbNoLin));
                    PP = zeros(16,length(EbNoLin));
                    for j = 1:length(EbNoLin)
                        for i=1:16
                            f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                            int_theta1 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta1(theta,M),gamma,kFactor)).^divOrder;
                            f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                            int_theta2 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta2(theta,M),gamma,kFactor)).^divOrder;
                            PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                        end
                        ber(j) = 2/5 * ( PP(1,j) + 2*PP(2,j) + 2*PP(3,j) + 2*PP(4,j) ...
                            + 3*PP(5,j) + 3*PP(6,j) + 2*PP(7,j) + 2*PP(8,j) ...
                            + 3*PP(9,j) + 4*PP(10,j) + 4*PP(11,j) + 3*PP(12,j) ...
                            + 3*PP(13,j) + 3*PP(14,j) + 2*PP(15,j) + PP(16,j) );
                    end
                else
                    ber = zeros(size(EbNoLin));
                    PP = zeros(M/2,length(EbNoLin));
                    w = gen_weights_psk(M);
                    for j = 1:length(EbNoLin)
                        for i=1:M/2
                            f_theta1 = @(theta,M) - (sin((2*i-1)*pi/M))^2./(sin(theta)).^2;
                            int_theta1 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta1(theta,M),gamma,kFactor)).^divOrder;
                            f_theta2 = @(theta,M) - (sin((2*i+1)*pi/M))^2./(sin(theta)).^2;
                            int_theta2 = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta2(theta,M),gamma,kFactor)).^divOrder;
                            PP(i,j) = 1/(2*pi) * quad(@(theta)int_theta1(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i-1))/M, tol(j), []) ...
                                - 1/(2*pi) * quad(@(theta)int_theta2(theta,M,gamma_c(j),kFactor), 1e-6, pi*(M-(2*i+1))/M, tol(j), []);
                        end
                        ber(j) = sum(w .* PP(:,j));
                    end
                end
            else
                if (M == 2) && (divOrder == 1)
                    if (kFactor > 300)   % considered AWGN due to limited numerical precision
                        ber = bersync(EbNo, phaserr, 'carrier');
                        ser = ber;
                    else
                        if (phaserr < 0.1)
                            phaserr = 0.1;  % due to limited numerical precision
                        end
                        % optimize tolerance for integration precision and speed
                        scale = exp(-kFactor) / pi;
                        tol = 1e-5 ./ EbNoLin.^((1 + 10*(1-exp(-kFactor/40))) * ...
                            max(0, 1 - sqrt(phaserr*kFactor/300)));
                        tul = 1e-4;
                        tol(tol>tul) = tul;   % upper limit of tolerance
                        tll = 10^(30*phaserr-21);
                        if (tll > 1e-6)
                            tll = 1e-6;
                        end
                        tol(tol<tll) = tll;   % lower limit of tolerance
                        tol = tol / scale;
                        % optimize upper limit of integration interval
                        ul = min(2*kFactor+40, kFactor+100);
                        ber = zeros(size(EbNoLin));
                        for i = 1:length(EbNoLin)
                            ber(i) = dblquad(@rician, 0, pi, 0, ul, tol(i), [], EbNoLin(i), kFactor, phaserr);
                        end
                        ber = ber * scale;
                        ser = ber;
                    end
                else
                    error('comm:berfading:PSK_phaseerr', ...
                        'No theoretical results for PSK in Rician fading with phase error if M > 2 or L > 1.');
                end
            end
        case 'depsk'
            if (M == 2)
                tol = 1e-4 ./ EbNoLin.^5;
                tol(tol>1e-4) = 1e-4;
                tol(tol<eps) = eps;
                ser = zeros(size(EbNoLin));
                f_theta = @(theta) -1./(sin(theta)).^2;
                int_theta = @(theta,gamma,kFactor) (mgf_rician_handle(f_theta(theta),gamma,kFactor)).^divOrder;
                for i = 1:length(EbNoLin)
                    ser(i) = quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 10e-6, pi/2, tol(i), []) ...
                        -quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 10e-6, pi/4, tol(i), []);
                end
                ser = 2/pi * ser;
                ber = ser;
            else
                error('comm:berfading:DEPSK', ...
                    'No theoretical results for DEPSK if M > 2.');
            end
        case 'oqpsk'
            [ber ser] = berfading(EbNo,'psk',4,divOrder,kFactor,0);
        case 'dpsk'
            struct_warning = warning('off', 'MATLAB:quad:MaxFcnCount');
            ser = zeros(size(EbNoLin));
            tol = 1e-4 ./ EbNoLin.^8;
            tol(tol>1e-4) = 1e-4;
            tol(tol<eps) = eps;
            f_theta_ser = @(theta,M) - (1-cos(pi/M)*cos(theta));
            int_theta_ser = @(theta,M,gamma,kFactor) 1./(1-cos(pi/M)*cos(theta)) ...
                .* (mgf_rician_handle(f_theta_ser(theta,M),gamma,kFactor)).^divOrder;
            for i = 1:length(EbNoLin)
                ser(i) = sin(pi/M)/(2*pi) * quad(@(theta)int_theta_ser(theta,M,gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []);
            end
            ber = zeros(size(EbNoLin));
            f_theta = @(theta,ksi) - (1-cos(ksi)*cos(theta));
            int_theta = @(theta,ksi,gamma,kFactor) 1./(1-cos(ksi)*cos(theta)) ...
                .* (mgf_rician_handle(f_theta(theta,ksi),gamma,kFactor)).^divOrder;
            if (M == 2)
                for i = 1:length(EbNoLin)
                    ber(i) = 2*(sin(pi/2)/(4*pi)) * quad(@(theta)int_theta(theta,(pi/2),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []);
                end
            elseif (M == 4)
                for i = 1:length(EbNoLin)
                    ber(i) = (-sin(5*pi/4)/(4*pi)) * quad(@(theta)int_theta(theta,(5*pi/4),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(pi/4)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/4),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []);
                end
            elseif (M == 8)
                for i = 1:length(EbNoLin)
                    ber(i) = 2/3 * ( (-sin(13*pi/8)/(4*pi)) * quad(@(theta)int_theta(theta,(13*pi/8),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(pi/8)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/8),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ) ;
                end
            elseif (M == 16)
                for i = 1:length(EbNoLin)
                    ber(i) = 1/2 * ( (-sin(13*pi/16)/(4*pi)) * quad(@(theta)int_theta(theta,(13*pi/16),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(9*pi/16)/(4*pi)) *  quad(@(theta)int_theta(theta,(9*pi/16),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(3*pi/16)/(4*pi)) *  quad(@(theta)int_theta(theta,(3*pi/16),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(pi/16)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/16),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ) ;
                end
            elseif (M == 32)
                for i = 1:length(EbNoLin)
                    ber(i) = 2/5 * ( (-sin(29*pi/32)/(4*pi)) * quad(@(theta)int_theta(theta,(29*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        + (-sin(23*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(23*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(19*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(19*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(17*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(17*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        + (-sin(13*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(13*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(9*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(9*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(3*pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(3*pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                        - (-sin(pi/32)/(4*pi)) *  quad(@(theta)int_theta(theta,(pi/32),gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ) ;
                end
            else
                w = gen_weights_psk(M);
                PP = zeros(M/2,length(EbNoLin));
                for i = 1:length(EbNoLin)
                    for j=1:M/2
                        PP(j,i) = (-sin((2*j+1)*pi/M)/(4*pi)) * quad(@(theta)int_theta(theta,(2*j+1)*pi/M,gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ...
                            - (-sin((2*j-1)*pi/M)/(4*pi)) * quad(@(theta)int_theta(theta,(2*j-1)*pi/M,gamma_c(i),kFactor), -pi/2, pi/2, tol(i), []) ;
                    end
                    ber(i) = sum(w .* PP(:,i));
                end
            end
            warning(struct_warning.state, struct_warning.identifier);     % recover warning state
        case 'pam'
            ser = zeros(size(EbNoLin));
            tol = 1e-4 ./ EbNoLin.^4;
            tol(tol>1e-4) = 1e-4;
            tol(tol<eps) = eps;
            f_theta = @(theta,M) - 3/(M^2-1)./(sin(theta)).^2;
            int_theta = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta(theta,M),gamma,kFactor)).^divOrder;
            for i = 1:length(EbNoLin)
                ser(i) = (M-1)/M * 2/pi * quad(@(theta)int_theta(theta,M,gamma_c(i),kFactor), 1e-6, pi/2, tol(i), []);
            end
            ber = zeros(size(EbNoLin));
            for l=1:length(EbNoLin)
                for i = 1:k
                    berk = 0;
                    for j=0:(1-2^(-i))*M - 1
                        f_theta = @(theta,M) - (2*j+1)^2*3/(M^2-1)./(sin(theta)).^2;
                        int_theta = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta(theta,M),gamma,kFactor)).^divOrder;
                        berk = berk + (-1)^(floor(j*2^(i-1)/M)) * (2^(i-1) - floor(j*2^(i-1)/M+1/2)) ...
                            * 1/pi * quad(@(theta)int_theta(theta,M,gamma_c(l),kFactor), 1e-6, pi/2, tol(l), []);
                    end
                    berk = berk*2/M;
                    ber(l) = ber(l) + berk;
                end
            end
            ber = ber/k;
        case 'qam'
            ser = zeros(size(EbNoLin));
            tol = 1e-4 ./ EbNoLin.^4;
            tol(tol>1e-4) = 1e-4;
            tol(tol<eps) = eps;
            if (ceil(k/2) == k/2)   % k is even
                f_theta = @(theta,M) - 3/(2*(M-1))./(sin(theta)).^2;
                int_theta = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta(theta,M),gamma,kFactor)).^divOrder;
                for i = 1:length(EbNoLin)
                    ser(i) = (sqrt(M)-1)/sqrt(M) * 4/pi * quad(@(theta)int_theta(theta,M,gamma_c(i),kFactor), 1e-6, pi/2, tol(i), []) ...
                        - ((sqrt(M)-1)/sqrt(M))^2 * 4/pi * quad(@(theta)int_theta(theta,M,gamma_c(i),kFactor), 1e-6, pi/4, tol(i), []);
                end
                ber = zeros(size(EbNoLin));
                for l = 1:length(EbNoLin)
                    for i = 1:log2(sqrt(M))
                        berk = 0;
                        for j=0:(1-2^(-i))*sqrt(M) - 1
                            f_theta = @(theta,M) - (2*j+1)^2*1.5/(M-1)./(sin(theta)).^2;
                            int_theta = @(theta,M,gamma,kFactor) (mgf_rician_handle(f_theta(theta,M),gamma,kFactor)).^divOrder;
                            berk = berk + (-1)^(floor(j*2^(i-1)/sqrt(M))) * (2^(i-1) - floor(j*2^(i-1)/sqrt(M)+1/2)) ...
                                * 1/pi * quad(@(theta)int_theta(theta,M,gamma_c(l),kFactor), 1e-6, pi/2, tol(l), []);
                        end
                        berk = berk*2/sqrt(M);
                        ber(l) = ber(l) + berk;
                    end
                end
                ber = ber/log2(sqrt(M));
            else
                I = 2^(ceil(log2(M)/2));
                J = 2^(floor(log2(M)/2));
                if (M == 8)
                    f_theta = @(theta) - 1/6./(sin(theta)).^2;
                    int_theta = @(theta,gamma,kFactor) (mgf_rician_handle(f_theta(theta),gamma,kFactor)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ser(i) = 5/(2*pi) * quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 1e-6, pi/2, tol(i), []) ...
                            - 3/(2*pi) * quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 1e-6, pi/4, tol(i), []);
                    end
                else
                    f_theta = @(theta) - 3/(I^2+J^2-2)./(sin(theta)).^2;
                    int_theta = @(theta,gamma,kFactor) (mgf_rician_handle(f_theta(theta),gamma,kFactor)).^divOrder;
                    for i = 1:length(EbNoLin)
                        ser(i) = (4*I*J-2*I-2*J)/(M*pi) * quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 1e-6, pi/2, tol(i), []) ...
                            - 4/(M*pi)*(1+I*J-I-J) * quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 1e-6, pi/4, tol(i), []);
                    end
                end
                berI = zeros(size(EbNoLin));
                berJ = zeros(size(EbNoLin));
                for l=1:length(EbNoLin)
                    for i = 1:log2(I)
                        berk = 0;
                        for j=0:(1-2^(-i))*I - 1
                            f_theta = @(theta,I,J) - (2*j+1)^2*3*log2(I*J)/(I^2+J^2-2)./(sin(theta)).^2;
                            int_theta = @(theta,I,J,gamma,kFactor) (mgf_rician_handle(f_theta(theta,I,J),gamma,kFactor)).^divOrder;
                            berk = berk + (-1)^(floor(j*2^(i-1)/I)) * (2^(i-1) - floor(j*2^(i-1)/I+1/2)) ...
                                * 1/pi * quad(@(theta)int_theta(theta,I,J,gamma_c(l)/k,kFactor), 1e-6, pi/2, tol(l), []);
                        end
                        berk = berk*2/I;
                        berI(l) = berI(l) + berk;
                    end
                end
                for l=1:length(EbNoLin)
                    for i = 1:log2(J)
                        berk = 0;
                        for j=0:(1-2^(-i))*J - 1
                            f_theta = @(theta,I,J) - (2*j+1)^2*3*log2(I*J)/(I^2+J^2-2)./(sin(theta)).^2;
                            int_theta = @(theta,I,J,gamma,kFactor) (mgf_rician_handle(f_theta(theta,I,J),gamma,kFactor)).^divOrder;
                            berk = berk + (-1)^(floor(j*2^(i-1)/J)) * (2^(i-1) - floor(j*2^(i-1)/J+1/2)) ...
                                * 1/pi * quad(@(theta)int_theta(theta,I,J,gamma_c(l)/k,kFactor), 1e-6, pi/2, tol(l), []);
                        end
                        berk = berk*2/J;
                        berJ(l) = berJ(l) + berk;
                    end
                end
                ber = (berI+berJ)/log2(I*J);
            end
        case 'fsk'
            if (rho == 0)
                % Orthogonal FSK
                if strncmpi(coherence, 'c', 1)
                    if (M == 2)
                        if divOrder == 1
                            d = gamma_c/2/(1+kFactor);
                            u = sqrt(kFactor*(1+2*d-2*sqrt(d.*(1+d)))./(2*(1+d)));
                            w = sqrt(kFactor*(1+2*d+2*sqrt(d.*(1+d)))./(2*(1+d)));
                            ber = marcumq(u,w) - 1/2 * (1+sqrt(d./(1+d))) ...
                                .* exp(-(u.^2+w.^2)/2) .* besseli(0,u.*w);
                            ser = ber;
                        else
                            tol = 1e-4 ./ EbNoLin.^5;
                            tol(tol>1e-4) = 1e-4;
                            tol(tol<eps) = eps;
                            ser = zeros(size(EbNoLin));
                            f_theta = @(theta) -(1/2)./(sin(theta)).^2;
                            int_theta = @(theta,gamma,kFactor) (mgf_rician_handle(f_theta(theta),gamma,kFactor)).^divOrder;
                            for i = 1:length(EbNoLin)
                                ser(i) = quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 10e-6, pi/2, tol(i), []);
                            end
                            ser = 1/pi * ser;
                            ber = ser;
                        end
                    else
                        error('comm:berfading:FSK', ...
                            'No theoretical results for coherent detection of orthogonal FSK with M > 2.');
                    end
                elseif strncmpi(coherence, 'n', 1)
                    if M > 32
                        error('comm:berfading:rician:fskOrthogonalNoncoherentRician', ...
                            'No theoretical results for noncoherent detection of orthogonal FSK in Rician fading with M > 32.');
                    else
                        b = gamma_c/(1+kFactor);
                        p = divOrder*kFactor*gamma_c/(1+kFactor);
                        ser = zeros(size(EbNoLin));
                        beta = zeros(M*divOrder,M);
                        for r = 1:M-1
                            Pml = zeros(size(EbNoLin));
                            for l = 0:r*(divOrder-1)
                                % Calculation of beta coefficients
                                if l == 0
                                    beta(l+1,r) = 1;
                                elseif r == 1
                                    beta(l+1,r) = 1/factorial(l);
                                elseif l == 1
                                    beta(l+1,r) = r;
                                else
                                    beta(l+1,r) = 0;
                                    for n = l-(divOrder-1):l
                                        % Calculation of indicator function
                                        if n >= 0 && n <= (r-1)*(divOrder-1)
                                            beta(l+1,r) = beta(l+1,r) ...
                                                + beta(n+1,r-1)/factorial(l-n);
                                        end
                                    end
                                end
                                Pml = Pml + beta(l+1,r)*gamma(divOrder+l)*((1+b)./((1+b)*r+1)).^l.*f1_1(divOrder+l,divOrder,p./((1+b).*((1+b)*r+1)));
                            end
                            ser = ser + nchoosek(M-1,r)*(-1)^(r+1)*(1./((1+b)*r+1)).^divOrder.*exp(-p./(1+b)).*Pml;
                        end
                        ser = 1/(gamma(divOrder))*ser;
                        ber = ser * M/(2*(M-1));
                    end
                end
            else
                % Non-orthogonal FSK
                if M == 2
                    if strncmpi(coherence, 'c', 1)
                        if divOrder == 1
                            d = gamma_c/2/(1+kFactor)*(1-real(rho));
                            u = sqrt(kFactor*(1+2*d-2*sqrt(d.*(1+d)))./(2*(1+d)));
                            w = sqrt(kFactor*(1+2*d+2*sqrt(d.*(1+d)))./(2*(1+d)));
                            ber = marcumq(u,w) - 1/2 * (1+sqrt(d./(1+d))) ...
                                .* exp(-(u.^2+w.^2)/2) .* besseli(0,u.*w);
                            ser = ber;
                        else
                            tol = 1e-4 ./ EbNoLin.^5;
                            tol(tol>1e-4) = 1e-4;
                            tol(tol<eps) = eps;
                            ser = zeros(size(EbNoLin));
                            f_theta = @(theta) -((1-real(rho))/2)./(sin(theta)).^2;
                            int_theta = @(theta,gamma,kFactor) (mgf_rician_handle(f_theta(theta),gamma,kFactor)).^divOrder;
                            for i = 1:length(EbNoLin)
                                ser(i) = quad(@(theta)int_theta(theta,gamma_c(i),kFactor), 10e-6, pi/2, tol(i), []);
                            end
                            ser = 1/pi * ser;
                            ber = ser;
                        end
                    elseif strncmpi(coherence, 'n', 1)
                        if divOrder == 1
                            if abs(rho) >= 0.999999
                                ber = 0.5*ones(size(EbNoLin));
                                ser = ber;
                            else
                                struct_warning = warning('off', 'MATLAB:quad:MaxFcnCount');
                                ber = zeros(size(EbNoLin));
                                tol = 1e-4 ./ EbNoLin.^4;
                                tol(tol>1e-4) = 1e-4;
                                tol(tol<eps) = eps;
                                xi = sqrt((1-sqrt(1-(abs(rho))^2))/(1+sqrt(1-(abs(rho))^2)));
                                f_theta = @(theta,rho,xi) -1/4 * (1+sqrt(1-(abs(rho))^2)) * (1+2*xi*sin(theta)+xi^2);
                                int_theta = @(theta,gamma,rho,xi,kFactor) (1-xi^2)./(1+2*xi*sin(theta)+xi^2) ...
                                    .* mgf_rician_handle(f_theta(theta,rho,xi),gamma,kFactor);
                                for i = 1:length(EbNoLin)
                                    ber(i) = 1/(4*pi) * quad(@(theta)int_theta(theta,gamma_c(i),rho,xi,kFactor), -pi, pi, tol(i), []);
                                end
                                ser = ber;
                                warning(struct_warning.state, struct_warning.identifier);     % recover warning state
                            end
                        else
                            error('comm:berfading:fskNonorthogonalNoncoherentDiversity', ...
                                'No results for noncoherent detection of nonorthogonal FSK with diversity.');
                        end
                    end
                else
                    error('comm:berfading:fskNonorthogonal', ...
                        'No results for nonorthogonal FSK with M > 2.');
                end
            end
    end
end
ber(ber>0.5) = 0.5;
ser(ser>1.0) = 1.0;
                
                
function out = pskf(mu, divOrder)
% (C-18) in Digital Communications (4th ed.), Proakis

out = zeros(size(mu));
for i = 0:divOrder-1
    out = out + nchoosek(2*i, i) * ((1-mu.^2)/4).^i;
end
out = (1-mu.*out) / 2;

function out = fskf(U, gamma_c, M, divOrder)
% integrand function for FSK on Rayleigh channel, (14.4-47)
% (14.4-47) in Digital Communications (4th ed.), Proakis

s = 0;
for i = 0:divOrder-1
    s = s + U.^i/factorial(i);
end
out = U.^(divOrder-1) .* exp(-U./(1+gamma_c)) ...
    ./ ((1+gamma_c).^divOrder .* factorial(divOrder-1)) ...
    .* (1-exp(-U).*s).^(M-1);

function out = rician(phi, y, EbNoLin, kFactor, phaserr)
% integrand function for the outer integration in (22) in
% "Convolutional code performance in the Rician fading channel",
% IEEE Trans. Commun., Modestino & Mui, 1976.

cosPhi = cos(phi);
a = sqrt(y / (1 + kFactor));
b = a / phaserr^2;
out = qfunc(sqrt(2*EbNoLin) * a * cosPhi) .* exp(b*cosPhi) * ...
    exp(-y) .* besseli(0, 2*sqrt(y*kFactor)) ./ besseli(0, b);


function out = int_dpsk(y, gamma, M)
% integrand function for DPSK: Sim00, eq. 8.172

out = 1./((1-cos(pi/M)*cos(y)).*(1+gamma*(1-cos(pi/M)*cos(y))));


function out = int_dpsk_ber(y, gamma, ksi)
% integrand function for ber of DPSK: Sim00, eq. 8.87

out = -sin(ksi)/(4*pi) * 1./((1-cos(ksi).*cos(y)).*(1+gamma.*(1-cos(ksi).*cos(y))));


function weights = gen_weights_psk(M)

k = log2(M);
z = zeros(M,k);
[y,map] = bin2gray(de2bi(0:M-1,'left-msb'),'psk',M);
z(:,:) = y(map+1,:);
w = sum(z,2);
wsym = [ w(2:M/2) + flipud(w(M/2+2:M)) ; w(M/2+1) ];
weights = wsym/k;


function result=f1_1(a,c,z)
% Confluent hypergeometric function

order = 60;
result = 0;

if c<=0
    result = Inf;
elseif (a==0)
    result = 1;
elseif z==0
    result = 1;
elseif (a==-1)
    result = 1-z/c;
elseif (a==c)
    result = exp(z);
elseif (a==c+1)
    result = (1+z/c) .* exp(z);
elseif (a==1 && c==2)
    result = (exp(z)-1) ./ z;
    % a positive integer
elseif (a>0 && floor(a)==a)
    for k=0:1:order
        prod_a = 1;
        prod_c = 1;
        for i=0:k-1
            prod_a = prod_a * (a+i);
            prod_c = prod_c * (c+i);
        end
        result = result + prod_a/prod_c*z.^k/factorial(k);
    end
    % a negative integer
elseif (a<0 && floor(a)==a)
    for k=0:1:-a
        prod_a = 1;
        prod_c = 1;
        for i=0:k-1
            prod_a = prod_a * (a+i);
            prod_c = prod_c * (c+i);
        end
        result = result + prod_a/prod_c*z.^k/factorial(k);
    end
    % a negative real
elseif (a<0)
    for k=0:1:order
        result = result + gamma(c-a+k)/gamma(c+k)*(-z).^k/factorial(k);
    end
    result = result * gamma(c)/gamma(c-a).*exp(z);
    % a positive real
else
    for k=0:1:order
        result = result + gamma(a+k)/gamma(c+k)*z.^k/factorial(k);
    end
    result = result * gamma(c)/gamma(a);
end
