function Dout = setIODelay(D,iod)
% Maps I/O delays to internal delays.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:50 $
Delay = D.Delay;
if D.Ts~=0
   Niod = round(iod);
   NotInt = (abs(Niod-iod)>1e3*eps*iod);
   if any(NotInt(:))
       ctrlMsgUtils.error('Control:ltiobject:ltiProperties04','ioDelay')
   else
      iod = Niod;
   end
end
   
% Build nominal model with all delays set to zeros
if ~isempty(Delay.Internal)
   % RE: Assumes all internal delays are I/O delays
   [D.a,D.b,D.c,D.d] = getABCDE(D);
end
[ny,nu] = size(D.d);
D.Delay.Input = zeros(nu,1);
D.Delay.Output = zeros(ny,1);
D.Delay.Internal = zeros(0,1);

% Consistency check
if isscalar(iod)
   iod = repmat(iod,ny,nu);
elseif ~isequal(size(iod),[ny nu])
   ctrlMsgUtils.error('Control:ltiobject:ltiProperties03')
end

% Decompose IOD to minimize overall number of internal delays (g389509)
% If IOD is reducible to input+output delays, this cuts the number of
% internal delays from NY*NU to NY+NU.
% Note: Give preference to output delays when NU=NY (fewer extra states in C2D)
ZeroTol = 1e3*eps*norm(iod,1);
if ny>nu
   id = min(iod,[],1);  iod = iod-id(ones(ny,1),:);
   od = min(iod,[],2);  iod = iod-od(:,ones(nu,1));
else
   od = min(iod,[],2);  iod = iod-od(:,ones(nu,1));
   id = min(iod,[],1);  iod = iod-id(ones(ny,1),:);  
end
iod(iod<ZeroTol) = 0; % beware of residual o(eps) delays due to rounding errors

% Construct realization of remaining I/O delays
if norm(iod,1)==0
   % Nothing to do if all zero
   Dout = D;
elseif ny>=nu
   % Realize by horizontal concatenation of ny-by-1 models
   Dout = utFoldDelay(getsubsys(D,':',1,'smin'),[],iod(:,1));
   for ct=2:nu
      Dsub = utFoldDelay(getsubsys(D,':',ct,'smin'),[],iod(:,ct));
      Dout = iocat(2,Dout,Dsub);
   end
else
   % Realize by vectical concatenation of 1-by-nu models
   Dout = utFoldDelay(getsubsys(D,1,':','smin'),iod(1,:).',[]);
   for ct=2:ny
      Dsub = utFoldDelay(getsubsys(D,ct,':','smin'),iod(ct,:).',[]);
      Dout = iocat(1,Dout,Dsub);
   end
end  

% Add factored-out portion of IOD
Dout = utFoldDelay(Dout,id.',od);

% Restore original input and output delays
Dout.Delay.Input = Delay.Input;
Dout.Delay.Output = Delay.Output;

% Note: Avoiding repeated state names is too tricky because of 'smin' flag
% above. Just use state names returned by GETSUBSYS and IOCAT
