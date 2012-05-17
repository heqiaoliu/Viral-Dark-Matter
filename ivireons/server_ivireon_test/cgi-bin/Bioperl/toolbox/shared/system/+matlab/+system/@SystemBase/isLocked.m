%isLocked Locked status (logical) for input attributes and non-tunable
%properties
%   L = isLocked(H) returns a logical value, L, which indicates whether
%   input attributes and non-tunable properties are locked for the object.
%   The object performs an internal initialization the first time the step
%   method is executed. This initialization locks non-tunable properties
%   and input specifications, such as dimensions, complexity, and data type
%   of the input data. Once this occurs, the isLocked method returns a true
%   value.
%
%   See also step, release.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2010/04/21 21:49:55 $

% [EOF]
