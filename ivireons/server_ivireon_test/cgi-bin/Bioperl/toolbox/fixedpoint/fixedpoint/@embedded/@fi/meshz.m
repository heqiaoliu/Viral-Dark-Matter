function varargout =meshz(varargin)
%MESHZ  Create mesh plot with curtain plot
%   Refer to the MATLAB MESHZ reference page for more information.
%
%   See also MESHZ

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:05 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
