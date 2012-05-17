function pdw = pvaluedw(dw,X,option)
%PVALUEDW  p-value of the Durbin-Watson statistic for linear regression.
%    PDW = PVALUEDW(DW,X,'METHOD') finds the probability that the Durbin-Watson
%    statistic is greater than DW for a linear regression with the design 
%    matrix X.  'METHOD' can be either of the following:
%       'exact'        Calculate an exact p-value using the PAN algorithm
%                      (default if the sample size is less than 400).
%       'approximate'  Calculate the p-value using a normal approximation.
%                      (default if the sample size is 400 or larger).
%     
%   See also DWTEST, REGRESS.

%   Reference:
%   R.W. Farebrother (1980), Pan's Procedure for the Tail Probabilities of
%       the Durbin-Watson Statistic. Applied Statistics, 29, 224-227.

%   Copyright 1993-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:57 $


[n,p] = size(X);

if ~strcmpi(option, 'approximate') && ~strcmpi(option, 'exact')...
        &&~strcmpi(option, 'approx')
    error('stats:pvaluedw:BadMethod',...
          'The METHOD argument must be ''approximate'' or ''exact''.');      
end;
    
if strcmpi(option, 'exact')
    % The following is sgguested by Cleve Moler for the efficient
    % computation of the eigen values of (I-X*inv(X'X)*X')*A
    % The method requires only the last n-p columns of Q.  These could
    % be computed without computing all of Q by using a "qrfactor" followed 
    % by "qrapply" approach that is available in LAPACK     
    [Q,ignore] = qr(X); 
    k = (p+1):n;
    Q = Q(:,k);
    T = [zeros(1,n-p); Q] - [Q; zeros(1,n-p)];
    e3 = sort(svd(T).^2);
    
    % This the Pan algorithm which has described in the reference.
    pdw = pan_alg(e3,dw,n);        
    
    % Pan may not fail some range of dw, so we force to use an approximate
    % method instead.
    if pdw>1 || pdw<0
        warning('stats:pvaluedw:BadMethod',...
          'The exact method is impossible. Will be forced to use approximate method.') 
        option = 'approximate';
    end;
end;

if strcmpi(option, 'approximate') || strcmpi(option, 'approx')     %approximation by normal 
    % the mean and standard deviation are computed to approximate the dw
    % statistic. The detailed formula can be found in Durbin and Watson 's
    % first paper about this test. (Biometrika)
    Q1 = (X'*X)\eye(p);  % 
    B = filter([-1,2,-1],1,X);
    B([1,n],:) = X([1,n],:)-X([2,n-1],:);
    C = X'*B*Q1;
    nu1 = 2*(n - 1)-trace(C);
    nu2 = 2*(3*n-4) - 2*trace(B'*B*Q1)+trace(C^2);  
    mu = nu1/(n-p);
    sigma =sqrt( 2/((n-p)*(n-p+2))*(nu2-nu1*mu));
    
    % evaluate the probability using normcdf
    pdw = normcdf(dw,mu,sigma);   
end;


% -------------------------------------    
function SUM  = pan_alg(lambda,dw,N) 
% Pan algorithm

M = length(lambda);
mu = find(lambda(:)>=dw,1);

% If there are no eigen values greater than DW statistic, p-value=0.
% This ensures the H-2*floor(H/2) is not 0.
if isempty(mu)
    SUM=0; 
    return;
end;

% These are parameters for numerical integration  
mu = mu - 1;
H = M - mu;
if H>mu
    D = 2; H = mu; K = -1;
    J1 = 0; J2 = 2; J3 = 3; J4 = 1;
else
    D = -2; mu = mu + 1; J1 = M - 2;
    J2 = M - 1; J3 = M + 1; J4 = M; K = 1;
end;

% Numerical integration starts here
% This is the heart of the Pan algorithm
% Durbin and Watson cited this algorithm in their third paper in
% Biometrika.

SUM = (K + 1)/2;
SGN = K /N;
for  L1 = H-2*floor(H/2):-1:0
    for L2 = J2:D:mu
        SUM1 = lambda(J4);
        if L2==0
            PROD = dw;
        else
            PROD = lambda(L2);
        end;
        U = 0.5 * (SUM1 + PROD);
        V = 0.5 * (SUM1 - PROD);
        SUM1 = 0;
        for  I = 1:2:(2*N - 1)
            Y = U - V * cos(I*pi/N);
            PROD = prod((Y-dw) ./ (Y - lambda([1:J1,J3:M])));
            SUM1 = SUM1 + sqrt(abs(PROD));
        end;
        SGN = -SGN;
        SUM = SUM + SGN * SUM1;
        J1 = J1 + D; J3 = J3 + D; J4 = J4 + D;
    end;
    if (D == 2) 
        J3 = J3 - 1;
    else
        J1 = J1 + 1;
    end
    J2 = 0; mu = 0;
end;
