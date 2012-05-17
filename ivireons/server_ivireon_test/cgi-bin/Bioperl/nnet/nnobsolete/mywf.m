function z=mywf(w,p)
%MYWF Example custom weight function.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  This function is obselete.
%  Use TEMPLATE_WEIGHT to design your function.

nnerr.obs_fcn('mywf','Use TEMPLATE_WEIGHT to design your function.')

%  Use this function as a template to write your own function.
%  
%  Calculation Syntax
%
%    Z = mywf(W,P)
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%      Z - SxQ matrix of Q weighted input (column) vectors.
%
%  Information Syntax
%
%    info = mytf(code) returns useful information for each CODE string:
%      'version' - Returns the Neural Network Toolbox version (3.0).
%      'deriv'   - Returns the name of the associated derivative function.
%
%  Example
%
%    w = rand(1,5);
%    p = rand(5,1);
%    z = mywf(w,p)

% Copyright 1997-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

if nargin < 1, nnerr.throw('Not enough arguments.'); end

if ischar(w)
  switch (w)
    case 'version'
    a = 3.0;       % <-- Must be 3.0.
    
    case 'deriv'
    a = 'mydtf';   % <-- Replace with the name of your
                   %     associated function or ''
    otherwise
      nnerr.throw('Unrecognized code.')
  end

else
% **  Replace the following calculation with your
% **  weighting calculation.  The only constraint, if you
% **  want to define a derivative function, is that Z must
% **  be a sum of i terms, where each ith term is only a
% **  a function of w(i) and p(i).

  z = w*(p.^2);
end
