function varargout =ezsurfc(varargin)
%EZSURFC Easy-to-use combination surface/contour plotter
%   Refer to the MATLAB EZSURFC reference page for more information.
%
%   See also EZSURFC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:38 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
