function varargout =comet(varargin)
%COMET  Create 2-D comet plot
%   Refer to the MATLAB COMET reference page for more information.
%
%   See also COMET

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:15 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
