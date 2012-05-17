function construct(h, varargin);
%CONSTRUCT  Construct multipath axes object.
%
%  Inputs:
%     fig: Figure handle

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:30 $

p = {'FigureHandle', 'ParentHandle', 'Tag', 'MultipathFigParent'};
minNumParams = 2;
error(nargchk(minNumParams+1, length(p)+1, nargin));
set(h, p(1:length(varargin)), varargin);

h.initialize;

h.Constructed = true;
