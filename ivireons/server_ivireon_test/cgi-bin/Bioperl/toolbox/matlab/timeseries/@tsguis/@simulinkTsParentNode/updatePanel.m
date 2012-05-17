function updatePanel(this,varargin)
%% simulinkTsParentNode panel update

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:16:55 $


%Update the time entry for the timeseries modified
this.tstable_timevectorupdate(varargin{:});


%% Update the timeseries editing table
%this.synctable;
% V = varargin;
% % process name change and time-vector-change as special events.
% if nargin>1 && ischar(V{1}) && strcmpi(V{1},'time_vector_change')
%     this.tstable_timevectorupdate(V{2:3});
% else
%     %call tstable method of the simulinkTsParentNode which will render a
%     %tabular list of members
%     this.tstable(V{:});
% end

% %explicitly update the immediate parent node
% myparent = this.up;
% if isa(myparent,' tsexplorer.node')
%     myparent.updatePanel(V{:});
% end
