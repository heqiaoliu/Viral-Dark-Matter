function codeword = encode(h, msg)
%ENCODE  Encode a message using an LDPC code.
%   CODEWORD = ENCODE(L, MSG) encodes MSG using the LDPC code specified by
%   an LDPC encoder object L.
%
%   MSG must be a binary 1-by-L.NumInfoBits vector.
%
%   CODEWORD is a binary 1-by-L.BlockLength vector. The first L.NumInfoBits
%   are the information bits (i.e. MSG) and the last L.NumParityBits bits are
%   the parity bits. The modulo-2 matrix product of L.ParityCheckMatrix and
%   CODEWORD' is a zero vector.
%
%   Example:
%
%     % Construct a default LDPC encoder object
%     l = fec.ldpcenc;
%     % Generate a random binary message
%     msg = randi([0 1],1,l.NumInfoBits);
%     % Encode the message
%     codeword = encode(l, msg);
%     % Verify the parity checks (which should be a zero vector)
%     paritychecks = mod(l.ParityCheckMatrix * codeword', 2);
%
%   See also FEC.LDPCENC, FEC.LDPCDEC, FEC.LDPCDEC/DECODE.

%   @fec/@ldpcenc

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:35 $

if ~isempty(find(nonzeros(msg)~=1,1))
    error('comm:ldpcenc:NonBinaryMessage', ...
          'The message must be binary.');
end

if size(msg, 1) ~= 1 || size(msg, 2) ~= h.NumInfoBits
    error('comm:ldpcenc:InvalidMessageDimensions', ...
          'The message must be a 1-by-NumInfoBits vector.');
end

paritychk = ldpcencode(int8(msg), h.NumInfoBits, h.NumParityBits, ...
   h.EncodingMethod, ...
   h.MatrixA_RowIndices, h.MatrixA_RowStartLoc, h.MatrixA_ColumnSum, ...
   h.MatrixB_RowIndices, h.MatrixB_RowStartLoc, h.MatrixB_ColumnSum, ...
   h.MatrixL_RowIndices, h.MatrixL_RowStartLoc, h.MatrixL_ColumnSum, ...
   h.RowOrder);

codeword = ([double(msg) double(paritychk)]);
