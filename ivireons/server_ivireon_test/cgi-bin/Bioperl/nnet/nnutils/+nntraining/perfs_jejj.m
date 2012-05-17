function [trainPerf,valPerf,testPerf,je,jj,gradient] = perfs_jejj(net,data,fcns)

% Copyright 2010 The MathWorks, Inc.
  % TODO - if no memory split, return intermediate variables
  %   if their output arg is present.
  
  % Direct Performance - dperf/dY
  if data.split.count == 1
    [trainPerfy,trainN,valPerfy,~,testPerfy,~,JEy,JJy] = singlecalc(net,data,fcns);
  else
    [trainPerfy,trainN,valPerfy,~,testPerfy,~,JEy,JJy] = splitcalc(net,data,fcns);
  end
  fcn = fcns.perform;
  % Indirect Performance - dperf/dWB
  perfWB = fcn.performance_wb(net,fcn.param);
  %JEwb = fcn.dperf_dwb(net,fcn.param);
  %JJwb = speye(length(JEwb));
  % TODO - Check this code,
  % TODO - Get better notation for weight/bias contribution
  % Full Performance
  trainPerf = trainPerfy + perfWB;
  valPerf = valPerfy + perfWB;
  testPerf = testPerfy + perfWB;
  je = JEy; % + JEwb;
  jj = JJy; % + JJwb;
  if nargout > 5
    switch net.performFcn
      case 'sse', gradient = 2*sqrt(je'*je);
      case 'mse', gradient = 2*sqrt(je'*je)/trainN;
      otherwise, nnerr.throw('Unsupported',...
        ['Unsupported performance function: ' net.performFcn]);
    end
  end
end

function [trainPerfy,trainN,valPerfy,valN,testPerfy,testN,JEy,JJy] = splitcalc(net,data,fcns)
  fcn = fcns.perform;
  % Split 1
  indices = data.split.indices{1};
  split = nntraining.split_data(data,indices);
  [trainPerfy,trainN,valPerfy,valN,testPerfy,testN,JEy,JJy] = singlecalc(net,split,fcns);
  % Split 2, etc
  for i=2:data.split.count
    indices = data.split.indices{i};
    split = nntraining.split_data(data,indices);
    [trainPerfy1,trainN1,valPerfy1,valN1,testPerfy1,testN1,JE1,JJ1] = singlecalc(net,split,fcns);
    % Combine
    JEy = JEy + JE1;
    JJy = JJy + JJ1;
    [trainPerfy,trainN] = fcn.combine_perf_y_or_grad(trainPerfy,trainN,trainPerfy1,trainN1,fcn.param);
    [valPerfy,valN] = fcn.combine_perf_y_or_grad(valPerfy,valN,valPerfy1,valN1,fcn.param);
    [testPerfy,testN] = fcn.combine_perf_y_or_grad(testPerfy,testN,testPerfy1,testN1,fcn.param);
  end
end

function [trainPerfy,trainN,valPerfy,valN,testPerfy,testN,JEy,JJy] = singlecalc(net,data,fcns)
  fcn = fcns.perform;
  [Y,trainPerfy,trainN,JEy,JJy] = calc_Y_trainPerfJeJJ(net,data,fcns);
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

function [Y,trainPerfy,trainN,JEy,JJy] = calc_Y_trainPerfJeJJ(net,data,fcns)
  % Encapsulate calculation to keep extra "signals" fields temporary.
  signals = nntraining.y_all(net,data,fcns);
  Y = signals.Y;
  signals.T = gmultiply(data.T,data.train.mask);
  fcn = fcns.perform;
  [trainPerfy,trainN] = fcn.performance_y(net,signals.T,signals.Y,signals.EW,fcn.param);
  E = gsubtract(signals.T,Y);
  E = fcns.perform.adjust_error(net,E,data.EW,fcns.perform.param);
  E = cell2mat(E);
  E = E(:);
  E(~isfinite(E)) = 0;
  Jwb_y = fcns.deriv.calc_jacobian(net,signals,fcns);
  JEy = Jwb_y * E;
  JJy = Jwb_y * Jwb_y';
end
