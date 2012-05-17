function [out,varargout] = getData(this,varargin)
% GETDATA  Method to retieve data from timestability object
%
 
% Author(s): A. Stothert 06-July-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:29 $

out = [];
varargout = cell(numel(varargin)-1,1);

%Map properties
idxN = find(strcmpi(varargin,'steadystatevalue'));
if any(idxN) 
   outN = this.steadystatevalue;
   if idxN(1) == 1, 
      out = outN;
   else
      varargout{idxN-1} = outN;
   end
end
idxN = find(strcmpi(varargin,'t0'));
if any(idxN) 
   outN = this.t0;
   if idxN(1) == 1, 
      out = outN;
   else
      varargout{idxN-1} = outN;
   end
end
idxN = find(strcmpi(varargin,'absTol'));
if any(idxN) 
   outN = this.absTol;
   if idxN(1) == 1, 
      out = outN;
   else
      varargout{idxN-1} = outN;
   end
end

%Get rest of properties
if isempty(out)
   out = this.Data.getData(varargin{1});
end
for ct=2:numel(varargin)
   if isempty(varargout{ct-1})
      varargout{ct-1} = this.Data.getData(varargin{ct});
   end
end