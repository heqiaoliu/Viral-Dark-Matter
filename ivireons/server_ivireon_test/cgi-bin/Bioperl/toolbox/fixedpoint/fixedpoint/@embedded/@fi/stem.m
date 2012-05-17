function varargout =stem(varargin)
%STEM   Plot discrete sequence data
%   Refer to the MATLAB STEM reference page for more information.
%
%   See also STEM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:40 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
