function nodes = getChildren(this, varargin)
% GETCHILDREN Returns the handles of the nodes children

% Copyright 2004-2005 The MathWorks, Inc.

nodes = this.find('-depth',1,varargin{:});
nodes(nodes==this) = [];
