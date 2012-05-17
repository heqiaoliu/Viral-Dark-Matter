function [out1,out2,out3,out4,out5,out6] = srchhyb(varargin)
%SRCHHYB One-dimensional minimization using a hybrid bisection-cubic search.
%
%  <a href="matlab:doc srchhyb">srchhyb</a> is a linear search routine.  It searches in a given direction
%  to locate the minimum of the performance function in that direction.
%  It uses a technique which is a combination of a bisection and a
%  cubic interpolation.
%
%  Search functions are not commonly called directly.  They are called
%  by training functions.
%
%  <a href="matlab:doc srchhyb">srchhyb</a>(NET,X,P,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF)
%    NET     - Neural network.
%    X       - Vector containing current values of weights and biases.
%    P       - Processed inputs.
%    Pd      - Delayed input vectors.
%    Ai      - Initial input delay conditions.
%    Tl      - Layer target vectors.
%    EW      - Error weights.
%    Q       - Batch size.
%    TS      - Time steps.
%    dX      - Search direction vector.
%    gX      - Gradient vector.
%    PERF    - Performance value at current X.
%    DPERF   - Slope of performance value at current X in direction of dX.
%    DELTA   - Initial step size.
%    TOL     - Tolerance on search.
%    CH_PERF - Change in performance on previous step.
%  and returns,
%    A       - Step size which minimizes performance.
%    gX      - Gradient at new minimum point.
%    PERF    - Performance value at new minimum point.
%    RETCODE - Return code which has three elements. The first two elements correspond to
%              the number of function evaluations in the two stages of the search
%              The third element is a return code. These will have different meanings
%              for different search algorithms. Some may not be used in this function.
%                0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                3 - beta condition not met.
%    DELTA   - New initial step size. Based on the current step size.
%    TOL     - New tolerance on search.
%
%  Parameters used for the hybrid bisection-cubic algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    beta      - Scale factor which determines sufficiently large step size.
%    bmax      - Largest step size.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                size delta. Usually set to 20.
%
%  Dimensions for these variables are:
%    Pd - NoxNixTS cell array, each element P{i,j,ts} is a DijxQ matrix.
%    Tl - NlxTS cell array, each element P{i,ts} is an VixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%  Where
%    Ni = net.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>
%    LD = net.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Vi = net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%    Dij = Ri * length(net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>)
%
%  Here a feed-forward network is trained with the <a href="matlab:doc traincgf">traincgf</a> training
%  function and this search function.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(20,'traincgf');
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.searchFcn">searchFcn</a> = '<a href="matlab:doc srchhyb">srchhyb</a>';
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x)
%
%  See also SRCHBAC, SRCHBRE, SRCHCHA, SRCHGOL

% Copyright 1992-2010 The MathWorks, Inc.
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% $Revision: 1.1.6.8.2.1 $ $Date: 2010/07/14 23:40:15 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Search Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me,
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    if length(varargin) < 17
      varargin = [varargin { nn.subfcns(varargin{1}) }];
    end
    [out1,out2,out3,out4,out5,out6] = do_search(varargin{:});
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnSearch(mfilename,...
    'Hybrid Bisection-Cubic One-Dimensional Minimization',fcnversion);
end

