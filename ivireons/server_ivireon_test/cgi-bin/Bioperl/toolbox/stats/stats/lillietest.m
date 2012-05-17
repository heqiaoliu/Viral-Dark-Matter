function [H,pValue,KSstatistic,criticalValue] = lillietest(x,alpha,distr,mctol)
%LILLIETEST Lilliefors' composite goodness-of-fit test.
%   H = LILLIETEST(X) performs Lilliefors goodness-of-fit test of composite
%   normality, i.e., that the data in the vector X came from an unspecified
%   normal distribution, and returns the result of the test in H. H=0
%   indicates that the null hypothesis ("the data are normally distributed")
%   cannot be rejected at the 5% significance level. H=1 indicates that the
%   null hypothesis can be rejected at the 5% level.
%
%   LILLIETEST treats NaNs as missing values, and ignores them.
%
%   Lilliefors' test is a 2-sided goodness-of-fit test suitable for situations
%   where a fully-specified null distribution is not known, and its parameters
%   must be estimated. In contrast, the usual one-sample Kolmogorov-Smirnov
%   test requires that the null distribution be completely specified. Critical
%   values, computed using Monte-Carlo simulation, have been been tabulated
%   for sample sizes N <= 1000 and significance levels 0.001 <= ALPHA <= 0.50.
%   LILLIETEST computes a critical value for a given test by interpolating
%   into that table or using an analytic approximation to extrapolate for
%   larger sample sizes.
%
%   Let S(x) be the empirical c.d.f. estimated from the sample vector X, and
%   CDF be the c.d.f. for a normal distribution with mean and standard
%   deviation equal to the MEAN(X) and STD(X). The Lilliefors hypotheses and
%   test statistic are:
%
%             Null Hypothesis:  X is normally distributed with unspecified
%                               mean and standard deviation.
%      Alternative Hypothesis:  X is not normally distributed.
%              Test Statistic:  KSSTAT = max|S(x) - CDF|.
%
%   H = LILLIETEST(X,ALPHA) performs the test at significance level ALPHA.
%   ALPHA is a scalar in the range 0.001 <= ALPHA <= 0.50.  To perform the
%   test at significance levels outside that range, use the MCTOL input
%   argument.
%
%   H = LILLIETEST(X,ALPHA,DISTR) performs the test of the null hypothesis
%   that X came from the location-scale family of distributions specified by
%   DISTR.  DISTR is 'norm' (normal), 'exp' (exponential), or 'ev' (extreme
%   value). Lilliefors' test can not be used when the null hypothesis is not a
%   location-scale family of distributions.
%
%   [H,P] = LILLIETEST(...) returns the p-value P, computed using inverse
%   interpolation into the look-up table of critical values. Small values of P
%   cast doubt on the validity of the null hypothesis. LILLIETEST warns when P
%   is not found within the limits of the table, i.e., outside the interval
%   [0.001, 0.50], and returns one or the other endpoint of that interval. In
%   this case, you can use the MCTOL input argument to compute a more
%   accurate value.
%
%   [H,P,KSTAT] = LILLIETEST(...) returns the test statistic KSTAT.
%
%   [H,P,KSTAT,CRITVAL] = LILLIETEST(...) returns the critical value CRITVAL
%   for the test. When KSTAT > CRITVAL, the null hypothesis can be rejected
%   at a significance level of ALPHA.
%
%   [H,P,...] = LILLIETEST(X,ALPHA,DISTR,MCTOL) computes a Monte-Carlo
%   approximation for P directly, rather than using interpolation of the
%   pre-computed tabulated values.  This is useful when ALPHA or P is outside
%   the range of the look-up table.  LILLIETEST chooses the number of MC
%   replications, MCREPS, large enough to make the MC standard error for P,
%   SQRT(P*(1-P)/MCREPS), less than MCTOL.
%
%   See also JBTEST, KSTEST, KSTEST2, CDFPLOT.

% Copyright 1993-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1.2.1 $   $ Date:  $

