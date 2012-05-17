function [out1,maxderiv] = deriv(net,X,Xi,Ai,T)
%DERIV Test network subfunction derivatives.

% Copyright 2010 The MathWorks, Inc.

% Network and Data Problem
if nargin == 1
  seed = net;
  rand('seed',seed);
  [net,X,Xi,Ai,T] = nntest.rand_problem(seed);
end

maxderiv = 0;
problems = {};

layerOrder = nn.layer_order(net);
layer2output = cumsum(net.outputConnect);
fcns = nn.subfcns(net);
NID = net.numInputDelays;
NLD = net.numLayerDelays;

Q = nnfast.numsamples(X);
TS = nnfast.numtimesteps(X);
P = cell(net.numInputs,NID+1);
A = cell(net.numLayers,NLD+1);
BZ = cell(net.numLayers,1);
sizeZ = zeros(net.numLayers,1);
Y = cell(net.numOutputs,TS);

A(:,1:NLD) = Ai;

Q1s = ones(1,Q);
for i = layerOrder
  if net.biasConnect(i)
    BZ{i} = net.b{i}(:,Q1s);
  end
  sizeZ(i) = sum([net.biasConnect(i) net.inputConnect(i,:) net.layerConnect(i,:)]);
end

showTime = (TS > 1) || (net.numInputDelays > 1) || (net.numLayerDelays > 1);

for ts = 1:net.numInputDelays
  disp(['Timestep ' num2str(ts-net.numInputDelays)]);
  disp(' ')
  
  for i = 1:net.numInputs
    object = ['inputs{' num2str(i) '}'];
    pi = Xi{i,ts};
    for j=1:length(fcns.inputs(i).process)
      processFcn = fcns.inputs(i).process(j);
      nextpi = processFcn.apply(pi,processFcn.settings);
      d1 = full_processing_dy_dx(processFcn.dy_dx(pi,nextpi,processFcn.settings),Q);
      d2 = processFcn.dy_dx_num(pi,nextpi,processFcn.settings);
      d3 = processing_dy_dx_deriv(processFcn.apply,pi,nextpi,processFcn.settings,d1);
      [problems,maxderiv] = print_error(object,processFcn,'dy_dx',d1,d2,d3,problems,maxderiv);
      pi = nextpi;
    end
    P{i,ts} = pi;
  end
  
  disp(' ')
end

