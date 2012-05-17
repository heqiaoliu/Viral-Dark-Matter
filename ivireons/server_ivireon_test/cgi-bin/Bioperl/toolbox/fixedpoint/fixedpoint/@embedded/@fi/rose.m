function varargout =rose(varargin)
%ROSE   Create angle histogram
%   Refer to the MATLAB ROSE reference page for more information.
%
%   See also ROSE

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:26 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});