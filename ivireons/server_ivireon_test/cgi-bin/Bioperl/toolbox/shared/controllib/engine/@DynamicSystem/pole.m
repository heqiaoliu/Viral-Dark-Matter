function p = pole(sys,varargin)
%POLE  Computes the poles of linear systems.
%
%   P = POLE(SYS) returns the poles P of the dynamic system SYS as a column
%   vector. For state-space models, the poles are the eigenvalues of the A 
%   matrix or the generalized eigenvalues of the (A,E) pair in the 
%   descriptor case.
%
%   P = POLE(SYS,J1,...,JN) computes the poles P of the model with subscripts 
%   (J1,...,JN) in the model array SYS.
%
%   See also DAMP, ESORT, DSORT, PZMAP, ZERO, LTI, DYNAMICSYSTEM.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:59 $
try
   if nargin>1 || numsys(sys)==1
      p = pole_(sys,varargin{:});
   else
      % Old syntax returning ND array padded with NaNs
      % REVISIT: turn off warning against internal delays in ssdata/pole
      s = size(sys);
      npmax = 0;
      p = zeros([npmax 1 s(3:end)]);
      for ct=1:prod(s(3:end))
         pp = pole_(sys,ct);
         np = length(pp);
         if np>npmax,
            p(npmax+1:np,:) = NaN;
            npmax = np;
         end
         p(1:np,1,ct) = pp;
         p(np+1:npmax,1,ct) = NaN;
      end
   end
catch E
   ltipack.throw(E,'command','pole',class(sys))
end