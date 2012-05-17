function [genpoly, t] = bchgenpoly(N,K,varargin)
%BCHGENPOLY  Generator polynomial of BCH code.
%   GENPOLY = BCHGENPOLY(N,K) returns the narrow-sense generator polynomial of a
%   BCH code with codeword length N and message length K.  The codeword
%   length N must have the form 2^m-1 for some integer m between 3 and 16.  The
%   output GENPOLY is a Galois row vector that represents the coefficients of
%   the generator polynomial in order of descending powers.  The narrow-sense
%   generator polynomial is LCM[m_1(x), m_2(x), ..., m_2t(x)], where
%     LCM is the least common multiple,
%     m_i(x) is the minimum polynomial corresponding to alpha^i,
%     alpha is a root of the default primitive polynomial for the field 
%       GF(N+1), and
%     t is the error-correcting capability of the code.
%
%   GENPOLY = BCHGENPOLY(N,K,PRIM_POLY) is the same as the syntax above, except
%   that PRIM_POLY specifies the primitive polynomial for GF(N+1) that has alpha
%   as a root.  PRIM_POLY is an integer whose binary representation indicates
%   the coefficients of the primitive polynomial in order of descending powers.
%   To use the default primitive polynomial, set PRIM_POLY to [].
%
%   [GENPOLY,T] = BCHGENPOLY(...) returns T, the error-correction capability of
%   the code.
%
%   See also BCHENC, BCHDEC, BCHNUMERR.

% Copyright 1996-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $  $Date: 2008/09/13 06:45:54 $


% Initial checks
error(nargchk(2,3,nargin,'struct'));

t = bchnumerr(N,K);
t2 = 2*t;

prim_poly = 1;

m = log2(N+1);

if ~isempty(varargin)
    prim_poly = varargin{1};
    % Check prim_poly
    if isempty(prim_poly)
        if ~isnumeric(prim_poly)
            error('comm:bchgenpoly:InvalidPrim_Poly','To use the default PRIM_POLY, it must be marked by [].');
        end
    else
        if ~isnumeric(prim_poly) || ~isscalar(prim_poly) || (floor(prim_poly) ~= prim_poly)
            error('comm:bchgenpoly:NonScalarPrim_Poly','PRIM_POLY must be a scalar integer.');
        end

        if ~isprimitive(prim_poly)
            error('comm:bchgenpoly:NotAPrim_Poly','PRIM_POLY must be a primitive polynomial.');
        end
    end

end

% Determine the cosets for this field
if prim_poly == 1
    coset = cosets(m,[],'nodisplay');
else
    coset = cosets(m,prim_poly,'nodisplay');
end

% For each coset that contains a power of alpha < 2t, add the corresponding
% minimum polynomial to the list of minimum polynomials. Then convolve all the
% minimum polynomials to make the generator polynomial.
minpol_list = [];
for idx1 = 2 : numel(coset)
    if(any(find(log(coset{idx1})<t2)))  % coset contains a power of alpha < 2t 
        
        % Compute the minimum polynomial for this coset
        tempPoly = 1;
        thisCoset = coset{idx1};
        for idx2 = 1 : length(thisCoset);
            tempPoly = conv(tempPoly, [1 thisCoset(idx2)]);
        end
        
        % Zero pad polynomial if necessary
        minPol = gf([zeros(1,m+1-length(tempPoly))  tempPoly.x],1);
        
        % add polynomial to list
        minpol_list = [minpol_list;minPol];         %#ok<AGROW>
    end
end

% Convolve all the rows of the minpol_list with each other.
len = size(minpol_list,1);
genpoly  = 1;
for i = 1:len,
    genpoly = conv(genpoly,minpol_list(i,:));
end

% Strip any leading zeros
% The size of the generator polynomial should be N-K+1
genpoly = genpoly( end-(N-K) :end);

% Remove global variables
clear global GF_TABLE1 GF_TABLE2 GF_TABLE_M GF_TABLE_PRIM_POLY

% [EOF]
