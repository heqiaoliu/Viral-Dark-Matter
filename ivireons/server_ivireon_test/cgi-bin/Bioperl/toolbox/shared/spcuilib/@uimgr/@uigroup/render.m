function render(h,varargin)
%RENDER Incrementally unrenders and re-renders subgraph.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/01/25 22:47:12 $

% only unrender if we are NOT on the initial render cycle.  this is done as
% a performance enhancement
if ~h.isInitialRenderCycle
    incrUnrender(h);
end
renderCore(h,varargin{:});
h.isInitialRenderCycle = false;


% [EOF]
