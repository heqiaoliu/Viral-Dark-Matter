function [h,n] = firgauss(varargin)
%FIRGAUSS FIR Gaussian digital filter design.
%   FIRGAUSS has been replaced by GAUSSFIR.  FIRGAUSS still works but
%   may be removed in the future. Use GAUSSFIR instead. Type help
%   GAUSSFIR for details.
%
%   See also FIRRCOS.

%   Author: P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.6 $  $Date: 2008/05/31 23:25:57 $

%   References:
%     [1] Wells, W. M. III, Efficient Synthesis of Gaussian Filters by Cascaded 
%         Uniform Filters, IEEE Transactions on Pattern Analysis and Machine 
%         Intelligence, Vol. PAMI-8, No. 2, March 1980
%     [2] Rau, R., and McClellan J. H., Efficient Approximation of Gaussian Filters, 
%         IEEE Transactions on Signal Processing, Vol. 45, No. 2, February 1997.

error(nargchk(2,3,nargin,'struct'));

% Parse input arguments
[k,n,msg] = parseinputs(varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Build the uniform-coefficient (boxcar) filter 
b = ones(1,n);
g = dfilt.dffir(b);

% Generate cascaded filter
Hd=cell(1,k);
[Hd{:}]=deal(g);
Hcas = cascade(Hd{:});

% Return the coefficients
h = impz(Hcas);


%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
function [k,n,msg] = parseinputs(k,varargin)
% Parse the input arguments
%
% Outputs:
%   k   - Number of cascades (always specified)
%   n   - Length of the uniform-coefficient filter
%   msg - Error message

% Default values
msg = '';
n = []; variance = [];
isminord   = 0;

if ischar(varargin{1}),
    isminord = 1; % N was not specified
    variance = varargin{2};
elseif isnumeric(varargin{1}),
    n = varargin{1};
end

if isminord && k >= 4,    
    % Variance was specified and number of cascades is 4 or more, 
    % compute the length, n using equation #4 in [2].
    n = getOptimalN(k,variance);
elseif isminord,
    % Variance was specified, compute the minimum n by rearranging the 
    % variance equation on page 237 of [1]. This will result in an n 
    % which meets the variance criterion specified, but is not optimal.
    n = round(sqrt((12*variance)/k + 1));
end

if k < 1, msg = 'K must be greater than 0.'; end
if n < 1, msg = 'N must be greater than 0.'; end


%-------------------------------------------------------------------
function n = getOptimalN(k,variance)
%   Determine the Optimal length for the uniform-coefficient filters
%   boxcar filters using equation 4 from [2].
%
%   Inputs:
%     k - Number of cascades  
%     variance - Overall variance of the gaussian filter
%
%   Output:
%     n - Optimal length of the uniform-coefficient filter

sigma = sqrt(variance);
if (sigma >= 2) && (sigma <= 400) && (k >= 4) && (k <= 8),
    alfa = 0.005;
else
    alfa = 0;
end

summation = 0;
for p = 0:floor(((k-1)/2)),
    summation = summation + ((-1^p/factorial(k-1))*nchoosek(k,p)*((k/2)-p)^(k-1));
end
n = abs(ceil((sqrt(2*pi)*summation + alfa)*sigma)); 

% [EOF]
