function z = pamdemod(y,M,varargin)
%PAMDEMMOD Pulse amplitude demodulation.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.PAMDEMOD object instead.
%
%
%   Z = PAMDEMOD(Y,M) demodulates the complex envelope Y of a pulse
%   amplitude modulated signal. M is the alphabet size and must be an
%   integer. The ideal modulated signal Y should have a minimum Euclidean
%   distance of 2. For two-dimensional signals, the function treats each
%   column as 1 channel.
%
%   Z = PAMDEMOD(Y,M,INI_PHASE) specifies the initial phase of the
%   modulated signal in radians. The default value of INI_PHASE is 0.
%
%   Z = PAMDEMOD(Y,M,INI_PHASE,SYMBOL_ORDER) specifies how the function
%   assigns binary words to corresponding integers. If SYMBOL_ORDER is set
%   to 'bin' (default), then the function uses a natural binary-coded
%   ordering. If SYMBOL_ORDER is set to 'gray', then the function uses a
%   Gray-coded ordering.
% 
%   See also PAMMOD, MODNORM, MODEM.PAMDEMOD, MODEM, MODEM/TYPES.

%    Copyright 1996-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:49:20 $ 

% error checks
if(nargin<2)
    error('comm:pammod:numarg','Too few input arguments.');
end

if(nargin>4)
    error('comm:pammod:toomanyinp','Too many input arguments.');
end

%Check y, m
if( ~isnumeric(y))
    error('comm:pamdemod:Ynum','Y must be numeric.');
end

if(~isreal(M) || ~isscalar(M) ||  M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:pamdemod:Mreal','M must be a scalar positive integer.');
end

if(nargin==2 || isempty(varargin{1}) )    
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:pamdemod:ini_phaseReal','INI_PHASE must be a real scalar.');    
    end
end

% Check SYMBOL_ORDER
if(nargin==2 || nargin==3 )    
   Symbol_Ordering = 'bin'; % default
else
    Symbol_Ordering = varargin{2};
    if (~ischar(Symbol_Ordering)) || (~strcmpi(Symbol_Ordering,'GRAY')) && (~strcmpi(Symbol_Ordering,'BIN'))
        error('comm:pamdemod:SymbolOrder','Invalid symbol set ordering.');    
    end
end
% --- Assure that Y, if one dimensional, has the correct orientation --- %
wid = size(y,1);
if(wid ==1)
    y = y(:);
end

% De-rotate
y = y .* exp(-i*ini_phase);

% Move the real part of input signal; scale appropriately and round the
% values to get ideal constellation points
z = round( ((real(y) + (M-1)) ./ 2) );
% clip the values that are outside the valid range 
z(z <= -1) = 0;
z(z > (M-1)) = M-1;

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    z = z';
end
% Gray decode if necessary
if (strcmpi(Symbol_Ordering,'GRAY'))
    [z_degray,gray_map] = gray2bin(z,'pam',M);   % Gray decode
    if(size(z,1) == 1)
        temp = zeros(size(y));
        temp(:) = gray_map(z+1);
        z(:) = temp(:);
    else
        z = gray_map(z+1);
    end
end
