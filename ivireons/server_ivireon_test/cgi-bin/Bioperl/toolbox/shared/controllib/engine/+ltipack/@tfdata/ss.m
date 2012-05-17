function [Dss,SingularFlag] = ss(D)
% Conversion to ss

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision $  $Date: 2010/02/08 22:48:09 $

% Add static method to be included for compiler
%#function ltipack.isEqualDen
SingularFlag = false;

% Minimize number of internal delays in realization
Delay = minimizeDelay(D);
iod = Delay.IO;  % RE: each row or col has at least one zero
Ts = D.Ts;

% Conversion starts
[ny,nu] = size(D.num);
if ny==0 || nu==0
   Dss = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),zeros(ny,nu),[],Ts);
   Dss.Delay.Input = Delay.Input;
   Dss.Delay.Output = Delay.Output;
elseif ny==1 && nu==1
   % SISO case
   [a,b,c,d,e] = compreal(D.num{1},D.den{1});
   Dss = ltipack.ssdata(a,b,c,d,e,Ts);
   Dss.Delay.Input = Delay.Input + iod;
   Dss.Delay.Output = Delay.Output;
else
   % MIMO case
   % Compute orders for row- and column-oriented realizations
   [ro,co,D] = getOrder(D);
   if any(iod(:))
      % Map residual I/O delays into internal delays, channel by channel
      if co<=ro
         % Realize each column and concatenate realizations
         for j=1:nu,
            [a,b,c,d,e] = LocalRealizeSingleChannel(D.num(:,j),D.den(:,j));
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
            [a,b,c,d,e] = LocalRealizeSingleChannel(D.num(i,:),D.den(i,:));
            Dsub = ltipack.ssdata(a,b,c,d,e,Ts);
            Dsub.Delay.Input = Delay.Input + iod(i,:).';
            Dsub.Delay.Output = Delay.Output(i);
            Dsub = utFoldDelay(Dsub,iod(i,:).',[]);
            if i==1
               Dss = Dsub;
            else
               Dss = iocat(1,Dss,Dsub);
            end
         end
      end
      
   else
      % No I/O delays
      if co<=ro
         % Realize each column and concatenate realizations
         % RE: Structure-aware balancing performing by COMPREAL
         a = [];  b = [];  c = zeros(ny,0);  d = zeros(ny,0);  e = [];
         for j=1:nu,
            [aj,bj,cj,dj,ej] = LocalRealizeSingleChannel(D.num(:,j),D.den(:,j));
            [a,b,c,d,e] = ssops('hcat',a,b,c,d,e,aj,bj,cj,dj,ej);
         end
      else
         % Realize each row and concatenate realizations
         a = [];  b = zeros(0,nu);  c = [];  d = zeros(0,nu);  e = [];
         for i=1:ny,
            [ai,bi,ci,di,ei] = LocalRealizeSingleChannel(D.num(i,:),D.den(i,:));
            [a,b,c,d,e] = ssops('vcat',a,b,c,d,e,ai,bi,ci,di,ei);
         end
      end
      Dss = ltipack.ssdata(a,b,c,d,e,Ts);
      Dss.Delay.Input = Delay.Input;
      Dss.Delay.Output = Delay.Output;
   end
   
end


%------------------------- Local Functions ---------------------------

function [a,b,c,d,e] = LocalRealizeSingleChannel(num,den)
% State-space realization of SIMO or MISO TF model.
[ny,nu] = size(num);

% Determine which entries are dynamic. Zero numerator is 
% considered static.
% RE: Relies on fact that NUM and DEN have equal lengths
dyn = cellfun(@(x) length(x)>1 && any(x),num);
istat = find(~dyn);
idyn = find(dyn);
ndyn = length(idyn);

% Take care of static entries
d = zeros(ny,nu);
for ct=1:length(istat)
   i = istat(ct);
   d(i) = num{i}(1)/den{i}(1);
end

% Compute realization for subset of non-static entries
if ndyn==0
   % Static gain
   a = [];
   b = zeros(0,nu);
   c = zeros(ny,0);
   e = [];
   return

elseif ndyn<2 || ltipack.isEqualDen(den{idyn}),
   % Common denominator for entries with dynamics
   [a,bdyn,cdyn,ddyn,e] = LocalComDen(num(idyn),den{idyn(1)});
   
else
   % Entry-by-entry realization
   a = [];   bdyn = [];   cdyn = [];   ddyn = [];   e = [];
   if nu==1,
      catop = 'vcat';
   else
      catop = 'hcat';
   end
   
   for k=1:ndyn,
      [ak,bk,ck,dk,ek] = compreal(num{idyn(k)},den{idyn(k)});
      [a,bdyn,cdyn,ddyn,e] = ...
         ssops(catop,a,bdyn,cdyn,ddyn,e,ak,bk,ck,dk,ek);
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



function [a,b,c,d,e] = LocalComDen(num,den)
% Realization of SIMO or MISO TF model with common denominator. 
%
%   [A,B,C,D] = COMDEN(NUM,DEN)  returns a state-space
%   realization for the SIMO or MISO model with data NUM,DEN.
%
%   Note: The NUM vectors are all nonzero by construction.

% Get number of outputs/inputs 
[p,m] = size(num);

% Turn NUM into an array and equalize the number of columns
% RE: lengths of numerators may vary for improper models
lnum = cellfun('length',num);
lmax = max(lnum);
if any(lnum<lmax)
   % Equalize lengths using zero padding
   for ct=1:max(p,m)
      num{ct} = [zeros(1,lmax-lnum(ct)) , num{ct}];
   end
   den = [zeros(1,lmax-length(den)) , den];
end
num = cat(1,num{:});

% Realize with COMPREAL
[a,b,c,d,e] = compreal(num,den);

% Transpose/permute A,B,C,D in MISO case to make A upper Hessenberg
if p<m,
   b0 = b;
   a = a.';  b = c.';  c = b0.';  d = d.';  e = e.';
   perm = size(a,1):-1:1;
   a = a(perm,perm);
   b = b(perm,:);
   c = c(:,perm);
   if ~isempty(e)
      e = e(perm,perm);
   end
end
