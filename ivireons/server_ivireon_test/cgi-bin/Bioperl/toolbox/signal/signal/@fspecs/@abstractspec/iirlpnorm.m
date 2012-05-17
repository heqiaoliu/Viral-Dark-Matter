function varargout = iirlpnorm(this,varargin)
%IIRLPNORM   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:19 $

[varargout{1:nargout}] = design(this, 'iirlpnorm', varargin{:});


% [EOF]
