function [tr,V1,V2,V3] = nn_divide_data(net,tr,signals)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

tr.divideMode = net.divideMode;
if feval(net.trainFcn,'usesValidation') && ~isempty(net.divideFcn)
  switch net.divideMode
    case 'sample'
      Q = nnfast.numsamples(signals.T);
      [tr.trainInd,tr.valInd,tr.testInd] = feval(net.divideFcn,Q,net.divideParam);
      if net.efficiencyFlags.separateValTestVectors
        V1 = nn_select_samples_struct_separate(signals,tr.trainInd,'Training');
        V2 = nn_select_samples_struct_separate(signals,tr.valInd,'Validation');
        V3 = nn_select_samples_struct_separate(signals,tr.testInd,'Test');
      else
        V1 = nn_select_samples_struct(signals,tr.trainInd,'Training');
        V2 = nn_select_samples_struct(signals,tr.valInd,'Validation');
        V3 = nn_select_samples_struct(signals,tr.testInd,'Test');
      end
    case 'timestep',
      TS = nnfast.numtimesteps(signals.T);
      [tr.trainInd,tr.valInd,tr.testInd] = feval(net.divideFcn,TS,net.divideParam);
      V1 = nn_select_timesteps_struct(signals,tr.trainInd,'Training');
      V2 = nn_select_timesteps_struct(signals,tr.valInd,'Validation');
      V3 = nn_select_timesteps_struct(signals,tr.testInd,'Test');
    case 'all',
      [N,Q,TS] = nnfast.nnsize(signals.T);
      [tr.trainInd,tr.valInd,tr.testInd] = feval(net.divideFcn,sum(N)*Q*TS,net.divideParam);
      V1 = nn_select_all_struct(signals,tr.trainInd,'Training');
      V2 = nn_select_all_struct(signals,tr.valInd,'Validation');
      V3 = nn_select_all_struct(signals,tr.testInd,'Test');
  end
else
  V1 = signals;
  V2 = [];
  V3 = [];
  Q = nnfast.numsamples(V1.X);
  tr.divideMode = 'sample';
  tr.trainInd = 1:Q;
  tr.valInd = [];
  tr.testInd = [];
end
