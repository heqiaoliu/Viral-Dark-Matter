function updatePanel(this,varargin)
%SimulinkTsArraynode panel update.

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:59:54 $

%Refresh the plot
this.syncPlotInfo(varargin{:});

%Update own table's time entry
this.tstable_timevectorupdate(varargin{:});

%Note: simulinkTsParentNode's panels are updated directly by the
%Timeseries's own simulinkTsNode Panel.



% 
% V = varargin;
% if nargin>1 && ischar(V{1}) && strcmpi(V{1},'time_vector_change')
%     this.tstable_timevectorupdate(V{2:3});
%     %update the parent time-info column
%     this.up.updatePanel('time_vector_change',this,V{3});
% else
%     this.syncPlotInfo;
%     this.tstable;
%     %explicitly update the immediate parent node
%     this.up.updatePanel(V{:});
% end
% 
