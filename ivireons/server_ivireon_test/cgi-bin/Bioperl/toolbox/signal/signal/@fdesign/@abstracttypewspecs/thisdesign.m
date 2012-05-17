function varargout = thisdesign(this, method, varargin)
%THISDESIGN   Design the filter.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:25 $

[varargout{1:nargout}] = feval(method, this.CurrentSpecs, varargin{:});

% [EOF]
