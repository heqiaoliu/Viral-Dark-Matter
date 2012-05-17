function varargout = design(this, varargin)
%DESIGN   Design the filter and return an object.

%   Author(s): R. Losada
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:42:18 $

[varargout{1:nargout}] = designcoeffs(this, varargin{:});

% Put it into a structure.
Hd = createobj(this,varargout{1});

Hd.setfmethod(this);

varargout{1} = Hd;

% [EOF]
