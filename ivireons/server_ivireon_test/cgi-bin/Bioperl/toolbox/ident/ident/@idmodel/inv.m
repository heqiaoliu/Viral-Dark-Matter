function sysinv = inv(sys)
%INV  Inverse IDMODEL object.
%   Requires Control System Toolbox.
%
%   IMOD = INV(MOD) computes the inverse model IMOD such that
%
%       y = MOD * u   <---->   u = IMOD * y 
%
%   The IDMODEL object MOD must have the same number of inputs and
%   outputs. For a state-space model the D-matrix must be
%   nonsingular. For discrete time models the delay must be zero.
%
%   Covariance information is lost in the transformation.
%
%   The noise inputs are first eliminated.
%

%    Copyright 1986-2009 The MathWorks, Inc.
%    $Revision: 1.4.4.8 $ $Date: 2009/12/05 02:03:03 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','inv')
end

if isa(sys,'idpoly')
   if size(sys,'nu')>1
      ctrlMsgUtils.error('Ident:idmodel:invCheck1')
   end
   if sys.Ts>0 % then do the inversion directly
      nk = pvget(sys,'nk');
      [a,b,~,~,f] = polydata(sys,1);
      
      sysinv = pvset(sys,'a',1,'b',conv(a,f)/b(nk+1),...
         'c',1','d',1,'f',b(nk+1:end)/b(nk+1),'InputDelay',-nk-pvget(sys,'InputDelay'),...
         'OutputName',pvget(sys,'InputName'),'InputName',pvget(sys,'OutputName'),...
         'OutputUnit',pvget(sys,'InputUnit'),'InputUnit',pvget(sys,'OutputUnit'));
      return
   end
end
sys.CovarianceMatrix = [];

try
   sys1 = ss(sys('m'));
catch E
   throw(E)
end

try
   sysinv = inv(sys1);
catch E
   throw(E)
end

if isa(sys,'idpoly')
   sysinv = idpoly(sysinv);
   sysinv = pvset(sysinv,'BFFormat',pvget(sys,'BFFormat'));
else
   sysinv = idss(sysinv);
end
