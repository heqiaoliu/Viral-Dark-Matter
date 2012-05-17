function this = tscollectionNode(varargin)
% tscollectionNode (for tscollection objects) constructor
%
% VARARGIN{1}: Node name
% VARARGIN{2}: Parent handle used for creating a unique node name
%

%   Author(s): Rajiv Singh
%   Copyright 2005-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $ $Date: 2007/12/14 14:55:59 $

% Create class instance
this = tsguis.tscollectionNode;
this.HelpFile = 'ts_collection_cpanel';

% Check input arguments
if nargin == 0 
  this.Label = 'New Child Node';
elseif nargin == 1
  %this.Label = varargin{1};
  set(this,'Label',get(varargin{1},'Name'),'Tscollection',varargin{1})
elseif nargin == 2
  this.Label = this.createDefaultName( varargin{1}, varargin{2} );
else
  error('tscollectionNode:tscollectionNode:noNode',...
      'Node name and an optional parent node handle should be provided')
end

this.AllowsChildren = true;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab','timeseries', ...
                          'arrayviewicon.gif');

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;
