function clearLLRPrivProps(h)
%CLEARLLRPRIVPROPS Clear private properties used for LLR computataion

% @modem/abstractDemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:25 $

% Clear the two private props - PrivS0 and PrivS1
setPrivProp(h, 'PrivS0', []);
setPrivProp(h, 'PrivS1', []);

%-------------------------------------------------------------------------------
% [EOF]