% References:
%   [1] Conover, W.J. (1980) Practical Nonparametric Statistics, Wiley.
%   [2] Lilliefors, H.W. (1967) "On the Kolmogorov-Smirnov test for normality
%       with mean and variance unknown", J.Am.Stat.Assoc. 62:399-402.
%   [3] Lilliefors, H.W. (1969) "On the Kolmogorov-Smirnov test for the
%       exponential distribution with mean unknown", J.Am.Stat.Assoc.
%       64:387-389.

% Ensure the sample data is a vector.
if ~isvector(x) || ~isreal(x)
    error('stats:lillietest:BadData',...
          'Input sample X must be a vector of real values.');
end

% Remove missing observations indicated by NaN's, and ensure that
% at least 4 valid observations remain.
x  =  x(~isnan(x));       % Remove missing observations indicated by NaN's.
x  =  x(:);               % Ensure a column vector.
if length(x) < 4
   error('stats:lillietest:NotEnoughData',...
         'Sample vector X must have at least 4 valid observations.');
end

if nargin < 2 || isempty(alpha)
   alpha = 0.05;
else
   if ~isscalar(alpha) || ~(0<alpha && alpha<1)
      error('stats:lillietest:BadAlpha',...
            'Significance level ALPHA must be a scalar between 0 and 1.');
   end
end

if nargin < 3 || isempty(distr)
    distr = 'norm';
end

if nargin < 4 || isempty(mctol)
    mctol = [];
else
   if ~isscalar(mctol) || mctol<=0
      error('stats:lillietest:BadMCReps',...
            'Monte-Carlo standard error tolerance MCTOL must be a positive scalar value.');
   end
end

% Calculate S(x), the sample CDF.
[sampleCDF,xCDF,n,emsg,eid] = cdfcalc(x);
if ~isempty(eid)
   error(sprintf('stats:lillietest:%s',eid),emsg);
end

% Estimate parameters for the data, and compute the CDF under the null hypothesis.
switch distr
case 'norm'
    nullCDF = normcdf(xCDF, mean(x), std(x));
case 'exp'
    nullCDF = expcdf(xCDF, mean(x));
case 'ev'
    phat = evfit(x);
    nullCDF = evcdf(xCDF, phat(1), phat(2));
otherwise
    error('stats:lillietest:BadDistr',...
          'DISTR must be ''norm'', ''exp'', or ''ev''.');
end

% Compute the test statistic of interest: T = max|S(x) - nullCDF(x)|.
delta1   = sampleCDF(1:end-1) - nullCDF;   % Vertical difference at jumps approaching from the LEFT.
delta2   = sampleCDF(2:end)   - nullCDF;   % Vertical difference at jumps approaching from the RIGHT.
deltaCDF = abs([delta1 ; delta2]);

KSstatistic = max(deltaCDF);

% Compute the critical value for acceptance or rejection of the null
% hypothesis using tabulated values.
if isempty(mctol)
    % Get a row of the critical value table for the current sample size.
    switch distr
    case 'norm', [alphas,CVs] = CVtbl_norm(n);
    case 'exp',  [alphas,CVs] = CVtbl_exp(n);
    case 'ev',   [alphas,CVs] = CVtbl_ev(n);
    end

    % Make sure requested alpha is within the look-up table.
    if (alpha < alphas(1)) || (alphas(end) < alpha)
        error('stats:lillietest:BadAlpha',...
              ['Significance level ALPHA is outside the range of the tabulated values.\n' ...
               'Use a value in the interval [%g, %g], or use the MCTOL input argument.'], ...
               alphas(1),alphas(end));
    end

    % 1-D interpolation into the tabulated quantiles.
    pp = pchip(alphas,CVs);
    criticalValue = ppval(pp,alpha);
    
    % Compute the P-value. Warn if the P-value is not found within the
    % available 'alphas' of the table and return one of the extremes.
    if nargout > 1
        if (KSstatistic < CVs(end)) % smallest critval at end
            warning('stats:lillietest:OutOfRangeP',...
                    'P is greater than the largest tabulated value, returning %.3g.',alphas(end));
            pValue = alphas(end);
        elseif (CVs(1) < KSstatistic) % largest critval at beginning
            warning('stats:lillietest:OutOfRangeP',...
                    'P is less than the smallest tabulated value, returning %.3g.',alphas(1));
            pValue = alphas(1);
        elseif (KSstatistic == CVs(1))
            pValue = alphas(1);
        else
            % 1-D inverse interpolation into the tabulated quantiles.
            i = find(KSstatistic > CVs, 1, 'first');
            pValue = fzero(@(x) ppval(pp,x)-KSstatistic,alphas([i-1 i]));
        end
    end

