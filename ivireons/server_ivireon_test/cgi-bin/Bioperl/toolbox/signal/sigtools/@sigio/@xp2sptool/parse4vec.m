function varargout = parse4vec(this, varargin)
%PARSE4VEC   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:51 $

if nargout
    [varargout{1:nargout}] = parse4obj(this, varargin{:});
else
    parse4obj(this, varargin{:});
end

% [EOF]
