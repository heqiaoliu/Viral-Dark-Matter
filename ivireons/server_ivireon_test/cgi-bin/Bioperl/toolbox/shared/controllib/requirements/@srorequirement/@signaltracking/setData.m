function setData(this,varargin) 
% SETDATA  Method to set data for a signaltracking requirement.
%
 
% Author(s): A. Stothert 06-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:02 $

%Map properties
idx = strcmpi(varargin,'time');
if any(idx), varargin{idx} = 'xdata'; end
idx = strcmpi(varargin,'value');
if any(idx), varargin{idx} = 'ydata'; end
idx = strcmpi(varargin,'weight');
if any(idx), varargin{idx} = 'weight'; end

iX = localFindProp('xdata',varargin{:});
iY = localFindProp('ydata',varargin{:});
iW = localFindProp('weight',varargin{:});

if ~isempty(iX) && ~isempty(iY) && ~isempty(iW)
   %Have all arguments
   varargin = {varargin{:}, ...
      'linked', false(size(iX,1),1)};
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
