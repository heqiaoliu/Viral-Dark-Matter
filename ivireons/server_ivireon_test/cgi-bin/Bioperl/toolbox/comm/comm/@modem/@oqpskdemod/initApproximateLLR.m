function initApproximateLLR(h, M, symbolMapping)
% INITAPPROXIMATELLR Initialize/pre-compute properties required for
% Approximate LLR computattion

%   @modem/@oqpskdemod

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:15:20 $

% clear private properties used for LLR computations
clearLLRPrivProps(h);

% convert SymbolMapping into binary form
binMapping = de2bi(symbolMapping(:), 'left-msb');
% compute PrivS0 and PrivS1
[privS0, varNotUsed] = find(binMapping == 0); %#ok
[privS1, varNotUsed] = find(binMapping == 1); %#ok

% compute secondary constellation
angleVector = ( ((0.5:2*M)*pi/M) + h.PhaseOffset + pi/4);
tmpConstellation = exp(i*angleVector);

% Call CPP-mex function to compute private props PrivMinIdx0 and PrivMinIdx1
% returned values - privMinIdx0 & privMinIdx1 - are int32 matrices
% 'PrivS0' and 'PrivS1' are converted to int32 as the core CPP function uses
% them as int32_T. To convert them from ML indices to C/CPP indices, 1 is
% subtracted.
[privMinIdx0, privMinIdx1] = initApproxLLR_PSK(M, ...
                                               log2(M), ...
                                               tmpConstellation, ...
                                               h.Constellation, ...
                                               int32(symbolMapping), ...
                                               int32(privS0-1), ...
                                               int32(privS1-1));

% convert to double and store for later use
privMinIdx0 = double(privMinIdx0(:));
privMinIdx1 = double(privMinIdx1(:));
setPrivProp(h, 'PrivMinIdx0', privMinIdx0);
setPrivProp(h, 'PrivMinIdx1', privMinIdx1);

%--------------------------------------------------------------------
% [EOF]