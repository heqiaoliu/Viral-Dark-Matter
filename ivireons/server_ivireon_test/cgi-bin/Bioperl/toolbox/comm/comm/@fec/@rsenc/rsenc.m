function h = rsenc(varargin)
%RSENC Reed-Solomon Encoder
%   ENC = FEC.RSENC(N,K) constructs an (N,K) Reed-Solomon encoder
%   object ENC.
%
%   ENC = FEC.RSENC(PROPERTY1, VALUE1, ...) constructs a Reed-Solomon encoder
%   object ENC with properties as specified by PROPERTY/VALUE pairs.
%
%   ENC = FEC.RSENC(BCHDEC_OBJECT) constructs a Reed-Solomon encoder object
%   ENC by reading the property values from the RS decoder object
%   RSDEC_OBJECT.
%
%   A RS encoder object has the following properties, which are all
%   writable except for the ones explicitly noted otherwise.
%
%   Type            - The type of encoder object. This property also
%                     displays the effective message length and codeword
%                     length, taking shortening and puncturing into
%                     consideration. This property is not writable.
%   N               - The codeword length of the base code, not
%                     including shortening or puncturing.
%   K               - The uncoded message length, not including
%                     shortening.
%   T               - The number of errors the base code is capable
%                     of correcting. This property is not writeable.
%   ShortenedLength - The number of symbols by which the code has been
%                     shortened.
%   ParityPosition  - Must be 'beginning' or 'end'.  Specifies if parity
%                     bits should appear at the beginning or end of the
%                     codeword.
%   GenPoly         - The generator polynomial for the code. GENPOLY must
%                     be a Galois row vector that lists the coefficients,
%                     in order of descending powers, of the generator
%                     polynomial.
%
%   ENC = FEC.RSENC constructs a Reed-Solomon encoder with default
%   properties. It is equivalent to: ENC = FEC.RSENC(7,3)
%
%   See also fec.rsenc/encode, fec.rsdec, fec.bchdec/decode, rsgenpoly,
%   fec.bchenc

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:43 $

h = fec.rsenc;

if(nargin == 0) % Default constructor
    N = 7;
    K = 3;
    rsConstructor(h,N,K);
elseif isa(varargin{1},'char') % P-V Pair constructor
    % For a Reed-Solomon code, N and K must both be specified
    if(nargin == 2) % only N or K has been specified
        error([getErrorId(h) ':notEnoughInput'],'N and K must both be specified for a Reed-Solomon code');
    end

    h = InitPropValuePairs(h,varargin{:});
    h.Nset = true;
    h.Kset = true;
    return

elseif isa(varargin{1},'fec.rsdec' ) % Construct from decoder
    dec = varargin{1};
    h.N = dec.N;
    h.K = dec.K;
    h.t = dec.t;
    h.m = dec.m;
    h.T2 = dec.T2;
    h.GenPoly = dec.GenPoly;
    h.ShortenedLength = dec.ShortenedLength;
    h.ParityPosition  = dec.ParityPosition;
    h.PuncturePattern = dec.PuncturePattern;
    h.type = algType(h,h.N,h.K,h.ShortenedLength,h.PuncturePattern);
    return
else
    % Standard constructor
    if(nargin ~= 2) % only N or K has been specified
        error([getErrorId(h) ':notEnoughInput'],'N and K must both be specified for a Reed-Solomon code');
    end
    N = varargin{1};
    K = varargin{2};
    rsConstructor(h,N,K);
end



