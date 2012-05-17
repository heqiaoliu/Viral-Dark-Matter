function deintrlved = randdeintrlv(data, hStream)
%RANDDEINTRLV Restore ordering of symbols using a random permutation.
%   DEINTRLVED = RANDDEINTRLV(DATA, S) rearranges the elements of DATA
%   using a random permutation.  S is a random stream that determines the
%   specific permutation. The output of RANDDEINTRLV is repeatable for a given
%   same random stream with the same state, but different random streams and/or
%   different states produce different permutations. See RandStream for more
%   details.
%
%   DEINTRLVED = RANDDEINTRLV(DATA, STATE) rearranges the elements of DATA
%   using a random permutation.  STATE is a scalar integer value from 0
%   to 2^32-1 that determines the specific permutation. The output of
%   RANDDEINTRLV is repeatable for a given value of STATE, but different
%   values produce different permutations.  RANDDEINTRLV may not accept STATE in
%   a future release.  Use S instead.
%
%   Example 1:
%   % Create two identical random streams, one for interleaver and one for
%   % deinterleaver. 
%   s1 = RandStream('mt19937ar', 'Seed', 12345);
%   s2 = RandStream('mt19937ar', 'Seed', 12345);
%   data = randi([0 255], 1, 10)
%   intlvData = randintrlv(data, s1)
%   deintlvData = randdeintrlv(intlvData, s2)
%
%   Example 2:
%   % Use the same random stream for both interleaver and deinterleaver. To get
%   % the same state, we need to reset the random stream before each
%   % interleaving or deinterleaving operation.
%   s = RandStream('mt19937ar', 'Seed', 12345);
%   data = randi([0 255], 1, 10)
%   intlvData = randintrlv(data, s)
%   reset(s)
%   deintlvData = randdeintrlv(intlvData, s)
%   reset(s)
%   intlvData = randintrlv(data, s)
%   reset(s)
%   deintlvData = randdeintrlv(intlvData, s)
%
%   See also RANDINTRLV, DEINTRLV, RANDPERM, RandStream.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $ $Date: 2009/01/05 17:45:07 $

% --- Usual error checks
error(nargchk(2,2,nargin,'struct'));
error(nargoutchk(0,1,nargout,'struct'));

data_size = size(data);          % Obtains size of DATA
orig_data = data;

% --- Checks if DATA is 1-D column vector
if (data_size(1) == 1)
    data = data(:);              % Converts sequence in DATA to a column vector
    data_size = size(data);
end

% --- Error checking on input arguments
if isempty(data)
    error('comm:randdeintrlv:DataIsEmpty','DATA cannot be empty.')  
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:randdeintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isa(hStream, 'RandStream')
    validateattributes(hStream, {'RandStream'}, {'scalar'}, 'RANDDEINTRLV', 'S')
else
    validateattributes(hStream, {'numeric'}, {'nonempty'}, 'RANDDEINTRLV', 'STATE')
    % Create a local random number stream using the STATE input, which may be
    % a seed or a full state vector.
    if isscalar(hStream)
        s = RandStream('swb2712','seed',hStream);
    elseif isequal(size(hStream), [35 1])
        s = RandStream('swb2712');
        s.State = hStream;
    else
        error('comm:randdeintrlv:InvalidState','STATE must be scalar or 35-by-1.')
    end
    hStream = s;
end

int_vec = randperm(hStream,data_size(1)); % Return a random permutation of the integers 1:data_size(2)

% --- Rearrange sequence of symbols
deintrlved = deintrlv(orig_data,int_vec);

% -- end of randdeintrlv ---