function [a,gX,perf,retcode,delta,tol] = ...
  do_search(net,X,P,Pd,Ai,T,EW,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf,fcns)

  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  if ischar(net)
    switch(net)
      case 'name'
        a = 'One-Dimensional Minimization w-Hybrid Bisection-Cubic';
      otherwise, nnerr.throw(['Unrecognized code: ''' net ''''])
    end
    return
  end

  u = 999.9;
  perfu = 999.99;
  dperfu = 999.99;

  % ALGORITHM PARAMETERS
  scale_tol = net.trainParam.scale_tol;
  alpha = net.trainParam.alpha;
  beta = net.trainParam.beta;
  bmax = net.trainParam.bmax;
  min_grad = net.trainParam.min_grad;

  % Parameter Checking
  if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
    (scale_tol <= 0)
    nnerr.throw('Scale_tol is not a positive real value.')
  end
  if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
    (alpha < 0) | (alpha > 1)
    nnerr.throw('Alpha is not a real value between 0 and 1.')
  end
  if (~isa(beta,'double')) | (~isreal(beta)) | (any(size(beta)) ~= 1) | ...
    (beta < 0) | (beta > 1)
    nnerr.throw('Beta is not a real value between 0 and 1.')
  end
  if (~isa(bmax,'double')) | (~isreal(bmax)) | (any(size(bmax)) ~= 1) | ...
    (bmax <= 0)
    nnerr.throw('Bmax is not a positive real value.')
  end
  if (~isa(min_grad,'double')) | (~isreal(min_grad)) | (any(size(min_grad)) ~= 1) | ...
    (min_grad < 0)
    nnerr.throw('Min_grad is not zero or a positive real value.')
  end

  % STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION (NORMALLY 2)
  scale = 2;

  % INITIALIZE A AND B
  a = 0;
  a_old = 0;

  % We check influence of this condition on solution. FIND FIRST STEP SIZE
  delta_star = abs(-2*ch_perf/dperf);
  delta = max([delta delta_star]);

  b = delta;
  perfa = perf;
  dperfa = dperf;
  perfa_old = perfa;
  dperfa_old = dperfa;
  cnt1 = 0;
  cnt2 = 0;

  % CALCLULATE PERFORMANCE FOR B
  X_temp = X + b*dX;
  net_temp = setx(net,X_temp);
  [perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
  gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfb,Q,TS,fcns);
  dperfb = gX_temp'*dX;
  cnt1 = cnt1 + 1;

  % INTERVAL LOCATION
  % FIND INITIAL INTERVAL WHERE MINIMUM PERF OCCURS
  while (perfa>perfb) && (b<bmax)
    a_old=a;
    perfa_old = perfa;
    dperfa_old = dperfa;
    perfa = perfb;
    dperfa = dperfb;
    a=b;
    b=scale*b;
    X_temp = X + b*dX;
    net_temp = setx(net,X_temp);
    [perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
    gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfb,Q,TS,fcns);
    dperfb = gX_temp'*dX;
    cnt1 = cnt1 + 1;
  end

  % If perfb is NaN we return
  if ~isnan(perfb)
    if (a == a_old)
      % TAKE INITIAL BISECTION STEP IF NO MIDPOINT EXISTS
      x = (a + b)/2;
      X_step = x*dX;
      X_temp = X + X_step;
      net_temp = setx(net,X_temp);
      [perfx,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
      gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfx,Q,TS,fcns);
      dperfx = gX_temp'*dX;
      cnt1 = cnt1 + 1;
    else
      % USE ALREADY COMPUTED VALUE AS INITIAL BISECTION STEP
      x = a;
      perfx = perfa;
      dperfx = dperfa;
      a=a_old;
      perfa=perfa_old;
      dperfa = dperfa_old;
    end

    % DETERMINE THE W POINT (A OR B WITH MINIMUM FUNCTION VALUE)
    if perfa>perfb
      w = b;
      perfw = perfb;
      dperfw = dperfb;
    else
      w = a;
      perfw = perfa;
      dperfw = dperfa;
    end

    % DETERMINE THE OVERALL MINIMUM POINT
    minperf = min([perfa perfb perfx]);
    amin = a; dperfmin = dperfa;
    if perfb<= minperf
      amin = b; dperfmin = dperfb;
    elseif perfx <= minperf
      amin = x; dperfmin = dperfx;
    end

    % LOCATE THE MINIMUM POINT BY THE HYBRID BISECTION-CUBIC SEARCH
    while ((b-a)>tol) && ((minperf > perf + alpha*amin*dperf) || abs(dperfmin)>abs(beta*dperf) )

      if(abs(w-x)<.02*(b-a))
        bisection = 1;
      else
        % CUBIC INTERPOLATION
        if (w > x)
          aa = x; fa = perfx; ga = dperfx;
          bb = w; fb = perfw; gb = dperfw;
        else
          bb = x; fb = perfx; gb = dperfx;
          aa = w; fa = perfw; ga = dperfw;
        end
        ww = 3*(fa - fb)/(bb-aa) + ga + gb;
        w_gagb = ww^2 - ga*gb;
        if (w_gagb >= 0)
          v = sqrt(w_gagb);
          den_star = (gb - ga +2*v);
          if den_star ==0,
            u_star = aa;
          else
            u_star = aa + (bb-aa)*(1 - (gb + v - ww)/den_star);
          end
          if ((u_star > a) && (u_star < b))
            X_temp = X + u_star*dX;
            net_temp = setx(net,X_temp);
            [perfu,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
            gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfu,Q,TS,fcns);
            dperfu = gX_temp'*dX;
            u = u_star;
            cnt2 = cnt2 + 1;
            bisection = 0;
          else
            bisection = 1;
          end
        else
          bisection = 1;
        end
      end

      if (bisection == 1)
        % BISECTION
        if ((dperfa<0) && ((dperfx>0) || (perfx>perfa))) || ((dperfa>0) && (dperfx>0) && (perfx<perfa))
          u = (a + x)/2;
        else
          u = (x + b)/2;
        end
        X_temp = X + u*dX;
        net_temp = setx(net,X_temp);
        [perfu,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
        gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfu,Q,TS,fcns);
        dperfu = gX_temp'*dX;
        cnt2 = cnt2 + 1;
      end

      % We must also check that the new points is smaller than extremes
      if ( dperfu < min_grad ) && (perfu <= perfa) && (perfu <= perfb)
        a = u; perfa = perfu; dperfa = dperfu;
        b = u; perfb = perfu; dperfb = dperfu;
      elseif (u>x)
        a = x; perfa = perfx; dperfa = dperfx;
      elseif (u<x)
        b = x; perfb = perfx; dperfb = dperfx;
      else
        a = x; perfa = perfx; dperfa = dperfx;
        b = x; perfb = perfx; dperfb = dperfx;
      end

      % DETERMINE THE W POINT (A OR B WITH MINIMUM FUNCTION VALUE)
      if perfa>perfb
        w = b;
        perfw = perfb;
        dperfw = dperfb;
      else
        w = a;
        perfw = perfa;
        dperfw = dperfa;
      end

      x = u; perfx = perfu; dperfx = dperfu; 

      minperf = min([perfa perfb perfx]);
      amin = a; dperfmin = dperfa;
      if perfb<= minperf
        amin = b; dperfmin = dperfb;
      elseif perfx <= minperf
        amin = x; dperfmin = dperfx;
      end

    end
  else
    minperf=perfa;
    amin=a;
  end	% END of ~isnan(perfb)

  a = amin;

  % COMPUTE FINAL GRADIENT
  X = X + a*dX;
  net = setx(net,X);
  [perf,Ac,N,Zb,Zi,Zl] = nnsim.perf(net,P,Pd,Ai,T,EW,Q,TS,fcns);
  gX = -nnprop.grad_s(net,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perf,Q,TS,fcns);

  % CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
  delta=a;
  if delta < net.trainParam.delta
    delta = net.trainParam.delta;
  end

  tol=delta/scale_tol;


  retcode = [cnt1 cnt2 0];
end
