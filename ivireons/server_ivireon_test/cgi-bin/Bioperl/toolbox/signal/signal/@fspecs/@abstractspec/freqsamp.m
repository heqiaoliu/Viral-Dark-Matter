function varargout = freqsamp(this,varargin)
%FREQSAMP   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:15 $

[varargout{1:nargout}] = design(this, 'freqsamp', varargin{:});


% [EOF]