% Compute the critical value and p-value on the fly using Monte-Carlo simulation.
else
    [criticalValue,pValue] = lillieMC(KSstatistic,n,alpha,distr,mctol);
end

% Returning "H = 0" implies that we "Do not reject the null hypothesis at the
% significance level of alpha" and "H = 1" implies that we "Reject the null
% hypothesis at significance level of alpha."
H = double(KSstatistic > criticalValue);


% ----------------------------------------------------------------------
function [alphas,CVs] = CVtbl_norm(n)
% Tabulated critical values for Lilliefors normal test

alphas = [0.001 0.0015 0.002 0.005 0.01 0.015 0.02 0.05 0.10 0.15 0.20 0.50];
if n <= 20
    % An improved version of Lilliefors' table for the quantiles.
    sampleSizes = (4:20)'; % Sample sizes for each row of 'quantiles'.
    quantiles =  ...
        [0.4328 0.4308 0.4292 0.4217 0.4131 0.4065 0.4008 0.3754 0.3453 0.3213 0.3028 0.2581
         0.4386 0.4335 0.4291 0.4128 0.3966 0.3851 0.3756 0.3431 0.3189 0.3026 0.2893 0.2332
         0.4225 0.4152 0.4091 0.3878 0.3703 0.3599 0.3521 0.3236 0.2973 0.2810 0.2688 0.2187
         0.4006 0.3931 0.3873 0.3677 0.3506 0.3397 0.3317 0.3041 0.2802 0.2643 0.2523 0.2062
         0.3828 0.3749 0.3692 0.3494 0.3326 0.3223 0.3146 0.2880 0.2651 0.2502 0.2387 0.1947
         0.3656 0.3582 0.3524 0.3332 0.3171 0.3071 0.2997 0.2740 0.2520 0.2379 0.2271 0.1851
         0.3509 0.3428 0.3377 0.3185 0.3034 0.2938 0.2866 0.2620 0.2410 0.2274 0.2171 0.1767
         0.3374 0.3305 0.3252 0.3067 0.2915 0.2823 0.2754 0.2515 0.2312 0.2181 0.2082 0.1695
         0.3253 0.3184 0.3131 0.2955 0.2808 0.2714 0.2647 0.2418 0.2224 0.2098 0.2002 0.1631
         0.3147 0.3074 0.3021 0.2849 0.2706 0.2618 0.2553 0.2333 0.2145 0.2025 0.1932 0.1574
         0.3033 0.2970 0.2923 0.2756 0.2619 0.2536 0.2473 0.2257 0.2075 0.1958 0.1868 0.1522
         0.2960 0.2893 0.2844 0.2673 0.2539 0.2457 0.2398 0.2189 0.2012 0.1898 0.1811 0.1475
         0.2884 0.2821 0.2772 0.2604 0.2472 0.2390 0.2331 0.2126 0.1953 0.1843 0.1759 0.1433
         0.2800 0.2736 0.2688 0.2532 0.2403 0.2324 0.2266 0.2068 0.1900 0.1792 0.1711 0.1393
         0.2732 0.2667 0.2621 0.2465 0.2341 0.2265 0.2208 0.2013 0.1850 0.1746 0.1666 0.1358
         0.2660 0.2602 0.2556 0.2408 0.2285 0.2209 0.2155 0.1965 0.1806 0.1703 0.1625 0.1324
         0.2603 0.2545 0.2503 0.2352 0.2232 0.2159 0.2105 0.1920 0.1763 0.1663 0.1587 0.1294];

    % Get the appropriate row of approximate quantiles.
    CVs = quantiles(n==sampleSizes,:);

