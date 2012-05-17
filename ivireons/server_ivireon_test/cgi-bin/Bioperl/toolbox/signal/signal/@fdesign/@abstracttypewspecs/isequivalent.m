function b = isequivalent(this, htest)
%ISEQUIVALENT   True if the object is equivalent.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:26:03 $

if isa(htest, class(this)) && ...
        strcmpi(this.Specification, htest.Specification)
    b = isequal(struct(this.CurrentSpecs), struct(htest.CurrentSpecs));
else
    b = false;
end

% [EOF]
