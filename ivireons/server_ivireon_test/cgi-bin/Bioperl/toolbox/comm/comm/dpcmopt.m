function [predictor, codebook, partition] = dpcmopt(training_set, ord, ini_codebook)
%DPCMOPT Optimize differential pulse code modulation parameters.
%   PREDICTOR = DPCMOPT(TRAINING_SET, ORD) estimates the predictive
%   transfer function using the given order ORD and training set
%   TRAINING_SET which must be a vector.
%
%   [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,CLENGTH)
%   returns the corresponding optimized CODEBOOK and PARTITION. CLENGTH is
%   an integer that prescribes the length of CODEBOOK.
%
%   [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,INI_CODEBOOK)
%   produces the optimized predictive transfer function PREDICTOR,
%   CODEBOOK, and PARTITION for the DPCM. The input variable INI_CODEBOOK
%   can either be a vector that contains the initial estimated value of the
%   codebook vector or a scalar integer that specifies the vector size of
%   CODEBOOK.
%
%   See also DPCMENCO, DPCMDECO, LLOYDS.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $ $Date: 2007/08/03 21:17:29 $ 

% routine check
error(nargchk(2,3,nargin,'struct'));

if min(size(training_set)) ~= 1
  error('comm:dpcmopt:Training_setIsMatrix','TRAINING_SET must be a vector.');
end

if any(size(ord) > 1) || (floor(ord) ~= ord) || (ord < 1)
  error('comm:dpcmopt:InvalidOrd','ORD must be a positive, integer scalar.');
end

training_set = training_set(:);
% compute the correlation vectors ri
len = length(training_set);
if len < ord+3
    error('comm:dpcmopt:InvalidInput','The size of the training set is not large enough for the design in DPCMOPT.')
end;
  
% allocate memory
r = zeros(ord+2,1);

for i = 1 : ord+2
    r(i) = training_set(1:len-i+1)' * training_set(i:len) / (len - i);
end;

% Levinson-Durbin Algorithm in finding the coeficient for A(z).
predictor = [1, zeros(1, ord)];
D = r(1);
r = r(:);

for m = 0 : ord-1
    beta = predictor(1:m+1) * r(m+2:-1:2);
    K = -beta/D;
    predictor(2 : m+2) = predictor(2 : m+2) + K * predictor(m+1 : -1 : 1);
    D = (1 - K*K) * D;
end;

% P = 1 - A(z), the FIR filter for the
predictor(1) = 0;
predictor=-predictor;


if nargout > 1
    error(nargchk(3,3,nargin,'struct'));
    
    % allocate memory
    err = zeros(len-ord,1);
    % continue to find the partition and codebook.
    % calculate the predictive errors:
    for i = ord+1 : len
        err(i-ord) = training_set(i) - predictor * training_set(i:-1:i-ord);
    end;
    % use err for partition and codebook optimization
    [partition, codebook] = lloyds(err, ini_codebook);
end;

% -- end of dpcmopt --
