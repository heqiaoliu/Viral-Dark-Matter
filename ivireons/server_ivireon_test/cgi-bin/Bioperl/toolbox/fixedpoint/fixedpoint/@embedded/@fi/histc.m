function varargout =histc(varargin)
%HISTC  Histogram count
%   Refer to the MATLAB HISTC reference page for more information.
%
%   See also HISTC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:48 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

