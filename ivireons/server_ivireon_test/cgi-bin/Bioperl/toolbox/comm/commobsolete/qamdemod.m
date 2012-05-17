function z =  qamdemod(y,M,varargin)
% QAMDEMOD Quadrature amplitude demodulation.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.QAMDEMOD object instead.
%
%
%   Z = QAMDEMOD(Y,M) demodulates the complex envelope Y of a quadrature
%   amplitude modulated signal. M is the alphabet size and must be an
%   integer power of two. The constellation is a rectangular
%   constellation. For two-dimensional signals, the function treats each
%   column as 1 channel.
%
%   Z = QAMDEMOD(Y,M,INI_PHASE) specifies the initial phase (rad) of
%   the modulated signal.
%
%   Z = QAMDEMOD(Y,M,INI_PHASE,SYMBOL_ORDER) specifies how the function 
%   assigns binary words to corresponding integers. If SYMBOL_ORDER is set
%   to 'bin' (default), then the function uses a natural binary-coded 
%   ordering. If SYMBOL_ORDER is set to 'gray', then the function uses a
%   Gray-coded ordering.
% 
%   See also QAMMOD, MODNORM, MODEM.QAMDEMOD, MODEM, MODEM/TYPES.

%    Copyright 1996-2007 The MathWorks, Inc. 
%    $Revision: 1.1.6.4 $  $Date: 2007/06/08 15:54:02 $ 

% error checks
if(nargin<2)
    error('comm:qamdemod:numarg','Too few input arguments.');
end

if(nargin>4)
    error('comm:qamdemod:numarg','Too many input arguments.');
end

%Check y, Fs, ini_phase
if( ~isnumeric(y))
    error('comm:qamdemod:Ynum','Y must be numeric.');
end

if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:qamdemod:Mreal','M must be a scalar positive integer.');
end

if( ~isnumeric(M) || ceil(log2(M)) ~= log2(M))
    error('comm:qamdemod:Mpow2','M must be in the form of M = 2^K, where K is a positive integer.');
end
if(nargin==2 || isempty(varargin{1}) )    
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:qamdemod:ini_phaseReal','INI_PHASE must be a real scalar.');    
    end
end

% Check SYMBOL_ORDER
if(nargin==2 || nargin==3 )    
   Symbol_Ordering = 'bin'; % default
else
    Symbol_Ordering = varargin{2};
    if (~ischar(Symbol_Ordering)) || (~strcmpi(Symbol_Ordering,'GRAY')) && (~strcmpi(Symbol_Ordering,'BIN'))
        error('comm:qamdemod:SymbolOrder','Invalid symbol set ordering.');    
    end
end
% End error check

if mod(log2(M), 2) % Cross constellation, including M=2
    const = squareqamconst(M,ini_phase);
    z = genqamdemod(y,const);
else % Square constellation, starting with M=4

    % Assure that Y, if one dimensional, has the correct orientation
    wid = size(y,1);
    if(wid ==1)
        y = y(:);
    end
    
    % De-rotate
    y = y .* exp(-i*ini_phase);

    % Precompute for later use
    sqrtM = sqrt(M);

    % Inphase/real rail
    % Move the real part of input signal; scale appropriately and round the
    % values to get index ideal constellation points
    rIdx = round( ((real(y) + (sqrtM-1)) ./ 2) );
    % clip values that are outside the valid range 
    rIdx(rIdx <= -1) = 0;
    rIdx(rIdx > (sqrtM-1)) = sqrtM-1;

    % Quadrature/imaginary rail
    % Move the imaginary part of input signal; scale appropriately and round 
    % the values to get index of ideal constellation points
    iIdx = round(((imag(y) + (sqrtM-1)) ./ 2));
    % clip values that are outside the valid range 
    iIdx(iIdx <= -1) = 0;
    iIdx(iIdx > (sqrtM-1)) = sqrtM-1;
    
    % compute output from indices of ideal constellation points 
    z = sqrtM-iIdx-1 +  sqrtM*rIdx;

    % Restore the output signal to the original orientation
    if(wid == 1)
        z = z';
    end

end


% Gray decode if necessary
if (strcmpi(Symbol_Ordering,'GRAY'))
    z = gray2bin(z,'qam',M);   % Gray decode
end
% EOF
