function [RealTimeData,idxSys] = moveInit(this)
%MOVEINIT  Initializes dynamic update.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2006/06/20 20:03:29 $

rv = handle([]);
dsL = handle([]);  % SourceChanged listeners for hidden responses
isVisible = false(size(this.Systems));
for v=cat(1,this.PlotCells{:})'
   if strcmp(v.Visible,'off')
      rh = v.Responses;
   else
      rvis = strcmp(get(v.Responses,'Visible'),'on');
      isVisible = isVisible | rvis;
      % Visible responses go to quick update mode
      % RE: RefreshFocus used to redefine t in time plots for optimal perf.
      xlim = getxlim(v.Axes,1);
      VisResp = v.Responses(rvis);
      set(VisResp,'RefreshMode','quick','RefreshFocus',xlim);
      % Update set of visible and hidden responses
      rv = [rv ; v.Responses(rvis)];  
      rh = v.Responses(~rvis);
   end
   L = get(rh,{'DataSrcListener'});
   dsL = [dsL ; cat(1,L{:})];
end

% Disable listeners to SourceChanged for hidden resp. (speed optim)
set(dsL,'Enable','off')  

% Store key info
RealTimeData = struct('VisibleResponses',rv, ...
   'DataListener',[], 'HiddenResponseListeners',dsL);

% Indices of visible systems (relative to this.Systems)
idxSys = find(isVisible);  
