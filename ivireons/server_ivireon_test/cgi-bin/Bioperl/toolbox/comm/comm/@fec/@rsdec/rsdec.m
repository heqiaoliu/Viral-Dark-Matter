function h = rsdec(varargin)
%   DEC = FEC.RSDEC(N,K) constructs an (N,K) Reed-Solomon decoder
%   object DEC.
%
%   DEC = FEC.RSDEC(PROPERTY1, VALUE1, ...) constructs a Reed-Solomon
%   decoder object DEC with properties as specified by PROPERTY/VALUE
%   pairs.
%
%   DEC = FEC.RSDEC(RSENC_OBJECT) constructs a Reed-Solomon decoder object
%   DEC by reading the property values from the Reed-Solmon encoder object
%   RSENC_OBJECT.
%
%   A Reed-Solomon decoder object has the following properties, which are
%   all writable except for the ones explicitly noted otherwise.
%
%   Type            - The type of decoder object. This property also
%                     displays the effective message length and codeword
%                     length, taking shortening and puncturing into
%                     consideration. This property is not writable.
%   N               - The codeword length of the base code, not including
%                     shortening or puncturing.
%   K               - The uncoded message length, not including shortening.
%   T               - The number of errors the base code is capable
%                     of correcting. This property is not writeable.
%   ShortenedLength - The number of code bits by which the code has been
%                     shortened
%   ParityPosition  - Must be 'beginning' or 'end'.  Specifies if parity
%                     bits should appear at the beginning or end of the
%                     codeword.
%   PuncturePattern - Indicates which parity bits in a codeword are
%                     punctured.  This binary-valued vector is of length
%                     N-K.  Values of "0" indicate bits that are punctured,
%                     and values of "1" indicate bits that are not.
%   GenPoly         - The generator polynomial for the code. GENPOLY must
%                     be a Galois row vector that lists the coefficients,
%                     in order of descending powers, of the generator
%                     polynomial.
%
%   DEC = FEC.RSDEC constructs a Reed-Solomon decoder with default
%   properties. It is equivalent to: DEC = FEC.RSDEC(7,3)
%
%   See also fec.rsdec/decode, fec.rsenc, rsgenpoly, fec.bchdec

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:49:19 $


h = fec.rsdec;
if(nargin == 0)
    N = 7;
    K = 3;
    rsConstructor(h,N,K);
elseif (isa(varargin{1},'fec.rsenc'))
    c = varargin{1};
    h.N = c.N;
    h.K = c.K;
    h.Nset = true;
    h.Kset = true;
    h.ParityPosition  = c.ParityPosition;
    h.PuncturePattern = c.PuncturePattern;
    h.ShortenedLength = c.ShortenedLength;
    h.t = c.t;
    h.m = c.m;
    h.T2 = c.T2;
    h.type = algType(h,h.N,h.K,h.ShortenedLength,h.PuncturePattern);
    h.GenPoly = c.GenPoly;
    return
elseif isa(varargin{1},'char')
    % For a Reed-Solomon code, N and K must both be specified
    if(nargin == 2) % only N or K has been specified
        error([getErrorId(h) ':notEnoughInput'],'N and K must both be specified for a Reed-Solomon code');
    end
    h = InitPropValuePairs(h,varargin{:});
    h.Nset = true;
    h.Kset = true;

    return
else
    if(nargin ~= 2) % only N or K has been specified
        error([getErrorId(h) ':notEnoughInput'],'N and K must both be specified for a Reed-Solomon code');
    end
    N = varargin{1};
    K = varargin{2};
    rsConstructor(h,N,K);
end

[GF_TABLE1 GF_TABLE2] = populateTables(h, h.m);
h.PrivGfTable1 = GF_TABLE1;
h.PrivGfTable2 = GF_TABLE2;
