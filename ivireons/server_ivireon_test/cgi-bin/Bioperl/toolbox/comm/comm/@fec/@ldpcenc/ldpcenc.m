function h = ldpcenc(H)
%LDPCENC  LDPC encoder.
%   L = FEC.LDPCENC(H) constructs an LDPC encoder object L for a binary
%   systematic LDPC code with a parity-check matrix H.
%
%   H must be a sparse zero-one matrix. N and N-K are the number of columns
%   and the number of rows in H. The last N-K columns in H must be an
%   invertible matrix in GF(2).
%
%   An LDPC encoder object has the following properties. Only ParityCheckMatrix
%   is writable. All other properties are derived from it.
%
%   ParityCheckMatrix  - Parity-check matrix of the LDPC code, i.e., H.
%                        Stored as a sparse logical matrix.
%
%   BlockLength        - Total number of bits in a codeword, i.e., N.
%
%   NumInfoBits        - Number of information bits in a codeword, i.e., K.
%
%   NumParityBits      - Number of parity bits in a codeword, i.e., N-K.
%
%   EncodingAlgorithm  - Method for solving the parity-check equation to compute
%                        the parity bits using the information bits.
%
%                        'Forward Substitution' - if the last N-K columns
%                        in H are a lower triangular matrix.
%
%                        'Backward Substitution' - if the last N-K columns
%                        in H are an upper triangular matrix.
%
%                        'Matrix Inverse' - otherwise.
%
%   L = FEC.LDPCENC constructs an LDPC encoder object with a default
%   parity-check matrix (32400-by-64800) corresponding to an irregular LDPC
%   code with the following structure:
%
%     Row     No. of 1's per row        Column       No. of 1's per column
%   ------------------------------    --------------------------------------
%      1               6                  1 to 12960            8
%   2 to 32400         7              12961 to 32400            3
%
%   Columns 32401 to 64800 are a lower triangular matrix. Only the elements
%   on its main diagonal and the subdiagonal immediately below are 1's.
%   This LDPC code is used in conjunction with a BCH code in Digital Video
%   Broadcasting standard (DVB-S.2) to achieve a packet error rate below 10^-7
%   at about 0.7 dB to 1 dB from the Shannon limit.
%
%   Examples:
%
%     % Construct an LDPC encoder object
%     i = [1  3  2  4  1  2  3  3  4];   % row indices of 1's
%     j = [1  1  2  2  3  4  4  5  6];   % column indices of 1's
%     H = sparse(i,j,ones(length(i),1)); % This is just an example and is not
%     l = fec.ldpcenc(H);                % a good LDPC code.
%
%     % Construct an LDPC encoder object with the default parity-check matrix
%     l = fec.ldpcenc;
%
%   See also FEC.LDPCENC/ENCODE, FEC.LDPCDEC, FEC.LDPCDEC/DECODE, SPARSE.

%   @fec/@ldpcenc

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/09/14 15:58:36 $

error(nargchk(0, 1, nargin,'struct')); 

h = fec.ldpcenc;
if nargin == 0
    h.ParityCheckMatrix = dvbs2ldpc(1/2);
else
    h.ParityCheckMatrix = H;
end

