function [muL muR sigma, rhoL, rhoR] = dualDiracTailFitting(this, rHist) %#ok
% DUALDIRACTAILFITTING Estimate the dual-Dirac parameters
%   [MUL MUR SIGMA RHOL RHOR] = DUALDIRACTAILFITTING(THIS, RHIST) estimates the
%   dual-Dirac parameters:
%   MUL: left Dirac function position
%   MUR: right Dirac function position
%   SIGMA: standard deviation of the Gaussian distribution
%   RHOL: amplitude of the left Dirac function
%   RHOR: amplitude of the right Dirac function
%   The input RHIST is a row vector and represents the histogram of the input
%   PDF.

%   @commscope/@eyemeaurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/13 04:14:24 $

% Calculate the PDF.
totalPopulation = sum(rHist);
pdfEst = rHist / totalPopulation;

% Make sure that the PDF has no holes by discarding bins separated from the main
% PDF by holes (bins with zero hits), i.e. set bins to the left (right) of the
% last hole from the left (right) to zeros.  Assumes that the tails of the two
% PDFs do not overlap.
idxNonZero = find(pdfEst~=0);
if ( length(idxNonZero) == 1 )
    muL = idxNonZero;
    muR = idxNonZero;
    sigma = 0;
    rhoL = 1;
    rhoR = 1;
    return;
end

% Fill in the zero population bins with 0.5/totalPopulation.
diffIdxNonZero = diff(idxNonZero);
for p=1:max(diffIdxNonZero)-1
    pdfEst(idxNonZero(diffIdxNonZero>p)+p) = 0.5/totalPopulation;
end

% The fitting algorithm works on the logarithm of the Gaussian PDF.  Calculate
% logatihm of the estimated PDF.  Also, prepare the time vector.  Replace 0 
% with NaN to avoid warning.
pdfEst(pdfEst==0) = NaN;
logPdfEst = log(pdfEst);
t = 0:1:(length(pdfEst)-1);

% Search from start to end.
nf = findNoiseFloor(logPdfEst);
idxNonZero = find(logPdfEst>nf);
idxLMin = idxNonZero(1);
idxRMax = idxNonZero(end);
minP = 3;
maxP = (idxRMax-idxLMin);

if ( maxP <= minP )
    % This must be a really narrow peaks.  It is not dual-dirac.  It has no
    % noise.
    muL = idxNonZero(1);
    muR = idxNonZero(end);
    sigma = 0;
    rhoL = 1;
    rhoR = 1;
else

    % Start the search
    mse = zeros(1,maxP);
    muLVec = zeros(1,maxP);
    muRVec = zeros(1,maxP);
    sigmaVec = zeros(1,maxP);
    rhoLVec = zeros(1,maxP);
    rhoRVec = zeros(1,maxP);
    for p=minP:maxP

        idxL = idxLMin+(0:p);
        idxR = idxRMax-(0:p);

        [muL, muR, sigma, rhoL, rhoR] = ...
            fitDualDiracLogGaussWeightedAnalytic(t(idxL), t(idxR), ...
            logPdfEst(idxL), logPdfEst(idxR));

        muLVec(p) = muL;
        muRVec(p) = muR;
        sigmaVec(p) = sigma;
        rhoLVec(p) = rhoL;
        rhoRVec(p) = rhoR;

        pdfLEst = rhoL*gaussian(muL, sigma, t);
        pdfREst = rhoR*gaussian(muR, sigma, t);

        mse(p) = mspe([pdfEst(idxL) pdfEst(idxR)], [pdfLEst(idxL) pdfREst(idxR)]);
    end

    % Eliminate complex fits
    findComplex = abs(imag(mse)) + abs(imag(rhoLVec)) + abs(imag(rhoRVec))...
        + abs(imag(sigmaVec)) + abs(imag(muLVec)) + abs(imag(muRVec));
    mse(findComplex~=0)=inf;

    % Eliminate fits with Gaussian bigger than the PDF.  Since sigma can be zero, 
    % instead of dividing on the right hand side, multiply on the left hand side.
    mse((2*max(pdfEst(idxL))*sigmaVec) < rhoLVec/sqrt(2*pi)) = inf;
    mse((2*max(pdfEst(idxR))*sigmaVec) < rhoRVec/sqrt(2*pi)) = inf;

    % Search the peak in a continuous region that does not include the
    % disqualified values.  First find all continuous regions of
    % disqualified values.
    disQualIdx = find(isinf(mse));
    regionBoundaries = find(diff(disQualIdx)~=1);
    if isempty(regionBoundaries)
        regions = [min(disQualIdx) max(disQualIdx)];
    else
        regions(1,:) = [disQualIdx(1), disQualIdx(regionBoundaries(1))];
        for p=2:length(regionBoundaries)
            regions(p,:) = disQualIdx([regionBoundaries(p-1)+1, regionBoundaries(p)]);
        end
        regions(length(regionBoundaries)+1,:) = [disQualIdx(regionBoundaries(end)+1), disQualIdx(end)];
    end
    if ~isempty(regions)
        % Reassign search field
        for p=1:size(regions,1)
            % If the lower bound of the region is greater than 43% of the whole 
            % region, then assign this lower bound as the upper bound for the
            % search region.
            if regions(p,1) > (length(mse)*0.43)
                maxP = regions(p,1)-1;
            end
            % If the upper bound of the region is less than 57% of the whole
            % region, then assign this upper bound as the lower bound for the
            % search region.
            if regions(p,2) < (length(mse)*0.57)
                minP = regions(p,2)+1;
            end
        end
    end

    % If the upper bound is greater than the lower bound (there is a region
    % to search) or not all of the mse values in the search region are
    % disqualifed, then look for the best fit.
    if (maxP > minP) && ~all(isinf(mse(minP:maxP) ))

        % Find a peak in the qualified region
        if (maxP-minP) < 3
            % findpeaks cannot work with less then 3 data points
            [val2 idx2] = max(-mse(minP:maxP));
        else
            warnState = warning('query', 'signal:findpeaks:noPeaks');
            warning('off', 'signal:findpeaks:noPeaks');
            [val2 idx2] = findpeaks(-mse(minP:maxP));
            warning(warnState);
        end
        if ~isempty(idx2)
            [~, idx3] = max(val2);
            idx2 = idx2(idx3);
            idx = idx2;
        else
            [~, idx] = min(mse(minP:maxP));
        end

        % Assign the best fit values to output variables
        muVec = [muLVec(idx+(minP-1)) muRVec(idx+(minP-1))];
        rhoVec = [rhoLVec(idx+(minP-1)) rhoRVec(idx+(minP-1))];
        sigma = sigmaVec(idx+(minP-1));

        % Make sure that the smaller mu value is muL
        [muL idxL] = min(muVec);
        [muR idxR] = max(muVec);
        rhoL = rhoVec(idxL);
        rhoR = rhoVec(idxR);
    else
        % No dual-Dirac Gaussian fit was found.  Sigma should be too small
        % to estimate, or effectively zero for us.
        muL = idxNonZero(1);
        muR = idxNonZero(end);
        sigma = 0;
        rhoL = 1;
        rhoR = 1;
    end
