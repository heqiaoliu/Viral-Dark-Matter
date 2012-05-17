function varargout =plotmatrix(varargin)
%PLOTMATRIX Draw scatter plots
%   Refer to the MATLAB PLOTMATRIX reference page for more information.
%
%   See also PLOTMATRIX

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:16 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
