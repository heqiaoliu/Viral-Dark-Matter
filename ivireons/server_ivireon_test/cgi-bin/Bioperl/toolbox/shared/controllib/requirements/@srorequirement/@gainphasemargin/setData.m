function setData(this,varargin) 
% SETDATA  Enter a description here!
%
 
% Author(s): A. Stothert 06-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:54 $

if isempty(this.Data)
   %Data object not yet instantiated.
   return
end

%Map properties
idxG = find(strcmpi(varargin,'gainmargin'));
idxP = find(strcmpi(varargin,'phasemargin'));
if ~isempty(idxG) && ~isempty(idxP)
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errGainOrPhaseMargin')
end
if isempty(idxG) && ~isempty(idxP)
   xdata = varargin{idxP+1};
   this.Data.setData('xData',xdata)
end
if isempty(idxP) && ~isempty(idxG)
   xdata = varargin{idxG+1};
   this.Data.setData('xData',xdata)
end

idx = 1:numel(varargin);
if ~isempty(idxG), idx = setdiff(idx,[idxG, idxG+1]); end;
if ~isempty(idxP), idx = setdiff(idx,[idxP, idxP+1]); end;

this.Data.setData(varargin{idx})


