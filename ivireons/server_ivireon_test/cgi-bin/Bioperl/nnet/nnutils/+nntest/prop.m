function ok = prop(net,x,xi,ai,t,seed)
%PROP Test gradient/Jacobian propagation code

% Copyright 2010 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai,t] = nntest.rand_problem(seed);
end

if nargin == 1, clc, end
disp(' ')
disp(['========== NNTEST.PROP(' num2str(seed) ') Testing...'])
disp(' ')
if nargin == 1, nntest.disp_problem(net,x,xi,ai,t,seed); disp(' '); end

rand('seed',seed);
ok = test_prop(net,x,xi,ai,t);

if ok, result = 'PASSED'; else result = 'FAILED'; end
disp(' ')
disp(['========== NNTEST.PROP(' num2str(seed) ') *** ' result ' ***'])
disp(' ')

% ====================================================================

function ok = test_prop(net1,inputs,inputStates,layerStates,targets)

net = struct(net1);
TS = nnfast.numtimesteps(inputs);

% Base Tolerances
tolerancesAnalytic.abs = 1e-15 * sqrt(TS);
tolerancesAnalytic.rel = 1e-10 * sqrt(TS);

tolerancesNumeric.abs = 1e-10 * sqrt(TS);
tolerancesNumeric.rel = 1e-7 * sqrt(TS);

skipIndividualTolerance = 1e30;
tolerancesSkipNumeric.abs = tolerancesAnalytic.abs;
tolerancesSkipNumeric.rel = 1;

% ====== ANALYTICAL TESTS ======

disp('ANALYTICAL:')
disp(' ')
ok = true;

% Static Test
doStatic = max([net.numInputDelays,net.numLayerDelays]) == 0;

% Static
if doStatic
  static = staticderiv('dperf_dwb',net,inputs,targets,inputStates,layerStates)';
  baseName = 'Static';
  base = static;
  title = 'Static';
  
  mag = sqrt(sumsqr(base));
  if mag == 0
    scale = 1;
  else
    scale = mag;
  end
  disp(title)
  disp([baseName ' Magnitude = ' num2str(mag)]);
  disp(' ')

  % Static Jacobian
  staticj = staticderiv('dperf_dwb_jac',net,inputs,targets,inputStates,layerStates)';
  ok = compare_deriv('Static Jacobian',staticj,'StaticJ',base,baseName,scale,tolerancesAnalytic,ok);
end 

% Backprop through time
btt = bttderiv('dperf_dwb',net,inputs,targets,inputStates,layerStates)';
if ~doStatic
  baseName = 'BTT';
  base = btt;
  title = 'Backprop through time';

  mag = sqrt(sumsqr(base));
  if mag == 0
    scale = 1;
  else
    scale = mag;
  end
  disp(title)
  disp([baseName ' Magnitude = ' num2str(mag)]);
  disp(' ')
else
  ok = compare_deriv('Backprop through time',btt,'BTT',base,baseName,scale,tolerancesAnalytic,ok);
end

% Backprop through time Jacobian
bttj = bttderiv('dperf_dwb_jac',net,inputs,targets,inputStates,layerStates)';
ok = compare_deriv('Backprop through time Jacobian',bttj,'BTTJ',base,baseName,scale,tolerancesAnalytic,ok);

% Forward perterbation
fp = fpderiv('dperf_dwb',net,inputs,targets,inputStates,layerStates)';
ok = compare_deriv('Forward perturbation',fp,'FP',base,baseName,scale,tolerancesAnalytic,ok);

% Forward perterbation Jacobian
fpj = fpderiv('dperf_dwb_jac',net,inputs,targets,inputStates,layerStates)';
ok = compare_deriv('Forward perturbation Jacobian',fpj,'FPJ',base,baseName,scale,tolerancesAnalytic,ok);

% ====== NUMERIC CHECKS ======

disp('NUMERIC:')
disp(' ')
numOk = true;

% 2-Point Numeric
num2 = num2deriv('dperf_dwb',net,inputs,targets,inputStates,layerStates)';
numOk = compare_deriv('Numeric 2-point',num2,'NUM2',base,baseName,scale,tolerancesNumeric,numOk);