end

%-------------------------------------------------------------------------------
function [muL muR sigma ampL ampR] = ...
    fitDualDiracLogGaussWeightedAnalytic(xL, xR, yL, yR)
% FITDUALDIRACLOGGAUSSWEIGHTEDANALYTIC Fit the left and right tail of a PDF
%   estimate to a Log-Gaussian curve.  This is basically a second order
%   polynomial fit since we fit the Gaussian curve in the log domain.
%
%   Reference: Data Reduction and Error Analysis for Physical Sciences, P.R.
%   Bevington, McGraw-Hill

% We need to normalize to assure the proper numerical accuracy
normFactor = max(xR);
xL = xL/normFactor;
xR = xR/normFactor;

% Calculate the weights for the fitting algorithm
wL = (sqrt(yL)).^2;
wR = (sqrt(yR)).^2;

% Calculate the linear equation coefficients
sumxL0 = sum(wL);
sumxL1 = sum(wL.*xL);
sumxL2 = sum(wL.*xL.^2);
sumxL3 = sum(wL.*xL.^3);
sumxL4 = sum(wL.*xL.^4);

sumxR0 = sum(wR);
sumxR1 = sum(wR.*xR);
sumxR2 = sum(wR.*xR.^2);
sumxR3 = sum(wR.*xR.^3);
sumxR4 = sum(wR.*xR.^4);

sumyxL0 = sum(yL.*wL);
sumyxL1 = sum(yL.*wL.*xL);
sumyxL2 = sum(yL.*wL.*xL.^2);

sumyxR0 = sum(yR.*wR);
sumyxR1 = sum(yR.*wR.*xR);
sumyxR2 = sum(yR.*wR.*xR.^2);

% Create the linear equation matrices A and B
A = [sumxL4+sumxR4 sumxL3 sumxR3 sumxL2 sumxR2; ...
    sumxL3 sumxL2 0 sumxL1 0; ...
    sumxR3 0 sumxR2 0 sumxR1; ...
    sumxL2 sumxL1 0 sumxL0 0; ...
    sumxR2 0 sumxR1 0 sumxR0];
B = [sumyxL2+sumyxR2 sumyxL1 sumyxR1 sumyxL0 sumyxR0]';

% Here is the result
if rank(A) < length(A)
    x = pinv(A)*B;
else
    x = A\B;
end

% Calculate fir parameters
sigma = sqrt(-1/(2*x(1)));

muL = x(2)*sigma^2;
muR = x(3)*sigma^2;

ampL = exp(x(4)+muL^2/(2*sigma^2)+log(sqrt(2*pi)*sigma));
ampR = exp(x(5)+muR^2/(2*sigma^2)+log(sqrt(2*pi)*sigma));

% Correct for normalization
sigma = sigma * normFactor;
muL = muL * normFactor;
muR = muR * normFactor;
ampL = ampL * normFactor;
ampR = ampR * normFactor;

%-------------------------------------------------------------------------------
function mse = mspe(x, y)
% Mean Square Percent Error
%   X: data
%   Y: estimate

mse = mean(((x - y)./x).^2);

%-------------------------------------------------------------------------------
function y = gaussian(mu, sigma, x)
% Generate a Gaussian pulse
%   GAUSSIAN(MU, SIGMA, T)
%   MU : mean value
%   SIGMA: standard deviation
%   x: time vector

y = exp(-((x-mu).^2)/(2*sigma^2))/(sqrt(2*pi)*sigma);
%-------------------------------------------------------------------------------
function nf = findNoiseFloor(x)
% Find the noise floor

minVal = min(x);
maxVal = max(x);
stepSize = (maxVal-minVal)/100;
threshold = minVal + (maxVal-minVal)*3/4;

found = 0;
while ~found
    idx = find(x>minVal);
    if all(diff(idx)==1)
        found = 1;
    else
        minVal = minVal + stepSize;
    end
end

nf = minVal;

% Check if noise floor is too high that we eliminate all the data points.  

if nf > threshold
    % The PDF estimate is too noisy.  Use all the available points and hope for
    % the best.  For a better estimate, we need more data.
    nf = min(x);
end

%-------------------------------------------------------------------------------
% [EOF]
