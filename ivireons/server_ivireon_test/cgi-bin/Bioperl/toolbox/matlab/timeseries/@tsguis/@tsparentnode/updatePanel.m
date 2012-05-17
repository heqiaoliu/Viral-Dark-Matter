function updatePanel(this,varargin)
%% tsparentnode panel update

%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/05/27 14:19:02 $

%% Update the timeseries editing table
%this.synctable;

%explicitly update the immediate parent node
% try-catch only on the tail-end nodes - tsnode, simulinkTsNode
V = varargin;
if nargin>1 && ischar(V{1}) && strcmp(V{1},'child_rename')
    this.tstable_childnameupdate;
    V = {};
elseif ~isempty(V) && isa(V{1},'tsdata.dataChangeEvent')
    if length(varargin)>1
        V = varargin{2:end};
    else
        V = {};
    end
end

this.tstable(V{:});


myparent = this.up;
if isa(myparent,' tsexplorer.node')
    myparent.updatePanel(V{:});
end
