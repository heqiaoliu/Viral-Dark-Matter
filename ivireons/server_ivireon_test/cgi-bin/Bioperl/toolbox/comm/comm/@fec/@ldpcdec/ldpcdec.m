function h = ldpcdec(H)
%LDPCDEC  LDPC decoder.
%   L = FEC.LDPCDEC(H) constructs an LDPC decoder object L for a binary
%   systematic LDPC code with a parity-check matrix H.
%
%   H must be a sparse zero-one matrix. N and N-K are the number of columns
%   and the number of rows in H.
%
%   An LDPC decoder object has the following properties. ParityCheckMatrix
%   specifies the LDPC code; DecisionType, OutputFormat, DoParityChecks,
%   NumIterations specify settings for the decoding operation.
%   All other properties are read-only.
%
%   ParityCheckMatrix   - Parity-check matrix of the LDPC code, i.e., H.
%                         Stored as a sparse logical matrix.
%
%   BlockLength         - Total number of bits in a codeword, i.e., N.
%
%   NumInfoBits         - Number of information bits in a codeword, i.e., K.
%
%   NumParityBits       - Number of parity bits in a codeword, i.e., N-K.
%
%   DecisionType        - 'Hard decision' or 'Soft decision'. Default value
%                         is 'Hard decision'.
%
%   OutputFormat        - 'Information part' or 'Whole codeword'. Default value
%                         is 'Information part'.
%
%   DoParityChecks      - 'Yes' or 'No'. Whether the parity-checks should be
%                         verified after each iteration, and whether the
%                         decoder should stop iterating if all parity-checks
%                         are satisfied. Default value is 'No'.
%
%   NumIterations       - Number of iterations to be performed for decoding one
%                         codeword. Default value is 50.
%
%   ActualNumIterations - Actual number of iterations executed for the last
%                         codeword. Initial value is [].
%
%   FinalParityChecks   - (N-K)-by-1 vector. The 1's indicate which
%                         parity-checks are not satisfied when the decoder
%                         stops. Initial value is [].
%
%   L = FEC.LDPCDEC constructs an LDPC encoder object with a default
%   parity-check matrix (32400-by-64800) corresponding to an irregular LDPC
%   code with the following structure:
%
%     Row     No. of 1's per row        Column       No. of 1's per column
%   ------------------------------    --------------------------------------
%      1               6                  1 to 12960            8
%   2 to 32400         7              12961 to 32400            3
%
%   Columns 32401 to 64800 form a lower triangular matrix. Only the elements
%   on its main diagonal and the subdiagonal immediately below are 1's.
%   This LDPC code is used in conjunction with a BCH code in Digital Video
%   Broadcasting standard (DVB-S.2) to achieve a packet error rate below 10^-7
%   at about 0.7 dB to 1 dB from the Shannon limit.
%
%   Examples:
%
%     % Construct an LDPC decoder object
%     i = [1  3  2  4  1  2  3  3  4];   % row indices of 1's
%     j = [1  1  2  2  3  4  4  5  6];   % column indices of 1's
%     H = sparse(i,j,ones(length(i),1)); % This is just an example and is not
%     l = fec.ldpcdec(H);                % a good LDPC code.
%
%     % Construct an LDPC decoder object with the default parity-check matrix
%     l = fec.ldpcdec;
%
%   See also FEC.LDPCDEC/DECODE, FEC.LDPCENC, FEC.LDPCENC/ENCODE, SPARSE.

%   @fec/@ldpcdec

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/09/14 15:58:35 $

error(nargchk(0, 1, nargin,'struct'));
h = fec.ldpcdec;

if nargin == 0
    h.ParityCheckMatrix = dvbs2ldpc(1/2);
else
    h.ParityCheckMatrix = H;
end

