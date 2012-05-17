function varargout = validate(this)
%VALIDATE Validate the specifications.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:10:14 $

% Pass validation to the response type.
[varargout{1:nargout}] = validate(this.responseTypeSpecs, this);

% [EOF]
