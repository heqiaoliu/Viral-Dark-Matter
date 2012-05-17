function [out,varargout] = getData(this,varargin) 
% GETDATA  method to return data property of a requirement object
%
 
% Author(s): A. Stothert
%   Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:13 $

%Map properties
idx = strcmpi('frequency',varargin);
if any(idx), varargin{idx} = 'xdata'; end
idx = strcmpi('magnitude',varargin);
if any(idx), varargin{idx} = 'ydata'; end

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

switch lower(this.Orientation)
   case {'vertical','horizontal'}
      OpenEnd = this.Data.getData('OpenEnd');
      if OpenEnd(1), weight = [weight(1); weight]; end
      if OpenEnd(2), weight = [weight; weight(end)]; end
   case 'both'
      weight = [weight(1); weight; weight(end)];
end