else
    % An improved version of Lilliefors' asymptotic approximation for the quantiles.
    CVs = [1.239 1.210 1.189 1.115 1.058 1.023 0.9964 0.9092 0.8358 0.7893 0.7539 0.6183] ./ sqrt(n) ...
        - [0.1725 0.1909 0.1978 0.1580 0.1582 0.1639 0.1540 0.1652 0.1626 0.1654 0.1678 0.1671] ./ n ...
        - [0.7237 0.5838 0.5180 0.5654 0.4871  0.4140 0.4180 0.2731 0.2215 0.1729 0.1323 0.04738] ./ n.^1.5;
end


% ----------------------------------------------------------------------
function [alphas,CVs] = CVtbl_exp(n)
% Tabulated critical values for Lilliefors exponential test

alphas = [0.001 0.0015 0.002 0.005 0.01 0.015 0.02 0.05 0.10 0.15 0.20 0.50];
if n <= 20
    % An improved version of Lilliefors' table for the quantiles.
    sampleSizes = (4:20)'; % Sample sizes for each row of 'quantiles'.
    quantiles =  ...
        [0.6212 0.6096 0.6019 0.5788 0.5575 0.5430 0.5314 0.4843 0.4444 0.4200 0.4009 0.3165
         0.5802 0.5705 0.5629 0.5369 0.5129 0.4966 0.4845 0.4422 0.4046 0.3795 0.3605 0.2877
         0.5507 0.5392 0.5312 0.5008 0.4757 0.4599 0.4484 0.4085 0.3732 0.3500 0.3320 0.2645
         0.5190 0.5068 0.4988 0.4702 0.4466 0.4317 0.4202 0.3813 0.3485 0.3266 0.3099 0.2458
         0.4909 0.4798 0.4712 0.4437 0.4206 0.4065 0.3961 0.3589 0.3274 0.3070 0.2913 0.2309
         0.4680 0.4563 0.4480 0.4216 0.3997 0.3861 0.3757 0.3405 0.3102 0.2907 0.2759 0.2186
         0.4475 0.4368 0.4289 0.4025 0.3805 0.3673 0.3577 0.3242 0.2955 0.2768 0.2626 0.2082
         0.4307 0.4199 0.4123 0.3865 0.3655 0.3528 0.3431 0.3103 0.2826 0.2646 0.2510 0.1991
         0.4138 0.4032 0.3963 0.3716 0.3513 0.3391 0.3298 0.2984 0.2716 0.2544 0.2412 0.1913
         0.3977 0.3880 0.3813 0.3579 0.3388 0.3267 0.3177 0.2870 0.2614 0.2449 0.2323 0.1842
         0.3864 0.3765 0.3699 0.3467 0.3276 0.3158 0.3072 0.2777 0.2526 0.2365 0.2243 0.1778
         0.3738 0.3641 0.3574 0.3351 0.3172 0.3058 0.2974 0.2690 0.2445 0.2290 0.2172 0.1721
         0.3628 0.3540 0.3470 0.3251 0.3071 0.2962 0.2881 0.2604 0.2370 0.2219 0.2104 0.1668
         0.3524 0.3439 0.3375 0.3166 0.2993 0.2883 0.2803 0.2532 0.2303 0.2157 0.2046 0.1622
         0.3441 0.3357 0.3295 0.3079 0.2911 0.2806 0.2729 0.2466 0.2243 0.2101 0.1991 0.1577
         0.3364 0.3278 0.3215 0.3006 0.2840 0.2738 0.2661 0.2404 0.2186 0.2046 0.1940 0.1538
         0.3288 0.3197 0.3138 0.2938 0.2774 0.2672 0.2597 0.2344 0.2132 0.1997 0.1893 0.1501];

    % Get the appropriate row of approximate quantiles.
    CVs = quantiles(n==sampleSizes,:);

