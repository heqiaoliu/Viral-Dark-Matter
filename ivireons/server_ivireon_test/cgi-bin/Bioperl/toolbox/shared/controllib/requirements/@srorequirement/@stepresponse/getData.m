function [out,varargout] = getData(this,varargin) 
% GETDATA  method to return data property of a requirement object
%
 
% Author(s): A. Stothert 16-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:09 $

out = this.Data.getData(varargin{1});
if strcmpi(varargin{1},'weight')
   out = localAddEndWeights(this,out);
end
varargout = cell(numel(varargin)-1,1);
for ct=2:numel(varargin)
   tmp = this.Data.getData(varargin{ct});
   if strcmpi(varargin{ct},'weight')
      tmp = localAddEndWeights(this,tmp);
   end
   varargout{ct-1} = tmp;
end

%--------------------------------------------------------------------------
function weight = localAddEndWeights(this,weight)
%Sub routine to add weights for projected edges

OpenEnd = this.Data.getData('OpenEnd');
%Add weights for extended upper and lower bounds
if OpenEnd(1), weight = [weight(1); weight(1); weight]; end
if OpenEnd(2), weight = [weight; weight(end); weight(end)]; end