for ts = 1:TS
  
  if showTime
    disp(['Timestep ' num2str(ts)]);
    disp(' ')
  end
  
  for i = 1:net.numInputs
    object = ['inputs{' num2str(i) '}'];
    pi = X{i,ts};
    for j=1:length(fcns.inputs(i).process)
      processFcn = fcns.inputs(i).process(j);
      nextpi = processFcn.apply(pi,processFcn.settings);
      d1 = full_processing_dy_dx(processFcn.dy_dx(pi,nextpi,processFcn.settings),Q);
      d2 = processFcn.dy_dx_num(pi,nextpi,processFcn.settings);
      d3 = processing_dy_dx_deriv(processFcn.apply,pi,nextpi,processFcn.settings,d1);
      [problems,maxderiv] = print_error(object,processFcn,'dy_dx',d1,d2,d3,problems,maxderiv);
      pi = nextpi;
    end
    P{i,1+NID} = pi;
  end
  if net.numInputs > 0, disp(' '); end
  
  for i=layerOrder

    Z = cell(1,sizeZ(i));
    zind = 1;

    if net.biasConnect(i)
      Z{zind} = BZ{i};
      zind = zind + 1;
    end

    for j=1:net.numInputs
      if net.inputConnect(i,j)
        object = ['inputWeights{' num2str(i) ',' num2str(j) '}'];
        weightFcn = fcns.inputWeights(i,j).weight;
        w = net.IW{i,j};
        d = net.inputWeights{i,j}.delays;
        p = cat(1,P{j,NID+1-d});
        z = weightFcn.apply(w,p,weightFcn.param);
        d1 = full_weight_dz_dp(weightFcn.dz_dp(w,p,z,weightFcn.param),Q);
        d2 = weightFcn.dz_dp_num(w,p,z,weightFcn.param);
        d3 = weight_fcn_p_deriv(weightFcn.apply,w,p,weightFcn.param,d1);
        [problems,maxderiv] = print_error(object,weightFcn,'dz_dp',d1,d2,d3,problems,maxderiv);

        d1 = full_weight_dz_dw(weightFcn.dz_dw(w,p,z,weightFcn.param),net.layers{i}.size);
        d2 = weightFcn.dz_dw_num(w,p,z,weightFcn.param);
        d3 = weight_fcn_w_deriv(weightFcn.apply,w,p,weightFcn.param,d1);
        [problems,maxderiv] = print_error(object,weightFcn,'dz_dw',d1,d2,d3,problems,maxderiv);
        Z{zind} = z;
        zind = zind + 1;
      end
    end

    for j=1:net.numLayers
      if net.layerConnect(i,j)
        object = ['layerWeights{' num2str(i) ',' num2str(j) '}'];
        weightFcn = fcns.layerWeights(i,j).weight;
        w = net.LW{i,j};
        d = net.layerWeights{i,j}.delays;
        p = cat(1,A{j,NLD+1-d});

        z = weightFcn.apply(w,p,weightFcn.param);
        d1 = full_weight_dz_dp(weightFcn.dz_dp(w,p,z,weightFcn.param),Q);
        d2 = weightFcn.dz_dp_num(w,p,z,weightFcn.param);
        d3 = weight_fcn_p_deriv(weightFcn.apply,w,p,weightFcn.param,d1);
        [problems,maxderiv] = print_error(object,weightFcn,'dz_dp',d1,d2,d3,problems,maxderiv);

        d1 = full_weight_dz_dw(weightFcn.dz_dw(w,p,z,weightFcn.param),net.layers{i}.size);
        d2 = weightFcn.dz_dw_num(w,p,z,weightFcn.param);
        d3 = weight_fcn_w_deriv(weightFcn.apply,w,p,weightFcn.param,d1);
        [problems,maxderiv] = print_error(object,weightFcn,'dz_dw',d1,d2,d3,problems,maxderiv);
        Z{zind} = z;
        zind = zind + 1;
      end
    end

    object = ['layers{' num2str(i) '}'];
    netFcn = fcns.layers(i).netInput;
    n = netFcn.apply(Z,netFcn.param);
    if isempty(Z), n = zeros(net.layers{i}.size,Q) + n; end
    for j=1:sizeZ(i)
      d1 = netFcn.dn_dzj(j,Z,n,netFcn.param);
      d2 = netFcn.dn_dzj_num(j,Z,n,netFcn.param);
      d3 = net_fcn_derive(netFcn.apply,j,Z,netFcn.param,d1);
      [problems,maxderiv] = print_error(object,netFcn,['dn_dz' num2str(j)],d1,d2,d3,problems,maxderiv);
    end

    transferFcn = fcns.layers(i).transfer;
    a = transferFcn.apply(n,transferFcn.param);
    d1 = transferFcn.da_dn_full(n,a,transferFcn.param);
    d2 = transferFcn.da_dn_num(n,a,transferFcn.param);
    d3 = transfer_fcn_derive(transferFcn.apply,n,transferFcn.param,d1);
    [problems,maxderiv] = print_error(object,transferFcn,'da_dn',d1,d2,d3,problems,maxderiv);
    A{i,1+NLD} = a;
  
    if net.outputConnect(i)
      ii = layer2output(i);
      object = ['outputs{' num2str(ii) '}'];
      yi = A{i,1+NLD};
      for j=length(fcns.outputs(ii).process):-1:1
        processFcn = fcns.outputs(ii).process(j);
        nextyi = processFcn.reverse(yi,processFcn.settings);
        d1 = full_processing_dx_dy(processFcn.dx_dy(nextyi,yi,processFcn.settings),Q);
        d2 = processFcn.dx_dy_num(nextyi,yi,processFcn.settings);
        d3 = processing_dx_dy_deriv(processFcn.reverse,nextyi,yi,processFcn.settings,d1);
        [problems,maxderiv] = print_error(object,processFcn,'dx_dy',d1,d2,d3,problems,maxderiv);
        yi = nextyi;
      end
      Y{ii,ts} = yi;
    end
    disp(' ')
  end
  
  % Shift input states
  P = [P(:,2:end) cell(net.numInputs,1)];
  A = [A(:,2:end) cell(net.numLayers,1)];
