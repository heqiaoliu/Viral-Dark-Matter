function UpdateFlag = fillresp(this, r, Tfinal)
%FILLRESP  Update data to span the current X-axis range.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:16 $

UpdateFlag = false;
if ~isfield(r.Context,'Type')
   return
else
   RespType = r.Context.Type;   
end

% Check for missing data
for ct=1:length(r.Data)
   rdata = r.Data(ct);
   ns = size(rdata.Amplitude,1);
   UpdateFlag = (ns>1 && rdata.Time(ns-1)<Tfinal && ...
      (rdata.Time(ns)<Tfinal || ~all(isfinite(rdata.Amplitude(ns,:)))));
   if UpdateFlag
      break
   end
end

% Plot-type-specific settings
if UpdateFlag
   switch RespType
   case {'step', 'impulse'}
      x0 = [];
   case 'initial'
      x0 = r.Context.IC;
   end
   
   % Extend response past Tfinal
   SysData = getPrivateData(this.Model);
   for ct=1:length(r.Data)
      d = r.Data(ct);
      [d.Amplitude, d.Time] = timeresp(SysData(ct), RespType, 1.5*Tfinal, x0);
   end
end