else
    % An improved version of Lilliefors' asymptotic approximation for the quantiles.
    CVs = [1.544 1.500 1.472 1.377 1.299 1.249 1.214 1.094 0.9954 0.9322 0.8843 0.7056] ./ sqrt(n) ...
        - [0.3558 0.3058 0.3233  0.3535 0.3127 0.2727 0.2549 0.2010 0.1871 0.1713 0.1592 0.1517] ./ n ...
        - [-0.1120 0.03913 -0.0726 -0.3270 -0.2395 -0.1372 -0.09488 0.006818 -0.002656 0.01954 0.04151 0.009159] ./ n.^1.5;
end


% ----------------------------------------------------------------------
function [alphas,CVs] = CVtbl_ev(n)
% Tabulated critical values for Lilliefors extreme value test

alphas = [0.001 0.0015 0.002 0.005 0.01 0.015 0.02 0.05 0.10 0.15 0.20 0.50];
if n <= 20
    % An improved version of Lilliefors' table for the quantiles.
    sampleSizes = (4:20)'; % Sample sizes for each row of 'quantiles'.
    quantiles =  ...
        [0.4668 0.4628 0.4594 0.4439 0.4309 0.4221 0.4150 0.3847 0.3502 0.3330 0.3232 0.2758
         0.4497 0.4418 0.4363 0.4153 0.3961 0.3844 0.3765 0.3512 0.3273 0.3100 0.2957 0.2460
         0.4207 0.4122 0.4066 0.3876 0.3715 0.3611 0.3532 0.3244 0.3015 0.2865 0.2746 0.2248
         0.3984 0.3913 0.3851 0.3648 0.3483 0.3384 0.3310 0.3051 0.2818 0.2670 0.2558 0.2103
         0.3784 0.3707 0.3648 0.3459 0.3300 0.3200 0.3127 0.2875 0.2660 0.2517 0.2408 0.1982
         0.3625 0.3548 0.3487 0.3296 0.3142 0.3045 0.2974 0.2730 0.2523 0.2388 0.2283 0.1876
         0.3473 0.3398 0.3340 0.3151 0.3004 0.2911 0.2842 0.2606 0.2405 0.2276 0.2176 0.1787
         0.3312 0.3244 0.3192 0.3021 0.2875 0.2786 0.2721 0.2496 0.2303 0.2178 0.2083 0.1710
         0.3193 0.3127 0.3079 0.2910 0.2772 0.2686 0.2622 0.2401 0.2215 0.2094 0.2002 0.1642
         0.3102 0.3034 0.2980 0.2813 0.2673 0.2589 0.2527 0.2317 0.2136 0.2019 0.1930 0.1582
         0.2981 0.2920 0.2875 0.2713 0.2580 0.2501 0.2442 0.2237 0.2063 0.1950 0.1864 0.1528
         0.2896 0.2835 0.2789 0.2634 0.2506 0.2426 0.2367 0.2167 0.1998 0.1888 0.1804 0.1479
         0.2825 0.2761 0.2710 0.2560 0.2434 0.2357 0.2300 0.2103 0.1939 0.1833 0.1752 0.1436
         0.2758 0.2694 0.2647 0.2493 0.2367 0.2293 0.2238 0.2048 0.1886 0.1782 0.1702 0.1396
         0.2683 0.2620 0.2575 0.2426 0.2304 0.2231 0.2177 0.1993 0.1836 0.1735 0.1658 0.1358
         0.2609 0.2553 0.2511 0.2365 0.2248 0.2177 0.2125 0.1944 0.1791 0.1693 0.1617 0.1324
         0.2552 0.2498 0.2458 0.2314 0.2198 0.2127 0.2075 0.1897 0.1747 0.1651 0.1578 0.1293];

    % Get the appropriate row of approximate quantiles.
    CVs = quantiles(n==sampleSizes,:);

else
    % An improved version of Lilliefors' asymptotic approximation for the quantiles.
    CVs = [1.214 1.186 1.166 1.096 1.039 1.005 0.9796 0.8950 0.8242 0.7794 0.7453 0.6131] ./ sqrt(n) ...
        - [0.1899 0.2157 0.2329 0.2218 0.1974 0.1833 0.1812 0.1686 0.1612 0.1630 0.1645 0.1596] ./ n ...
        - [0.6016 0.4132 0.3075 0.2306 0.2498 0.2481 0.2217 0.1801 0.1341 0.09096 0.05882 -0.01397] ./ n.^1.5;
