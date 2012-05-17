function ber = bercoding(EbNodB, coding, decision, varargin)
%BERCODING Bit error rate (BER) for coded AWGN channels.
%   BERUB = BERCODING(EbNo, 'conv', DECISION, CODERATE, DSPEC) returns an upper
%   bound of the BER of binary convolutional codes with coherent BPSK or QPSK
%   modulation. 
%   EbNo -- information bit energy to noise power spectral density ratio (in dB)
%   DECISION -- string variable: 'hard' for hard decision,
%                                'soft' for unquantized soft decision
%   CODERATE -- code rate
%   DSPEC -- structure containing the following properties of the code:
%                                   the minimum free distance DSPEC.DFREE 
%                                   the distance spectrum DSPEC.WEIGHT
%
%   BERUB = BERCODING(EbNo, 'block', DECISION, N, K, DMIN) returns an upper
%   bound of the BER of (N, K) linear binary block codes with coherent BPSK
%   or QPSK modulation. 
%   DMIN -- minimum distance of the code, bounded by DMIN <= N - K + 1.
%
%   BERAPPROX = BERCODING(EbNo, 'Hamming', 'hard', N) returns an approximation
%   of the BER of a Hamming code using hard decision decoding and coherent
%   BPSK or QPSK modulation.
%   Note: for a Hamming code, K is computed directly from N.
% 
%   BERUB = BERCODING(EbNo, 'Golay', 'hard', 24) returns an upper bound of
%   the BER of an extended (24, 12) Golay code using hard decision decoding
%   and coherent BPSK or QPSK modulation.
%   Note: currently, only the extended (24, 12) Golay code is supported.
%
%   BERAPPROX = BERCODING(EbNo, 'RS', 'hard', N, K) returns an approximation of
%   the BER of an (N, K) Reed-Solomon code using hard decision decoding and
%   coherent BPSK or QPSK modulation.
%
%   See also DISTSPEC, BERAWGN, BERFADING, BERSYNC, BERTOOL.

%   References 
%   [1] J. G. Proakis, Digital Communications, 4th edition, 
%           McGraw-Hill, 2001. 
%   [2] P. Frenger, P. Orten, and T. Ottosson, "Convolutional codes with
%           optimum distance spectrum", IEEE Commun. Letters, vol. 3,
%           no. 11, Nov. 1999.
%   [3] J. P. Odenwalder, Error Control Coding Handbook, Final Report,
%           LINKABIT Corporation, 1976. 
%   [4] B. Sklar, Digital Communications, 2nd edition, Prentice Hall, 2001.
%   [5] T. A. Gulliver, "Matching Q-ary Reed-Solomon codes with M-ary
%           modulation", IEEE Trans. on Commun., vol. 45, no. 11, Nov. 1997. 

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2007/06/08 15:51:38 $

if (~is(EbNodB, 'real') || ~is(EbNodB, 'vector'))
    error('comm:bercoding:EbNo', 'EbNo must be a real vector.');
end

EbNo = 10.^(EbNodB/10);    % converting EbNo from dB to linear scale
errString =  'N must be of the form 2^m - 1, such that m>=2'; % error message. Used multiple times.

