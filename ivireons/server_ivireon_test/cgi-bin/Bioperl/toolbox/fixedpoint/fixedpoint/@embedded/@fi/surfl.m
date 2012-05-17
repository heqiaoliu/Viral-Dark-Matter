function varargout =surfl(varargin)
%SURFL  Create surface plot with colormap-based lighting
%   Refer to the MATLAB SURFL reference page for more information.
%
%   See also SURFL

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:50 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
