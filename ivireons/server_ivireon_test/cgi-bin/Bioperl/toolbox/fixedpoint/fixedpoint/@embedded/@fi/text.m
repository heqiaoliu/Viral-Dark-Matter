function varargout =text(varargin)
%TEXT   Create text object in current axes
%   Refer to the MATLAB TEXT reference page for more information.
%
%   See also TEXT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:52 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
