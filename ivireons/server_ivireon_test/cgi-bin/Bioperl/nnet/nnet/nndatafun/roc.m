function [tpr,fpr,thresholds] = roc(targets,outputs)
%ROC Receiver operating characteristic.
%
%  The reciever operating characteristic is a metric used to check
%  the quality of classifiers. For each class of a classifier,
%  threshold values across the interval [0,1] are applied to
%  outputs. For each threshold, two values are calculated, the
%  True Positive Ratio (the number of outputs greater or equal
%  to the threshold, divided by the number of one targets),
%  and the False Positive Ratio (the number of outputs greater
%  then the threshold, divided by the number of zero targets).
%
%  [TPR,FPR,TH] = <a href="matlab:doc roc">roc</a>(T,Y) takes an SxQ target matrix T, where each
%  column contains a single 1 value, with all other elements 0. The index
%  of the 1 indicates which of S categories that vector represents. It also
%  takes an SxQ output matrix Y, with values in the range [0,1]. The index
%  of the largest element in the column indicates which of S categories that
%  vector presents.
%
%  It returns and Sx1 cell array of 1xN true-positive/positive ratios TPR,
%  an Sx1 cell array of 1xN false-positive/negative ratios FPR, and an
%  Sx1 cell array of 1xN thresholds TH over interval [0,1].
%
%  <a href="matlab:doc roc">roc</a>(T,Y) can also take a boolean row vector T, and row vector Y, in
%  which case two categories are represented by targets 1 and 0.
%
%  Here a network is trained to recognize iris flowers the the ROC is
%  calculated and plotted.
%
%    [x,t] = <a href="matlab:doc iris_dataset">iris_dataset</a>;
%    net = <a href="matlab:doc patternnet">patternnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x);
%    [tpr,fpr,th] = <a href="matlab:doc roc">roc</a>(t,y)
%    <a href="matlab:doc plotroc">plotroc</a>(t,y)
%
%  See also PLOTROC, CONFUSION

% Copyright 2007-2010 The MathWorks, Inc.

nnassert.minargs(nargin,2);
targets = nntype.data('format',targets,'Targets');
outputs = nntype.data('format',outputs,'Outputs');
% TOTO - nnassert_samesize({targets,outputs},{'Targets','Outputs'});
if size(targets,1) > 1
  warning('nnet:roc:Arguments','ROC will only use the first input and target signals.');
end
targets = [targets{1,:}];
outputs = [outputs{1,:}];
numClasses = size(targets,1);

known = find(~isnan(sum(targets,1)));
targets = targets(:,known);
outputs = outputs(:,known);

if (numClasses == 1)
  targets = [targets; 1-targets];
  outputs = [outputs; 1-outputs-eps*(outputs==0.5)];
  [tpr,fpr,thresholds] = roc(targets,outputs);
  tpr = tpr{1};
  fpr = fpr{1};
  thresholds = thresholds{1};
  return;
end

fpr = cell(1,numClasses);
tpr = cell(1,numClasses);
thresholds = cell(1,numClasses);

for i=1:numClasses
  [tpr{i},fpr{i},thresholds{i}] = roc_one(targets(i,:),outputs(i,:));
end

%%
function [tpr,fpr,thresholds] = roc_one(targets,outputs)

numSamples = length(targets);
numPositiveTargets = sum(targets);
numNegativeTargets = numSamples-numPositiveTargets;

thresholds = unique([0 outputs 1]);
numThresholds = length(thresholds);

sortedPosTargetOutputs = sort(outputs(targets == 1));
numPosTargetOutputs = length(sortedPosTargetOutputs);
sortedNegTargetOutputs = sort(outputs(targets == 0));
numNegTargetOutputs = length(sortedNegTargetOutputs);

fpcount = zeros(1,numThresholds);
tpcount = zeros(1,numThresholds);

posInd = 1;
negInd = 1;
for i=1:numThresholds
  threshold = thresholds(i);
  while (posInd <= numPosTargetOutputs) && (sortedPosTargetOutputs(posInd) <= threshold)
    posInd = posInd + 1;
  end
  tpcount(i) = numPosTargetOutputs + 1 - posInd;
  while (negInd <= numNegTargetOutputs) && (sortedNegTargetOutputs(negInd) <= threshold)
    negInd = negInd + 1;
  end
  fpcount(i) = numNegTargetOutputs + 1 - negInd;
end

tpr = fliplr(tpcount) ./ numPositiveTargets;
fpr = fliplr(fpcount) ./ numNegativeTargets;
thresholds = fliplr(thresholds);
