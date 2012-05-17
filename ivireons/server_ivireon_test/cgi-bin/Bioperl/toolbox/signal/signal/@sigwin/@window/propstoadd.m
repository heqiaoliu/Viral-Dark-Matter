function props = propstoadd(this)
%PROPSTOADD Method that lists the properties associated with this object.
%
% This method can be used in conjunction with the utility function
% ADDPROPS, which dynamically adds properties from one object to another.
% This is useful in the case of one object containing another object.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:41:30 $

props = fieldnames(this);

% [EOF]
