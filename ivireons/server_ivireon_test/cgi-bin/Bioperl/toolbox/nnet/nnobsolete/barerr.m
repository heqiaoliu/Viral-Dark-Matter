function barerr(e,t)
%BARERR Plot bar chart of errors.
%
% Obsoleted in R2008b NNET 6.0.  Last used in R2007b NNET 5.1.
%
%  This function is obselete.
%  Use BAR to make bar plots.

nnerr.obs_fcn('barerr','Use BAR to make bar plots.')

%  
%  BARERR(E)
%    E - SxQ matrix of error vectors.
%  Plots bar chart of the squared errors in each column.
%  
%  EXAMPLE: e = [1.0  0.0 -0.2  2.0; 0.5  0.0  0.6 -1.0];
%           barerr(e)
%  
%  See also NNPLOT, ERRSURF, PLOTERR, PLOTES, PLOTEP.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.4 $  $Date: 2010/03/22 04:06:26 $

if nargin < 1, nnerr.throw('Not enough input arguments'),end
if nargin == 2, e = t-e; end

bar(nnsumc(e .* e));
title('Network Errors');
xlabel('Input/Target Pairs')
ylabel('Sum-Squared Error')
