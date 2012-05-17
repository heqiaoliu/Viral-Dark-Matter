function varargout =scatter3(varargin)
%SCATTER3 Create 3-D scatter or bubble plot
%   Refer to the MATLAB SCATTER3 reference page for more information.
%
%   See also SCATTER3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:28 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
