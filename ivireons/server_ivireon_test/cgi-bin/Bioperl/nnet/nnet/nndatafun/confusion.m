function [c,cm,ind,per] = confusion(targets,outputs)
%CONFUSION Classification confusion matrix.
%
%  [C,CM,IND,PER] = <a href="matlab:doc confusion">confusion</a>(T,Y) takes an SxQ target and output matrices
%  T and Y, where each column of T is all zeros with one 1 indicating the
%  target class, and where the columns of Y have values in the range [0,1],
%  the largest Y indicating the models output class.
%
%  It returns the confusion value C, indicating the fraction of samples
%  misclassified, CM an SxS confusion matrix, where CM(i,j) is the number
%  of target samples of the ith class classified by the outputs into class
%  j.  Also returned are IND an SxS cell array whose elements IND{i,j}
%  contain the sample indices of class i targets classified as class j,
%  and PER an Sx3 matrix where each ith row contains the percentages of
%  false negatives, falst positives and true positives of the ith class.
%
%  <a href="matlab:doc confusion">confusion</a>(T,Y) can also take a row vector T of 0/1 target values and a
%  corresponding row vector Y output values.  This case is treated as
%  a two-class case, so CM and IND will be 2x2, and PER 2x3.
%
%  Here a classifier is trained and the confusion values calculated.
%
%    [x,t] = <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a>;
%    net = patternnet(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x);
%    [c,cm,ind,per] = <a href="matlab:doc confusion">confusion</a>(t,y)
%
% See also PLOTCONFUSION, ROC

% Copyright 2007-2010 The MathWorks, Inc.

if nargin < 2
  nnerr.throw('Not enough input arguments.');
end
if any(size(targets)~=size(outputs))
  nnerr.throw('Targets and outputs have different dimensions.')
end
if ~all((targets==0) | (targets==1) | isnan(targets))
  warning('nnet:confusion:Args','Targets were not all 1/0 values and have been rounded.')
  targets = compet(targets);
end

numClasses = size(outputs,1);
if (numClasses == 1)
  targets = [targets; 1-targets];
  outputs = [outputs; 1-outputs-eps*(outputs==0.5)];
  [c,cm,ind,per] = confusion(targets,outputs);
  return;
end

% Unknown/dont-care targets
known = find(isfinite(sum(targets,1)));
targets = targets(:,known);
outputs = outputs(:,known);
numSamples = length(known);

% Transform outputs
outputs = compet(outputs);

% Confusion value
c = sum(sum(targets ~= outputs))/(2*numSamples);
c = full(c);

% Confusion matrix
if nargout < 2, return, end
cm = zeros(numClasses,numClasses);
i = vec2ind(targets);
j = vec2ind(outputs);
for k=1:numSamples
  cm(i(k),j(k)) = cm(i(k),j(k)) + 1;
end

% Indices
if nargout < 3, return, end
ind = cell(numClasses,numClasses);
for k=1:numSamples
  ind{i(k),j(k)} = [ind{i(k),j(k)} k];
end

% Percentages
if nargout < 4, return, end
per = zeros(numClasses,3);
for i=1:numClasses,
  tot = sum(cm(i,:));
  per(i,1) = sum(cm(i,[1:(i-1) (i+1):numClasses]))/tot;
  per(i,2) = sum(cm([1:(i-1) (i+1):numClasses],i))/tot;
  per(i,3) = cm(i,i)/tot;
end
