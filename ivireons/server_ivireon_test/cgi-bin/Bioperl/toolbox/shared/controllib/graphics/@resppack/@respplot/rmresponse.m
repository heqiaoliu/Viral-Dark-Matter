function rmresponse(this, r)
%RMRESPONSE  Removes a response from the current response plot.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:32 $

% Validate input argument
if ~ishandle(r)
    ctrlMsgUtils.error('Controllib:plots:rmwave1','resppack.respplot.rmresponse')
end

% Find position of @response object
idx = find(this.Responses == r);

% Delete @response object
if ~isempty(idx)
  delete(this.Responses(idx));
  this.Responses = this.Responses([1:idx-1, idx+1:end]);
end

% Update limits
this.AxesGrid.send('ViewChanged')
