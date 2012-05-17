function sv = getSV(H,type)
%GETSV  Compute singular values of frequency response.
%
%   SV = GETSV(H,TYPE) returns the singular values of
%   H, inv(H), I+H, or I+inv(H) for TYPE = 0,1,2,3.

%   Copyright 1986-2010 The MathWorks, Inc.
%  $Revision $  $Date: 2010/02/08 22:46:39 $
[ny,nu,nf] = size(H);
if type==3
   % invert H
   sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   for ct=1:nf,
      H(:,:,ct) = inv(H(:,:,ct));
   end
   clear sw;
   type = 2;
end

% Compute singular values
sv = zeros(min(ny,nu),nf);
heye = eye(nu);
for ct=1:nf,
   % Derive appropriate frequency response based on type
   h = H(:,:,ct);
   if type==2
      % Use I+H
      h = heye + h;
   end
   % Compute singular values
   if any(isnan(h(:)))
      sv(:,ct) = NaN;
   elseif any(isinf(h(:)))
      sv(:,ct) = Inf;
   else
      sv(:,ct) = svd(h);
   end
end

% Handle case TYPE=1
if type==1,
   % Singular values of inv(H) are the reciprocals of those of SYS
   zsv = (sv==0);    % zero SV
   if any(zsv),
      ctrlMsgUtils.warning('Control:analysis:InfiniteFreqResp')
   end
   sv(zsv) = Inf;
   idx = find(~zsv);
   sv(idx) = 1./sv(idx);
   sv = flipud(sv);
end

