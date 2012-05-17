function varargout = iirls(this,varargin)
%IIRLS   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:37 $

[varargout{1:nargout}] = design(this, 'iirls', varargin{:});


% [EOF]
