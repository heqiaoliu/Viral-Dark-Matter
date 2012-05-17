function H = hilb(n,classname)
%HILB   Hilbert matrix.
%   HILB(N) is the N by N matrix with elements 1/(i+j-1),
%   which is a famous example of a badly conditioned matrix.
%   See INVHILB for the exact inverse.
%
%   HILB(N,CLASSNAME) produces a matrix of class CLASSNAME.
%   CLASSNAME must be either 'single' or 'double' (the default).
%
%   This is also a good example of efficient MATLAB programming
%   style where conventional FOR or DO loops are replaced by
%   vectorized statements.  This approach is faster, but uses
%   more storage.
%
%   See also INVHILB.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.10.4.4 $  $Date: 2005/11/18 14:14:30 $

if nargin < 2
   classname = 'double';
else  % nargin == 2
   if ~strcmpi(classname,'double') && ~strcmpi(classname,'single') 
      error('MATLAB:hilb:notSupportedClass',...
            'CLASSNAME must be ''double'' or ''single''.');
   end
end

%   I, J and E are matrices whose (i,j)-th element
%   is i, j and 1 respectively.

J = 1:cast(n,classname);
J = J(ones(n,1),:);
I = J';
E = ones(n,classname);
H = E./(I+J-1);
