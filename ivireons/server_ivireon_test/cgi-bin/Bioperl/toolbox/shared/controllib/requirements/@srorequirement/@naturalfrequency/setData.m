function setData(this,varargin) 
% SETDATA  Overloaded setData method for naturalfrequency object
%
 
% Author(s): A. Stothert 31-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:14 $

if isempty(this.Data)
   %Data object not yet instantiated.
   return
end

%Map properties
idx = 1:numel(varargin);
idxN = find(strcmpi(varargin,'naturalfrequency'));
if ~isempty(idxN)
   xdata = varargin{idxN+1};
   this.Data.setData('xData',xdata)
   idx = setdiff(idx,[idxN, idxN+1]);
end

if ~isempty(idx)
   this.Data.setData(varargin{idx})
end
