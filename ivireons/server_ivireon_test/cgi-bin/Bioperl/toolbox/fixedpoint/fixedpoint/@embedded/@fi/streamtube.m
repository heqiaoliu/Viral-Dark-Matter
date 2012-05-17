function varargout =streamtube(varargin)
%STREAMTUBE Create 3-D stream tube plot
%   Refer to the MATLAB STREAMTUBE reference page for more information.
%
%   See also STREAMTUBE

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:44 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
