function [decoded,cnumerr,ccode] = decode(decoder,code,varargin)
%DECODE Decode Reed-Solomon encoded data.
%   DECODED = DECODE(DEC,CODE) attempts to decode the received signal in
%   CODE using the Reed-Solomon decoder DEC. CODE must be a vector of
%   integer elements, with an integer multiple of N-ShortenedLength-(Number
%   of punctures) elements per column. There may be multiple codewords per
%   channel, where each group of N-ShortenedLength-(Number of punctures)
%   input elements represents one codeword to be decoded. Each column of
%   CODE is considered to be a separate channel, with the same Reed-Solomon
%   code applied to each channel.
%  
%   DECODED = DECODE(DEC,CODE,ERASURES) attempts to decode the received
%   signal with the additional erasure information provided by the ERASURES
%   vector. The size of the ERASURES vector must be the same as the size of
%   CODE, where a 0 marks no erasure, and a 1 marks an erased symbol.
%  
%   In each column of DECODED, each group of K-ShortenedLength elements
%   represents the attempt at decoding the corresponding codeword in CODE.
%   A decoding failure occurs if the codeword contains 2*NumErasures +
%   NumErrors > T. T is the number of correctable errors as returned from
%   RSGENPOLY. NumErasures is the number of erasures present in the
%   codeword, and NumErrors is the number of errors found. When decoding
%   fails, BCHDEC forms the corresponding column of DECODED by merely
%   removing N-K bits from the parity positions of CODE.
%  
%   [DECODED,CNUMERR] = DECODE(...) returns an array CNUMERR with the same
%   number of columns as CODE.  Within each column of CNUMERR, each element
%   is the number of corrected errors in the corresponding codeword of
%   CODE. A value of -1 in CNUMERR indicates a decoding failure in that
%   codeword in CODE.
%  
%   [DECODED,CNUMERR,CCODE] = DECODE(...) returns CCODE, the corrected
%   version of CODE. The array CCODE is in the same format as CODE. If a
%   decoding failure occurs in a certain codeword (i.e. full or partial
%   column of CODE), then the corresponding full or partial column in CCODE
%   contains that full or partial column unchanged.
% 
%   Example:
%     
%     % Code parameters
%     n = 7; k = 3;
%     % Construct encoder
%     coder = fec.rsenc(n,k);
%     % Message to encode
%     msg = [0 1 2]';
%     % Perform Coding
%     code = encode(coder,msg);
%     % Construct decoder from encoder
%     decoder = fec.rsdec(coder);
%     % Introduce 1 error in the codeword
%     code(end) = 0;
%     [decoded,cnumerr,ccode] = decode(decoder,code);
%     
%   See also fec.rsenc, fec.rsdec, fec.rsdec/encode, rsgenpoly,
%   fec.bchdec/decode

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:49:18 $

% Initial checks
error(nargchk(2,3,nargin,'struct'))

%Check that the input is a double
if ~isa(code, 'double')
    error('comm:bchdec:notDoub', 'CODE must be a double');
end

% Find fundamental parameters
M = decoder.m;
N = decoder.N;
K = decoder.K;
t = decoder.t;
T2 = decoder.T2;
shortened = decoder.shortened;
numPuncs = sum(~decoder.puncturePattern);
genpoly   = decoder.GenPoly;
parityPos = decoder.ParityPosition;

actN = N - numPuncs - shortened;
actK = K - shortened;

%Check the range of the input, must be integers between 0 and N
if(any(floor(code) ~= code))
    error('comm:rsdec:intErr','Values of CODE must be integers between 0 and N.');
end

if  any(any(code < 0)) || any(any(code>N))
    error('comm:rsdec:rangeErr','Values of CODE must be integers between 0 and N.');
end

% Check the dimensions. Each column is a channel, must have an integer
% multpile of K elements in each column
[nRows,nChan] = size(code);
nCodeWords = nRows/actN*nChan;

if floor(nRows/actN) ~= (nRows/actN)
    error('comm:bchenc:wrongcodesize',...
        'The number of rows in CODE must be an integer multiple of N.')
end

% check the erasures
if(nargin == 3)
    erasures = varargin{1};
    %check that erasures are binary
    if  any(nonzeros(erasures)~=1)
        error('comm:rsdec:erasBin','ERASURES must be a binary vector')
    end
    % check size of erasures
    if any(size(erasures) ~= size(code) )
        error('comm:rsdec:eraseSize','The size of the ERASURES vector must match the size of the CODE vector')
    end
else
    erasures = zeros(size(code));
end

% reshape into a matrix of one code word per row. Easier to work with
code = reshape(code,actN,nCodeWords)';
erasures = reshape(erasures,actN,nCodeWords)';

%Pre-allocate the return arguments.
decoded = (zeros(nCodeWords, actK));
cnumerr = zeros(nCodeWords,1);
ccode   = (zeros(nCodeWords, actN));

% Ensure that the code format into the berlekamp function is [msg parity], since
% the function works only in that mode.  The berlekamp function also takes care
% of prepending zeros for shortened codes.
if strcmp(parityPos, 'beginning')
    code = [code(:,T2+1:actN) code(:,1:T2)];
end

% Get b
b = genpoly2b(genpoly(:)', genpoly.m, genpoly.prim_poly);

% Reed-Solomon decoding
for j = 1 : nCodeWords
    % Call to core algorithm BERLEKAMP
    inputCode    = code(j,:);
    inputCodeVal = inputCode;
    inWidth      = length(code(j,:));
    inputErasure = erasures(j,:);
    [decodedInt cnumerr(j) ccodeInt] = commprivate('berlekamp',inputCodeVal, ...
        N-shortened, ...
        K-shortened, ...
        M, ...
        t, ...
        b, ...
        shortened, ...
        inWidth,...
        decoder.PuncturePattern,...
        inputErasure,...
        decoder.PrivGfTable1,...
        decoder.PrivGfTable2);
    decoded(j,:) = decodedInt;
    ccode(j,:)   = ccodeInt;
end

%reshape back into original format
decoded = reshape(decoded',actK*nCodeWords/nChan,nChan);

% If necessary, flip message and parity symbols in corrected codeword, undoing
% the flip prior to decoding.

if strcmp(parityPos, 'beginning')
    ccode = [ccode(:,K+1-shortened:end) ccode(:,1:K-shortened)];
end

%reshape back into original format
ccode = reshape(ccode',nCodeWords*actN/nChan,nChan);
%Also reshape cnumerr
cnumerr = reshape(cnumerr,nCodeWords/nChan,nChan);

% [EOF]
