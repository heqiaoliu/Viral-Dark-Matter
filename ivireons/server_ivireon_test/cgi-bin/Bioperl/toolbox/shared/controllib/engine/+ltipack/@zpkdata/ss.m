function [Dss,SingularFlag] = ss(D,varargin)
% Conversion to ss

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision $  $Date: 2010/02/08 22:48:20 $

% NOTE: ss(D,'generic') realizes each entry independently and 
% does not take advantage of common denominators (used by
% zpkdata/mtimes)
GenericFlag = (nargin>1);
SingularFlag = false;

% Minimize number of internal delays in realization
Delay = minimizeDelay(D);
iod = Delay.IO;  % RE: each row or col has at least one zero
Ts = D.Ts;

% Conversion starts
[ny,nu] = size(D.k);
if ny==0 || nu==0
   % Empty system
   Dss = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),zeros(ny,nu),[],Ts);
   Dss.Delay.Input = Delay.Input;
   Dss.Delay.Output = Delay.Output;
   
elseif ny==1 && nu==1
   % SISO case
   [a,b,c,d,e] = zpkreal(D.z{1},D.p{1},D.k);
   Dss = ltipack.ssdata(a,b,c,d,e,Ts);
   Dss.Delay.Input = Delay.Input + iod;
   Dss.Delay.Output = Delay.Output;
   
else
   % MIMO case
   % Compute orders for row- and column-oriented realizations
   [ro,co] = getOrder(D);
   
   % Build realization
   if any(iod(:))
      % Map residual I/O delays into internal delays, channel by channel
      if co<=ro
         % Realize each column and concatenate realizations
         for j=1:nu,
            [a,b,c,d,e] = LocalRealizeSingleChannel(D.z(:,j),D.p(:,j),D.k(:,j),GenericFlag);
            Dsub = ltipack.ssdata(a,b,c,d,e,Ts);
            Dsub.Delay.Input = Delay.Input(j);
            Dsub.Delay.Output = Delay.Output + iod(:,j);
            Dsub = utFoldDelay(Dsub,[],iod(:,j));
            if j==1
               Dss = Dsub; 
            else
               Dss = iocat(2,Dss,Dsub);
            end
         end
      else
         % Realize each row and concatenate realizations
         for i=1:ny,
            [a,b,c,d,e] = LocalRealizeSingleChannel(D.z(i,:),D.p(i,:),D.k(i,:),GenericFlag);
            Dsub = ltipack.ssdata(a,b,c,d,e,Ts);
            Dsub.Delay.Input = Delay.Input + iod(i,:).';
            Dsub.Delay.Output = Delay.Output(i);
            Dsub = utFoldDelay(Dsub,iod(i,:).',[]);
            if i==1
               Dss = Dsub;
            else
               Dss = iocat(1,Dss,Dsub1);
            end
         end
      end
      
   else
      % No I/O delays
      if co<=ro
         % Realize each column and concatenate realizations
         a = [];  b = [];  c = zeros(ny,0);  d = zeros(ny,0);  e = [];
         for j=1:nu,
            [aj,bj,cj,dj,ej] = LocalRealizeSingleChannel(D.z(:,j),D.p(:,j),D.k(:,j),GenericFlag);
            [a,b,c,d,e] = ssops('hcat',a,b,c,d,e,aj,bj,cj,dj,ej);
         end
      else
         % Realize each row and concatenate realizations
         a = [];  b = zeros(0,nu);  c = [];  d = zeros(0,nu);  e = [];
         for i=1:ny,
            [ai,bi,ci,di,ei] = LocalRealizeSingleChannel(D.z(i,:),D.p(i,:),D.k(i,:),GenericFlag);
            [a,b,c,d,e] = ssops('vcat',a,b,c,d,e,ai,bi,ci,di,ei);
         end
      end
      Dss = ltipack.ssdata(a,b,c,d,e,Ts);
      Dss.Delay.Input = Delay.Input;
      Dss.Delay.Output = Delay.Output;
   end
   
end


%------------------------- Local Functions ---------------------------

function [a,b,c,d,e] = LocalRealizeSingleChannel(z,p,k,GenericFlag)
% State-space realization of SIMO or MISO ZPK model.
[ny,nu] = size(k);
d = k;  % to pick static gains

% Determine which entries have dynamics
dyn = (cellfun('length',p)+cellfun('length',z)>0 & k~=0);
idyn = find(dyn);
ndyn = length(idyn);

% Compute realization for subset of non-static entries
if ndyn==0
   % Static gain
   a = [];
   b = zeros(0,nu);
   c = zeros(ny,0);
   e = [];
   return
   
elseif ndyn==1
   % SISO case
   [a,bdyn,cdyn,ddyn,e] = zpkreal(z{idyn},p{idyn},k(idyn));

elseif isequal(p{idyn}) && ~GenericFlag
   % Common denominator for entries with dynamics
   [a,bdyn,cdyn,ddyn,e] = zpkrealComDen(z(idyn),p{idyn(1)},k(idyn));

   % Transpose A,B,C,D,E in MISO case and permute to preserve the
   % quasi upper-triangular structure of A (ensures poles of ZPK and 
   % SS models match exactly)
   if ny<nu,
      b0 = bdyn;
      a = a.';  bdyn = cdyn.';  cdyn = b0.';  ddyn = ddyn.';  e = e.';
      perm = size(a,1):-1:1;
      a = a(perm,perm);
      bdyn = bdyn(perm,:);
      cdyn = cdyn(:,perm);
      if ~isempty(e)
         e = e(perm,perm);
      end
   end

else
   % Entry-by-entry realization
   a = [];   bdyn = [];   cdyn = [];   ddyn = [];   e = [];
   if nu==1,
      catop = 'vcat';
   else
      catop = 'hcat';
   end
   
   for ct=1:ndyn,
      [aa,bb,cc,dd,ee] = zpkreal(z{idyn(ct)},p{idyn(ct)},k(idyn(ct)));
      [a,bdyn,cdyn,ddyn,e] = ...
         ssops(catop,a,bdyn,cdyn,ddyn,e,aa,bb,cc,dd,ee);
   end
end

% Expand realization to include entries w/o dynamics
na = size(a,1);
if nu==1,
   c = zeros(ny,na);
   c(idyn,:) = cdyn;
   b = bdyn;
else
   b = zeros(na,nu);
   b(:,idyn) = bdyn;
   c = cdyn;
end
d(idyn) = ddyn;
