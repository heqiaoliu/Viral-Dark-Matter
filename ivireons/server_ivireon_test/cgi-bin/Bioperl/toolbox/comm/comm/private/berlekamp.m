function [msg, cnumerr, corrCode] = ...
    berlekamp(code, n, k, m, t, b, shortened, inWidth, varargin)
%BERLEKAMP Berlekamp-Massey Algorithm for RS and BCH Decoding.  Core algorithm of RSDEC/BCHDEC.
%   [MSG, CNUMERR, CORRCODE] = BERLEKAMP(CODE, N, K, M, T, B, SHORTENED,
%   INWIDTH) attempts to correct the errors in the received word CODE to form a
%   valid Reed Solomon or BCH codeword CORRCODE.  MSG is the non-parity portion
%   of CORRCODE.  CODE must be a gf object with a row vector as its x field.  N
%   and K are the codeword length and the message length, respectively.  M is
%   the exponent of the extension field to which CODE belongs. T is the
%   error-correcting capability which must be a positive integer.  B is the
%   smallest exponent of alpha among all the monomials of the generator
%   polynomial, and must be equal to 1 for a narrow-sense code. SHORTENED is the
%   length, if any, by which the code is shortened.  INWIDTH is the length of
%   the CODE vector.  CNUMERR returns the number of errors corrected.  In the
%   case of a decoding failure, which is when CODE differs for more than T
%   symbols from any possible valid codewords, CNUMERR returns -1.
%
%   See also GF, RSDEC, BCHDEC

% Copyright 1996-2009 The MathWorks, Inc.
% $Revision: 1.4.4.6 $  $Date: 2009/03/30 23:24:28 $
%
% References : (1) "Error-Correction Coding for Digital Communications",
%                  Clark and Cain, Plenum, 1981.
%
%              (2) "Error Control Systems for Digital Communication and Storage",
%                  Wicker, Prentice Hall, 1995.
%                  Section 9.2.2 : "The Berlekemp-Massey Algorithm"
%
%              (3) "Algebraic Coding Theory", Berlekamp, McGraw-Hill, 1968.
%                 Section 10.3 : "Alternate BCH codes and Extended BCH codes"
%
% NOTE that there is no error checking of the input arguments.  All checking
% should have been done in RSDEC/BCHDEC.

% Call a shared CPP-mex function to perform the Berlekamp algorithm.  GF_TABLE1
% and GF_TABLE2 have already been created as global variables, but they need to
% be brought into the scope of the berlekamp function.  If the tables are empty
% because a non-default primitive polynomial is being used, then populate them
% with the proper values.
showNumErr = true;    % output the # of errors
global GF_TABLE1 GF_TABLE2

% Define puncture and erasure parameters (currently not used)
if(nargin == 8) % to preserve old functionality
    punctVec = true(1,n-k);
    numPuncs = 0;
    erasures = false(1,inWidth);

    if isempty(GF_TABLE1) || isempty(GF_TABLE2)
        [GF_TABLE1 GF_TABLE2] = populateTables(m);
    end
else % for new object based functionality
    punctVec = varargin{1};
    erasures = varargin{2};
    numPuncs = sum(~punctVec);
    GF_TABLE1 = varargin{3};
    GF_TABLE2 = varargin{4};
end

%Check the number of erasures and return early if there are too many
if sum(erasures) > 2*t
    msg = code(1:k);
    cnumerr = -1;
    corrCode = code;
    return
end


[msg cnumerr corrCode] = berlekampDecode(int32(code), ...
    int32(n), ...
    int32(k), ...
    int32(m), ...
    int32(t), ...
    int32(b), ...
    int32(shortened), ...
    logical(punctVec), ...
    int32(numPuncs), ...
    logical(erasures), ...
    logical(showNumErr), ...
    int32(inWidth), ...
    uint32(GF_TABLE1), ...
    uint32(GF_TABLE2));

%Ensure that if the decoding failed, we return the original code-word. This
%won't be necessary after G386125 gets addressed.
if(cnumerr == -1)
    corrCode = code;
    msg = code(1:k);
end

% ==============================================================================
function [GF_TABLE1 GF_TABLE2] = populateTables(m)
% POPULATETABLES - Create GF tables for user-defined primitive polynomials
%
%   This function requires m, the exponent of the extension field.  It uses code
%   that is also used in gftable.m.

global GF_TABLE_PRIM_POLY
x = gf(0:2^m-1,m, GF_TABLE_PRIM_POLY)';

% Turn off the gftable warning about lookup tables not being defined for
% nondefault primitive polynomials, since the purpose of this function is to
% create nondefault tables.
warnState = warning('off','comm:gftablewarning');
x1 = x(3).^(0:2^m-2);
warning(warnState);

% Create indices corresponding to the integer values of x1.  For example, if
% m=3 and prim_poly=13, then ind = [1 2 4 5 7 3 6].
ind = double(x1.x);

% Create a vector corresponding to the exponential representation of the field
% elements.  For example, if m=3 and prim_poly=13, then x = [0 1 5 2 3 6 4].
[notUsed, x] = sort(ind);  
x = x - 1;

table = [[ind'; 1] [-1; x']];
GF_TABLE1 = uint32(table(2:end,1));
GF_TABLE2 = uint32(table(2:end,2));

% [EOF]
