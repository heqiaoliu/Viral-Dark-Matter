function setData(this,varargin) 
% SETDATA  method to set object data properties. Includes consistency
% checking
%
 
% Author(s): A. Stothert 28-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:34 $

narg = numel(varargin);
if rem(narg,2)
   ctrlMsgUtils.error('Controllib:general:CompletePropertyValuePairs','srorequirement/requirementdata/setData')
end

%Extract specific arguments and perform basic error checking
nEdge = [];
inX = localFindProp('xdata',1,varargin{:});
if isempty(inX), nEdge = size(this.getData('ydata'),1); end
inY = localFindProp('ydata',1,varargin{:});
if isempty(inY)&&isempty(nEdge), nEdge = size(this.getData('xdata'),1); end
inWeight = localFindProp('weight',1,varargin{:});
if isempty(inWeight)&&isempty(nEdge), nEdge = size(this.getData('Weight'),1); end

inXUnits = '';
inYUnits = '';
inType = '';
idx = find(strcmpi('xunits',varargin));
if ~isempty(idx), inXUnits = varargin{idx+1}; end
idx = find(strcmpi('yunits',varargin));
if ~isempty(idx), inYUnits = varargin{idx+1}; end
idx = find(strcmpi('type',varargin));
if ~isempty(idx), inType = varargin{idx+1}; end

%Perform consistency checking
if isempty(nEdge)
   %Have all arguments
   if  size(inX,1) ~= size(inY,1) || size(inY,1) ~= size(inWeight,1) 
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errSameNumberOfRows')
   end
else
   %Have subset of arguments
   if size(inX,1) > 0 && size(inX,1) ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','xdata',nEdge)
   end
   if size(inY,1) > 0 && size(inY,1) ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','ydata',nEdge)
   end
   if size(inWeight,1) > 0 && size(inWeight,1) ~= nEdge
      ctrlMsgUtils.error('Controllib:graphicalrequirements:errDataInconsistentRows','weight',nEdge)
   end
end

%Ready to set the new data values
if ~isempty(inX), this.xCoords = inX; end
if ~isempty(inY), this.yCoords = inY; end
if ~isempty(inWeight), this.Weight = inWeight; end
if ~isempty(inXUnits), this.xUnits = inXUnits; end
if ~isempty(inYUnits), this.yUnits = inYUnits; end
if ~isempty(inType), this.Type = inType; end

%Notify listeners that data has changed
this.send('DataChanged')

%--------------------------------------------------------------------------
function inValue = localFindProp(Prop,expectedDim,varargin)
%Sub-function to find property in property value vector

idx = find(strcmpi(Prop,varargin));
if ~isempty(idx)
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
