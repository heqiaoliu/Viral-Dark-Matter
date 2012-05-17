function [out,varargout] = getData(this,varargin)
% GETDATA  Method to retrieve data for signaltracking requirement.
%
 
% Author(s): A. Stothert 06-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:59 $

%Map properties
idx = strcmpi(varargin,'time');
if any(idx), varargin{idx} = 'xdata'; end
idx = strcmpi(varargin,'value');
if any(idx), varargin{idx} = 'ydata'; end
idx = strcmpi(varargin,'weight');
if any(idx), varargin{idx} = 'weight'; end

out = this.Data.getData(varargin{1});
varargout = cell(numel(varargin)-1,1);
for ct=2:numel(varargin)
   varargout{ct-1} = this.Data.getData(varargin{ct});
end
