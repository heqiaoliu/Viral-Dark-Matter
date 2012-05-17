function varargout = design(this, varargin)
%DESIGN   Design the filter.
%   DESIGN(D, M, VARARGIN) Design the filter using the method in the string
%   M on the specs D.  VARARGIN is passed to M.

%   Author(s): J. Schickler
%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/03/31 00:00:11 $

if nargout
    varargout{1} = superdesign(this, varargin{:});
else
    superdesign(this, varargin{:});
end

% [EOF]
