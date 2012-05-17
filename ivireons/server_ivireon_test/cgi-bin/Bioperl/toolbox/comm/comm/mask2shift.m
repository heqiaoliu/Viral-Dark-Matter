function shift = mask2shift(prpoly, mask)
%MASK2SHIFT Convert mask vector to shift for a shift register configuration.
%   SHIFT = MASK2SHIFT(PRPOLY, MASK) returns the equivalent shift for a 
%   specified mask for a linear feedback shift register whose connections are
%   given by the primitive polynomial, PRPOLY.
%
%   The primitive polynomial, PRPOLY must either be a binary vector of 
%   coefficients in descending powers or an equivalent scalar decimal number.
%   The MASK parameter must be a binary vector of length equal to the 
%   degree of the polynomial. 
%  
%   Example:
%       % For a polynomial x^3 + x + 1, and mask x^2,
%       s = mask2shift([1 0 1 1],[1 0 0])
%
%   See also SHIFT2MASK, GF/LOG, ISPRIMITIVE, PRIMPOLY, DE2BI.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2008/08/01 12:17:39 $

error(nargchk(2,2,nargin,'struct'));

% Convert to binary vector
if isscalar(prpoly)
    if (prpoly < 3) % => [1 1]
        error('comm:mask2shift:InvalidPrpoly','Invalid primitive polynomial parameter specified.');
    end
    prpoly = de2bi(prpoly, 'left-msb');
end

% Check for polynomial argument
if ( ~( isvector(prpoly) && ~isempty(prpoly) && ~isscalar(prpoly) ) | ...
     any(prpoly~=1 & prpoly~=0) | prpoly(1)==0 | prpoly(end)==0 )
    error('comm:mask2shift:NonBinaryPrpoly','The primitive polynomial must be a binary vector of coefficients in descending powers.');
end

% Compute degree/order of polynomial
ord = length(prpoly)-1; % has to be greater than 0 as prpoly is a strict vector
if ord > 53
    error('comm:mask2shift:InvalidPrpolyDegree','Only primitive polynomials of degree 53 or less are allowed.');
end

% Check for mask input - can be a scalar too
if ( ~isvector(mask) | length(mask) ~= ord | any(mask~=1 & mask~=0) )
    error('comm:mask2shift:InvalidMask','The mask must be a binary vector of length equal to the order of the polynomial.');
end

% Check against an all-zero mask
if (isequal(mask(:), zeros(ord,1)))
    error('comm:mask2shift:InvalidMaskVal','The mask vector must have at least one nonzero value.');
end

% Function call
shift = sh2mkormk2sh(prpoly, mask);

% [EOF]
