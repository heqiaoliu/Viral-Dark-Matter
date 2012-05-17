function rcvals = refvals(this)
%REFVALS   Reference coefficient values.
%This should be a private method.
%   The values are returned in a cell array.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:00:36 $

rcnames = refcoefficientnames(this);

rcvals = get(this,rcnames);

% [EOF]