end

if showTime
  disp('Performance')
  disp(' '),
end

object = 'net';
performFcn = fcns.perform;
perf = performFcn.apply(net,T,Y,{1},performFcn.param);
d1 = performFcn.dperf_dy(net,T,Y,{1},perf,performFcn.param);
d2 = performFcn.dperf_dy_num(net,T,Y,{1},perf,performFcn.param);
d3 = performance_y_derive(performFcn,net,Y,T,d1);
[problems,maxderiv] = print_error(object,performFcn,'dperf_dy',d1,d2,d3,problems,maxderiv);

d1 = performFcn.dperf_dwb(net,performFcn.param);
d2 = performFcn.dperf_dwb_num(net,performFcn.param);
d3 = performance_wb_derive(performFcn.apply,net,Y,T,{1},performFcn.param);
[problems,maxderiv] = print_error(object,performFcn,'dperf_dwb',d1,d2,d3,problems,maxderiv);

if nargout > 0
  out1 = problems;
elseif ~isempty(problems)
  disp(' ')
  for i=1:length(problems)
    disp(problems{i})
  end
  disp(' ')
else
  disp(' ')
  disp('PASSED.');
  disp(' ')
end

% === PROCESSING DY_DX DERIVATIVE

function d2 = full_processing_dy_dx(d1,Q)
if iscell(d1)
  d2 = d1;
else
  d2 = cell(1,Q);
  d2(:) = {d1};
end

function y = processing_y_wrapper(x,f,v,s,i,j)
persistent processingFcn;
persistent X;
persistent settings;
persistent indX;
persistent indY;
if ischar(x) && strcmp(x,'setup');
  processingFcn = f;
  X = v;
  settings = s;
  indX = i;
  indY = j;
  y = @processing_y_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    X2 = X;
    X2(indX) = x(i);
    yall = feval(processingFcn,X2,settings);
    y(i) = yall(indY);
  end
end

function d = processing_dy_dx_deriv(processingFcn,x,y,settings,da)
[numX,Q] = size(x);
[numY,Q] = size(y);
d = cell(1,Q); 
for q=1:Q
  xq = x(:,q);
  dq = zeros(numY,numX);
  for indY=1:numY
    for indX=1:numX
      fcn = processing_y_wrapper('setup',processingFcn,xq,settings,indX,indY);
      dq(indY,indX) = nntest.numderivn(fcn,xq(indX),da{q}(indY,indX));
    end
  end
  d{q} = dq;
end

% === WEIGHT dz_dw DERIVATIVE

function d2 = full_weight_dz_dw(d1,S)
if iscell(d1)
  d2 = d1;
else
  d2 = cell(1,S);
  d2(1:S) = {d1};
end

function y = weight_w_wrapper(x,f,w,wi,inp,p)
persistent fcn;
persistent weights;
persistent weightIndex;
persistent inputs;
persistent param;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  weights = w;
  weightIndex = wi;
  inputs = inp;
  param = p;
  y = @weight_w_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(y)
    weights2 = weights;
    weights2(weightIndex) = x(i);
    y(i) = feval(fcn,weights2,inputs,param);
  end
end

function d = weight_fcn_w_deriv(f,weights,inputs,param,da)
[S,R] = size(weights);
[R,Q] = size(inputs);
d = cell(1,S);
for i=1:S
  di = zeros(R,Q);
  if (R > 0)
    for q=1:Q
      for j=1:R
        fcn = weight_w_wrapper('setup',f,weights(i,:),j,inputs(:,q),param);
        di(j,q) = nntest.numderivn(fcn,weights(i,j),da{i}(j,q));
      end
    end
  end
  d{i} = di;
