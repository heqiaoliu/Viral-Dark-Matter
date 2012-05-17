function p = geometry(Constr)
%GEOMETRY  Computes parameters defining constraint geometry.
%
%   Continuous time: returns X such that constraint equivalent to Re(s)<X
%   Discrete time: returns RHO such that constraint equivalent to |z|<RHO

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:42 $

TbxPrefs = cstprefs.tbxprefs;
alpha = log(TbxPrefs.SettlingTimeThreshold)/Constr.SettlingTime;  % Re(p)<alpha

if Constr.Ts
    p = exp(alpha*Constr.Ts);
else
    p = alpha;
end
