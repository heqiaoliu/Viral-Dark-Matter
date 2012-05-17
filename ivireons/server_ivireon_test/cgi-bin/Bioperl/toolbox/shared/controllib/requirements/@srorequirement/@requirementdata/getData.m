function [out,varargout] = getData(this,varargin) 
% GETDATA  method to retrieve data from requirementdata object
%
 
% Author(s): A. Stothert 28-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:30 $

out = localGetProp(varargin{1},this);
varargout = cell(numel(varargin)-1,1);
for ct = 2:numel(varargin)
   varargout{ct} = localGetProp(varargin{ct},this);
end

%--------------------------------------------------------------------------
function out = localGetProp(Prop,this)
%Sub-function to return object property.

switch lower(Prop)
   case 'xdata'
      out = this.xCoords;
   case 'ydata'
      out = this.yCoords;
   case 'weight'
      out = this.Weight;
   case 'xunits'
      out = this.xUnits;
   case 'yunits'
      out = this.yUnits;
   case 'type'
      out = this.Type;
   otherwise
      out = [];
end
