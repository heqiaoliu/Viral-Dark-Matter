function [p dw]=dwtest(r,X,option,alternative)
%DWTEST Durbin-Watson test for autocorrelation in linear regression.
%    [P,DW]=DWTEST(R,X) performs a Durbin-Watson test on the vector R
%    of residuals from a linear regression, where X is the design matrix
%    from that linear regression.  P is the computed p-value for the test,
%    and DW is the Durbin-Watson statistic.  The Durbin-Watson test is used
%    to test if the residuals are uncorrelated, against the alternative that
%    there is autocorrelation among them.
%
%    [...]=DWTEST(R,X,'METHOD') specifies the method to be used in
%    computing the p-value.  'METHOD' can be either of the following:
%       'exact'        Calculate an exact p-value using the PAN algorithm
%                      (default if the sample size is less than 400).
%       'approximate'  Calculate the p-value using a normal approximation
%                      (default if the sample size is 400 or larger).
%
%    [...]=DWTEST(R,X,'METHOD','TAIL') performs the test against the
%    alternative hypothesis specified by TAIL:
%       'both'   "serial correlation is not 0" (two-tailed test, default)
%       'right'  "serial correlation is greater than 0" (right-tailed test)
%       'left'   "serial correlation is less than 0" (left-tailed test)
%
%   Example:
%      % Fit a straight line to the census data and note the 
%      % autocorrelation in the residuals
%      load census
%      n = length(cdate);
%      X = [ones(n,1), cdate];
%      [b,bint,r1] = regress(pop,X);
%      p1 = dwtest(r1,X)
%      plot(cdate,r1,'b-', cdate,zeros(n,1),'k:')
% 
%      % Adding a squared term reduces the autocorrelation but it is still
%      % significantly different from zero
%      X = [ones(n,1), cdate, cdate.^2];
%      [b,bint,r2] = regress(pop,X);
%      p2 = dwtest(r2,X)
%      line(cdate,r2,'color','r')
%     
%   See also REGRESS.

%   Reference:
%   J. Durbin & G.S. Watson (1950), Testing for Serial Correlation in Least
%   Squares Regression I. Biometrika (37), 409-428.
%
%   R.W. Farebrother (1980), Pan's Procedure for the Tail Probabilities of
%   the Durbin-Watson Statistic. Applied Statistics, 29, 224-227.
%
%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:25 $

[n,p] = size(X);   
if  nargin<3
    if n<400
        option = 'exact';
    else 
        option = 'approximate';
    end;        
end;
if   nargin<4    
     alternative = 'both';% Assume the default test is two sided
end;

if ~ismember(lower(alternative),{'both','left','right'})
    error('stats:dwtest:BadAlternative',...
      'The TAIL argument must be ''both'', ''left'', or ''right''.');
end;


dw = sum(diff(r).^2)/sum(r.^2); % durbin-watson statistic

% This calls the function of Pan algorithm/normal approximation
% Recall that the distribution of dw depends on the design matrix
% in the regression.
pdw = pvaluedw(dw,X,option);

% p-value depends on the alternative hypothesis.
switch lower(alternative)
    case 'both'  
        p = 2*min(pdw, 1-pdw); 
    case 'left'
        p = 1-pdw;
    case 'right'
        p = pdw;
end


        
        