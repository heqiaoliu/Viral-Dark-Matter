function setData(this,varargin) 
% SETDATA  Overloaded setData method for timestability object
%
 
% Author(s): A. Stothert 06-July-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:32 $

if isempty(this.Data)
   %Data object not yet instantiated.
   return
end

%Map properties
idx = 1:numel(varargin);
idxN = find(strcmpi(varargin,'steadystatevalue'));
if ~isempty(idxN)
   this.steadystatevalue = varargin{idxN+1};
   idx = setdiff(idx,[idxN, idxN+1]);
end
idxN = find(strcmpi(varargin,'t0'));
if ~isempty(idxN)
   this.t0 = varargin{idxN+1};
   idx = setdiff(idx,[idxN, idxN+1]);
end
idxN = find(strcmpi(varargin,'absTol'));
if ~isempty(idxN)
   this.absTol = varargin{idxN+1};
   idx = setdiff(idx,[idxN, idxN+1]);
end

if ~isempty(idx)
   this.Data.setData(varargin{idx})
end