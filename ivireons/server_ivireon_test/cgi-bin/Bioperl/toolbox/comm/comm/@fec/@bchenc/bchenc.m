function h = bchenc(varargin)
%BCHENC BCH Encoder
%   ENC = FEC.BCHENC(N,K) constructs an (N,K) BCH encoder
%   object ENC.
%
%   ENC = FEC.BCHENC(PROPERTY1, VALUE1, ...) constructs a BCH encoder
%   object ENC with properties as specified by PROPERTY/VALUE pairs.
%
%   ENC = FEC.BCHENC(BCHDEC_OBJECT) constructs a BCH encoder object ENC by
%   reading the property values from the BCH decoder object BCHDEC_OBJECT.
%
%   A BCH encoder object has the following properties, which are all
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
%   PuncturePattern - Indicates which parity bits in a codeword are 
%                     punctured.  This binary-valued vector is of
%                     length N-K.  Values of “0” indicate bits that are
%                     punctured, and values of “1” indicate bits that
%                     are not.
%
%   ENC = FEC.BCHENC constructs a BCH encoder ENC with default properties. It
%   is equivalent to:
%   ENC = FEC.BCHENC(7,4)
%
%   See also fec.bchenc/encode, fec.bchdec, fec.bchdec/decode, fec.rsenc


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:22:10 $

h = fec.bchenc;

h = bchcon(h, varargin{:});
