%% Plane Rotations

%  Copyright 1993-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2009/04/16 00:44:13 $

%%
% Create a symbolic variable named t.

t = sym('t')

%%
% Create a 2-by-2 matrix representing a plane rotation through an angle t.

G = [ cos(t) sin(t); -sin(t) cos(t)]

%%
% Compute the matrix product of G with itself.

G*G

%%
% This should represent a rotation through an angle of 2*t.
% Simplification using trigonometric identities is necessary.

ans = simple(ans)

%%
% G is an orthogonal matrix; its transpose is its inverse.

G.'*G

ans = simple(ans)

%%
% What are the eigenvalues of G?

e = eig(G)

%%
% Repeatedly apply the simplification rules.

e, for k = 1:4, e = simple(e), end


displayEndOfDemoMessage(mfilename)
