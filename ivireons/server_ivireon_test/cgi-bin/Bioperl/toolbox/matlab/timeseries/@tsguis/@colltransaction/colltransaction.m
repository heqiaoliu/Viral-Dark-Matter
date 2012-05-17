function h = colltransaction(varargin)
% Returns instance of @colltransaction class
% this represents the transaction objection for actions on tscollection
% objects - adding and removing time series members. Modifications within
% member objects (such as changing time or timeseries data) are handled by
% the tsguis.transaction object.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:14:48 $


%% Create transaction and set its tsTransaction property to capture
%% operations on the time series object. 

h = tsguis.colltransaction;

if nargin>1
    h.TimeseriesCell = varargin{1}; % a cell array of timeseries objects
    h.WasRemoved = varargin{2}; % a boolean indicating if the members were deleted (1) or added (0)
    h.TscollectionHandle = varargin{3}; % handle to the tscollection object being modified
end
