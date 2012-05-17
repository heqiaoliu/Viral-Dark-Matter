function Slope = slope(Constr,iConstr)
%SLOPE  Computes constraint slope

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:25 $

if nargin < 2, iConstr = Constr.SelectedEdge; end

dM = diff(Constr.Magnitude(iConstr,:),1,2);
dF = diff(log10(Constr.Frequency(iConstr,:)),1,2);
dF(abs(dF)<eps) = nan;   %Avoid division by zero problems

Slope = dM./dF;

