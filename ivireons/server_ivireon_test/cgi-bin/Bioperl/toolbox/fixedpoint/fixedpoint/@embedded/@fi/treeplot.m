function varargout =treeplot(varargin)
%TREEPLOT Plot picture of tree
%   Refer to the MATLAB TREEPLOT reference page for more information.
%
%   See also TREEPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:56 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
