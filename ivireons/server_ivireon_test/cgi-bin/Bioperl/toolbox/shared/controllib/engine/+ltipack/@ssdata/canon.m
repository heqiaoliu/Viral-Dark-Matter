function [D,T] = canon(D,Type,varargin)
% Canonical realizations of state-space model
%    canon(D,'companion')
%    canon(D,'modal',condT)

%   Author(s): P. Gahinet
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:30:45 $
na0 = size(D.a,1);

% Check properness
[isProper,D] = isproper(D,'explicit');
if ~isProper
    ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','canon')
end

% Extract data and scale for numerical accuracy
a = D.a; b = D.b; c = D.c; d = D.d;
if ~D.Scaled,
   [a,b,c,~,s,p] = xscale(a,b,c,d,[],D.Ts);
end
na = size(a,1);

% Compute companion form
switch lower(Type(1))
   case 'm'
      % Modal form
      if isreal(a)
         [T,a] = bdschur(a,varargin{1});
         if na>1
            % Rescale 2x2 blocks in Schur form to look like [s w;-w s]
            % (s and w then give the real and imaginary parts of the
            % complex poles)
            idxBlks = find(diag(a,-1));
            for ct = 1:length(idxBlks)
               n = idxBlks(ct);
               % Scale 2x2 block
               %    a(n:n+1,n:n+1) = [ s  q ] to  [  s  w ]
               %                     [ r  s ]     [ -w  s ]
               %    w = sqrt(abs(q*r))
               % Scaling factor = sign(q) * sqrt(q/r)
               sfactor = sign(a(n,n+1)) * sqrt(abs(a(n+1,n)/a(n,n+1)));
               % Set off-diagonal terms to w and -w by applying scaling
               a(:,n+1) = a(:,n+1)*sfactor;
               a(n+1,:) = a(n+1,:)/sfactor;
               % Augment T with scaling factor
               T(:,n+1) = T(:,n+1)*sfactor;
            end
         end
      else
         % REVISIT: need complex version of BDSCHUR
         [T,a] = eig(a);
      end
      b = T\b;
      c = c*T;

   case 'c'
      % Companion form
      % Transformation to companion form based on controllability matrix
      if isempty(b)
         T = eye(na);
      else
         T = ctrb(a,b(:,1));
         [l,u,q] = lu(T,'vector');
         if rcond(u)<eps,
             ctrlMsgUtils.error('Control:transformation:canon2')
         end
         Anb = a*T(:,na);  % A^n * b(:,1)
         a = [[zeros(1,na-1);eye(na-1)] , u\(l\Anb(q,:)) ];  % T\a*T
         b = [[1;zeros(na-1,1)] , u\(l\b(q,2:end))];  % T\b
         c = c*T;
      end

   otherwise
      ctrlMsgUtils.error('Control:transformation:canon1')
end

% Update data
D.a = a;
D.b = b;
D.c = c;
D.e = [];
D.Scaled = false;

if nargout>1 && na==na0
   % Return inverse of T to be compatible with ss2ss
   T = T(p,:) \ diag(1./s);
else
   T = [];
end
