function [trainPerf,valPerf,testPerf] = perfs(net,data,fcns)

% Copyright 2010 The MathWorks, Inc.
  if data.split.count == 1
    [trainPerfy,valPerfy,testPerfy] = singlecalc(net,data,fcns);
  else
    [trainPerfy,valPerfy,testPerfy] = splitcalc(net,data,fcns);
  end
  % perfwb - dperf/dWB
  fcn = fcns.perform;
  perfWB = fcn.performance_wb(net,fcn.param);
  % Full Performance
  trainPerf = trainPerfy + perfWB;
  valPerf = valPerfy + perfWB;
  testPerf = testPerfy + perfWB;
end

function [trainPerfy,valPerfy,testPerfy] = splitcalc(net,data,fcns)
  % Split 1
  indices = data.split.indices{1};
  split = nntraining.split_data(data,indices);
  [trainPerfy,trainN,valPerfy,valN,testPerfy,testN] = singlecalc(net,split,fcns);
  % Split 2, etc
  fcn = fcns.perform;
  for i=2:data.split.count
    indices = data.split.indices{i};
    split = nntraining.split_data(data,indices);
    [trainPerfy1,trainN1,valPerfy1,valN1,testPerfy1,testN1] = singlecalc(net,split,fcns);
    % Combine
    [trainPerfy,trainN] = fcn.combine_perf_y_or_grad(net,trainPerfy,trainN,trainPerfy1,trainN1,fcn.param);
    [valPerfy,valN] = fcn.combine_perf_y_or_grad(net,valPerfy,valN,valPerfy1,valN1,fcn.param);
    [testPerfy,testN] = fcn.combine_perf_y_or_grad(net,testPerfy,testN,testPerfy1,testN1,fcn.param);
  end
end

function [trainPerfy,valPerfy,testPerfy,trainN,valN,testN] = singlecalc(net,data,fcns)
  signals = nntraining.y_all(net,data,fcns);
  Y = signals.Y;
  fcn = fcns.perform;
  maskedT = gmultiply(data.T,data.train.mask);
  [trainPerfy,trainN] = fcn.performance_y(net,maskedT,Y,data.EW,fcn.param);
  if data.val.enabled
    maskedT = gmultiply(data.T,data.val.mask);
    [valPerfy,valN] = fcn.performance_y(net,maskedT,Y,data.EW,fcn.param);
  else
    valPerfy = NaN;
    valN = 0;
  end
  if data.test.enabled
    maskedT = gmultiply(data.T,data.test.mask);
    [testPerfy,testN] = fcn.performance_y(net,maskedT,Y,data.EW,fcn.param);
  else
    testPerfy = NaN;
    testN = 0;
  end
end

