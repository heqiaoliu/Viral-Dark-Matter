function updatePanel(this,varargin)
%% ModelDataLogs panel update

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:15:46 $

% Update own time-info in the table for the timeseries changed
this.tstable_timevectorupdate(varargin{:});






% %% Update the timeseries editing table
% V = varargin;
% if nargin>1 && ischar(V{1}) && strcmpi(V{1},'time_vector_change')
%     this.tstable_timevectorupdate(V{2:3});
%     this.up.updatePanel('time_vector_change',this,V{3});
% else
%     this.tstable;
%     %explicitly update the immediate parent node
%     this.up.updatePanel(V{:});
% end
% 
