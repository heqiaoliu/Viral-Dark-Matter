function [out1,out2,out3,out4,out5,out6] = srchbac(varargin)
%SRCHBAC One-dimensional minimization using backtracking.
%
%  <a href="matlab:doc srchbac">srchbac</a> is a linear search routine.  It searches in a given direction
%  to locate the minimum of the performance function in that direction.
%  It uses a technique called backtracking.
%
%  Search functions are not commonly called directly.  They are called
%  by training functions.
%
%  <a href="matlab:doc srchbac">srchbac</a>(NET,X,P,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF)
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
%               the number of function evaluations in the two stages of the search
%              The third element is a return code. These will have different meanings
%               for different search algorithms. Some may not be used in this function.
%                 0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                 3 - beta condition not met.
%    DELTA   - New initial step size. Based on the current step size.
%    TOL     - New tolerance on search.
%
%  Parameters used for the backstepping algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    beta      - Scale factor which determines sufficiently large step size.
%    low_lim   - Lower limit on change in step size.
%    up_lim    - Upper limit on change in step size.
%    maxstep   - Maximum step length.
%    minstep   - Minimum step length.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                   size delta. Usually set to 20.
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
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(20,'<a href="matlab:doc traincgf">traincgf</a>');
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.searchFcn">searchFcn</a> = '<a href="matlab:doc srchbac">srchbac</a>';
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x)
%
%  See also SRCHBRE, SRCHCHA, SRCHGOL, SRCHHYB

% Copyright 1992-2010 The MathWorks, Inc.
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% $Revision: 1.1.6.8.2.1 $ $Date: 2010/07/14 23:40:11 $

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
  info = nnfcnSearch(mfilename,'Backtracing One-Dimensional Minimization',fcnversion);
end

function [a,gX,perfb,retcode1,delta,tol] = ...
  do_search(net,X,P,Pd,Ai,T,EW,Q,TS,dX,gX,perfa,dperfa,delta,tol,ch_perf,fcns)

