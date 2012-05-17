function D = pade(D,Ni,No,Nio)
% Pade approximation of delays in FRD models.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:47 $
if ~hasdelay(D)
   return
end
ctrlMsgUtils.warning('Control:transformation:PadeFRD')
Delay = D.Delay;
[ny,nu,nf] = size(D.Response);

% Check arguments
[Ni,No,Nio] = checkPadeOrders(D,Ni,No,Nio);

% Approximate delays
s = 1i * unitconv(D.Frequency,D.FreqUnits,'rad/s');
s = reshape(s,[1 nf]);

if ~isempty(Nio) && any(Delay.IO(:)>0)
   % I/O delays
   R = reshape(D.Response,ny*nu,nf);
   for ct=1:ny*nu
      if Nio(ct)>0 && isfinite(Nio(ct))
         [n,d] = pade(Delay.IO(ct),Nio(ct));
         h = polyval(n,s) ./ polyval(d,s);
         R(ct,:) = R(ct,:) .* h;
      end
   end
   D.Response = reshape(R,ny,nu,nf);
   D.Delay.IO(isfinite(Nio)) = 0;
end

if ~isempty(Ni) && any(Delay.Input>0)
   for ct=1:nu
      if Ni(ct)>0 && isfinite(Ni(ct))
         [n,d] = pade(Delay.Input(ct),Ni(ct));
         h = polyval(n,s) ./ polyval(d,s);
         for cf=1:nf
            D.Response(:,ct,cf) = D.Response(:,ct,cf) * h(cf);
         end
      end
   end
   D.Delay.Input(isfinite(Ni)) = 0;
end

if ~isempty(No) && any(Delay.Output>0)
   for ct=1:ny
      if No(ct)>0 && isfinite(No(ct))
         [n,d] = pade(Delay.Output(ct),No(ct));
         h = polyval(n,s) ./ polyval(d,s);
         for cf=1:nf
            D.Response(ct,:,cf) = D.Response(ct,:,cf) * h(cf);
         end
      end
   end
   D.Delay.Output(isfinite(No)) = 0;
end
