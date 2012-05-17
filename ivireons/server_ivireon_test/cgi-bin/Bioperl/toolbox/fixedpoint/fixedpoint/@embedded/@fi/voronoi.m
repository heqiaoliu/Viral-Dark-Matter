function varargout =voronoi(varargin)
%VORONOI Create Voronoi diagram
%   Refer to the MATLAB VORONOI reference page for more information.
%
%   See also VORONOI

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:20:04 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

