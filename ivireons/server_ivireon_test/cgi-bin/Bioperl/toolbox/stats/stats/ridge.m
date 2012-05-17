function b = ridge(y,X,k,flag)
%RIDGE Ridge regression.
%   B1 = RIDGE(Y,X,K) returns the vector B1 of regression coefficients
%   obtained by performing ridge regression of the response vector Y
%   on the predictors X using ridge parameter K.  The matrix X should
%   not contain a column of ones.  The results are computed after
%   centering and scaling the X columns so they have mean 0 and
%   standard deviation 1.  If Y has n observations, X is an n-by-p
%   matrix, and K is a scalar, the result B1 is a column vector with p
%   elements.  If K has m elements, B1 is p-by-m.
%
%   B0 = RIDGE(Y,X,K,0) performs the regression without centering and
%   scaling.  The result B0 has p+1 coefficients, with the first being
%   the constant term.   RIDGE(Y,X,K,1) is the same as RIDGE(Y,X,K).
%
%   The relationship between B1 and B0 is as follows:
%
%      m = mean(X);
%      s = std(X,0,1)';
%      temp = B1./s;
%      B0 = [mean(Y)-m*temp; temp]
%
%   In general, B1 is more useful for producing ridge traces (see the
%   following example) where the coefficients are displayed on the same
%   scale.  B0 is more useful for making predictions.
%
%   Example:  Create a ridge trace (plot of the coefficients as a
%             function of the ridge parameter) for the Hald data:
%      load hald
%      k = 0:.01:1;
%      b = ridge(heat, ingredients, k);
%      plot(k, b');
%      xlabel('Ridge parameter'); ylabel('Standardized coef.');
%      title('Ridge Trace for Hald Data')
%      legend('x1','x2','x3','x4');
%
%   See also REGRESS, STEPWISE.

%   Some authors use a different scaling.  The ridge function scales
%   X to have standard deviation 1, but for example Draper and Smith
%   (Applied Regression Analysis, 3rd ed., 1998) scale X so that the
%   sum of squared deviations of each column from its mean is n.
%   This has the effect of rescaling K by the factor n.  In the
%   example above where n=13, the following produces results comparable
%   to those of Draper and Smith results using coefficients on the
%   original scale:
%      b = ridge(heat,ingredients,k*13,0);
%      plot(k,b(2:5,:)')

%   You can use the B0 coefficients directly to make predictions at new X
%   values. To use B1 to make predictions, you have to invert the above
%   relationship:  Ypred = mean(Y) + ((Xpred-m)./s')*B1

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:19 $

if nargin < 3,              
    error('stats:ridge:TooFewInputs',...
          'Requires at least three input arguments.');      
end 

if nargin<4 || isempty(flag) || isequal(flag,1)
   unscale = false;
elseif isequal(flag,0)
   unscale = true;
else
   error('stats:ridge:BadScalingFlag','The scaling flag must be 0 or 1.');
end

% Check that matrix (X) and left hand side (y) have compatible dimensions
[n,p] = size(X);

[n1,collhs] = size(y);
if n~=n1, 
    error('stats:ridge:InputSizeMismatch',...
          'The number of rows in Y must equal the number of rows in X.'); 
end 

if collhs ~= 1, 
    error('stats:ridge:InvalidData','Y must be a column vector.'); 
end

% Remove any missing values
wasnan = (isnan(y) | any(isnan(X),2));
if (any(wasnan))
   y(wasnan) = [];
   X(wasnan,:) = [];
   n = length(y);
end

% Normalize the columns of X to mean zero, and standard deviation one.
mx = mean(X);
stdx = std(X,0,1);
idx = find(abs(stdx) < sqrt(eps(class(stdx)))); 
if any(idx)
  stdx(idx) = 1;
end

MX = mx(ones(n,1),:);
STDX = stdx(ones(n,1),:);
Z = (X - MX) ./ STDX;
if any(idx)
  Z(:,idx) = 1;
end

% Compute the ridge coefficient estimates using the technique of
% adding pseudo observations having y=0 and X'X = k*I.
pseudo = sqrt(k(1)) * eye(p);
Zplus  = [Z;pseudo];
yplus  = [y;zeros(p,1)];

% Set up an array to hold the results
nk = numel(k);

% Compute the coefficient estimates
b = Zplus\yplus;

if nk>1
   % Fill in more entries after first expanding b.  We did not pre-
   % allocate b because we want the backslash above to determine its class.
   b(end,nk) = 0;
   for j=2:nk
      Zplus(end-p+1:end,:) = sqrt(k(j)) * eye(p);
      b(:,j) = Zplus\yplus;
   end
end

% Put on original scale if requested
if unscale
   b = b ./ repmat(stdx',1,nk);
   b = [mean(y)-mx*b; b];
end
