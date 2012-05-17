function varargout = emlcprivate(varargin)
%EMLCPRIVATE EMLC run-time support

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.10.5 $  $Date: 2009/05/14 16:53:05 $

if nargin < 1, return; end
cmd = varargin{1};
switch cmd
    case 'callfcn'
        varargout = cell(1,nargout);
        [varargout{:}] = feval(varargin{2},varargin{3:end});
    case 'callproc'
        feval(varargin{2},varargin{3:end});
    otherwise
        if nargout > 0
            varargout = cell(1,nargout);
            [varargout{:}] = feval(varargin{1},varargin{2:end});
        else
            feval(varargin{1},varargin{2:end});
        end
end