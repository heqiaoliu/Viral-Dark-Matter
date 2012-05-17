function y = pammod(x,M, varargin)
%PAMMOD Pulse amplitude modulation
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.PAMMOD object instead.
%
%
%   Y = PAMMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X using pulse amplitude modulation. M is the alphabet
%   size and must be an integer. The message signal must consist of
%   integers between 0 and M-1. The modulated signal Y has a minimum
%   Euclidean distance of 2. For two-dimensional signals, the function
%   treats each column as 1 channel.
%
%   Y = PAMMOD(X,M,INI_PHASE) specifies the initial phase of the modulated
%   signal in radians. The default value of INI_PHASE is 0.
%
%   Y = PAMMOD(X,M,INI_PHASE,SYMBOL_ORDER) specifies how the function
%   assigns binary words to corresponding integers. If SYMBOL_ORDER is set
%   to 'bin' (default), then the function uses a natural binary-coded
%   ordering. If SYMBOL_ORDER is set to 'gray', then the function uses a
%   Gray-coded ordering.
%
%   See also PAMDEMOD, MODNORM, MODEM.PAMMOD, MODEM, MODEM/TYPES.

%    Copyright 1996-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:49:21 $ 

% error checks
if(nargin<2)
    error('comm:pammod:numarg','Too few input arguments.');
end

if(nargin>4)
    error('comm:pammod:toomanyinp','Too many input arguments.');
end

%Check x, ini_phase
if ( ~isreal(x) || any(any(ceil(x)~=x)) || ~isnumeric(x) ) 
    error('comm:pammod:Xreal','Elements of input X must be real integers in the range [0, M-1].');
end

if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:pammod:Mreal','M must be a scalar positive integer.');
end

% check that X are all integers within range.
if (min(min(x)) < 0)  || (max(max(x)) > (M-1))
    error('comm:pammod:Xreal','Elements of input X must be real integers in the range [0, M-1].');
end

if(nargin==2 || isempty(varargin{1}) )    
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:pammod:ini_phaseReal','INI_PHASE must be a real scalar.');    
    end
end

% Check Symbol set ordering
if(nargin==2 || nargin==3)    
   Symbol_Ordering = 'bin';
else
    Symbol_Ordering = varargin{2};
    if (~ischar(Symbol_Ordering)) || (~strcmpi(Symbol_Ordering,'GRAY')) && (~strcmpi(Symbol_Ordering,'BIN'))
        error('comm:pammod:SymbolOrder','Invalid symbol set ordering.');    
    end
end


% --- End Parameter checks --- %

% create constellation
const = (-(M-1):2:(M-1)).*exp(j*ini_phase);

% Gray encode if necessary
if (strcmpi(Symbol_Ordering,'GRAY'))
    [x_gray,gray_map] = bin2gray(x,'pam',M);   % Gray encode
    [tf,index]=ismember(x,gray_map);
     x=index-1;
end


% modualte
y = genqammod(x,const);    

% EOF
