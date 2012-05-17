function [D,SingularFlag] = ss2ss(D,T,varargin)
% Coordinate transformation z = Tx
%            (new matrices are TE/T, TA/T, TB, C/T)

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:43 $
if nargin==2
   [l,u,p] = lu(T,'vector');
else
   % LU factors supplied
   l = varargin{1};
   u = varargin{2};
   p = varargin{3};
end
D.a(:,p) = T*((D.a/u)/l);
D.b = T*D.b;
D.c(:,p) = (D.c/u)/l;
if ~isempty(D.e),
   D.e(:,p) = T*((D.e/u)/l);
end
D.StateName = [];
D.StateUnit = [];
D.Scaled = false;
% Flag singularities
SingularFlag = (hasInfNaN(D.a) || hasInfNaN(D.c) || hasInfNaN(D.e));
