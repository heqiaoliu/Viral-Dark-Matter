function this = loadobj(SavedObj)
% Display method for @dataset class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:44 $

% RE: SaveObj is either a dataset object, or a struct containing the 
%     saved information (note: only values that differ from the 
%     FactoryValue get saved on disk)
try
   Version = SavedObj.Version;
catch
   Version = 1;
end

% Copy data
this = hds.dataset;

% Add data variables and copy data
try
   for ct=1:length(SavedObj.Data_)
      % Use name as variable handle may be stale
      this.addvar(SavedObj.Data_(ct).Variable.Name);
   end
   this.Data_ = SavedObj.Data_;
end

% Add links variables and copy linked data
try
   for ct=1:length(SavedObj.Children_)
      this.addlink(SavedObj.Children_(ct).Alias.Name);
   end
   this.Children_ = SavedObj.Children_;
end

% Set grid
try
   if ~isempty(SavedObj.Grid_)
      this.setgrid(SavedObj.Grid_.Variable)
      this.Grid_ = SavedObj.Grid_;
   end
end
