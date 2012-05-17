function code = encode(h, msg)
%ENCODE  Encode a message using a Reed-Solomon code.
%   CODEWORD = ENCODE(ENC, MSG) encodes MSG using the Reed-Solomon code
%   specified by a Reed-Solomon encoder object ENC. MSG must be an array of
%   integer elements, with an integer multiple of K-ShortenedLength elements
%   per column. There may be multiple codewords per channel, where each
%   group of K-ShortenedLength input elements represents one message word to
%   be encoded. Each column of MSG is considered to be a separate channel,
%   with the same Reed-Solomon code applied to each channel.
%
%   Example:
%
%   %Create Reed-Solomon encoder object.
%   enc = fec.rsenc(7,3);
%
%   % Create a message to be encoded.
%   msg = [0 1 0]'; 
%
%   % Encode msg with the ENCODE function.
%   code = encode(enc,msg);
%
%    % Create a shortened encoder
%    encShort = copy(enc);
%    encShort.ShortenedLength = 1;
%
%   % Create a shortened message
%   msgShort = [0 1]';
%
%   codeShort = encode(encShort,msgShort);
%
%   See also fec.rsenc, fec.rsdec, fec.rsdec/decode, fec.bchenc/encode

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:01 $

error(nargchk(2,2,nargin,'struct'))

% Get the fundamental parameters of the code.
genpoly = h.GenPoly;
shortened  = h.ShortenedLength;
M = h.M;
paritypos = h.ParityPosition;
puncs = h.PuncturePattern;
numPuncs = sum(~puncs);

N = h.N;
K = h.K;
actN = N - numPuncs - shortened;
actK = K - shortened;
nParity = N-K;

%Check that the input is a double
if ~isa(msg, 'double')
    error('comm:rsenc:notDoub', 'MSG must be a double');
end

%Check the range of the input, must be integers between 0 and N
if(any(floor(msg) ~= msg))
    error('comm:rsenc:intErr','Values of MSG must be integers between 0 and N.');
end

if  any(any(msg < 0)) || any(any(msg>N))
    error('comm:rsenc:rangeErr','Values of MSG must be integers between 0 and N.');
end

% Check the dimensions. Each column is a channel, must have an integer
% multpile of K elements in each column
[nRows,nCols] = size(msg);

if floor(nRows/actK) ~= (nRows/actK)
    error('comm:rsenc:wrongMSGsize',...
        'The number of rows in MSG must be an integer multiple of K')
end

nChan = nCols;
nCodeWords = nRows/actK*nChan;

%convert MSG to Galois field format
msg = gf(msg,M,genpoly.prim_poly);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %
%        ENCODING         %
%                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pre-allocate memory
% Each row is a 2t-long register for parity symbols for the same row of msg
parity = gf(zeros(nCodeWords,nParity),M,msg.prim_poly);

% First element (Coeff of X^nParity) not used in algorithm.  (Always monic)
genpoly = genpoly(2:nParity+1);

% Reshape msg into a matrix of one code word per row. Easier to work with
msg = reshape(msg,actK,nCodeWords)';

% Shortened RS code - append zeros to the front of input msg
if shortened > 0
   msgZ = [zeros(nCodeWords,shortened), msg];
else
    msgZ = msg;
end

% Encoding
% Each row gives the parity symbols for each message word
for j=1:size(msgZ,2),
    parity = [parity(:,2:nParity) zeros(nCodeWords,1)] + (msgZ(:,j)+parity(:,1))*genpoly;
end

% Return to doubles
parity = double(parity.x);
msg = double(msg.x);

% Do the puncturing
if(any(h.puncturePattern == 0))
    parity(:,h.puncturePattern==0) = [];
end

% Make codeword by appending / prepending parity to msg
switch paritypos
    case 'end'
        code = [msg parity];
    case 'beginning'
        code = [parity msg];
end;

%reshape back into the correct size
code = reshape(code',(nCodeWords/nChan)*actN,nChan);

% EOF
