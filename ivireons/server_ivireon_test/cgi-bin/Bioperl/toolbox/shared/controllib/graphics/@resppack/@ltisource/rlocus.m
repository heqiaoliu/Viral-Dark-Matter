function rlocus(this,r,varargin)
%RLOCUS   Computes or updates root locus data.

%  Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:35 $
nsys = length(r.Data);
SysData = getPrivateData(this.Model);
if numel(SysData)~=nsys
   return  % number of models does not match number of data objects
end
NormalRefresh = strncmp(r.RefreshMode,'normal',1);

% Get new data from the @ltisource object.
for ct=1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Roots) && ...
         strcmp(r.View(ct).Visible,'on') && isfinite(SysData(ct))
      Dsys = SysData(ct);
      d = r.Data(ct);
      try
         if nargin>=3 || NormalRefresh
            [Roots,Gains,Info] = rlocus(Dsys,varargin{:});
            % Focus
            [d.XFocus,d.YFocus] = rloclims(Roots);
         else
            % Reuse the current gain vector for maximum speed
            [Roots,Gains,Info] = rlocus(Dsys,d.Gains);
         end
         % Store in response data object (@rldata instance)
         d.Gains = Gains(:);
         d.Roots = Roots.';
         d.Ts = Dsys.Ts;
         if Info.InverseFlag
            d.SystemZero = Info.Pole;
            d.SystemPole = Info.Zero;
            d.SystemGain = 1/Info.Gain;
         else
            d.SystemZero = Info.Zero;
            d.SystemPole = Info.Pole;
            d.SystemGain = Info.Gain;
         end
      end
   end
end
