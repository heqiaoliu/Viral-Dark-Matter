function [nData, varargout] = bsc(data, p, hStream)
%BSC Model a binary symmetric channel.
%   NDATA = BSC(DATA, P) passes the binary input signal DATA through a
%   binary symmetric channel with error probability P. If the input DATA is
%   a Galois field over GF(2), the Galois field data is passed through the
%   binary symmetric channel.
% 
%   NDATA = BSC(DATA, P, S) causes RAND to use the random stream S.  S is
%   any valid random stream.  See RandStream for more details.
% 
%   NDATA = BSC(DATA, P, STATE) causes RAND to use the generator determined
%   by the 'state' method, and initializes the state of that generator
%   using the value of STATE, prior to the generation of the error vector.
%   BSC may not accept STATE in a future release.  Use S instead.
% 
%   [NDATA, ERR] = BSC(...) returns the errors introduced by the channel in
%   ERR.
% 
%   Example 1:
%       data = randi([0 1], 20);
%       p = 0.2;
%       [nData, err] = bsc(data, p);
%       obsP = sum(err(:))/prod(size(data))
% 
%   Example 2:
%       % Specify the random stream to obtain repeatable results
%       s = RandStream('mt19937ar', 'Seed', 12345);
%       data = randi([0 1], 1, 10)
%       p = 0.2;
%       [nData, err] = bsc(data, p, s);
%       nData
%       reset(s)
%       [nData, err] = bsc(data, p, s);
%       nData
% 
%   See also RAND, AWGN, RandStream.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2009/01/05 17:45:03 $

% Begin error checking ----------------------------------------------------
%
% Number of input arguments
error(nargchk(2, 3, nargin, 'struct'));

% Number of output arguments
error(nargoutchk(0, 2, nargout, 'struct'));

% Check for real binary DATA or field data
if isa(data, 'gf')
    if (~isnumeric(data.x) || ~isreal(data.x) || (data.m ~= 1))
        error('comm:bsc:gfDataReal', ...
            'DATA field data must be binary values.');
    end
else
    if (~isnumeric(data) || ~isreal(data) || ...
        ~isequal((data + ~data), ones(size(data))))
    error('comm:bsc:dataReal', 'DATA must be real binary values.');
    end
end

% Check for real P within range
if (~isnumeric(p) || ~isreal(p) || ~isscalar(p) || ~((0 <= p) && (p <= 1))) 
    error('comm:bsc:pReal', 'P must be a real scalar between 0 and 1.');
end

% Check for valid third argument
if (nargin == 3) 
    if isa(hStream, 'RandStream')
        validateattributes(hStream, {'RandStream'}, {'scalar'}, 'BSC', 'S');
    else
        validateattributes(hStream, {'numeric'}, ...
            {'scalar', 'real', 'integer'}, 'BSC', 'STATE');
        hStream = RandStream('swb2712','Seed',hStream);
    end
    randFunc = @(a)rand(hStream, a);
else
    randFunc = @(a)rand(a);
end


% End of input error checking ---------------------------------------------



% Begin output argument processing ----------------------------------------

% Generate uniformly distributed random numbers in the interval (0,1) and
% compare them to the probability P of a channel error. If the generated
% random numbers are smaller, then an error has occurred in the channel.

if isa(data, 'gf')
    err = double(randFunc(size(data.x)) < p);
    nData = gf(xor(data.x, err));
else
    err = double(randFunc(size(data)) < p);
    nData = double(xor(data, err));
end

if (nargout == 2)
	varargout{1} = err;
end 

% End output argument processing ------------------------------------------

% EOF - bsc.m