if (nargin < 1), nnerr.throw('Not enough arguments.'); end
if ischar(net)
  switch(net)
    case 'name'
      a = 'One Dimensional Minimization w-Backtracking';
    otherwise, nnerr.throw(['Unrecognized code: ''' net ''''])
  end
  return
end

% ALGORITHM PARAMETERS
scale_tol = net.trainParam.scale_tol;
alpha = net.trainParam.alpha;
beta = net.trainParam.beta;
low_lim = net.trainParam.low_lim;
up_lim = net.trainParam.up_lim;
maxstep = net.trainParam.max_step;
minstep = net.trainParam.min_step;
norm_dX = norm(dX);
% New minimum lambda may depend on dperfa
minlambda = min([minstep/norm_dX minstep/norm(dperfa)]);
maxlambda = maxstep/norm_dX;
cnt1 = 0;
cnt2 = 0;
start = 1;

% Parameter Checking
if (~isa(scale_tol,'double')) || (~isreal(scale_tol)) || (any(size(scale_tol)) ~= 1) || ...
  (scale_tol <= 0)
  nnerr.throw('Scale_tol is not a positive real value.')
end
if (~isa(alpha,'double')) || (~isreal(alpha)) || (any(size(alpha)) ~= 1) || ...
  (alpha < 0) || (alpha > 1)
  nnerr.throw('Alpha is not a real value between 0 and 1.')
end
if (~isa(beta,'double')) || (~isreal(beta)) || (any(size(beta)) ~= 1) || ...
  (beta < 0) || (beta > 1)
  nnerr.throw('Beta is not a real value between 0 and 1.')
end
if (~isa(low_lim,'double')) || (~isreal(low_lim)) || (any(size(low_lim)) ~= 1) || ...
  (low_lim < 0) || (low_lim > 1)
  nnerr.throw('Low_lim is not a real value between 0 and 1.')
end
if (~isa(up_lim,'double')) || (~isreal(up_lim)) || (any(size(up_lim)) ~= 1) || ...
  (up_lim < 0) || (up_lim > 1)
  nnerr.throw('Up_lim is not a real value between 0 and 1.')
end
if (~isa(maxstep,'double')) || (~isreal(maxstep)) || (any(size(maxstep)) ~= 1) || ...
  (maxstep <= 0)
  nnerr.throw('Maxstep is not a positive real value.')
end
if (~isa(minstep,'double')) || (~isreal(minstep)) || (any(size(minstep)) ~= 1) || ...
  (minstep <= 0)
  nnerr.throw('Minstep is not a positive real value.')
end

% TAKE INITIAL STEP
lambda = 1;

% We check influence of this condition on solution. FIND FIRST STEP SIZE
delta_star = abs(-2*ch_perf/dperfa);
lambda = max([lambda delta_star]);

X_temp = X + lambda*dX;
net_temp = setx(net,X_temp);
  
% CALCULATE PERFORMANCE AT NEW POINT
[perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
g_flag = 0;
cnt1 = cnt1 + 1;

count = 0;
% MINIMIZE ALONG A LINE (BACKTRACKING)
retcode = 4;

while retcode>3
  % If NaN we return
  if isnan(perfb)
     perfb=perfa;
     % No change
     a=0;       
     retcode = 0;  
     retcode1 = [cnt1 cnt2 retcode];
     return
  end

  count=count+1;

  % Condition Alpha changed
  if (perfb <= perfa + alpha*lambda*dperfa) || ((perfb<perfa) && (perfa < -alpha*lambda*dperfa))        %CONDITION ALPHA IS SATISFIED
 
    if (g_flag == 0)
      gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfb,Q,TS,fcns);
      dperfb = gX_temp'*dX;
    end
  
    if (dperfb < beta * dperfa)                     %CONDITION BETA IS NOT SATISFIED

      if (start==1) && (norm_dX<maxstep)
        
        % Condition Alpha changed
        while ((perfb<=perfa+alpha*lambda*dperfa) || ((perfb<perfa) && (perfa < -alpha*lambda*dperfa))) ...
            &&(dperfb<beta*dperfa) && (lambda<maxlambda)
          
          % INCREASE STEP SIZE UNTIL BETA CONDITION IS SATISFIED
          
          lambda_old = lambda;
          perfb_old = perfb;
          lambda = min ([2*lambda maxlambda]);
          X_temp = X + lambda*dX;
          net_temp = setx(net,X_temp);
          [perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
          cnt1 = cnt1 + 1;
          g_flag = 0;
          % Condition Alpha changed
          if (perfb <= perfa+alpha*lambda*dperfa) || ((perfb<perfa) && (perfa < -alpha*lambda*dperfa))          
            gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfb,Q,TS,fcns);
            dperfb = gX_temp'*dX;
            g_flag = 1;
          end
        end
      end
    
      if (lambda<1) || ((lambda>1) && (perfb>perfa+alpha*lambda*dperfa))
        lambda_lo = min([lambda lambda_old]);
        lambda_diff = abs(lambda_old - lambda);
    
        if (lambda < lambda_old)
          perf_lo = perfb;
          perf_hi = perfb_old;
        else
          perf_lo = perfb_old;
          perf_hi = perfb;
        end
    
        while (dperfb<beta*dperfa) && (lambda_diff>minlambda)
    
          lambda_incr=-dperfb*(lambda_diff^2)/(2*(perf_hi-(perf_lo+dperfb*lambda_diff)));
          if (lambda_incr<0.2*lambda_diff)
             lambda_incr=0.2*lambda_diff;
          end
      
          %UPDATE X
          lambda = lambda_lo + lambda_incr;
          X_temp = X + lambda*dX;
          net_temp = setx(net,X_temp);
          [perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
          g_flag = 0;
          cnt2 = cnt2 + 1;

          % Condition Alpha changed
          if (perfb > perfa + alpha*lambda*dperfa) && ((perfb>=perfa) || (perfa >= -alpha*lambda*dperfa))
            lambda_diff = lambda_incr;
            perf_hi = perfb;
          else
            gX_temp = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfb,Q,TS,fcns);
            dperfb = gX_temp'*dX;
            g_flag = 1;
            if (dperfb<beta*dperfa)
              lambda_lo = lambda;
              lambda_diff = lambda_diff - lambda_incr;
              perf_lo = perfb;
            end
          end

        end
    
        retcode = 0;

        % IF low perf is smaller than new one, we use smaller.
        if (dperfb < beta*dperfa) || (perf_lo < perfb)    % COULDN'T SATISFY BETA CONDITION
          perfb = perf_lo;
          lambda = lambda_lo;
          X_temp = X + lambda*dX;
          net_temp = setx(net,X_temp);
          [perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
          g_flag = 0;
          cnt2 = cnt2 + 1;
          retcode = 3;
        end
            
      % For large lambda and condition alpha satisfied we must return.
      elseif ((lambda>1) && (perfb<=perfa+alpha*lambda*dperfa))
        retcode = 0;  
      end

      if (lambda*norm_dX>0.99*maxstep)    % MAXIMUM STEP TAKEN
        retcode = 2;
      end

    else
      
      retcode = 0;
    
      if (lambda*norm_dX>0.99*maxstep)    % MAXIMUM STEP TAKEN
        retcode = 2;
      end

    end

  elseif (lambda<minlambda)   % MINIMUM STEPSIZE REACHED

    retcode = 1;

  else    % CONDITION ALPHA IS NOT SATISFIED - REDUCE THE STEP SIZE

    if (start == 1)
      % FIRST BACKTRACK, QUADRATIC FIT
      lambda_temp = -dperfa/(2*(perfb - perfa - dperfa));

    else
      % LOCATE THE MINIMUM OF THE CUBIC INTERPOLATION
      mat_temp = [1/lambda^2 -1/lambda_old^2; -lambda_old/lambda^2 lambda/lambda_old^2];
      mat_temp = mat_temp/(lambda - lambda_old);
      vec_temp = [perfb - perfa - dperfa*lambda; perfb_old - perfa - lambda_old*dperfa];
  
      cub_coef = mat_temp*vec_temp;
      c1 = cub_coef(1); c2 = cub_coef(2);
      disc = c2^2 - 3*c1*dperfa;
      if c1 == 0
        lambda_temp = -dperfa/(2*c2);
      else
        lambda_temp = (-c2 + sqrt(disc))/(3*c1);
      end
    
    end

    % CHECK TO SEE THAT LAMBDA DECREASES ENOUGH
  if lambda_temp > up_lim*lambda
    lambda_temp = up_lim*lambda;
  end
    
  % SAVE OLD VALUES OF LAMBDA AND FUNCTION DERIVATIVE
  lambda_old = lambda;
    perfb_old = perfb;
   
  % CHECK TO SEE THAT LAMBDA DOES NOT DECREASE TOO MUCH
  if lambda_temp < low_lim*lambda
    lambda = low_lim*lambda;
  else
    lambda = lambda_temp;
  end
    
  % COMPUTE PERFORMANCE AND SLOPE AT NEW END POINT
    X_temp = X + lambda*dX;
    net_temp = setx(net,X_temp);
    [perfb,Ac,N,Zb,Zi,Zl] = nnsim.perf(net_temp,P,Pd,Ai,T,EW,Q,TS,fcns);
    g_flag = 0;
    cnt2 = cnt2 + 1;
    
    % Check for lambda NAN
    if isnan(lambda)
      % No change
      a=0;       
      retcode = 0;  
      retcode1 = [cnt1 cnt2 retcode];
      return
   end

  end

start = 0;

end

% We update variables if results OK.
if perfb <= perfa
   if (g_flag == 0)
      gX = -nnprop.grad_s(net_temp,P,Pd,Zb,Zi,Zl,N,Ac,T,EW,perfb,Q,TS,fcns);
   else
      gX = gX_temp;
   end

   a = lambda;
else
   perfb=perfa;
   % No change
   a=0;       
end

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < net.trainParam.delta
  delta = net.trainParam.delta;
end

% We always update the tolerance.
tol=delta/scale_tol;

retcode1 = [cnt1 cnt2 retcode];
end

