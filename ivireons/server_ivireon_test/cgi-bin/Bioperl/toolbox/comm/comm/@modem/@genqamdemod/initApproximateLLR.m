function initApproximateLLR(h, M, symbolMapping) %#ok
% INITAPPROXIMATELLR Initialize/pre-compute properties required for
% Approximate LLR computattion

%   @modem/@genqamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:31 $

% clear private properties used for LLR computations
clearLLRPrivProps(h);

% convert SymbolMapping into binary form
binMapping = de2bi(symbolMapping(:), 'left-msb');
% compute PrivS0 and PrivS1
[privS0, varNotUsed] = find(binMapping == 0); %#ok
[privS1, varNotUsed] = find(binMapping == 1); %#ok

setPrivProp(h, 'PrivS0', privS0);
setPrivProp(h, 'PrivS1', privS1);

%--------------------------------------------------------------------
% [EOF]