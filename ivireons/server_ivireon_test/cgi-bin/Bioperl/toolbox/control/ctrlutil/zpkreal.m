function [a,b,c,d,e] = zpkreal(z,p,Gain)
%ZPKREAL  Realization of SISO ZPK model.
%
%   [A,B,C,D,E] = ZPKREAL(ZERO,POLE,GAIN) computes a state-space
%   realization for the ZPK model with data ZERO, POLE, GAIN.  
%   The E matrix is empty (identity) if there are at least as
%   many poles than zeros and is singular otherwise.
%
%   Note: No rescaling of (A,B,C,E) is performed here.

%   Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/10/15 22:40:46 $
e = [];
if Gain==0
   % Zero gain -> no dynamics
   a = [];
   b = zeros(0,1);
   c = zeros(1,0);
   d = 0;
else
   nz = length(z);
   np = length(p);
   if isconjugate(z) && isconjugate(p)
      % Real case: realize as a series connection of first- and
      % second-order sections

      % Sort zeros and poles by magnitude (see g248208 for motivation)
      z = z(imag(z)>=0);
      [junk,is] = sort(abs(z));  z = z(is);
      p = p(imag(p)>=0);
      [junk,is] = sort(abs(p));  p = p(is);
      
      % Pull out polynominal part ZPOL,PPOL and realize separately
      zpol = [];
      if nz>np
         % Split Z into [Z,ZPOL] such that length(Z)=np. If impossible,
         % move a real pole out of P and decrement np
         ppol = [];
         lengthZ = [0;cumsum(1+(imag(z)>0))];
         icut = find(lengthZ>=np,1)-1;
         zpol = z(icut+1:end);
         z = z(1:icut);
         nz = lengthZ(icut+1); % np or np+1
         if nz>np  % nz=np+1
            % Enforce NZ=NP by doing one of the following:
            % * Move real zero from Z to ZPOL if Z contains any real zero
            % * Trade complex pair in Z for real zero in ZPOL if ZPOL
            %   contains any real zero
            % * If both Z and ZPOL contain only complex pairs, move one
            %   real pole from P to PPOL (polynomial part is then p(s)/(s+a))
            idxr1 = find(imag(z)==0,1,'last');
            idxr2 = find(imag(zpol)==0,1);
            if ~isempty(idxr1)
               % Move real zero from Z to ZPOL
               zpol = [zpol ; z(idxr1)];
               z(idxr1,:) = [];
               nz = nz-1;
            elseif ~isempty(idxr2)
               % Trade complex pair in Z for real zero in ZPOL
               zpol = [zpol ; z(icut)];
               z = [z(1:icut-1) ; zpol(idxr2)];
               zpol(idxr2,:) = [];
               nz = nz-1;
            else
               % All zeros are complex (nz even, np odd). Move one real pole 
               % from P to PPOL and one complex zero from Z to ZPOL
               idxr = find(imag(p)==0,1,'last');
               ppol = p(idxr);
               p(idxr,:) = [];
               np = np-1;
               zpol = [zpol ; z(icut)];
               z = z(1:icut-1);
               nz = nz-2;
            end
         end
         
         % Realize ZPOL,PPOL
         nzpol = length(zpol);
         ns = nzpol + sum(imag(zpol)>0) + 1;  % number of states
         apol = eye(ns);
         epol = diag(ones(1,ns-1),1);
         bpol = [zeros(ns-1,1) ; -1];
         cpol = [1 , zeros(1,ns-1)];
         dpol = 0;
         row = 1;
         for ct=1:nzpol
            zz = zpol(ct);
            zzi = imag(zz);
            if zzi==0
               apol(row,row+1) = real(zz);
               row = row+1;
            else
               rho = abs(zz);
               zzr = real(zz);
               apol([row row+1],[row+1 row+2]) = [zzr -zzi*(zzi/rho);rho zzr];
               cpol(1) = rho * cpol(1);
               row = row+2;
            end
         end
         if ~isempty(ppol)
            apol(1,1) = -ppol;
            epol(1,1) = -1;
         end
      end

      % Realize and connect first- and second-order sections of proper part
      a = zeros(np);
      b = zeros(np,1);
      c = zeros(1,np);
      d = 1;
      ct = 1;  % scans z,p vectors
      ix = 0;  % start of next block written in A
      while np>0
         % Extract next first- or second-order section (zz,pp)
         % RE: Inlined for speed
         p1 = p(ct);
         if nz==0
            % No more zeros
            zz = [];
            if imag(p1)==0
               pp = p1;
            else
               pp = [p1,conj(p1)];
            end
         else
            z1 = z(ct);
            if imag(z1)==0
               % Real zero
               if imag(p1)==0
                  % Real pole and real zero: realize z/p
                  zz = z1;  pp = p1;
               else
                  % Real zero and complex pair of poles
                  pp = [p1,conj(p1)];
                  if nz<np
                     % Realize z/(p,conj(p))
                     zz = z1;
                  else
                     % Must match complex pair of poles with two zeros. Look for next real zero
                     irznext = find(imag(z(ct+1:end))==0,1);
                     if isempty(irznext)
                        % Match with next complex pair of zeros (swap z(ct) and z(ct+1))
                        z([ct ct+1]) = z([ct+1 ct]);
                        zz = [z(ct) , conj(z(ct))];
                     else
                        % Match with pair of real zeros (ct,ct+irznext)
                        zz = [z1 z(ct+irznext)];
                        z(ct+irznext) = [];
                     end
                  end
               end
            else
               % Complex zero
               zz = [z1,conj(z1)];
               if imag(p1)==0
                  % Real pole + complex pair of zeros: look for next real pole
                  irpnext = find(imag(p(ct+1:end))==0,1);
                  if isempty(irpnext)
                     % Match with next complex pair of poles (swap p(ct) and p(ct+1))
                     p([ct ct+1]) = p([ct+1 ct]);
                     pp = [p(ct) , conj(p(ct))];
                  else
                     % Match with pair of real poles (ct,ct+irpnext)
                     pp = [p1 p(ct+irpnext)];
                     p(ct+irpnext) = [];
                  end
               else
                  % Complex pairs of poles and zeros
                  pp = [p1,conj(p1)];
               end
            end
         end

         % Realize the (zz,pp) section
         ns = length(pp);  % section size
         if ns==1
            % First order
            [as,bs,cs,ds] = fos(zz,pp);
         else
            % Second order
            [as,bs,cs,ds] = sos(zz,pp);
         end

         % In-place series connection
         jx = ix+1:ix+ns;
         a(1:ix+ns,jx) = [b(1:ix,:) * cs ; as];
         b(1:ix+ns,:) = [b(1:ix,:) * ds ; bs];
         c(:,jx) = d*cs;
         d = d*ds;

         % Update counters
         nz = nz - length(zz);
         np = np - ns;
         ct = ct+1;
         ix = ix + ns;
      end
      
      % Add polynomial part
      if ~isempty(zpol)
         [a,b,c,d,e] = ssops('mult',a,b,c,d,[],apol,bpol,cpol,dpol,epol);
      end

   else
      % Complex case (only first-order sections)
      a = zeros(np);
      b = zeros(np,1);
      c = zeros(1,np);
      d = 1;
      
      % Sort zeros and poles by increasing magnitude
      [junk,is] = sort(abs(z));  z = z(is);
      [junk,is] = sort(abs(p));  p = p(is);
      
      % Realize each FOS sections
      for ct=1:np
         % Realize section
         [as,bs,cs,ds] = fos(z(ct:min(ct,nz)),p(ct));
         % In-place series connection
         a(1:ct,ct) = [b(1:ct-1,:) * cs ; as];
         b(1:ct,:) = [b(1:ct-1,:) * ds ; bs];
         c(:,ct) = d*cs;
         d = d*ds;
      end
      
      % Add polynomial part
      if nz>np,
         r = nz-np;  % relative degree
         ns = r+1;   % number of states
         as = eye(ns) + diag(z(np+1:nz),1);
         es = diag(ones(1,r),1);
         bs = [zeros(r,1) ; -1];
         cs = [1 , zeros(1,r)];
         ds = 0;
         % Combine proper and polynomial parts
         [a,b,c,d,e] = ssops('mult',a,b,c,d,[],as,bs,cs,ds,es);
      end
   end
   
   % Add gain (Note: gain is nonzero here)
   d = d * Gain;
   c = c * Gain;
   
   % Rescale B,C so that their norm roughly matches
   bnorm = norm(b,1);
   cnorm = norm(c,1);
   if bnorm>0 && cnorm>0
      sf = pow2(round(log2(cnorm/bnorm)/2));
      b = b * sf;
      c = c / sf;
   end

