function y = pskmod(x,M,varargin)
%PSKMOD Phase shift keying modulation
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.PSKMOD object instead.
%
%
%   Y = PSKMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X, using the phase shift keying modulation. M is the
%   alphabet size and must be an integer power or 2. The message signal X
%   must consist of integers between 0 and M-1. For two-dimensional
%   signals, the function treats each column as 1 channel.
%
%   Y = PSKMOD(X,M,INI_PHASE) specifies the desired initial phase in
%   INI_PHASE. The default value of INI_PHASE is 0.
%
%   Y = PSKMOD(X,M,INI_PHASE,SYMBOL_ORDER) specifies how the function 
%   assigns binary words to corresponding integers. If SYMBOL_ORDER is set 
%   to 'bin' (default), then the function uses a natural binary-coded ordering. 
%   If SYMBOL_ORDER is set to 'gray', then the function uses a Gray-coded
%   ordering.
%
%   See also PSKDEMOD, MODNORM, MODEM.PSKMOD, MODEM, MODEM/TYPES.

%    Copyright 1996-2007 The MathWorks, Inc. 
%    $Revision: 1.1.6.4 $  $Date: 2007/06/08 15:54:00 $ 


% Error checks
if(nargin<2)
    error('comm:pskmod:numarg','Too few input arguments.');
end

if (nargin > 4)
    error('comm:pskmod:numarg', 'Too many input arguments. ');
end

% Check that x is a positive integer
if (~isreal(x) || any(any(ceil(x) ~= x)) || ~isnumeric(x))
    error('comm:pskmod:xreal', 'Elements of input X must be integers in the range [0, M-1].');
end

% Check that M is a positive integer
if (~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M))
    error('comm:pskmod:Mreal', 'M must be a scalar positive integer.');
end

% Check that M is of the form 2^K
if(~isnumeric(M) || (ceil(log2(M)) ~= log2(M)))
    error('comm:pskmod:Mpow2', 'M must be in the form of M = 2^K, where K is an integer. ');
end

% Check that x is within range
if ((min(min(x)) < 0) || (max(max(x)) > (M-1)))
    error('comm:pskmod:xreal', 'Elements of input X must be integers in [0, M-1].');
end

% Determine initial phase. The default value is 0
if (nargin >= 3)
    ini_phase = varargin{1};
    if (isempty(ini_phase))
        ini_phase = 0;
    elseif (~isreal(ini_phase) || ~isscalar(ini_phase))
        error('comm:pskmod:ini_phaseReal', 'INI_PHASE must be a real scalar. ');
    end
else
    ini_phase = 0;
end

% Check SYMBOL_ORDER
if(nargin==2 || nargin==3)    
   Symbol_Ordering = 'bin'; % default
else
    Symbol_Ordering = varargin{2};
    if (~ischar(Symbol_Ordering)) || (~strcmpi(Symbol_Ordering,'GRAY')) && (~strcmpi(Symbol_Ordering,'BIN'))
        error('comm:pskmod:SymbolOrder','Invalid symbol set ordering.');    
    end
end

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if (wid == 1)
    x = x(:);
end

% Gray encode if necessary
if (strcmpi(Symbol_Ordering,'GRAY'))
    [x_gray,gray_map] = bin2gray(x,'psk',M);   % Gray encode
    [tf,index]=ismember(x,gray_map);
     x=index-1;
end
    
% Evaluate the phase angle based on M and the input value. The phase angle
% lies between 0 - 2*pi. 
theta = 2*pi*x/M;

% The complex envelope is (cos(theta) + j*sin(theta)). This can be
% expressed as exp(j*theta). If there is an initial phase, it is added
% to the existing phase angle
y = exp(j*(theta + ini_phase));

% --- modulator output must be complex
if isreal(y)
    y = complex(y,0);
end

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y.';
end

% EOF
