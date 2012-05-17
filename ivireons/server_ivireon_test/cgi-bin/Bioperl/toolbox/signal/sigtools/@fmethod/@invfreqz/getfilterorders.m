function [NumOrder DenOrder] = getfilterorders(this,hspecs)
%GETFILTERORDERS   Get the filterorders.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:29:09 $

NumOrder  = hspecs.FilterOrder;
DenOrder = hspecs.FilterOrder;

% [EOF]
