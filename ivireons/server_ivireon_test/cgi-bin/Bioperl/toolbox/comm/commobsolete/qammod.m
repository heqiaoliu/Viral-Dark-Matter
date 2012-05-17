function y = qammod(x,M, varargin)
%QAMMOD Quadrature amplitude modulation
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.QAMMOD object instead.
%
%
%   Y = QAMMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X using quadrature amplitude modulation. M is the alphabet
%   size and must be an integer power of two. The message signal must consist of
%   integers between 0 and M-1. The signal constellation is a rectangular
%   constellation. For two-dimensional signals, the function treats each column
%   as 1 channel.
%
%   Y = QAMMOD(X,M,INI_PHASE) specifies a phase offset (rad).
%
%   Y = QAMMOD(X,M,INI_PHASE,SYMBOL_ORDER) specifies how the function assigns
%   binary words to corresponding integers. If SYMBOL_ORDER is set to 'bin'
%   (default), then the function uses a natural binary-coded ordering. If
%   SYMBOL_ORDER is set to 'gray', then the function uses a Gray-coded ordering.
%
%   See also QAMDEMOD, MODNORM, MODEM.QAMMOD, MODEM, MODEM/TYPES.

%    Copyright 1996-2007 The MathWorks, Inc. 
%    $Revision: 1.1.6.3 $  $Date: 2007/06/08 15:54:04 $ 

% error checks
if(nargin<2)
    error('comm:qammod:numarg','Too few input arguments.');
end

if(nargin>4)
    error('comm:qammod:numarg','Too many input arguments.');
end

%Check x, ini_phase
if ( ~isreal(x) || any(any(ceil(x)~=x)) || ~isnumeric(x) ) 
    error('comm:qammod:xreal','Elements of input X must be integers in the range [0, M-1].');
end

if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:qammod:Mreal','M must be a scalar positive integer.');
end

if( ~isnumeric(M) || ceil(log2(M)) ~= log2(M))
    error('comm:qammod:Mpow2','M must be in the form of M = 2^K, where K is a positive integer.');
end

% check that X are all integers within range.
if (min(min(x)) < 0)  || (max(max(x)) > (M-1))
    error('comm:qammod:xreal','Elements of input X must be integers in the range [0, M-1].');
end

if(nargin>=3)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    elseif(~isreal(ini_phase) || ~isscalar(ini_phase) )
        error('comm:qammod:ini_phaseReal','INI_PHASE must be a real scalar.');
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
        error('comm:qammod:SymbolOrder','Invalid symbol set ordering.');    
    end
end
% End error check

% Gray encode if necessary
if (strcmpi(Symbol_Ordering,'GRAY'))
    x = bin2gray(x,'qam',M);   % Gray encode use the mapping
end

const = squareqamconst(M,ini_phase);
y = genqammod(x,const);

% --- EOF --- %
