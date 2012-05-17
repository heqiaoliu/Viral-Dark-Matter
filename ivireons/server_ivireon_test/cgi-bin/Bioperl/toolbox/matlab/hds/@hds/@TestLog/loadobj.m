function this = loadobj(SavedObj)
% Display method for @TestLog class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:17 $

% RE: SaveObj is either a dataset object, or a struct containing the 
%     saved information (note: only values that differ from the 
%     FactoryValue get saved on disk)
try
   Version = SavedObj.Version;
catch
   Version = 1;
end

% Copy data
this = hds.TestLog;

% Copy storage info
try
   this.Storage = SavedObj.Storage;
end

% Add variables and copy data
try
   for ct=1:length(SavedObj.Data_)
      this.addvar(SavedObj.Data_(ct).Variable);
   end
   this.Data_ = SavedObj.Data_;
end

