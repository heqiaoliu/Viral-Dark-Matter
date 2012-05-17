function [out,varargout] = getData(this,varargin)
% GETDATA  Method to retrieve data for gainphasemargin requirement
%
 
% Author(s): A. Stothert 06-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:48 $

out = [];
varargout = cell(numel(varargin)-1,1);

%Map properties
idxG = find(strcmpi(varargin,'gainmargin'));
idxP = find(strcmpi(varargin,'phasemargin'));
%Get gain/phase properties
if any(idxG) || any(idxP)
   xdata = this.Data.getData('xdata');
   outG = xdata(1);
   outP = xdata(2);
   if idxG(1) == 1, 
      out = outG;
   else
      varargout{idxG-1} = outG;
   end
   if idxP(1) == 1, 
      out = outP;
   else
      varargout{idxP-1} = outP;
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





