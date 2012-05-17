function ok = net(net,x,xi,ai,seed)
%NET Run all tests on a network

% Copyright 2010 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai,t] = nntest.rand_problem(seed);
end

if nargin == 1, clc, end
disp(' ')
disp(['================================ NNTEST.NET(' num2str(seed) ') Testing...'])
disp(' ')
if nargin == 1, nntest.disp_problem(net,x,xi,ai,t,seed); disp(' '); end

rand('seed',seed);
ok = test_net(net,x,xi,ai,t,seed);

if ok, result = 'PASSED'; else result = 'FAILED'; end
disp(' ')
disp(['================================ NNTEST.NET(' num2str(seed) ') *** ' result ' ***'])
disp(' ')

% ====================================================================

function ok = test_net(net,x,xi,ai,t,seed)

ok = nntest.prop(net,x,xi,ai,t,seed);
if ~ok, return, end
  
ok = nntest.sim(net,x,xi,ai,seed);

% ====================================================================
