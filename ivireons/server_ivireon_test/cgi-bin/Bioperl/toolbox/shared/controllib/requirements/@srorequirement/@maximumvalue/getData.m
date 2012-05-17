function [out,varargout] = getData(this,varargin)
% GETDATA  Method to retrieve data from maximumvalue object
%
 
% Author(s): A. Stothert 23-Aug-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:02 $

out = [];
varargout = cell(numel(varargin)-1,1);

%Map properties
idxN = find(strcmpi(varargin,'maximumvalue'));
%Get maximum value properties
if any(idxN) 
   outN = this.Data.getData('xdata');
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
