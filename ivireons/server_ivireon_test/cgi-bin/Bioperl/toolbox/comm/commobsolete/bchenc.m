function code = bchenc(msg, N, K, varargin)
%BCHENC BCH encoder.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use the FEC.BCHENC object instead.
%
%   CODE = BCHENC(MSG,N,K) encodes the message in MSG using an (N,K) BCH
%   encoder with the narrow-sense generator polynomial. MSG is a Galois 
%   array of symbols over GF(2). Each K-element row of MSG represents a 
%   message word, where the leftmost symbol is the most significant symbol. 
%   Parity symbols are at the end of each word in the output Galois array CODE. 
%      
%   CODE = BCHENC(...,PARITYPOS) specifies whether BCHENC appends or prepends
%   the parity symbols to the input message to form CODE. The string PARITYPOS
%   can be either 'end' or 'beginning'. The default is 'end'.
%   
%   See also BCHDEC, BCHGENPOLY, BCHNUMERR. 

% Copyright 1996-2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:22:29 $ 

% Initial checks
error(nargchk(3,4,nargin,'struct'));

% Fundamental checks on parameter data types
if ~isa(msg,'gf')
   error('comm:bchenc:InvalidMsg','MSG must be a Galois array.');
end

if msg.m~=1
    error('comm:bchenc:InvalidMsg','MSG must be in GF(2).');
end

% Set and check the parity position
if nargin>3
    parityPos = varargin{1};
else
    parityPos = 'end';
end

if ~strcmp(parityPos,'beginning') && ~strcmp(parityPos, 'end')
    error('comm:bchenc:InvalidParityPos','PARITYPOS must be either ''beginning'' or ''end''  ')
end

[nRows nCols] = size(msg);

if nCols~= K
    error('comm:bchenc:InvalidMsgLength','The message length must equal K.')
end

% Get the generator polynomial
genpoly = bchgenpoly(N,K);

% Set up the shift register
a  = fliplr(logical(genpoly.x));  % Extract the value from the gf object
st = length(a)-1;

u = logical(msg.x);

reg = false(nRows, st);
for iCol = 1 : nCols  % Loop over bits in the message words

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
if strcmp(parityPos, 'beginning')
    code = gf([parity double(u)]);
else
    code = gf([double(u) parity]);
end

% [EOF]