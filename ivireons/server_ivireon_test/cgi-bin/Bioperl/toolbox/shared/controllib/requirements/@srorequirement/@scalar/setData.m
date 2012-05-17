function setData(this,varargin) 
% SETDATA  method to set data properties of a requirement object
%
 
% Author(s): A. Stothert 06-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:47 $

iX = localFindProp('value',varargin{:});

if ~isempty(iX)
   %Map value property to xdata
   varargin = {'xdata',iX};
end

if ~isempty(this.Data)
   this.Data.setData(varargin{:})
end

%--------------------------------------------------------------------------
function inValue = localFindProp(Prop,varargin)
%Sub-function to find property in property value vector

idx = find(strcmpi(Prop,varargin));
if ~isempty(idx)
   inValue = varargin{idx+1};
else
   inValue = [];
end
