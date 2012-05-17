function code = encode(h, msg)
%ENCODE  Encode a message using a BCH code.
%   CODEWORD = ENCODE(ENC, MSG) encodes MSG using the BCH code specified by
%   a BCH encoder object ENC. MSG must be an array of binary elements, with
%   an integer multiple of K-ShortenedLength elements per column. There may
%   be multiple codewords per channel, where each group of K-ShortenedLength
%   input elements represents one message word to be encoded. Each column
%   of MSG is considered to be a separate channel, with the same BCH code
%   applied to each channel.
% 
%    Example:
% 
%    %Create BCH encoder object.
%    enc = fec.bchenc(7,4);
% 
%    % Create a message to be encoded.
%    msg = [0 1 1 0]'; 
% 
%    % Encode msg with the ENCODE function.
%    code = encode(enc,msg);
%    
%    % Create a shortened encoder
%    encShort = copy(enc);
%    encShort.ShortenedLength = 1;
%
%   % Create a shortened message
%   msgShort = [0 1 1]';
%
%   codeShort = encode(encShort,msgShort);
%  
%    See also fec.bchenc, fec.bchdec, fec.bchdec/decode, fec.rsenc/encode


%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/29 08:21:44 $

error(nargchk(2,2,nargin,'struct'))

% Get parameters from object.
N = h.N;
K = h.K;
parityPos = h.ParityPosition;
shortened = h.ShortenedLength;
numPuncs = sum(~h.puncturePattern);

actN = N - numPuncs - shortened;
actK = K - shortened;

%Check that the input is a double
if ~isa(msg, 'double')
    error('comm:bchenc:notDoub', 'MSG must be a double');
end

% Check the dimensions. Each column is a channel, must have an integer
% multiple of K elements in each column
[nRows,nCols] = size(msg);

if floor(nRows/actK) ~= (nRows/actK)
    error('comm:bchenc:wrongMSGsize',...
        'The number of rows in MSG must be an integer multiple of K')
end

nCodeWords = nRows/actK;
nChan = nCols;


if( ~all(msg == 1 | msg == 0))
    error('comm:bchenc:notBin',...
        'The values of MSG must be 0 or 1');
end
   
% Get the generator polynomial
genpoly = h.GenPoly;

% Set up the shift register
a  = fliplr(logical(genpoly.x));  % Extract the value from the gf object
st = length(a)-1;

% reshape into a matrix of one code word per row. Easier to work with
u = logical(reshape(msg,actK,nCodeWords*nChan))';
[uRows,uCols] = size(u');

reg = false(uCols,st);
for iCol = 1 : uRows  % Loop over bits in the message words

    % Perform an XOR between the input and the shift register.  Recall that
    % there is one codeword per row.
    d = (u(:,iCol) | reg(:,st)) & ~(u(:,iCol) & reg(:,st));

    for idxPoly = st : -1 : 2

        % For one codeword, the line below is equivalent to
        % If d
        %     reg(idxPoly) = reg(idxPoly-1) || a(idxPoly) && ...
        %                    ~(reg(idxPoly-1) && a(idxPoly));
        % else
        %     reg(idxPoly) = reg(idxPoly-1);
        % end
        % It performs an XOR between the register and the generator polynomial.
        reg(:,idxPoly) = ( reg(:,idxPoly-1) | (d & a(:,idxPoly)) ) & ...
            ( ~d | ~(reg(:,idxPoly-1) & a(:,idxPoly)) );
    end
    reg(:,1) = d;
end

% Rearrange parity if necessary
parity = double(fliplr(reg));

% Perform the puncturing
if(any(h.puncturePattern == 0))
    parity(:,h.puncturePattern==0) = [];
end

if strcmp(parityPos, 'beginning')
   code = [parity double(u)];
else
    code = [double(u) parity];
end

% reshape back into the correct size
code = reshape(code',nCodeWords*actN,nChan);

%EOF
