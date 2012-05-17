function updatePZGroups(this,zpkdata)
% Imports compensator data.
%

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/09/15 20:36:37 $

% RE: Two compensator representations are used
%                                 prod(s-zi)
%  1) C(s) = sign_r * K_r * s^m * ----------  when FORMAT = 'ZeroPoleGain'
%                                 prod(s-pj)
%
%                                 prod(1-s/zi)
%  2) C(s) = sign_b * K_b * s^m * ------------  when FORMAT = 'TimeConstant'
%                                 prod(1-s/pj)
%
%                                         prod(1-(z-1)/(zi-1))
%     (or C(z) = sign_b * K_b * (z-1)^m * --------------------
%                                         prod(1-(z-1)/(pi-1))
%
%  The fields GainSign and GainMag store sign_* and K_*
if isempty(zpkdata)
   % Leave value unchanged except during first import 
   if isempty(this.Gain) 
      this.Gain = 1;
   end
else
   % Importing new value
   z = [zpkdata.z{:}];
   p = [zpkdata.p{:}];
   Ts = abs(zpkdata.Ts);
   
   % Detect notch components
   [z,p,zn,pn] = LocalFindNotch(z,p,Ts);
   
   % Real poles and zeros
   pr = p(~imag(p),:);
   zr = z(~imag(z),:);
   
   % Complex poles and zeros
   pc = p(imag(p)>0,:);
   zc = z(imag(z)>0,:);
   
   % Adjust length of PZ group list (reuse existing groups)
   Nr = length(pr) + length(zr);
   Nc = length(pc)+length(zc);
   Nn = size(zn,2);
   
   PZGroup = this.PZGroup;
   
   PZTypes = get(PZGroup,{'Type'});

   RealPZGroups = PZGroup(strcmp(PZTypes, 'Real'));
   ComplexPZGroups = PZGroup(strcmp(PZTypes, 'Complex'));
   NotchPZGroups = PZGroup(strcmp(PZTypes, 'Notch'));
   LeadLagPZGroups = PZGroup(strcmp(PZTypes, 'LeadLag'));
   
   % Can't reconstruct lead-lag
   delete(LeadLagPZGroups);
   
   
   % Add/Delete real pzgroups 
   if length(RealPZGroups) > Nr
      delete(RealPZGroups(Nr+1:end));
      RealPZGroups(Nr+1:end) = [];
   else
      for ct = 1:Nr-length(RealPZGroups)
         RealPZGroups = [RealPZGroups; sisodata.PZGroupReal(this)];
      end
   end
   
   % Add/Delete complex pzgroups 
   if length(ComplexPZGroups) > Nc
      delete(ComplexPZGroups(Nc+1:end));
      ComplexPZGroups(Nc+1:end) = [];
   else
      for ct = 1:Nc-length(ComplexPZGroups)
         ComplexPZGroups = [ComplexPZGroups; sisodata.PZGroupComplex(this)];
      end
   end
   
   % Add/Delete Notch pzgroups
   if length(NotchPZGroups) > Nn
      delete(NotchPZGroups(Nn+1:end));
      NotchPZGroups(Nn+1:end) = [];
   else
      for ct = 1:Nn-length(NotchPZGroups)
         NotchPZGroups = [NotchPZGroups; sisodata.PZGroupNotch(this)];
      end
   end   
   
   this.PZGroup = [RealPZGroups; ComplexPZGroups; NotchPZGroups];
   
   % Update PZ groups
   N = 0;
   for ct=1:length(zr)
       set(this.PZGroup(N+ct),'Type','Real','Zero',zr(ct),'Pole',zeros(0,1));
       this.PZGroup(N+ct).resetParameterSpec;
   end
   N = N + length(zr);
   for ct=1:length(pr)
       set(this.PZGroup(N+ct),'Type','Real','Zero',zeros(0,1),'Pole',pr(ct));
       this.PZGroup(N+ct).resetParameterSpec;
   end
   N = N + length(pr);
   for ct=1:length(zc)
       set(this.PZGroup(N+ct),'Type','Complex',...
           'Zero',[zc(ct);conj(zc(ct))],'Pole',zeros(0,1));
       this.PZGroup(N+ct).resetParameterSpec;
   end
   N = N + length(zc);
   for ct=1:length(pc)
       set(this.PZGroup(N+ct),'Type','Complex',...
           'Zero',zeros(0,1),'Pole',[pc(ct);conj(pc(ct))]);
       this.PZGroup(N+ct).resetParameterSpec;
   end
   N = N + length(pc);
   for ct=1:size(zn,2)
       set(this.PZGroup(N+ct),'Type','Notch',...
           'Zero',zn(:,ct),'Pole',pn(:,ct));
   end

end   


%%%%%%%%%%%%%%%%%%
% LocalFindNotch %
%%%%%%%%%%%%%%%%%%
function [z,p,zn,pn] = LocalFindNotch(z,p,Ts)
% Detects notch filters in imported compensator
NearTol = sqrt(eps);
nz = length(z);
np = length(p);

% Get natural freq. and damping
[wz,zetaz] = damp(z,Ts);
[wp,zetap] = damp(p,Ts);

% Sort Wn
zeta = [zetaz;zetap];
idx = [1:nz,nz+1:nz+np]';
[wn,is] = sort([wz;wp]);
idx = idx(is,:);
zeta = zeta(is,:);

% Find isolated groups of four roots with same wn
nr = nz+np;
delta = [(abs(wn(2:nr,:)-wn(1:nr-1,:))<NearTol*wn(1:nr-1,:));0];
isNotchSeed = ...
    [delta(1:nr-3,:) & delta(2:nr-2,:) & delta(3:nr-1,:) & ~delta(4:nr,:) ; zeros(3,1)];

% Such groups with two poles and two zeros qualify as notches
isZero = (idx<=nz);
isPole = (idx>nz);
isPZPair = (filter([1 1 1 1],[1 0 0 0],isZero)==2 & ...
    filter([1 1 1 1],[1 0 0 0],isPole)==2);
isNotchSeed = isNotchSeed & [isPZPair(4:nr,:);zeros(3,1)];

% Check compatibility of damping (|zetaz|<|zetap|)
for k=find(isNotchSeed)',
    zetaz = zeta(k-1+find(isZero(k:k+3)));
    zetap = zeta(k-1+find(isPole(k:k+3)));
    isNotchSeed(k) = (abs(zetaz(1))<=abs(zetap(1)));
end

% Extract notches
idxn = find(isNotchSeed);
zn = zeros(2,length(idxn));
pn = zeros(2,length(idxn));
for ct=1:length(idxn),
    % Position of notch poles and zeros in Z and P
    k = idxn(ct);
    idxz = idx(k-1+find(isZero(k:k+3)));
    idxp = idx(k-1+find(isPole(k:k+3)))-nz;
    % Extract notch
    zk = z(idxz(1));
    pk = p(idxp(1));
    zn(:,ct) = real(zk) + [1i;-1i] * abs(imag(zk));
    pn(:,ct) = real(pk) + [1i;-1i] * abs(imag(pk));
end

% Delete notch roots from Z and P
isNotch = zeros(nr,1);
isNotch([idxn;idxn+1;idxn+2;idxn+3],:) = 1;
z(idx(isZero & isNotch),:) = [];
p(idx(isPole & isNotch)-nz,:) = [];
    
