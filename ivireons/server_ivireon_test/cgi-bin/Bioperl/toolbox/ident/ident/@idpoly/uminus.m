function sys = uminus(sys)
%UMINUS  Unary minus for IDPOLY models.
%
%   MMOD = UMINUS(MOD) is invoked by MMOD = -MOD.
%
%   See also MINUS, PLUS.

 
%       Copyright 1986-2009 The MathWorks, Inc.
%       $Revision: 1.3.4.2 $  $Date: 2009/12/05 02:03:48 $

[~,b] = polydata(sys,1);
sys = pvset(sys,'b',-b);
% REVISIT Covariance matrix