end

%%%%%%%%%%%%%

function [a,b,c,d] = sos(z,p)
%SOS  Realization of real second-order section (d*s^2+e*s+f)/(s-p(1))/(s-p(2))

% Numerator coefficients
switch length(z)
case 0
   d = 0;
   e = 0;
   f = 1;
case 1
   d = 0;
   e = 1;
   f = -z;
case 2
   d = 1;
   e = real(sum(p)-sum(z));
   f = real(prod(z)-prod(p));
   if e==0 && f==0
      % Exact cancellations lead to a drop in the structural order of the 
      % realization (zpk(ss(zpk([1+i 1-i],[1+i 1-i],1))) is a pure gain).
      % Slightly perturb data to enforce consistent structural order
      e = eps/8 * (eps + abs(sum(p)));
   end
end

% Construct realization (b = [0;1] in all cases)
p1 = p(1);
sigma = abs(imag(p1));
if sigma==0
   % Real roots
   a = [p1 1;0 p(2)];
   c = [f+p1*e , e];
else
   % Complex pair
   rho = real(p1);
   if sigma>1
      a = [rho sigma;-sigma rho];
      c = [(f+rho*e)/sigma , e];
   else
      a = [rho 1;-sigma^2 rho];
      c = [f+rho*e , e];
   end
end

% Scale b vs. c
lambda = sqrt(norm(c)); % always nonzero (special handling of e=f=0)
b = [0 ; lambda];
c = c/lambda;

%------------------------

function [a,b,c,d] = fos(z,p)
%FOS  Realization of first-order section 1/(s-p) or (s-z)/(s-p)
nump = prod(p-z);          % num(p)=1 or num(p)=p-z
if nump==0
   % Exact cancellations lead to b=c=0 and a drop in the structural
   % order of the realization (zpk(ss(zpk(1,1,1))) is a pure gain).
   % This leads to inconsistencies in SISO Tool (g323031, 325363).
   % Slightly perturb data to enforce consistent structural order
   nump = eps/4 * (eps + abs(p));
end
lambda = sqrt(abs(nump));  % |num(p)|^.5

a = p;
b = lambda;
c = sign(nump)*lambda;
if isempty(z)
   d = 0;
else
   d = 1;
end
