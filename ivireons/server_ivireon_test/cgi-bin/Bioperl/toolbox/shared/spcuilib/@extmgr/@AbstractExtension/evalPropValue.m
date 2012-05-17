function varargout = evalPropValue(this, property)
%EVALPROPVALUE Evaluate the property value.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:33:41 $

string_value = getPropValue(this, property);
[varargout{1:nargout}] = uiservices.evaluate(string_value);

% [EOF]
