function perf = evalnet(in1,in2,in3)

% Copyright 2010 The MathWorks, Inc.

persistent net;
persistent x;
persistent t;
if nargin == 3
  net = in1;
  x = in2;
  t = in3;
  return
end

net = setwb(net,in1);
y = nnsim.y(net,x);
perf = perform(net,t,y);