end

% === WEIGHT dz_dp DERIVATIVE

function d2 = full_weight_dz_dp(d1,Q)
if iscell(d1)
  d2 = d1;
else
  d2 = cell(1,Q);
  d2(1:Q) = {d1};
end

function y = weight_p_wrapper(x,f,w,inp,r,p)
persistent fcn;
persistent weights;
persistent inputs;
persistent inputIndex;
persistent param;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  weights = w;
  inputs = inp;
  inputIndex = r;
  param = p;
  y = @weight_p_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(y)
    inputs2 = inputs;
    inputs2(inputIndex) = x(i);
    y(i) = feval(fcn,weights,inputs2,param);
  end
end

function d = weight_fcn_p_deriv(f,weights,inputs,param,da)
[S,R] = size(weights);
[R,Q] = size(inputs);
d = cell(1,Q);
for q=1:Q
  di = zeros(S,R);
  if (R > 0)
    for s=1:S
      for r=1:R
        fcn = weight_p_wrapper('setup',f,weights(s,:),inputs(:,q),r,param);
        di(s,r) = nntest.numderivn(fcn,inputs(r,q),da{q}(s,r));
      end
    end
  end
  d{q} = di;
end

% === NET INPUT DERIVATIVE

function y = net_fcn_wrapper(x,f,z,j,p)
persistent fcn;
persistent allz;
persistent jind;
persistent param;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  allz = z;
  jind = j;
  param = p;
  y = @net_fcn_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    allz2 = allz;
    allz2{jind} = x(i);
    y(i) = feval(fcn,allz2,param);
  end
end

function d = net_fcn_derive(tf,j,z,p,da)
[S,Q] = size(z{j});
d = zeros(S,Q);
for i=1:S
  for q=1:Q
    ziq = nnfast.getelements(nnfast.getsamples(z,q),i);
    fcn = net_fcn_wrapper('setup',tf,ziq,j,p);
    d(i,q) = nntest.numderivn(fcn,ziq{j},da(i,q));
  end
end

% === TRANSFER FCN DERIVATIVE

function y = transfer_fcn_wrapper(x,f,inp,p,xi,yi)
persistent fcn;
persistent inputs;
persistent param;
persistent xind;
persistent yind;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  inputs = inp;
  param = p;
  xind = xi;
  yind = yi;
  y = @transfer_fcn_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    inputs2 = inputs;
    inputs2(xind) = x(i);
    yall = feval(fcn,inputs2,param);
    y(i) = yall(yind);
  end
end

function d = transfer_fcn_derive(tf,n,param,da)
[S,Q] = size(n);
d = cell(1,Q); 
for q=1:Q
  dq = zeros(S,S);
  for yind=1:S
    for xind=1:S
      fcn = transfer_fcn_wrapper('setup',tf,n(:,q),param,xind,yind);
      dq(yind,xind) = nntest.numderivn(fcn,n(xind,q),da{q}(yind,xind));
    end
  end
  d{q} = dq;
end

% === PERFORMANCE DPERF_DY DERIVATIVE

function y = performance_y_wrapper(x,f,n,t,nt)
persistent fcn;
persistent net;
persistent target;
persistent numFinite;
if ischar(x) && strcmp(x,'setup')
  fcn = f;
  net = n;
  target = t;
  numFinite = nt;
  y = @performance_y_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    yi = feval(fcn.performance_y,net,{target},{x(i)},{1},fcn.param);
    y(i) = feval(fcn.weight_perf_y_or_grad,yi,1,numFinite,fcn.param);
  end
end

function d = performance_y_derive(f,net,outputs,targets,da)
[N,Q,TS] = nnsize(outputs);
outputs = cell2mat(outputs);
targets = cell2mat(targets);
da = cell2mat(da);
d = zeros(sum(N),Q);
numFinite = numfinite(outputs-targets);
for i=1:sum(N)
  for q=1:(Q*TS)
    fcn = performance_y_wrapper('setup',f,net,targets(i,q),numFinite);
    d(i,q) = nntest.numderivn(fcn,outputs(i,q),da(i,q));
  end
