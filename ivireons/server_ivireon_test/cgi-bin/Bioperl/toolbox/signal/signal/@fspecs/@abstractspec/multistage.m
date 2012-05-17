function varargout = multistage(this, varargin)
%MULTISTAGE    Design a multistage equiripple filter.

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:22 $

[varargout{1:nargout}] = design(this, 'multistage', varargin{:});

% [EOF]
