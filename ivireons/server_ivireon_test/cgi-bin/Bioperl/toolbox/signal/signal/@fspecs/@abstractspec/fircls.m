function varargout = fircls(this, varargin)
%FIRCLS   Design a constrained least-squares filter.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:36:19 $

[varargout{1:nargout}] = design(this, 'fircls', varargin{:});