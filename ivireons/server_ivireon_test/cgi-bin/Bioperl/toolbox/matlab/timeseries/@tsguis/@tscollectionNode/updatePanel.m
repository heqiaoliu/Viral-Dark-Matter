function updatePanel(this,varargin)
%% tscoolectionNode panel update

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:02:46 $

%% Update the timeseries editing table
%this.synctable;
V = varargin;
if nargin>1 && ischar(V{1}) && strcmp(V{1},'child_rename')
    this.tstable_childnameupdate;
    V = {}; % do not pass the "child_rename" flag to the parent automatically.
else
    this.tstable(V{:});
end

myparent = this.up;
if isa(myparent,'tsexplorer.node')
    %explicitly update the immediate parent node
    myparent.updatePanel(V{:});  
end

