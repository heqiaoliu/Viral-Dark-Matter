function setData(this,varargin) 
% SETDATA  method to set data properties of bodegain object
%
 
% Author(s): A. Stothert 23-Aug-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:34 $

%Map properties
idx = strcmpi('frequency',varargin);
if any(idx), varargin{idx} = 'xdata'; end
idx = strcmpi('magnitude',varargin);
if any(idx), varargin{idx} = 'ydata'; end

iX = localFindProp('xdata',varargin{:});
iY = localFindProp('ydata',varargin{:});
iW = localFindProp('weight',varargin{:});
[iL,idx] = localFindProp('linked',varargin{:});

if ~isempty(iX) && ~isempty(iY) && ~isempty(iW) && isempty(iL)
   %Have all arguments but no linked argument, create one with correct size
   if isempty(idx)
      varargin = {varargin{:}, ...
         'linked', false(size(iX,1)-1,2)};
   else
      varargin{idx+1} = false(size(iX,1)-1,2);
   end
end

if ~isempty(this.Data)
   this.Data.setData(varargin{:})
end

%--------------------------------------------------------------------------
function [inValue,idx] = localFindProp(Prop,varargin)
%Sub-function to find property in property value vector

idx = find(strcmpi(Prop,varargin));
if ~isempty(idx)
   inValue = varargin{idx+1};
else
   inValue = [];
end
