function varargout = kaiserwin(this, varargin)
%KAISERWIN   Design a filter using a kaiser window.
%   KAISERWIN(D) Design a filter using a kaiser window and the
%   specifications in the object D.

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/21 16:30:15 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'kaiserwin', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
