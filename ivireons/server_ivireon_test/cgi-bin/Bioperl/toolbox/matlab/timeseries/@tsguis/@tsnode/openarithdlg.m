function openarithdlg(h,manager,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Optional argument is the name of the selected time series
if ~isempty(h.getParentNode)
    openarithdlg(h.getParentNode,manager,varargin{:})
end