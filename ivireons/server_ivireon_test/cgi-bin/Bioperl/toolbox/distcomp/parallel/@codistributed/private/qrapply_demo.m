function X = qrapply_demo(H,X,trans)
%QRAPPLY_DEMO  Demo of application of the Householder reflections
%    The array H obtained from [H,R] = QRFACTOR)DEMO(A) defines
%    Householder reflections whose product is a unitary matrix Q.
%    QRAPPLY_DEMO(H,X) computes Q*X without forming Q.
%    QRAPPLY_DEMO(H,X,'T') computes Q'*X without forming Q.
%    QRAPPLY_DEMO(H,X,op) with any op ~= 'T' is the same as
%    QRAPPLY_DEMO(H,X).
%
%    Example:
%       [H,R1] = qrfactor_demo(A);
%       Q = qrapply_demo(H,eye(size(A,1),codistributor()));
%       R2 = Q'*A;
%       R3 = qrapply_demo(H,A,'T');
%       is the QR factorization of A, computing R three different ways.
%
%       Q = qrapply_demo(H,eye(size(A),codistributor())) is the economy sized Q.
%
%    See also QRFACTOR_DEMO.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:28 $

mh = size(H, 1); 
mx = size(X, 1); 
if mh ~= mx
   error('distcomp:codistributed:qrapply_demo:sizeInputs', ...
       'The inputs must have the same number of rows.')
end
Hloc = getLocalPart(H);
Xloc = getLocalPart(X);
hDist = getCodistributor(H);
if nargin < 3
   trans = 'N';
end
trans = upper(trans(1));
mwTag = 31475;
for k = 1:numlabs
   if trans == 'N'
      % Form H1*H2*...*Hk*X
      p = numlabs+1-k;
   elseif trans == 'T'
      % Form Hk*...*H2*H1*X
      p = k;
   else
      error('distcomp:codistributed:qrapply_demo:stringInputs', ...
          'String input is not recognized.')
   end
   [e,f] = globalIndices(H, hDist.Dimension, p); %#ok<NASGU> Ignore the second output argument.
   if p == labindex
      % Send Householder reflectors to other processors.
      Hp = Hloc(e:mh,:);
      labSend(Hp,[1:p-1 p+1:numlabs],mwTag);
   else
      % Wait to receive reflectors.
      Hp = labReceive(p,mwTag);
   end
   % Apply reflectors.
   tau = diag(Hp);
   HpXloc = dormqr('L',trans,Hp,tau,Xloc(e:mx,:));
   Xloc = [Xloc(1:e-1,:); HpXloc];
end
X = codistributed.build(Xloc,getCodistributor(X));
