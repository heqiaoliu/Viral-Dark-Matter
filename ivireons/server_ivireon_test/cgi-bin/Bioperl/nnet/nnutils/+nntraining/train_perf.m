function trainPerf = train_perf(net,data,fcns)

% Copyright 2010 The MathWorks, Inc.
  % Direct Performance - dperf/dY
  if data.split.count == 1
    trainPerfy = singlecalc(net,data,fcns);
  else
    trainPerfy = splitcalc(net,data,fcns);
  end
  % Indirect Performance - dperf/dWB
  fcn = fcns.perform;
  perfWB = fcn.performance_wb(net,fcn.param);
  % Full Performance
  trainPerf = trainPerfy + perfWB;
end

function trainPerfy = splitcalc(net,data,fcns)
  % Split 1
  indices = data.split.indices{1};
  split = nntraining.split_data(data,indices);
  [trainPerfy,trainN] = singlecalc(net,split,fcns);
  % Split 2, etc
  for i=2:data.split.count
    indices = data.split.indices{i};
    split = nntraining.split_data(data,indices);
    [trainPerf1,trainN1] = singlecalc(net,split,fcns);
    % Combine
    trainPerfy = (trainPerfy*trainN + trainPerf1*trainN1) / (trainN+trainN1);
  end
end

function [trainPerfy,trainN] = singlecalc(net,data,fcns)
  y = nntraining.y_only(net,data,fcns);
  ew = data.EW;
  t = data.T;
  if data.train.masked
    t = gmultiply(t,data.train.mask);
  end
  fcn = fcns.perform;
  [trainPerfy,trainN] = fcn.performance_y(net,t,y,ew,fcn.param);
end