% 2-Point Jacobian
%num2j = num2deriv('dperf_dwb_jac',net,inputs,targets,inputStates,layerStates)';
%numOk = compare_deriv('Numeric 2-point Jacobian',num2j,'NUM2J',base,baseName,scale,tolerancesNumeric,numOk);

if numOk, return, end
numOk = true;

% 5-Point Numeric
num5 = num5deriv('dperf_dwb',net,inputs,targets,inputStates,layerStates)';
numOk = compare_deriv('Numeric 5-point',num5,'NUM5',base,baseName,scale,tolerancesNumeric,numOk);

% 5-Point Jacobian
%num5j = num5deriv('dperf_dwb_jac',net,inputs,targets,inputStates,layerStates)';
%numOk = compare_deriv('Numeric 5-point Jacobian',num5j,'NUM5J',base,baseName,scale,tolerancesNumeric,numOk);

if numOk, return, end
if ~ok, return, end

% FINAL ACCURATE NUMERIC TESTS

% Individual Derivatives
disp(' ')
[problems,maxderiv] = nntest.deriv(net,inputs,inputStates,layerStates,targets);
if ~isempty(problems)
  disp(' ')
  disp('*** FAILURE ***')
  for i=1:length(problems)
    disp(problems{i})
  end
  ok = false;
  return;
end

% Accurate Numerical
disp(' ')
numn = net_wb_deriv(struct(net),inputs,targets,inputStates,layerStates,base')';

if (maxderiv > skipIndividualTolerance)
  ok = compare_deriv('Numeric adaptive',numn,'NUMN',base,baseName,scale,tolerancesSkipNumeric,ok);
else
  ok = compare_deriv('Numeric adaptive',numn,'NUMN',base,baseName,scale,tolerancesNumeric,ok);
end

function y = net_wb_deriv_wrapper(x,n,p,t,pi,ai,wb,i)
persistent net;
persistent inputs;
persistent targets;
persistent inputStates;
persistent layerStates;
persistent weights;
persistent index;
if ischar(x) && strcmp(x,'setup')
  net = n;
  inputs = p;
  targets = t;
  inputStates = pi;
  layerStates = ai;
  weights = wb;
  index = i;
  y = @net_wb_deriv_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    weights2 = weights;
    weights2(index) = x(i);
    net = setwb(net,weights2);
    outputs = nnsim.y(net,inputs,inputStates,layerStates);
    y(i) = feval(net.performFcn,net,targets,outputs,{1},net.performParam);
  end
end

function d = net_wb_deriv(net,inputs,targets,inputStates,layerStates,da)
wb = getwb(net);
d = zeros(size(wb));
num = numel(wb);
disp(['Calculation numn: ' num2str(num) ' elements'])
for i=1:num
  if (i<10)
    fprintf(' %g ',i);
  else
    fprintf('%g ',i);
  end
  if rem(i,25) == 0, fprintf('\n'); end
  fcn = net_wb_deriv_wrapper('setup',net,inputs,targets,inputStates,layerStates,wb,i);
  d(i) = -nntest.numderivn(fcn,wb(i),-da(i));
end
fprintf('<done>\n');
disp(' ')


function ok = compare_deriv(title,other,otherName,base,baseName,scale,tolerances,ok)
diff_abs = sqrt(sumsqr(base-other));
diff_rel = diff_abs/scale;
disp(title)
fail1 = diff_rel > tolerances.rel;
fail2 = diff_abs > tolerances.abs;
if fail1 && fail2
  if ~isempty(strmatch(otherName,{'NUM2','NUM2J','NUM5','NUM5J'}))
    failstr = '  <<< UNSUCCESSFUL';
  else
    failstr = '  <<< FAILURE';
  end
  absStr = [' > ' num2str(tolerances.abs) failstr];
  relStr = [' > ' num2str(tolerances.rel) failstr];
  ok = false;
else
  compareStr = '<>';
  absStr = [' ' compareStr(fail1+1) ' ' num2str(tolerances.abs)];
  relStr = [' ' compareStr(fail2+1) ' ' num2str(tolerances.rel)];
end
disp(['Absolute ' baseName ' - ' otherName '  = ' num2str(diff_abs) absStr])
disp(['Relative ' baseName ' - ' otherName '  = ' num2str(diff_rel) relStr])
disp(' ')

% ====================================================================
