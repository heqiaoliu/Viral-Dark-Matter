function [trainPerf,valPerf,testPerf] = perfs_u_mr(net,data,fcns)
%NN_CALCU_PERFS Calculate tr/va/te perfs from unified data, w-mem reduc

% Copyright 2010 The MathWorks, Inc.
  fcn = fcns.perform;
  % perfy - dperfy/dWB
  if data.split.count == 1
    [trainPerfy,valPerfy,testPerfy] = singlecalc(net,data,fcns);
  else
    [trainPerfy,valPerfy,testPerfy] = splitcalc(net,data,fcns);
  end
  % perfwb - dperf/dWB
  perfWB = fcn.performance_wb(net,fcn.param);
  % Full Performance
  trainPerf = trainPerfy + perfWB;
  valPerf = valPerfy + perfWB;
  testPerf = testPerfy + perfWB;
end

function [trainPerfy,valPerfy,testPerfy] = splitcalc(net,data,fcns)
  % Split 1
  fcn = fcns.perform;
  indices = data.split.indices{1};
  split = nntraining.split_data(data,indices);
  [trainPerfy,trainN1,valPerfy,valN1,testPerfy,testN1] = singlecalc(net,split,fcns);
  % Split 2, etc
  for i=2:data.split.count
    indices = data.split.indices{i};
    split = nntraining.split_data(data,indices);
    [trainPerf1,trainN1,valPerf1,valN1,testPerf1,testN1] = singlecalc(net,split,fcns);
    % Combine
    [trainPerfy,trainN] = fcn.combine_perf_y_or_grad(net,trainPerfy,trainN,trainPerfy1,trainN1,fcn.param);
    [valPerfy,valN] = fcn.combine_perf_y_or_grad(net,valPerfy,valN,valPerfy1,valN1,fcn.param);
    [testPerfy,testN] = fcn.combine_perf_y_or_grad(net,testPerfy,testN,testPerfy1,testN1,fcn.param);
  end
end

function [trainPerfy,valPerfy,testPerfy,trainN,valN,testN] = singlecalc(net,data,fcns)
  Y = nntraining.y_only(net,data,fcns);
  T = gmultiply(data.T,data.train.mask);
  fcn = fcns.perform;
  [trainPerfy,trainN] = fcn.performance_y(net,T,Y,data.EW,fcn.param);
  if data.val.enabled
    T = gmultiply(data.T,data.val.mask);
    [valPerfy,valN] = fcn.performance_y(net,T,Y,data.EW,fcn.param);
  else
    valPerfy = NaN;
    valN = 0;
  end
  if data.test.enabled
    T = gmultiply(data.T,data.test.mask);
    [testPerfy,testN] = fcn.performance_y(net,T,Y,data.EW,fcn.param);
  else
    testPerfy = NaN;
    testN = 0;
  end
end


