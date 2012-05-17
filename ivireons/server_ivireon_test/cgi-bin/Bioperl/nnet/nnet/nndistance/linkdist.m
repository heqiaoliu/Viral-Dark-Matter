function out1 = linkdist(in1,in2,in3,in4,in5)
%LINKDIST Link distance function.
%
% <a href="matlab:doc linkdist">linkdist</a>(P) takes an RxQ matrix P of Q R-element column vectors, and
% returns a QxQ matrix of the distances between each of the Q vectors.
%
% The link distance between two vectors P(:,i) and P(:,j) is
% calculated as D(i,j) =
%
%   0, if i==j
%   1, if sum((P(i,:)-P(j,:)).^2).^0.5 is <= 1
%   2, if k exists, Dik = Dkj = 1
%   3, if k1, k2 exist, Dik1 = Dk1k2 = Dk2j = 1.
%   N, if k1..kN exist, Dik1 = Dk1k2 = ...= DkNj = 1
%   R, if none of the above conditions apply.
%
% For instance, here the distances between 12 neurons arranged in an
% 4x3 hexagonal grid are calculated.
%
%   positions = <a href="matlab:doc hextop">hextop</a>(4,3);
%   distances = <a href="matlab:doc linkdist">linkdist</a>(pos);
%
% Here is how to assign this function to define the distances in the same
% way between the neurons in layer i of a network. Then the neuron's
% positions and distances can be accessed:
%
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_topologyFcn">topologyFcn</a> = '<a href="matlab:doc hextop">hextop</a>';
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distanceFcn">distanceFcn</a> = '<a href="matlab:doc linkdist">linkdist</a>';
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distances">distances</a>
%
% <a href="matlab:doc linkdist">linkdist</a>, like all distance functions, may be used as a weight function.
%
% Z = <a href="matlab:doc linkdist">linkdist</a>(W,P) takes an SxR weight matrix and RxQ input matrix and
% returns the SxQ matrix of distances between W's rows and P's columns.
% <a href="matlab:doc linkdist">linkdist</a>(P',P) returns the same result as <a href="matlab:doc linkdist">linkdist</a>(P).
%
% See <a href="matlab:doc dotprod">dotprod</a> for more information on how weight functions are used.
%
% See also DIST, MANDIST, LINKDIST, DOTPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8.2.1 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Distance Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  if ischar(in1)
    switch in1
      
      case 'dist'
        % this('dist',p,param)
        nnassert.minargs(nargin,1);
        if nargin < 2, in2 = INFO.defaultParam; end
        out1 = calc_dist(in1,in2);
        
      case 'apply'
        % this('apply',w,p,param)
        nnassert.minargs(nargin,3);
        if nargin < 3, in3 = INFO.defaultParam; end
        out1 = apply(in1,in2,in3);
        
      case 'dz_dp'
        % this('dz_dp',w,p,z,param)
        if nargin < 3, nnerr.throw('Not enough input arguments.'); end
        if nargin < 4, in4 = apply(in2,in3,INFO.defaultParam); end
        if nargin < 5, in5 = INFO.defaultParam; end
        out1 = dz_dp(in2,in3,in4,in5);
        
      case 'dz_dp_num'
        % this('dz_dp_num',w,p,z,param)
        if nargin < 3, nnerr.throw('Not enough input arguments.'); end
        if nargin < 4, in4 = apply(in2,in3,INFO.defaultParam); end
        if nargin < 5, in5 = INFO.defaultParam; end
        out1 = dz_dp_num(in2,in3,in4,in5);
        
      case 'dz_dw'
        % this('dz_dw',w,p,z,param)
        if nargin < 4, nnerr.throw('Not enough input arguments.'); end
        if nargin < 4, in4 = apply(in2,in3,INFO.defaultParam); end
        if nargin < 5, in5 = INFO.defaultParam; end
        out1 = dz_dw(in2,in3,in4,in5);
        
      case 'dz_dw_num'
        % this('dz_dw_num',w,p,z,param)
        if nargin < 4, nnerr.throw('Not enough input arguments.'); end
        if nargin < 4, in4 = apply(in2,in3,INFO.defaultParam); end
        if nargin < 5, in5 = INFO.defaultParam; end
        out1 = dz_dw_num(in2,in3,in4,in5);
        
      case 'info',
        out1 = INFO;
      case 'check_param'
        out1 = check_param(in2);
      case 'size',
        if nargin < 3,nnerr.throw('Not enough arguments for action ''size''.'); end
        if nargin < 4, in4 = INFO.defaultParam; end
        out1 = weight_size(in2,in3,in4);
        
      % NNET 6.0 Compatibility
      case 'name', info = get_info; out1 = info.name;
      case 'dp', out1 = dz_dp(in2,in3,in4,in5);
      case 'dw', out1 = dz_dw(in2,in3,in4,in5);

      % Info field access
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
    return
  elseif (nargin == 3)
    out1 = apply(in1,in2,in3);
  elseif (nargin == 2) && isnumeric(in2)
    in3 = INFO.defaultParam;
    out1 = apply(in1,in2,in3);
  elseif (nargin == 2)
    out1 = calc_dist(in1,in2);
  elseif nargin == 1
    in2 = INFO.defaultParam;
    out1 = calc_dist(in1,in2);
  else
    nnerr.throw('Unrecognized input arguments.')
  end
end

function d = dz_dp_num(w,p,z,param)
  delta = 1e-7;
  [S,R] = size(w);
  [R,Q] = size(p);
  d = cell(1,Q);
  for q=1:Q
    pq = p(:,q);
    dq = zeros(S,R);
    for i=1:R
      z1 = apply(w,addp(pq,i,+2*delta),param);
      z2 = apply(w,addp(pq,i,+delta),param);
      z3 = apply(w,addp(pq,i,-delta),param);
      z4 = apply(w,addp(pq,i,-2*delta),param);
      dq(:,i) = (-z1 + 8*z2 - 8*z3 + z4) / (12*delta);
    end
    d{q} = dq;
  end
end

function n = addp(n,i,v)
  n(i) = n(i) + v;
end

function d = dz_dw_num(w,p,z,param)
  delta = 1e-7;
  [S,R] = size(w);
  Q = size(p,2);
  d = cell(1,S);
  for i=1:S
    wi = w(i,:);
    di = zeros(R,Q);
    for j=1:R
      z1 = apply(addw(wi,j,+2*delta),p,param);
      z2 = apply(addw(wi,j,+delta),p,param);
      z3 = apply(addw(wi,j,-delta),p,param);
      z4 = apply(addw(wi,j,-2*delta),p,param);
      di(j,:) = (-z1 + 8*z2 - 8*z3 + z4) / (12*delta);
    end  
    d{i} = di;
  end
end

function n = addw(n,i,v)
  n(i) = n(i) + v;
end

function sf = subfunctions
  sf.is_dotprod = strcmp(mfilename,'dotprod');
  sf.p_deriv = p_deriv;
  sf.w_deriv = w_deriv;
  sf.calc_dist = @calc_dist;
  sf.weight_size = @weight_size;
  sf.apply = @apply;
  sf.dz_dp = @dz_dp;
  sf.dz_dw = @dz_dw;
  sf.dz_dp_num = @dz_dp_num;
  sf.dz_dw_num = @dz_dw_num;
end

function info = get_info
  info = nnfcnDistance(mfilename,function_name,7,subfunctions,...
    is_continuous,p_deriv,w_deriv,parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'Link'; end
function flag = is_continuous, flag = false; end
function d = p_deriv, d = 1; end
function d = w_deriv, d = 1; end
function param = parameters, param = []; end

function err = check_param(param)
  err = '';
end

function d = calc_dist(pos,param)
  s = size(pos,2);
  found = eye(s,s);
  links = double((dist(pos) <= 1.00001) & ~found);
  d = s*(1-eye(s,s));
  for i=1:s
    nextfound = (found*links) | found;
    newfound = nextfound & ~found;
    ind = find(newfound);
    if isempty(ind)
      break;
    end
    d(ind) = i;
    found = nextfound;
  end
end

function dim = weight_size(s,r,param)
  dim = [s r];
end

function d = apply(w,p,param)
  d = [];
end

function dp = dz_dp(w,p,z,param) % TODO
  dp = [];
end

function dz = dz_dw(w,p,z,param) % TODO
  dz = [];
end
