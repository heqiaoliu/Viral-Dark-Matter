function z = pskdemod(y,M,varargin)
%PSKDEMOD Phase shift keying demodulation
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.PSKDEMOD object instead.
%
%
%   Z = PSKDEMOD(Y,M) demodulates the complex envelope Y of a signal
%   modulated using the phase shift key method. M is the alphabet size and
%   must be an integer power of 2. For two-dimensional signals, the
%   function treats each column as 1 channel.
%
%   Z = PSKDEMOD(Y,M,INI_PHASE) specifies the initial phase which was used
%   to modulate the original signal. The default value of INI_PHASE is 0.
%
%   Z = PSKDEMOD(Y,M,INI_PHASE,SYMBOL_ORDER) specifies how the function  
%   assigns binary words to corresponding integers. If SYMBOL_ORDER is set  
%   to 'bin' (default), then the function uses a natural binary-coded ordering. 
%   If SYMBOL_ORDER is set to 'gray', then the function uses a Gray-coded
%   ordering.
% 
%   See also PSKMOD, MODNORM, MODEM.PSKDEMOD, MODEM, MODEM/TYPES.

%    Copyright 1996-2007 The MathWorks, Inc. 
%    $Revision: 1.1.6.3 $  $Date: 2007/06/08 15:53:59 $ 

% Error checks
if(nargin<2)
    error('comm:pskdemod:numarg','Too few input arguments.');
end

if (nargin > 4)
    error('comm:pskdemod:numarg', 'Too many input arguments. ');
end

%Check y, m
if( ~isnumeric(y))
    error('comm:pskdemod:Ynum','Y must be numeric.');
end

% Checks that M is positive integer
if (~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M))
    error('comm:pskdemod:Mreal','M must be a scalar positive integer.');
end

% Checks that M is in of the form 2^K
if(~isnumeric(M) || (ceil(log2(M)) ~= log2(M)))
    error('comm:pskdemod:Mpow2', 'M must be in the form of M = 2^K, where K is an integer. ');
end

% Determine INI_PHASE. The default value is 0
if (nargin >= 3)
    ini_phase = varargin{1};
    if (isempty(ini_phase))
        ini_phase = 0;
    elseif (~isreal(ini_phase) || ~isscalar(ini_phase))
        error('comm:pskdemod:Ini_phaseReal', 'INI_PHASE must be a real scalar. ');
    end
else
    ini_phase = 0;
end

% Check SYMBOL_ORDER
if(nargin==2 || nargin==3 )    
   Symbol_Ordering = 'bin'; % default
else
    Symbol_Ordering = varargin{2};
    if (~ischar(Symbol_Ordering)) || (~strcmpi(Symbol_Ordering,'GRAY')) && (~strcmpi(Symbol_Ordering,'BIN'))
        error('comm:pskdemod:SymbolOrder','Invalid symbol set ordering.');    
    end
end

% End error checks

% Assure that Y, if one dimensional, has the correct orientation
wid = size(y,1);
if(wid==1)
    y = y(:);
end

% De-rotate
y = y .* exp(-i*ini_phase);

% Demodulate
normFactor = M/(2*pi); % normalization factor to convert from PI-domain to
                       % linear domain
% convert input signal angle to linear domain; round the value to get ideal
% constellation points 
z = round((angle(y) .* normFactor));
% move all the negative integers by M
z(z < 0) = M + z(z < 0);

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    z = z';
end

% Gray decode if necessary
if (strcmpi(Symbol_Ordering,'GRAY'))
    [z_degray,gray_map] = gray2bin(z,'psk',M);   % Gray decode
    % --- Assure that X, if one dimensional, has the correct orientation --- %
    if(size(z,1) == 1)
        temp = zeros(size(y));
        temp(:) = gray_map(z+1);
        z(:) = temp(:);
    else
        z = gray_map(z+1);
    end
end

% EOF

