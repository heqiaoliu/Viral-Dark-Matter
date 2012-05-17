function [decoded,cnumerr,ccode] = bchdec(code,N,K,varargin)
%BCHDEC BCH decoder.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use the FEC.BCHDEC object instead.
%
%   DECODED = BCHDEC(CODE,N,K) attempts to decode the received signal in CODE 
%   using an (N,K) BCH decoder with the narrow-sense generator polynomial. CODE
%   is a Galois array of symbols over GF(2). Each N-element row of CODE
%   represents a corrupted systematic codeword, where the parity symbols are at
%   the end and the leftmost symbol is the most significant symbol. 
%   
%   In the Galois array DECODED, each row represents the attempt at decoding the 
%   corresponding row in CODE. A decoding failure occurs if a row of CODE 
%   contains more than T errors, where T is the number of correctable errors as
%   returned from BCHGENPOLY. In this case, BCHDEC forms the corresponding row
%   of DECODED by merely removing N-K symbols from the end of the row of CODE.
%   
%   DECODED = BCHDEC(...,PARITYPOS) specifies whether the parity symbols in CODE 
%   were appended or prepended to the message in the coding operation. The
%   string PARITYPOS can be either 'end' or 'beginning'. The default is 'end'.
%   If PARITYPOS is 'beginning', then a decoding failure causes BCHDEC to remove 
%   N-K symbols from the beginning rather than the end of the row.
%   
%   [DECODED,CNUMERR] = BCHDEC(...) returns a column vector CNUMERR, each
%   element of which is the number of corrected errors in the corresponding row
%   of CODE. A value of -1 in CNUMERR indicates a decoding failure in that row
%   in CODE.
%   
%   [DECODED,CNUMERR,CCODE] = BCHDEC(...) returns CCODE, the corrected version
%   of CODE. The Galois array CCODE is in the same format as CODE. If a decoding 
%   failure occurs in a certain row of CODE, then the corresponding row in CCODE
%   contains that row unchanged.
%
%   See also BCHENC. 

% Copyright 1996-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:22:28 $  

error(nargchk(3,4,nargin,'struct'));

% Fundamental checks on parameter data types
if ~isa(code,'gf')
   error('comm:bchdec:InvalidCode','CODE must be a Galois array.');
end

if(code.m~=1)
    error('comm:bchdec:InvalidCode','Code must be in GF(2).');
end

% Check mandatory parameters : code, N, K, t

% --- code
if isempty(code.x)
    error('comm:bchdec:InvalidCode','CODE must be a nonempty Galois array.');
end;

% --- width of code
[m_code, n_code] = size(code);
if N ~= n_code
    error('comm:bchdec:InvalidCodeWidth','CODE must be either a N-element row vector or a matrix with N columns.');
end

% Set and check the parity position
if(nargin>3)
    parityPos = varargin{1};
else
    parityPos = 'end';
end

if( ~strcmp(parityPos,'beginning') && ~strcmp(parityPos, 'end') )
    error('comm:bchdec:InvalidParityPos','PARITYPOS must be either ''beginning'' or ''end''  ')
end
% Get the number of errors we can correct 
t = bchnumerr(N,K);
     
% Bring the code word into the extension field
M = log2(N+1);
code = gf(code.x,M);

% Ensure that the code format into the berlekamp function is [msg parity], since
% the function works only in that mode.  The berlekamp function also takes care
% of prepending zeros for shortened codes.
if strcmp(parityPos, 'beginning')
    code = [code(:,N-K+1:n_code) code(:,1:N-K)];
end

% Pre-allocate memory.  Each element in this column vector holds the number of
% errors in the corresponding row
decoded = gf(zeros(m_code, K));
cnumerr = zeros(m_code,1);
ccode   = gf(zeros(m_code, N));

for j = 1 : m_code,  
    
    % Call to core algorithm BERLEKAMP
    inputCode    = code(j,:);
    inputCodeVal = inputCode.x;
    b            = 1;  % narrow-sense codeword
    shortened    = 0;  % no shortened codewords
    inWidth      = length(code(j,:));
[decodedInt cnumerr(j) ccodeInt] = commprivate('berlekamp',inputCodeVal, ...
                                                           N, ...
                                                           K, ...
                                                           M, ...
                                                           t, ...
                                                           b, ...
                                                           shortened, ...
                                                           inWidth);

    decoded(j,:) = gf(decodedInt);
    ccode(j,:)   = gf(ccodeInt);
end

% If necessary, flip message and parity symbols in corrected codeword, undoing
% the flip prior to decoding.
if strcmp(parityPos, 'beginning')
    ccode = [ccode(:,K+1:n_code) ccode(:,1:K)];  %#ok
end

% [EOF]