function setData(this,varargin) 
% SETDATA  method to set object data properties. Includes consistency
% checking
%
 
% Author(s): A. Stothert 28-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:44 $

narg = numel(varargin);
if rem(narg,2)
   ctrlMsgUtils.error('Controllib:general:CompletePropertyValuePairs','srorequirement/piecewisedata/setData')
end

%Extract specific arguments and determine the number of edges for the
%constraint. The number of edges can only change when all data is passed.
nEdge       = [];
nEdgeChange = true;
[inX,haveX] = localFindProp('xdata',2,varargin{:});
if ~haveX 
   nEdge       = size(this.getData('xdata'),1); 
   nEdgeChange = false;
end
[inY,haveY] = localFindProp('ydata',2,varargin{:});
if ~haveY
   nEdge       = size(this.getData('ydata'),1); 
   nEdgeChange = false;
end
[inWeight,haveWeight] = localFindProp('weight',1,varargin{:});
if ~haveWeight
   nEdge       = size(this.getData('Weight'),1); 
   nEdgeChange = false;
end
[inLinked,haveLinked]  = localFindProp('linked',2,varargin{:});
if ~haveLinked
   nEdge       = size(this.getData('Linked'),1)+1;
   nEdgeChange = false;
end
[inOpenEnd,haveOpenEnd] = localFindProp('openend',2,varargin{:});
inXUnits  = ''; %Default, no change
inYUnits  = ''; %Default, no change
inType    = ''; %Default, no change
idx = find(strcmpi('xunits',varargin));
if ~isempty(idx), inXUnits = varargin{idx+1}; end
idx = find(strcmpi('yunits',varargin));
if ~isempty(idx), inYUnits = varargin{idx+1}; end
idx = find(strcmpi('type',varargin));
if ~isempty(idx), inType = varargin{idx+1}; end

%Perform consistency checking
if nEdgeChange
   %Passed all arguments and have potential change in number of edges
   nEdge = size(inX,1);
   if  size(inY,1) ~= nEdge || size(inWeight,1) ~= nEdge || ...
         size(inLinked,1)+1  ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errSameNumberOfRows')
   end
else
   %Have subset of arguments
   if haveX && size(inX,1) > 0 && size(inX,1) ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','xdata',nEdge)
   end
   if haveY && size(inY,1) > 0 && size(inY,1) ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','ydata',nEdge)
   end
   if haveWeight && size(inWeight,1) > 0 && size(inWeight,1) ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','weight',nEdge)
   end
   if haveLinked && size(inLinked,1) > 0 && size(inLinked,1) ~= nEdge -1
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','linked',nEdge-1)
   end
end

%Ready to set the new data values
if haveX, this.xCoords = inX; end
if haveY, this.yCoords = inY; end
if haveWeight, this.Weight = inWeight; end
if haveLinked, this.Linked = inLinked; end
if ~isempty(inXUnits), this.xUnits = inXUnits; end
if ~isempty(inYUnits), this.yUnits = inYUnits; end
if ~isempty(inType), this.Type = inType; end
if haveOpenEnd, this.OpenEnd = inOpenEnd; end

%Notify listeners that data has changed
this.send('DataChanged')

%--------------------------------------------------------------------------
function [inValue,haveValue] = localFindProp(Prop,expectedDim,varargin)
%Sub-function to find property in property value vector

idx = find(strcmpi(Prop,varargin));
haveValue = ~isempty(idx);
if haveValue
   inValue = varargin{idx+1};
   if ~islogical(inValue)&&(~isnumeric(inValue) || ~all(isfinite(inValue(:))))
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errPropertyFiniteNumeric',Prop)  
   end
   if numel(size(inValue)) > 2
      ctrlMsgUitls.error('Controllib:graphicalrequirements:err2DData')
   end
   if size(inValue,2) ~= expectedDim
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errColumnSize',Prop,expectedDim)
   end
else 
   inValue = [];
end
