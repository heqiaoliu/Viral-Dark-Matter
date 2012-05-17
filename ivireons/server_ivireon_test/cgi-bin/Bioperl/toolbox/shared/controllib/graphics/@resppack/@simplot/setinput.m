function setinput(this,t,u,varargin)
%SETINPUT  Defines driving input data for SIMPLOTs.

%  Author(s): P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:55 $

% RE: Only used for LSIM-type plots (multi-output response data)
if prod(this.AxesGrid.Size(2))>1
   ctrlMsgUtils.error('Controllib:plots:simplot1')
end
Ny = this.AxesGrid.Size(1);

% Error checking on t,u
t = t(:);
Ns = length(t);
uSize = size(u);
if ~isreal(u) || length(uSize)>2
   ctrlMsgUtils.error('Controllib:plots:simplot2')
elseif ~any(uSize==Ns)
   ctrlMsgUtils.error('Controllib:plots:simplot3')
elseif uSize(1)~=Ns
   u = u.';
end
Nu = size(u,2);

% Adjust input width
setInputWidth(this,Nu);

% Write data and initialize views
Axes = getaxes(this);
rInput = this.Input;
if strcmp(this.InputStyle,'tiled')
   for ct=1:Nu
      rInput.Data(ct).Time = t;
      rInput.Data(ct).Amplitude = u(:,ct);
      rInput.Data(ct).Focus = [t(1) t(end)];
   end
else
   rInput.Data.Time = t;
   rInput.Data.Amplitude = u;
   rInput.Data.Focus = [t(1) t(end)];
end
if length(varargin)
   set(rInput.Data,varargin{:});
end
   
% Redraw plot (ensures proper update of overall scene)
draw(this)