end


% ----------------------------------------------------------------------
function [crit,p] = lillieMC(KSstat,n,alpha,distr,mctol)
%LILLIEMC Simulated critical values and p-values for Lilliefors' test.
%   [CRIT,P] = LILLIEMC(KSSTAT,N,ALPHA,DISTR,MCTOL) returns the critical value
%   CRIT and p-value P for Lilliefors' test of the null hypothesis that data
%   were drawn from a distribution in the family DISTR, for a sample size N
%   and confidence level 100*(1-ALPHA)%.  P is the p-value for the observed
%   value KSSTAT of the Kolmogorov-Smirnov statistic.  DISTR is 'norm', 'exp',
%   'or 'ev'. ALPHA is a scalar or vector.  LILLIEMC uses Monte-Carlo
%   simulation to approximate CRIT and P, and chooses the number of MC
%   replications, MCREPS, large enough to make the standard error for P,
%   SQRT(P*(1-P)/MCREPS), less than MCTOL.

vartol = mctol^2;

crit = 0;
p = 0;
mcRepsTot = 0;
mcRepsMin = 1000;
while true
    mcRepsOld = mcRepsTot;
    mcReps = ceil(mcRepsMin - mcRepsOld);
    KSstatMC = zeros(mcReps,1);

    switch distr

    % Simulate critical values for the normal
    case 'norm'
        mu0 = 0; sigma0 = 1;
        yCDF = (0:n)'/n;
        for rep = 1:length(KSstatMC)
            x = normrnd(mu0,sigma0,n,1);
            xCDF = sort(x); % unique values, no need for ECDF
            nullCDF = normcdf(xCDF, mean(x), std(x)); % MLE fit to the data
            delta1  = yCDF(1:end-1) - nullCDF;
            delta2  = yCDF(2:end)   - nullCDF;
            KSstatMC(rep) = max(abs([delta1; delta2]));
        end

    % Simulate critical values for the exponential
    case 'exp'
        mu0 = 1;
        yCDF = (0:n)'/n;
        for rep = 1:length(KSstatMC)
            x = exprnd(mu0,n,1);
            xCDF = sort(x); % unique values, no need for ECDF
            nullCDF = expcdf(xCDF, mean(x)); % MLE fit to the data
            delta1  = yCDF(1:end-1) - nullCDF;
            delta2  = yCDF(2:end)   - nullCDF;
            KSstatMC(rep) = max(abs([delta1; delta2]));
        end

    % Simulate critical values for the extreme value
    case 'ev'
        mu0 = 0; sigma0 = 1;
        yCDF = (0:n)'/n;
        for rep = 1:length(KSstatMC)
            x = evrnd(mu0,sigma0,n,1);
            xCDF = sort(x); % unique values, no need for ECDF
            phat = evfit(x); % MLE fit to the data
            nullCDF = evcdf(xCDF, phat(1), phat(2));
            delta1  = yCDF(1:end-1) - nullCDF;
            delta2  = yCDF(2:end)   - nullCDF;
            KSstatMC(rep) = max(abs([delta1; delta2]));
        end
    end

    critMC = prctile(KSstatMC,100*(1-alpha));
    pMC = sum(KSstatMC > KSstat) ./ mcReps;

    mcRepsTot = mcRepsOld + mcReps;
    crit = (mcRepsOld*crit + mcReps*critMC) / mcRepsTot;
    p = (mcRepsOld*p + mcReps*pMC) / mcRepsTot;

    % Compute a std err for p, with lower bound (1/N)*(1-1/N)/N when p==0.
    sepsq = max(p*(1-p)/mcRepsTot, 1/mcRepsTot^2);
    if sepsq < vartol
        break
    end

    % Based on the current estimate, find the number of trials needed to
    % make the MC std err less than the specified tolerance.
    mcRepsMin = 1.2 * (mcRepsTot*sepsq)/vartol;
end
