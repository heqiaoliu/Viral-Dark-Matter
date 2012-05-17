function [trainData,valData,testData] = divide_data(data)

% Copyright 2010 The MathWorks, Inc.

if data.train.all
  trainData = data;
  valData = [];
  testData = [];
else
  trainData = nntraining.split_data(data,data.train.sampleMask);
  valData = nntraining.split_data(data,data.val.sampleMask);
  testData = nntraining.split_data(data,data.test.sampleMask);
end
