function this = TunedBlockSnapshotFolder(label)
% TUNEDBLOCKSNAPSHOTFOLDER Constructor for @TunedBlockSnapshotFolder class

% Author(s): John Glass
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:38:25 $

% Create class instance
this = controlnodes.DesignSnapshotFolder;

if nargin == 0
  % Call when reloading object
  return
end

this.Label = label;
this.AllowsChildren = true;
this.Editable = false;
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'data_folder.gif');
this.Status   = xlate('Maintain your previous design snapshots.');
