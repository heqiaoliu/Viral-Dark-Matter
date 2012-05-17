function alg2obj(this,Model)
% update the properties by reading off values from alg struct

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:24 $

nloptionspack.utAlg2Obj(this,Model);

% focus
if strcmpi(Model.Focus,'prediction')
    this.Estimation_Focus = 'Prediction';
else
    this.Estimation_Focus = 'Simulation';
end

alg = Model.Algorithm;

% iterWavenet
if strcmpi(alg.IterWavenet,'auto')
    this.Iterative_Wavenet = 'Auto';
elseif strcmpi(alg.IterWavenet,'on')
    this.Iterative_Wavenet = 'On';
else
    this.Iterative_Wavenet = 'Off';
end
