function rcvals = refvals(this)
%REFVALS   Reference coefficient values.
%This should be a private method.
%   The values are returned in a cell array.

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:59:17 $

rcnames = refcoefficientnames(this);

rcvals = get(this,rcnames);

% [EOF]
