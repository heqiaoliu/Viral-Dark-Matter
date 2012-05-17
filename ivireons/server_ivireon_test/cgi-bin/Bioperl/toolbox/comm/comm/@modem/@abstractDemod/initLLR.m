function initLLR(h, symbolMapping)
%INITLLR Initialize/pre-compute properties required for LLR computation.

%   @modem/@abstractDemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:31 $

% clear private properties used for Approximate LLR computations
clearApproxLLRPrivProps(h);

% convert SymbolMapping into binary form
binMapping = de2bi(symbolMapping(:), 'left-msb');
% compute and set PrivS0 & PrivS1
[privS0, varNotUsed] = find(binMapping == 0); %#ok
[privS1, varNotUsed] = find(binMapping == 1); %#ok
setPrivProp(h, 'PrivS0', privS0);
setPrivProp(h, 'PrivS1', privS1);

%-------------------------------------------------------------------------------
% [EOF]