end
d = mat2cell(d,N,Q*ones(1,TS));

% === PERFORMANCE WB DERIVATIVE

function y = performance_wb_wrapper(x,f,wb,y,t,ew,p,i)
persistent fcn;
persistent weights;
persistent outputs;
persistent targets;
persistent errorWeights;
persistent param;
persistent index;
if ischar(x) && strcmp(x,'setup')
  fcn = f;
  weights = wb;
  outputs = y;
  targets = t;
  errorWeights = ew;
  param = p;
  index = i;
  y = @performance_wb_wrapper;
else
  weights2 = weights;
  weights2(index) = x;
  y = feval(fcn,weights2,outputs,targets,errorWeights,param);
end

function d = performance_wb_derive(f,wb,y,t,ew,p)
if ~isnumeric(wb), wb = getwb(wb); end
d = zeros(size(wb));
for i=1:numel(d)
  fcn = performance_wb_wrapper('setup',f,wb,y,t,ew,p,i);
  d(i) = nntest.gnumn(fcn,wb(i));
end

% === PROCESSING DX_DY DERIVATIVE

function d2 = full_processing_dx_dy(d1,Q)
if iscell(d1)
  d2 = d1;
else
  d2 = cell(1,Q);
  d2(:) = {d1};
end

function y = processing_x_wrapper(x,f,v,s,i,j)
persistent processingFcn;
persistent vector;
persistent settings;
persistent inputIndex;
persistent outputIndex;
if ischar(x) && strcmp(x,'setup');
  processingFcn = f;
  vector = v;
  settings = s;
  inputIndex = i;
  outputIndex = j;
  y = @processing_x_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    vector2 = vector;
    vector2(outputIndex) = x(i);
    yall = feval(processingFcn,vector2,settings);
    y(i) = yall(inputIndex);
  end
end

function d = processing_dx_dy_deriv(processingFcn,x,y,settings,da)
[N,Q] = size(x);
[M,Q] = size(y);
d = cell(1,Q); 
for q=1:Q
  yq = y(:,q);
  dq = zeros(N,M);
  for i=1:N
    for j=1:M
      fcn = processing_x_wrapper('setup',processingFcn,yq,settings,i,j);
      dq(i,j) = nntest.numderivn(fcn,yq(j),da{q}(i,j));
    end
  end
  d{q} = dq;
end

% ====

function [problems,maxderiv] = print_error(object,fcn,derivName,d1,d2,d3,problems,maxderiv)

absTolerance = 1e-10;
relTolerance = 1e-7;

if iscell(d1)
  d1 = cell2mat(d1);
  d2 = cell2mat(d2);
  d3 = cell2mat(d3);
end
mag = sqrt(sumsqr(d1));
maxderiv = max(maxderiv,mag);
if isempty(mag), mag = 0; end
if mag == 0
  scale = 1;
else
  scale = mag;
end
e1 = sqrt(sumsqr(d1-d2))/scale;
e2 = sqrt(sumsqr(d1-d3))/scale;
failed = (e2 > relTolerance) && (scale*e2 > absTolerance);
if failed
  probstr = '  <<< FAILED';
  problems = [problems {['Failed derivative: ' upper(fcn.mfunction) ', ' derivName]}];
else
  probstr = '';
end
object = [object nnstring.spaces(20-length(object))];
fcnName = fcn.mfunction;
derivName = [fcnName nnstring.spaces(24-length(fcnName)-length(derivName)) derivName];
magStr = sprintf('%g',mag);
magStr = [magStr nnstring.spaces(11-length(magStr))];
e1str = sprintf('%g',e1);
e1str = [e1str nnstring.spaces(11-length(e1str))];
fprintf('%s%s  mag: %s num5: %s numN: %g%s\n',...
  object,derivName,magStr,e1str,e2,probstr);

% Reasons for worst matches
% Very large (1e8) P going into NEGDIST, e2 = 4.2472e-08
