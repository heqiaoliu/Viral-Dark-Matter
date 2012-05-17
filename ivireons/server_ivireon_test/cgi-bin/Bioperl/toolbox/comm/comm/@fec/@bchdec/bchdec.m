function h = bchdec(varargin)
%BCHDEC BCH Decoder
%   DEC = FEC.BCHDEC(N,K) constructs an (N,K) BCH decoder
%   object DEC.
%
%   DEC = FEC.BCHDEC(PROPERTY1, VALUE1, ...) constructs a BCH decoder
%   object DEC with properties as specified by PROPERTY/VALUE pairs.
%
%   DEC = FEC.BCHDEC(BCHENC_OBJECT) constructs a BCH decoder object DEC by
%   reading the property values from the BCH encoder object BCHENC_OBJECT.
%
%   A BCH decoder object has the following properties, which are all
%   writable except for the ones explicitly noted otherwise.
%
%   Type            - The type of decoder object. This property also 
%                     displays the effective message length and codeword 
%                     length, taking shortening and puncturing into
%                     consideration. This property is not writable.
%
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
%  
%   DEC = FEC.BCHDEC constructs a BCH decoder with default properties. It
%   is equivalent to:
%
%   DEC = FEC.BCHDEC(7,4)
%  
%   See also fec.bchenc/encode, fec.bchenc, fec.bchdec/decode, fec.rsdec
% 

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/12/05 01:58:24 $

h = fec.bchdec;

h = bchcon(h, varargin{:});

updateTables(h,log2(h.N+1));

% %EOF
