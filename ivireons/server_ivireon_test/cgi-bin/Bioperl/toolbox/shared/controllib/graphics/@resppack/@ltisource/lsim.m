function lsim(this, r)
% Updates lsim plot response data

%  Author(s): James G. owen
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:26 $
SimInput = r.Parent.Input; % @siminput instance
nsys = length(r.Data);
SysData = getPrivateData(this.Model);
if prod(size(SysData))~=nsys
   return  % number of models does not match number of data objects
end
NormalRefresh = strncmp(r.RefreshMode,'normal',1);
[ny,nu] = iosize(SysData(1));

% Retrieve t,u,x0 data
if strcmp(r.Parent.InputStyle,'tiled')
   % If there are insufficient inputs or missing time vectors ->
   % exception
   InputData = SimInput.Data(r.Context.InputIndex); % handle vector
   if NormalRefresh && any(cellfun('isempty',get(InputData,{'Amplitude'})))
      return
   end
   % Get the input data and initial states
   t = InputData(1).Time;
   for ct=nu:-1:1
      u(:,ct) = InputData(ct).Amplitude;  % ns-by-nu
   end
else
   t = SimInput.Data.Time;
   u = SimInput.Data.Amplitude;
end
x0 = r.Context.IC;
  
% Update data
for ct = 1:nsys
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Amplitude) && ...
         strcmp(r.View(ct).Visible,'on') && isfinite(SysData(ct))
      Dsys = SysData(ct);
      d = r.Data(ct);
      try
         % Skip if model is NaN or response cannot be computed
         s = warning('query','all');
         warning('off','all');
         d.Amplitude = lsim(Dsys,u,t,x0,SimInput.Interpolation); % @ltidata method
         warning(s);
         [lastmsg lastid] = lastwarn;
         if strcmp(lastid,'control:UnderSampledInput')
             warndlg(lastmsg,'Linear Simulation Tool','modal');
         end
         d.Time = t;
         d.Focus = [t(1) t(end)];
         d.Ts =  Dsys.Ts;
      end
   end
end
