function varargout =coneplot(varargin)
%CONEPLOT Plot velocity vectors as cones in 3-D vector field
%   Refer to the MATLAB CONEPLOT reference page for more information.
%
%   See also CONEPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:18 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
