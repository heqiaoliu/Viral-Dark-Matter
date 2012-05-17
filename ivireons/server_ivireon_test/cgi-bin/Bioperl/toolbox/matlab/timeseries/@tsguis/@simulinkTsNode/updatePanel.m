function updatePanel(this,varargin)
%% SimulinkTsnode panel update

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:00:07 $

%% Update the timeseries editing table

if isempty(this.getRoot)
    return
end

this.syncPlotInfo;
%% Send a timeserieschange event 
% Potential listeners are views only.
% note: the pedigree up the tree shall be updated explicitly using the
% updatePanel method. It does not listen to this event. 
this.getRoot.send('timeserieschange');

%Explicitly update the immediate parent node and the root
%simulinkTsParentNode:
this.up.updatePanel(varargin{:}); 
if ~isequal(this.up,this.getParentNode)
    this.getParentNode.updatePanel(varargin{:});
end
