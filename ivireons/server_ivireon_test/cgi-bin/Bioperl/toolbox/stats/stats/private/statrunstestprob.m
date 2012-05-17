function p=statrunstestprob(N,m,n,R,updown)
%STATRUNSTESTPROB Compute probabilities for values of runs statistic
%   STATRUNSTESTPROB(N,n,m,R,false) computes the probability of R runs in a
%   sequence of N binary values with n ones and m zeros in a random order.
%   N, m, and n must be integer scalars, but R can be an array of any size.
%   This function is used by the RUNSTEST function and it is not meant to
%   be called directly.
%
%   STATRUNSTESTPROB(N,n,m,R,true) computes the probability of R runs 
%   up or down in a sequence of N distinct numbers in a random order.
%
%   See also RUNSTEST.

%   Copyright 2005-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:26 $

if nargin~=5   % minimal error checking to detect a bad call
   error('stats:statrunstestprob:BadInput','Wrong number of input arguments.');
end
if isempty(R)
    p = R;
    return
end

persistent rundist
if updown
    % Get pre-calculated results stored in a mat file
    if isempty(rundist)
        temp = load('rundist');
        rundist = temp.rundist;
    end

    % Note that m and n are not used here
    if N<=1 || N>length(rundist)
        error('stats:statrunstestprob:BadN','Bad value of N.');
    end
    M = rundist{N};
    p = M / sum(M);
    p = p(R);

else  % runs above/below
    if m==0 || n==0
        p = double(R==1);   % must have exactly one run in this case
        return
    end
    mod2 = mod(R,2);
    p = zeros(size(R));
    t = (mod2 == 0);
    if any(t)
        % If R=2k is even, the answer is
        %     2*C(m-1,k-1)*C(n-1,k-1)/C(N,n)
        % where C(a,b) is the binomial coefficient "a choose b"
        k = R(t)/2;
        p(t) = 2 * exp(logNchooseK(m-1,k-1) + logNchooseK(n-1,k-1) - ...
                       logNchooseK(N,n));
    end
    t = ~t;
    if any(t)
        % If R=2k+1 is odd, the answer is
        %     (C(m-1,k-1)*C(n-1,k) + C(m-1,k)*C(n-1,k-1)) / C(N,n)
        k = floor(R(t)/2);
        logdenom = logNchooseK(N,n);
        p(t) = exp(logNchooseK(m-1,k-1) + logNchooseK(n-1,k) - logdenom) + ...
               exp(logNchooseK(m-1,k) + logNchooseK(n-1,k-1) - logdenom);
    end 
end

% -------------------------------------
function a=logNchooseK(N,n)
%LOGNCHOOSEK Compute the log of the binomial coefficient, N choose K
%   Note:  unlike NCHOOSEK, here the inputs are treated as counts
%   rather than as vectors of values to choose.  If N or K is an array,
%   then LOGNCHOOSEK simply calculates its results for all array values.

%     logNchooseK(N,n)
% is the same as
%     log(factorial(N)/(factorial(n)*factorial(N-n)))
% which is the same as
%     log(gamma(N+1)/(gamma(n+1)*gamma(N-n+1)))
% which is the same as the following:

a = gammaln(N+1) - gammaln(n+1) - gammaln(N-n+1);