function d = utadddata(h, d, thisSignal, varargin)
%UTADDDATA

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/14 16:54:08 $

dIdx = numel(d) + 1;
d(dIdx).isMdlRef = false;
d(dIdx).ModelReference = '';
pthItem  = '';
if(nargin > 3)
  d(dIdx).isMdlRef = varargin{1};
  if(d(dIdx).isMdlRef)
    d(dIdx).ModelReference = varargin{2};
    pthItem = ['(' varargin{3} ')'];
  end
end
d(dIdx).Path = thisSignal.BlockPath;
% Don't create a Simulink.Timeseries again if it is already a
% Simulink.Timeseries.
if(strcmp(thisSignal.ParentName, 'Workspace')) && ~isa(thisSignal,'Simulink.Timeseries')
  %Multi-D data
  if(ndims(thisSignal.Data) > 2)
    copy = thisSignal.TsValue;
    copy = copy';
    copy = Simulink.Timeseries(copy);
    copy.Name = thisSignal.Name;
    copy.BlockPath = thisSignal.BlockPath;
    copy.PortIndex = thisSignal.PortIndex;
    copy.SignalName = thisSignal.SignalName;
    copy.ParentName = thisSignal.ParentName;
    thisSignal = copy;
    copy = [];
  end
end
d(dIdx).Signal = thisSignal;
prt_name = num2str(thisSignal.PortIndex);
% Fold port# and Output signal name if feature is turned on
if h.featureportsigname
    blk = locgetblock(d(dIdx));
    if ~isempty(blk)
      d(dIdx).PathItem = [pthItem fxptds.getPortSignalName(prt_name,blk)];
    end
else
    % revert to old behavior if feature is turned off
    d(dIdx).PathItem = [pthItem prt_name];
end

%-----------------------------------------------------------------------
function blkobj = locgetblock(d)
% get the block object of the block on which signal is logged.
blkobj = [];
try
    % Simulink block logged data
    blkobj = get_param(d.Signal.BlockPath,'Object');
catch e %#ok<NASGU>
    % Modelreference logged data
    if d.isMdlRef
       blkobj = fxptds.getMdlRefObject(d);
    else
       % stateflow logged data
       sfobj  = fxptds.getSfObject(d);
       if isempty(sfobj) ; return; end
       sfobj = sfobj.getParent;
       if isequal(class(sfobj),'Stateflow.Chart')
          blkobj = get_param(sfobj.Path,'Object'); % return the parent stateflow object
       else
          blkobj = get_param(sfobj.Chart.Path,'Object');
       end
    end
end
%-----------------------------------------------------------------------
    % [EOF]