switch(lower(coding))
    
    case 'conv'    % convolutional coding
        
        if (nargin < 5)
            error('comm:bercoding:minArgsconv', ...
                'BERCODING requires 5 input arguments for convolutional coding.');
        end
        
        codeRate = varargin{1};
        if (~is(codeRate, 'real') || ~is(codeRate, 'scalar') ...
                || codeRate > 1 || codeRate <= 0)
            error('comm:bercoding:codeRate', ...
                'CODERATE must be a real number between 0 and 1.');
        end
        
        dspec = varargin{2};
        if (~isstruct(dspec)||~isfield(dspec,'dfree') || ~isfield(dspec,'weight'))
            error('comm:bercoding:dspec', ...
                'DSPEC must be a structure containing dfree and weight fields.');
        end     
        distSpec = dspec.weight;
        dfree = dspec.dfree;
        if (~is(dfree, 'scalar') || ~is(dfree, 'positive integer'))
            error('comm:bercoding:dfree', ...
                'DSPEC.DFREE must be a positive integer.');
        end
        if (~is(distSpec, 'real') || ~is(distSpec, 'vector'))
            error('comm:bercoding:distSpec', ...
                'DSPEC.WEIGHT must be a real vector.');
        end

        ber = zeros(size(EbNo));

        if strncmpi(decision, 'h', 1)           % hard decision
            % BER for BSC
            if (nargin == 5)
                % Default: BPSK, absolutely encoded
                EbNodBcoded = 10*log10(EbNo*codeRate);
                p = berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
            else
                try
                    EbNodBcoded = 10*log10(EbNo*codeRate);
                    p = berawgn(EbNodBcoded, varargin{3:end});
                catch
                    error('comm:bercoding:convhard', ...
                            'BERCODING requires 5 input arguments for convolutional coding.');
                end        
            end
            for d = dfree : (length(distSpec) + dfree - 1)
                P2d = 0;
                for k = ceil((d+1)/2):d
                    P2d = P2d + nchoosek(d, k) * p.^k .* (1-p).^(d-k);
                end
                if (ceil(d/2) == d/2)
                    P2d = P2d + nchoosek(d, d/2) * (p.*(1-p)).^(d/2)/2;
                end
                ber = ber + distSpec(d-dfree+1) * P2d;
            end
        elseif strncmpi(decision, 's', 1)   % soft decision
            for d = dfree : (length(distSpec) + dfree - 1)
                if (nargin == 5)
                    % Default: BPSK, absolutely encoded
                    EbNodBcoded = 10*log10(EbNo*codeRate*d);
                    P2d = berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
                elseif ( strcmpi(varargin{3}, 'psk') && (nargin>=7) && (varargin{4} <= 4) ) ...
                    || ( strcmpi(varargin{3}, 'oqpsk') ) ...
                    || ( strcmpi(varargin{3}, 'dpsk') && (nargin>=7) && (varargin{4} == 2) ) ...
                    || ( strcmpi(varargin{3}, 'pam') && (nargin>=7) && (varargin{4} == 2) ) ...
                    || ( strcmpi(varargin{3}, 'qam') && (nargin>=7) && (varargin{4} == 4) ) ...
                    || ( strcmpi(varargin{3}, 'fsk') && (nargin>=7) && (varargin{4} == 2) ) ...
                    || ( strcmpi(varargin{3}, 'msk') )
                    try
                        EbNodBcoded = 10*log10(EbNo*codeRate*d);
                        P2d = berawgn(EbNodBcoded, varargin{3:end});
                    catch
                        error('comm:bercoding:convsoftpsk', ...
                            'BERCODING requires 5 input arguments for convolutional coding.');
                    end    
                else
                    error('comm:bercoding:convsoft', ...
                            'BERCODING requires 5 input arguments for convolutional coding.');
                end
                ber = ber + distSpec(d-dfree+1)*P2d;
            end
        else
            error('comm:bercoding:decision', ...
                'DECISION must be either ''hard'' or ''soft''.');
        end

    case 'block'  % block coding
        if (nargin < 6)
                error('comm:bercoding:minArgsBlock', ...
                'BERCODING requires 6 input arguments for block coding.');
        end

        n = varargin{1};
        if ( isempty(n) || ~is(n, 'scalar') || ~is(n, 'positive integer') ...
                || isinf(n) || isnan(n) )
            error('comm:bercoding:N', 'N must be a finite positive integer.');
        end

        k = varargin{2};
        if ( isempty(k) || ~is(k, 'scalar') || ~is(k, 'positive integer') ...
               || isinf(k) || isnan(k) || k > n)
            error('comm:bercoding:K', ...
                'K must be a positive integer smaller than N.');
        end

        dmin = varargin{3};
        if ( isempty(dmin) || ~is(dmin, 'scalar') || ~is(dmin, 'positive integer') ...
                || dmin>(n-k+1) )
            error('comm:bercoding:dmin', ...
             'DMIN must be a positive integer smaller than or equal to N-K+1.');
        end

        if strncmpi(decision, 'h', 1)   % hard decision
            % BER for BSC
            if (nargin == 6)
                % Default: BPSK, absolutely encoded
                EbNodBcoded = 10*log10(EbNo*k/n);
                p = berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
            else
                try
                    EbNodBcoded = 10*log10(EbNo*k/n);
                    p = berawgn(EbNodBcoded, varargin{4:end});
                catch
                    error('comm:bercoding:blockhard', ...
                      'BERCODING requires 6 input arguments for block coding.');
                end        
            end
            
            t = floor((dmin-1)/2);
            % [3], Eqs. 4.3-4.4, upper bound
            ber = 0;
            for m = t+1:n
                ber = ber + (m+t) * nchoosek(n, m) * p.^m .* (1-p).^(n-m);
            end
            ber = ber / n;

        elseif strncmpi(decision, 's', 1)   % Soft decision
            if (nargin == 6)
                % Default: BPSK, absolutely encoded
                EbNodBcoded = 10*log10(EbNo*k/n*dmin);
                wer = (2^k - 1) * berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
            elseif ( strcmpi(varargin{4}, 'psk') && (nargin>=8) && (varargin{5} <= 4) ) ...
                    || ( strcmpi(varargin{4}, 'oqpsk') ) ...
                    || ( strcmpi(varargin{4}, 'pam') && (nargin>=8) && (varargin{5} == 2) ) ...
                    || ( strcmpi(varargin{4}, 'qam') && (nargin>=8) && (varargin{5} == 4) ) ...
                    || ( strcmpi(varargin{4}, 'fsk') && (nargin>=9) && (varargin{5} == 2) && strncmpi(varargin{6}, 'coherent',1) ) ...
                    || ( strcmpi(varargin{4}, 'msk') )
                try
                    EbNodBcoded = 10*log10(EbNo*k/n*dmin);
                    wer = (2^k - 1) * berawgn(EbNodBcoded, varargin{4:end});
                catch
                    error('comm:bercoding:blocksoftpsk', ...
                        'BERCODING requires 6 input arguments for block coding.');
                end
            elseif ( strcmpi(varargin{4}, 'fsk') && (nargin >= 9) && (varargin{5} == 2) && strncmpi(varargin{6}, 'noncoherent',1) )
                if nargin == 10
                    % No results for non-orthogonal non-coherent BFSK
                    rho = varargin{7};
                    if ischar(rho)
                        rho = str2double(rho);
                    end
                    if rho ~= 0
                        error('comm:bercoding:blocksoftfsknoncoherentnonorthogonal', ...
                        'No results for coded non-orthogonal non-coherent BFSK.');
                    end
                end    
                sum_ii = 0;
                for ii = 0:(dmin-1)
                    sum_rr = 0;
                    for rr = 0:(dmin-1-ii)
                        sum_rr = sum_rr + nchoosek(2*dmin-1,rr);
                    end
                    sum_ii = sum_ii + (1/2*EbNo*k/n*dmin).^ii .* 1/factorial(ii) * sum_rr;
                end
                wer = (2^k - 1) * 1/(2^(2*dmin-1)) .* exp(-1/2*EbNo*k/n*dmin) .* sum_ii ;
            elseif ( strcmpi(varargin{4}, 'dpsk') && (nargin >= 8) && (varargin{5} == 2) )
                sum_ii = 0;
                for ii = 0:(dmin-1)
                    sum_rr = 0;
                    for rr = 0:(dmin-1-ii)
                        sum_rr = sum_rr + nchoosek(2*dmin-1,rr);
                    end
                    sum_ii = sum_ii + (EbNo*k/n*dmin).^ii .* 1/factorial(ii) * sum_rr;
                end
                wer = (2^k - 1) * 1/(2^(2*dmin-1)) .* exp(-EbNo*k/n*dmin) .* sum_ii ;
            else
                error('comm:bercoding:blocksoft', ...
                    'BERCODING requires 6 input arguments for block coding.');
            end
            % Converting WER to BER upper bound
            % [1], p. 443
            ber = wer / 2;
        else
            error('comm:bercoding:decision', ...
                'DECISION must be either ''hard'' or ''soft''.');
        end


    case 'hamming'  % Hamming coding
        if (nargin  < 4)
            error('comm:bercoding:nArgsHamming', ...
                'BERCODING requires 4 input arguments for Hamming coding.');
        end
        
        switch(lower(decision))
            case 'hard'
                n = varargin{1};

                if isempty(n)
                   error('comm:bercoding:invalidN', errString); 
                end             
                
                % Parameter checking for m (see [4] pp. 366-367)
                m = log2(n+1);
                if (~is(m, 'scalar') || ~is(m, 'positive integer')  ||  (m<2))
                    error('comm:bercoding:invalidN', errString);
                end
                
                k = 2^m - 1 - m;
                
                % BER for BSC
                if (nargin == 4)
                    % Default: BPSK, absolutely encoded
                    EbNodBcoded = 10*log10(EbNo*k/n);
                    p = berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
                else
                    try
                        EbNodBcoded = 10*log10(EbNo*k/n);
                        p = berawgn(EbNodBcoded, varargin{2:end});
                    catch
                        error('comm:bercoding:hamminghard', ...
                            'BERCODING requires 4 input arguments for Hamming coding.');
                    end
                end
                
                berapprox = p - p .* (1-p).^(n-1);
                ber = berapprox;
            otherwise
                error('comm:bercoding:invalidDecision', ...
                    'DECISION must be ''hard'' for Hamming');
        end
        
    case 'golay'  % Golay coding
        if (nargin  < 4)
            error('comm:bercoding:nArgsGolay', ...
                'BERCODING requires 4 input arguments for Golay coding.');
        end
        
        switch(lower(decision))
            case 'hard'
                n = varargin{1};        
                if (n~=24)
                    error('comm:bercoding:invalidN', 'N must be 24 for Golay');
                end     
                
                k = 12;
                
                % BER for BSC
                if (nargin == 4)
                    % Default: BPSK, absolutely encoded
                    EbNodBcoded = 10*log10(EbNo*k/n);
                    p = berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
                else
                    try
                        EbNodBcoded = 10*log10(EbNo*k/n);
                        p = berawgn(EbNodBcoded, varargin{2:end});
                    catch
                        error('comm:bercoding:golayhard', ...
                            'BERCODING requires 4 input arguments for Golay coding.');
                    end
                end

                % See [3], pp. 78-79
                % Weight Enumerator and Betai coefficients for the extended Golay Code 
                %                   column1=index   column2=A(index)    column3=Beta(index)
                Golay_Coef_Table =  [   0               1                   0;...
                                        1               0                   0;...
                                        2               0                   0;...
                                        3               0                   0;...
                                        4               0                   4;...
                                        5               0                   8;...
                                        6               0                   120/19;...
                                        7               0                   8;...
                                        8               759                 8;...
                                        9               0                   2637/323;...
                                        10              0                   3256/323;...
                                        11              0                   3656/323;...
                                        12              2576                12;...
                                        13              0                   4096/323;...
                                        14              0                   4496/323;...
                                        15              0                   5115/323;...
                                        16              759                 16;...
                                        17              0                   16;...
                                        18              0                   336/19;...
                                        19              0                   16;...
                                        20              0                   20;...
                                        21              0                   24;...
                                        22              0                   24;...
                                        23              0                   24;...
                                        24              1                   24      ];
                Beta = Golay_Coef_Table(:,3);                                                
                berub = 0;
                for index = 4:24
                    berub = berub + ...
                             (1/24) * Beta(index+1) * nchoosek(24,index) * ...
                              p.^index .* (1-p).^(24-index);
                end
                ber = berub;
            otherwise
                error('comm:bercoding:invalidDecision', ...
                    'DECISION must be ''hard'' for Golay');
        end
        
    case 'rs'  % Reed-Solomon coding
        if (nargin  < 5)
            error('comm:bercoding:nArgsRS', ...
                'BERCODING requires 5 input arguments for Reed-Solomon coding.');
        end
        
        switch(lower(decision))
            case 'hard'    
                n = varargin{1}; 
                if isempty(n)
                    error('comm:bercoding:invalidN', errString); 
                end
                
                m = log2(n+1); 
                % Check parameter values for m, k (see [4] p. 437)
                if ( ~is(m, 'scalar') || ~is(m, 'positive integer') || (m<=2) )
                    error('comm:bercoding:invalidN', errString);
                end
                
                k = varargin{2};
                if ( ~is(k, 'scalar') || ~is(k, 'positive integer') || (k>=n) )
                    error('comm:bercoding:invalidK', ...
                        'K must be a positive integer such that K<N');
                end
                
                t = floor( (n-k)/2 );
                
                % See [3] and [4], p. 439
                % BER for BSC
                if (nargin == 5)
                    % Default: BPSK, absolutely encoded
                    EbNodBcoded = 10*log10(EbNo*k/n);
                    p = berawgn(EbNodBcoded, 'psk', 2, 'nondiff');
                    ps = 1 - (1-p).^m;
                else
                    try
                        EbNodBcoded = 10*log10(EbNo*k/n);
                        [p, s] = berawgn(EbNodBcoded, varargin{3:end});
                    catch
                        error('comm:bercoding:rshard', ...
                            'BERCODING requires 5 input arguments for Reed-Solomon coding.');
                    end
                    
                    if strcmpi(varargin{3}, 'oqpsk')
                        M = 4;
                    elseif strcmpi(varargin{3}, 'msk')    
                        M = 2;
                    else    
                        M = varargin{4};
                    end
                    K = log2(M);
                    if ( floor(m/K) == m/K )
                        ps = 1 - (1-s).^(m/K);
                    else
                        % c.f. [5]
                        if ( K <= 6 && m <= 7 )
                            Sym_Error_Table = { [ 1 0 0 0 0], [2 -1 0 0 0], [2 -1 0 0 0], [3 -3 1 0 0], [3 -3 1 0 0], [4 -6 4 -1 0], [4 -6 4 -1 0], [5 -10 10 -5 1], [5 -10 10 -5 1]; ...
                                                [ 4/3 -1/3 0 0 0], [1 0 0 0 0], [2 -1 0 0 0], [7/3 -5/3 1/3 0 0], [2 -1 0 0 0], [3 -3 1 0 0], [10/3 -4 2 -1/3 0], [3 -3 1 0 0], [4 -6 4 -1 0]; ...
                                                [ 1 0 0 0 0], [3/2 -1/2 0 0 0], [1 0 0 0 0], [2 -1 0 0 0], [2 -1 0 0 0], [5/2 -2 1/2 0 0], [2 -1 0 0 0], [3 -3 1 0 0], [3 -3 1 0 0]; ...
                                                [ 6/5 -1/5 0 0 0], [7/5 -2/5 0 0 0], [8/5 -3/5 0 0 0], [1 0 0 0 0], [2 -1 0 0 0], [2 -1 0 0 0], [5/2 -2 1/2 0 0], [13/5 -11/5 3/5 0 0], [2 -1 0 0 0]; ...
                                                [ 1 0 0 0 0], [1 0 0 0 0], [4/3 -1/3 0 0 0], [5/3 -2/3 0 0 0], [1 0 0 0 0], [2 -1 0 0 0], [2 -1 0 0 0], [2 -1 0 0 0], [7/3 -5/3 1/3 0 0] };
                            ps = zeros(1, length(EbNo));
                            for i=1:length(EbNo)
                                ps(i) = sum( Sym_Error_Table{K-1, m-1} .* [s(i) s(i).^2 s(i).^3 s(i).^4 s(i).^5] );
                            end
                        else
                            % Rough approximation
                            ps = ceil(m/K) * s;
                        end    
                    end    
                end
                
                % Note Pascal's triangle can be used as a quick way to
                % compute nchoosek
                % The relationship is as follows:
                % nchoosek(n,k) = nchoosekLUT(n+1-k,k+1)                
                nchoosekLUT = pascal(2^m);
                berapprox = 0;
                for index = t+1:n
                    berapprox = berapprox + index * nchoosekLUT(n+1-index, index+1) ...
                                            * ps.^index .* (1-ps).^(n-index);
                end
                if (nargin == 5)
                    berapprox = 1/m * 1/n * berapprox;
                    %berapprox = 2^(m-1)/(2^m-1) * 1/n * berapprox;
                else 
                    if strcmpi(varargin{3}, 'fsk')
                        berapprox = 2^(m-1)/(2^m-1) * 1/n * berapprox;
                    else
                        berapprox = 1/m * 1/n * berapprox;
                        %berapprox = 2^(m-1)/(2^m-1) * 1/n * berapprox;
                    end
                end
                ber = berapprox;
            otherwise
                error('comm:bercoding:invalidDecision', ...
                    'DECISION must be ''hard'' for Reed-Solomon');
        end
                
    otherwise
        error('comm:bercoding:coding', ...
            'CODING must be either ''conv'', ''block'',''Hamming'',''Golay'', or ''RS''.');

end

ber(ber>0.5) = 0.5;  % set upper limit to 0.5

if any(ber<0)
    ber(ber<0) = NaN;
    warning('comm:bercoding:NaN', ...
        'NaN is returned due to numerical difficulties.');
end
