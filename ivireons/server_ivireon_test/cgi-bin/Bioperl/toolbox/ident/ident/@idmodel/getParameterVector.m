function par = getParameterVector(sys)
%GETPARAMETERVECTOR Return model parameters as a vector
%   Used for estimation and reporting purposes.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:13:58 $

par = pvget(sys,'ParameterVector'); 
