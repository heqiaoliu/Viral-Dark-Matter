function [decoded,cnumerr,ccode] = decode(decoder,code,varargin)
%DECODE Decode a BCH codeword.
%   DECODED = DECODE(DEC,CODE) attempts to decode the received signal in CODE
%   using the BCH decoder DEC. CODE must be a vector of binary elements, with an
%   integer multiple of N-ShortenedLength-(Number of punctures) elements per
%   column. There may be multiple codewords per channel, where each group of
%   N-ShortenedLength-(Number of punctures) input elements represents one
%   codeword to be decoded. Each column of CODE is considered to be a separate
%   channel, with the same BCH code applied to each channel.
%  
%   DECODED = DECODE(DEC,CODE,ERASURES) attempts to decode the received signal
%   with the additional erasure information provided by the ERASURES vector. The
%   size of the ERASURES vector must be the same as the size of CODE, where a 0
%   marks no erasure, and a 1 marks an erased symbol.
%  
%   In each column of DECODED, each group of K-ShortenedLength elements
%   represents the attempt at decoding the corresponding codeword in CODE. A
%   decoding failure occurs if the codeword contains 2*NumErasures + NumErrors >
%   T. T is the number of correctable errors as returned from BCHGENPOLY.
%   NumErasures is the number of erasures present in the codeword, and NumErrors
%   is the number of errors found. When decoding fails, BCHDEC forms the
%   corresponding column of DECODED by merely removing N-K bits from the parity
%   positions of CODE.
%  
%   [DECODED,CNUMERR] = DECODE(...) returns an array CNUMERR with the same
%   number of columns as CODE.  Within each column of CNUMERR, each element is
%   the number of corrected errors in the corresponding codeword of CODE. A
%   value of -1 in CNUMERR indicates a decoding failure in that codeword in
%   CODE.
%  
%   [DECODED,CNUMERR,CCODE] = DECODE(...) returns CCODE, the corrected version
%   of CODE. The array CCODE is in the same format as CODE. If a decoding
%   failure occurs in a certain codeword (i.e. full or partial column of CODE),
%   then the corresponding full or partial column in CCODE contains that full or
%   partial column unchanged.
% 
%   Example:
%     
%     % Code parameters
%     n = 7; k =4;
%     % Construct encoder
%     coder = fec.bchenc(n,k);
%     % Message to encode
%     msg = [0 1 1 0]';
%     % Perform Coding
%     code = encode(coder,msg);
%     % Construct decoder from encoder
%     decoder = fec.bchdec(coder);
%     % Introduce 1 error in the codeword
%     code(end) = 0;
%     [decoded,cnumerr,ccode] = decode(decoder,code);
%     
%     See also fec.bchenc, fec.bchdec, fec.bchdec/encode, fec.rsdec
 
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/12/05 01:58:26 $

error(nargchk(2,3,nargin,'struct'))

%Check that the input is a double
if ~isa(code, 'double')
    error('comm:bchdec:notDoub', 'CODE must be a double');
end

% Check the dimensions. Each column is a channel, must have an integer
% multiple of K elements in each column
[nRows,nCols] = size(code);

N = decoder.N;
K = decoder.K;
parityPos = decoder.paritypos;
t = decoder.t;
shortened = decoder.ShortenedLength;
numPuncs = sum(~decoder.puncturePattern);

actN = N - numPuncs - shortened;
actK = K - shortened;

if floor(nRows/actN) ~= (nRows/actN)
    error('comm:bchdec:wrongCODEsize',...
        'The number of rows in CODE must be an integer multiple of N') 
end

nChan = nCols;
nCodeWords = nChan*(nRows/actN);

if( ~all(code == 1 | code == 0))
    error('comm:bchdec:notBin',...
        'The values of CODE must be 0 or 1');
end

% check the erasures
if(nargin == 3)
    erasures = varargin{1};
    %check that erasures are binary
    if  any(nonzeros(erasures)~=1)
        error('comm:bchdec:eraseNotBin','ERASURES must be a binary vector')
    end
    % check size of erasures
    if any(size(erasures) ~= size(code) )
        error('comm:bchdec:eraseSize', ['The size of the ERASURES '....
            'vector must match the size of the CODE vector'])
    end
else
    erasures = zeros(size(code));
end

% Check that the GF tables are valid, if not, correct them.
if ~isequal(length(decoder.PrivGfTable1),N) || ...
        ~isequal(length(decoder.PrivGfTable2),N)
    updateTables(decoder,log2(N+1))
end

% Bring the code word into the extension field
M = log2(N+1);

% Pre-allocate memory.  Each element in this column vector holds the number of
% errors in the corresponding row
decoded = (zeros(nCodeWords, actK));
cnumerr = zeros(nCodeWords,1);
ccode   = (zeros(nCodeWords, actN));

% Reshape the column vector of code words into matrix with one codeword per
% row
code = logical(reshape(code,actN,nCodeWords))';
erasures = reshape(erasures,actN,nCodeWords)';

% Ensure that the code format into the berlekamp function is [msg parity], since
% the function works only in that mode.  The berlekamp function also takes care
% of prepending zeros for shortened codes.
if strcmpi(parityPos, 'beginning')
    n_code = size(code,2);
    code = [code(:,actN-actK+1:n_code) code(:,1:actN-actK)];
end

for j = 1 : nCodeWords
    % Call to core algorithm BERLEKAMP
    inputCode    = code(j,:);
    inputCodeVal = inputCode;
    b            = 1;  % narrow-sense codeword
    inWidth      = length(code(j,:));
    inputErasure = erasures(j,:);
        [decodedInt cnumerr(j) ccodeInt] = commprivate('berlekamp',...
            inputCodeVal, ...
            N - shortened, ...
            K - shortened,... 
            M, ...
            t, ...
            b, ...
            shortened, ...
            inWidth,...
            decoder.puncturepattern,...
            inputErasure,...
            decoder.PrivGfTable1,...
            decoder.PrivGfTable2);
    decoded(j,:) = decodedInt(1:actK);
    ccode(j,:)   = ccodeInt;
end

%reshape back into original format
decoded = reshape(decoded',actK*nCodeWords/nChan,nChan);

% If necessary, flip message and parity symbols in corrected codeword, undoing
% the flip prior to decoding.
if strcmp(parityPos, 'beginning')
    ccode = [ccode(:,actK+1:n_code) ccode(:,1:actK)];  
end

%reshape back into original format
ccode = reshape(ccode',nCodeWords*actN/nChan,nChan);
%Also reshape cnumerr
cnumerr = reshape(cnumerr,nCodeWords/nChan,nChan);
% [EOF]