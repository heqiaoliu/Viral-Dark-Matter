function h = colltransaction(varargin)
% Returns instance of @nodetransaction class.
% This represents the transaction object for strcutural changes on nodes - 
% adding and removing time series or tscollection members, or Simulink data
% logs. Modifications within a member object (such as changing time or
% timeseries data) are handled by the tsguis.transaction object.
%
% Renaming a node is not an undoable action.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:15:53 $

h = tsguis.nodetransaction;

if nargin>1
    h.ObjectsCell = varargin{1}; % a cell array of timeseries/tscollection objects
    h.Action = varargin{2}; % a string indicating if the members were 'renamed', 'added', or 'removed'
    h.ParentNodeHandle = varargin{3}; % handle to the parent node containing the 
end
