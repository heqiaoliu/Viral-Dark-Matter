function varargout = ifir(this, varargin)
%IFIR    Design an two-stage equiripple filter.

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:18 $

[varargout{1:nargout}] = design(this, 'ifir', varargin{:});

% [EOF]
