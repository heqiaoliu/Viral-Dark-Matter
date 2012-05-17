function clearApproxLLRPrivProps(h)
%CLEARAPPROXLLRPRIVPROPS Clear private properties used for Approximate LLR computataion

% @modem/abstractDemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:24 $

% Clear the two private props - PrivMinIdx0 and PrivMinIdx1
setPrivProp(h, 'PrivMinIdx0', []);
setPrivProp(h, 'PrivMinIdx1', []);

%-------------------------------------------------------------------------------
% [EOF]