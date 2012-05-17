function varargout = berfit(empEbNo, empBER, varargin)
%BERFIT Fit a curve to nonsmooth empirical BER data.
%   FITBER = BERFIT(EMPEbNo, EMPBER) returns a vector of bit error rate (BER)
%   points that have been fitted to the empirical BER data EMPBER. The values in
%   EMPBER and FITBER correspond to the Eb/No values, in dB, given by EMPEbNo.
%
%   FITBER = BERFIT(EMPEbNo, EMPBER, FITEbNo) returns a vector of fitted BER
%   points evaluated at the Eb/No values, in dB, given by FITEbNo.  The length
%   of FITEbNo must equal or exceed that of EMPEbNo.
%
%   FITBER = BERFIT(EMPEbNo, EMPBER, FITEbNo, OPTIONS) uses the structure
%   OPTIONS to override the default options used for optimization.  These
%   options are the ones used by the FMINSEARCH function.  You can create the
%   OPTIONS structure using the OPTIMSET function.  Particularly relevant fields
%   are:
%       OPTIONS.Display      Level of display. 'off' (default) displays no
%                            output; 'iter' displays output at each iteration;
%                            'final' displays just the final output; 'notify'
%                            displays output only if the function does not
%                            converge.
%       OPTIONS.MaxFunEvals  Maximum number of function evaluations before
%                            optimization ceases.  The default is 10000.
%       OPTIONS.MaxIter      Maximum number of iterations before
%                            optimization ceases.  The default is 10000.
%       OPTIONS.TolFun       Termination tolerance on the closed-form
% 	                         function used to generate the fit.  The
%                            default is 1e-4.
%       OPTIONS.TolX         Termination tolerance on the coefficient values
%                            of the functional form used to generate the fit.
%                            The default is 1e-4.
%   
%   FITBER = BERFIT(EMPEbNo, EMPBER, FITEbNo, OPTIONS, FITTYPE) specifies which
%   of four functional forms BERFIT uses to fit the empirical data. FITTYPE can
%   be 'exp', 'exp+const', 'polyRatio', or 'doubleExp+const'. To avoid
%   overriding default options, use OPTIONS = [].
%
%   [FITBER, FITPROPS] = BERFIT(...) returns a structure FITPROPS that describes
%   the results of the curve fit:
%       FITPROPS.fitType     The closed-form function type used to generate
%                            the fit: 'exp', 'exp+const', 'polyRatio', or
%                            'doubleExp+const'.
%       FITPROPS.coeffs      The coefficients used to generate the fit.
%       FITPROPS.sumSqErr    The sum squared error between the log of the
%                            fitted BER points and the log of the empirical BER
%                            points.
%       FITPROPS.exitState   The exit condition of BERFIT: 
%                            'The curve fit converged to a solution', 'The
%                            maximum number of function evaluations was
%                            exceeded', or 'No desirable fit was found'.
%       FITPROPS.funcCount   The number of function evaluations used in
%                            minimizing the sum squared error function.
%       FITPROPS.iterations  The number of iterations taken in minimizing
%                            the sum squared error function (not necessarily
%                            equal to the number of function evaluations).
%
%   BERFIT(...) plots the empirical and fitted BER data.
%
%   BERFIT(EMPEbNo, EMPBER, FITEbNo, OPTIONS, 'all') plots the empirical and
%   fitted BER data from all four possible fits.  To avoid overriding default
%   options, use OPTIONS = [].
%
%   See also FMINSEARCH, OPTIMSET.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/09/13 06:45:56 $

% Begin error checking
% --------------------------------------------------------
%
% Number of input arguments
error(nargchk(2, 5, nargin, 'struct'));

% Number of output arguments
error(nargchk(0, 2, nargout, 'struct'));

% empEbNo
if (isempty(empEbNo) || ~isvector(empEbNo) || ~isnumeric(empEbNo) || ...
    ~isreal(empEbNo) || ~isequal(empEbNo, sort(empEbNo)))
    error('comm:berfit:AscEmpEbNo', ...
        'EMPEbNo must be a vector of ascending, real values');
end

% empBER
if (isempty(empBER) || ~isvector(empBER) || ~isnumeric(empBER) || ...
    ~isreal(empBER) || any(empBER<0) || any(empBER>0.5))
    error('comm:berfit:EmpBERRange', ...
        'EMPBER must be a real vector between 0 and 0.5 inclusive');
end

if (~isequal(length(empEbNo), length(empBER)) || length(empEbNo)<4)
    error('comm:berfit:BERLength', ...
          ['EMPEbNo and EMPBER must be the same length, ' ...
          'and at least 4 elements long']);
end

% Check that empBER has no values of NaN.  If so, strip those values out
% and warn the user.
if (any(isnan(empBER)))
    empEbNo = empEbNo(~isnan(empBER));
    empBER = empBER(~isnan(empBER));
    warning('comm:berfit:BERNaN', ...
        'One or more values of EMPBER is NaN.  Removing NaN-valued EMPBERs');
end
    
% Check that empBER has an overall negative slope
checkMatrix = [empEbNo(:) ones(length(empEbNo),1)];
slopeInt = checkMatrix \ empBER(:);
slope = slopeInt(1);
if (slope > 0)
    error('comm:berfit:EmpBERSlope', 'EMPBER must have a negative slope');
end


% Define several fitType variables in case fitType is not in varargin
valFitType = {'' 'exp' 'exp+const' 'polyRatio' 'doubleExp+const' 'all'};

% Parse the variable length arguments
[fitEbNo, options, fitType] = parseVarargin(varargin, empEbNo, valFitType);

% Check if 'all' is used with output arguments
if (isequal(fitType, 'all') && nargout~=0)
    error('comm:berfit:invalidFitType', ...
        ['If any output arguments are specified for BERFIT, ' ...
        'FITTYPE cannot be ''all''']);
end


% End of input error checking -------------------------------------------------


% Begin curve fitting ---------------------------------------------------------

% Define some variables just so that they exist later.  This will be needed if
% any of the possible fit types are not executed.
coeffsExp = [];   coeffsExpConst = [];   coeffsPoly = [];   coeffsDblExp = [];
sumSqErrExp = inf;sumSqErrExpConst = inf;sumSqErrPoly = inf;sumSqErrDblExp = inf;
exitflagExp = 1;  exitflagExpConst = 1;  exitflagPoly = 1;  exitflagDblExp = 1;
fitPropsExp = []; fitPropsExpConst = []; fitPropsPoly = []; fitPropsDblExp = [];
fitBERExp = [];   fitBERExpConst = [];   fitBERPoly = [];   fitBERDblExp = [];
rejectExp = 0;    rejectExpConst = 0;    rejectPoly = 0;    rejectDblExp = 0;


% Perform a few tests on the data to determine if certain functional fits can be
% eliminated from consideration.
%
% In the first test, filter the log10 of the BER data to remove some noise, and
% take the derivative.  Check whether the last 3 values of that derivative are
% less than -0.5, indicating that the last 3 BER values are falling by half an
% order of magnitude per dB of Eb/No.  If this is the case, run the exponential
% method unless overridden by the user.
%
% In the second test, check whether the last 3 values of the above-referenced
% derivative are greater than -0.1, indicating that an error rate floor may be
% present.  If this is the case, do not run the exponential method unless
% overridden by the user.

runOnlyExpAndPoly = 0;
runExp = 1;
log10EmpBER = log10(empBER);        % use for this test only
filtLength = 3;
filtLogEmpBER = filter(ones(filtLength,1)/filtLength, 1, log10EmpBER);
deriv = diff(filtLogEmpBER) ./ diff(empEbNo);

% Define fitTypes that require exp+const, polyRatio, or doubleExp+const methods
% to be run
fitTypeCheck1 = {'exp+const' 'doubleExp+const' 'all'};
if (~ismember(fitType, fitTypeCheck1))
    if (all(deriv(end-2:end) < -0.5))
        runOnlyExpAndPoly = 1;
    end
end

% Define fitTypes that require exp method to be run
fitTypeCheck2 = {'exp' 'all'};
if (~ismember(fitType, fitTypeCheck2))
    if (all(deriv(end-2:end) > -0.1))
        runExp = 0;
    end
end


% Perform the actual curve fitting.  Begin by initializing the variables of
% interest for fminsearch
empEbNoLin = 10.^(empEbNo/10);
fitEbNoLin = 10.^(fitEbNo/10);
logEmpBER = log(empBER);

% Check if the exponential method is to be attempted
expFitTypes = {'' 'exp' 'all'};
if (ismember(fitType, expFitTypes) && runExp)
    [fitBERExp, coeffsExp, sumSqErrExp, exitflagExp, fitPropsExp, rejectExp] = ...
        getExpFit(options, empEbNoLin, fitEbNoLin, logEmpBER);
end


% Check if the exponential plus constant method is to be attempted
expConstFitTypes = {'' 'exp+const' 'all'};
if (ismember(fitType, expConstFitTypes) && ~runOnlyExpAndPoly)
    [fitBERExpConst, coeffsExpConst, sumSqErrExpConst, exitflagExpConst, fitPropsExpConst, rejectExpConst] = ...
        getExpConstFit(options, empEbNoLin, fitEbNoLin, logEmpBER, fitEbNo);
end


% Check if the ratio of polynomials method is to be attempted
polyFitTypes = {'' 'polyRatio' 'all'};
if (ismember(fitType, polyFitTypes))
    [fitBERPoly, coeffsPoly, sumSqErrPoly, exitflagPoly, fitPropsPoly, rejectPoly] = ...
        getPolyFit(options, empEbNoLin, fitEbNoLin, logEmpBER, fitEbNo);
end


% Check if the double exponential plus constant method is to be attempted
dblExpConstFitTypes = {'' 'doubleExp+const' 'all'};
if (ismember(fitType, dblExpConstFitTypes) && ~runOnlyExpAndPoly)
    [fitBERDblExp, coeffsDblExp, sumSqErrDblExp, exitflagDblExp, fitPropsDblExp, rejectDblExp] = ...
        getDblExpFit(options, empEbNoLin, fitEbNoLin, logEmpBER, fitEbNo);
end


% Collect the output data into regular arrays and cell arrays.  Insert a dummy
% element into the first slot in each array.  This is so the indexing of these
% arrays follows the indexing of the valFitType cell array.
fitCoeffs    = {1 coeffsExp coeffsExpConst coeffsPoly coeffsDblExp};
fitSumSqErr  = [1 sumSqErrExp sumSqErrExpConst sumSqErrPoly sumSqErrDblExp];
fitExitflags = [1 exitflagExp exitflagExpConst exitflagPoly exitflagDblExp];
fitPropsList = {1 fitPropsExp fitPropsExpConst fitPropsPoly fitPropsDblExp};
fitBERs      = {1 fitBERExp fitBERExpConst fitBERPoly fitBERDblExp};
rejectBERs   = [0 rejectExp rejectExpConst rejectPoly rejectDblExp];

fitSumSqErr(rejectBERs>0) = inf;       % Prepare for min function on next line
[minSumSqErr, minIdx] = min(fitSumSqErr(2:end));    % omit the first element
minIdx = minIdx + 1;        % account for omission of first element in search

allTypes = {'' 'all'};
if (ismember(fitType, allTypes))
    % Ensure that at least one fit is not rejected.  If not, then warn the user.
    if (isinf(minSumSqErr))
        warning('comm:berfit:noDesirableFit', ...
            ['No desirable fit was found.  A valid fit must be real valued' ...
             ' and monotonically decreasing between 0 and 0.5 inclusively']);
    end;
else
    rejectID = rejectBERs(rejectBERs > 0);
    if ( ~isempty(rejectID) )
        switch ( rejectID )
            case 2
                warningID = 'comm:berfit:fitIsGreaterThanZeroPointFive';
            case 3
                warningID = 'comm:berfit:fitIsLessThanZero';
            case 4
                warningID = 'comm:berfit:fitIsNonMonotonic';
            case 5
                warningID = 'comm:berfit:fitHasMoreThan1InflPoints';
            case 6
                warningID = 'comm:berfit:fitHasTooMuchSlopeChange';
        end
        warning(warningID, ...
            ['Selected method did not produce a desirable fit.  Rerun with' ...
            ' no output arguments and FITTYPE==''all'' to view all acceptable' ...
            ' fits']);
    end;
end

% End of curve fitting --------------------------------------------------------


% Begin output argument processing --------------------------------------------

fitIdx = find(strcmp(fitType, valFitType));  % Index into valFitType
allIdx = length(valFitType);                 % Index of 'all' option
switch fitIdx
    case 1      % best-fit option
        fitber = fitBERs{minIdx};
        outIdx = minIdx;
    case allIdx % all-fits option
        % Remove the rejected ones from all evaluated fits,  including the
        % dummy at the beginning
        outIdx = 1:length(valFitType)-1;   
        outIdx = outIdx(rejectBERs == 0);
        outIdx = outIdx(2:end);
    otherwise   % user-specified fit option
        fitber = fitBERs{fitIdx};
        outIdx = fitIdx;
end

switch nargout
    case 0          % Plot results
        
        %  Proceed if only there was at least one fit that was not rejected
        if ( ~isinf(minSumSqErr) )
            % Determine which fit is to be plotted:  the best fit, a user-specified
            % fit, or all fits.  The following code uses the fact that the best-fit
            % option is the first one in the valFitType cell array, and the 'all'
            % option is the last one.
            legendFits = {'', 'Exp Fit', 'Exp Plus Const Fit', ...
                'Poly Ratio Fit', 'Dbl Exp Plus Const Fit'};

            switch fitIdx
                case 1      % best-fit option
                    semilogy(empEbNo, empBER, 'x', ...
                        fitEbNo, fitber, 'r');
                    title('BER vs. Eb/No with Best Curve Fit');
                case allIdx % plot all fits
                    lineLable = 'grcmy';
                    semilogy(empEbNo, empBER, 'x');
                    hold on
                    for idx=outIdx
                        semilogy(fitEbNo, fitBERs{idx}, lineLable(idx));
                    end;
                    hold off
                    title('BER vs. Eb/No with All Curve Fits');

                otherwise   % plot a user-specified fit
                    semilogy(empEbNo, empBER, 'x', ...
                        fitEbNo, fitber, 'r');
                    title('BER vs. Eb/No with a User-Specified Curve Fit');
            end
            xlabel('Eb/No (dB)');
            ylabel('BER');
            grid on;
            legend('Empirical BER', legendFits{outIdx}, 'Location', 'SouthWest');
            set(gca, 'YMinorGrid', 'off');

            xMin = min([empEbNo(:); fitEbNo(:)]) - 1;
            xMax = max([empEbNo(:); fitEbNo(:)]) + 1;
            yMin = 10.^(floor(log10(min(empBER))));
            yMax = 10.^(ceil(log10(max(empBER))));
            axis([xMin xMax yMin yMax]);

        end;
    otherwise
        for idx = 1 : nargout
            switch(idx)
                case 1
                    if ( ~isinf(minSumSqErr) )
                        varargout{1} = fitber;
                    else
                        varargout{1} = [];
                    end;
                case 2
                    % Output the properties with calculated values only if
                    % there was at least one fit that was not rejected.
                    % Otherwise, return failure properties
                    if ( ~isinf(minSumSqErr) )
                        % Build up the output fitProps structure
                        fitProps.fitType = valFitType{outIdx};
                        fitProps.coeffs = fitCoeffs{outIdx};
                        fitProps.sumSqErr = fitSumSqErr(outIdx);

                        exitflag = fitExitflags(outIdx);
                        if (exitflag == 1)
                            fitProps.exitState = ...
                                'The curve fit converged to a solution';
                        else
                            if ( regexpi(fitPropsList{outIdx}.message, 'iter') )
                                fitProps.exitState = ...
                                    ['The maximum number of iterations' ...
                                    ' has been exceeded'];
                            else
                                fitProps.exitState = ...
                                    ['The maximum number of function' ...
                                    ' evaluations has been exceeded'];
                            end
                        end

                        fitProps.funcCount = fitPropsList{outIdx}.funcCount;
                        fitProps.iterations = fitPropsList{outIdx}.iterations;
                    else
                        fitProps.fitType = '';
                        fitProps.coeffs = [];
                        fitProps.sumSqErr = Inf;
                        fitProps.exitState = ...
                            'No desirable fit was found';
                        fitProps.funcCount = fitPropsList{outIdx}.funcCount;
                        fitProps.iterations = fitPropsList{outIdx}.iterations;
                    end;
                    varargout{2} = fitProps;
            end
        end
end

%-------------------------------------------------------------------------------
function [fitBERExp, coeffsExp, sumSqErrExp, exitflagExp, fitPropsExp, rejectExp] = ...
    getExpFit(options, empEbNoLin, fitEbNoLin, logEmpBER)
% Set up and execute the exponential fit method.  Choose initial parameters
% such that the starting functional form is the ideal BER expression for
% DBPSK.  (See the subfunction fitErrExp for more details.)  Then calculate
% the fitted BER with the closed-form expression.
paramsExp = [0.5 0 1 1]';
[coeffsExp, sumSqErrExp, exitflagExp, fitPropsExp] = ...
    fminsearch(@fitErrExp, paramsExp, options, empEbNoLin, logEmpBER);

% Calculate BER from fminsearch output.
expExp = (fitEbNoLin - coeffsExp(2)).^coeffsExp(3) / coeffsExp(4);
fitBERExp = coeffsExp(1) * exp(-expExp);

% If the best fit is desired, reject any results that fit the following
% criteria:
% 2. fitted BER points greater than 0.5
% 3. fitted BER points less than 0
% 4. non-monotonic fitted BER
if ( any(fitBERExp > 0.5) )
    rejectExp = 2;
elseif ( any(fitBERExp < 0) )
    rejectExp = 3;
elseif ( nonMono(fitBERExp) )
    rejectExp = 4;
else
    rejectExp = 0;
end

%-------------------------------------------------------------------------------
function [fitBERExpConst, coeffsExpConst, sumSqErrExpConst, exitflagExpConst, fitPropsExpConst, rejectExpConst] = ...
    getExpConstFit(options, empEbNoLin, fitEbNoLin, logEmpBER, fitEbNo)
% Set up and execute the exponential-plus-constant fit method.  Then
% calculate the fitted BER with the closed-form expression.
paramsExpConst = [0.5 0 1 1 0]';
[coeffsExpConst, sumSqErrExpConst, exitflagExpConst, fitPropsExpConst] = ...
    fminsearch(@fitErrExpConst, paramsExpConst, options, empEbNoLin, ...
    logEmpBER);

% Calculate BER from fminsearch output.
exp1 = (fitEbNoLin - coeffsExpConst(2)).^coeffsExpConst(3) / coeffsExpConst(4);
term1 = coeffsExpConst(1) * exp(-exp1);
term2 = coeffsExpConst(5);
fitBERExpConst = term1 + term2;

% If the best fit is desired, reject any results that fit the following
% criteria:
% 2. fitted BER points greater or equal to 1
% 3. fitted BER points less than or equal to 0
% 4. non-monotonic fitted BER
% 6. fitted BER with excessive slope changes
if ( any(fitBERExpConst > 0.5) )
    rejectExpConst = 2;
elseif ( any(fitBERExpConst < 0) )
    rejectExpConst = 3;
elseif ( nonMono(fitBERExpConst) )
    rejectExpConst = 4;
elseif ( tooMuchSlopeChange(fitEbNo, fitBERExpConst) )
    rejectExpConst = 6;
else
    rejectExpConst = 0;
end

%-------------------------------------------------------------------------------
function [fitBERPoly, coeffsPoly, sumSqErrPoly, exitflagPoly, fitPropsPoly, rejectPoly] = ...
    getPolyFit(options, empEbNoLin, fitEbNoLin, logEmpBER, fitEbNo)
% Set up and execute the ratio of polynomials fit method.  Then calculate
% the fitted BER with the closed-form expression.
paramsPoly = [1 1 1 1 1 1]';
[coeffsPoly, sumSqErrPoly, exitflagPoly, fitPropsPoly] = ...
    fminsearch(@fitErrPoly, paramsPoly, options, empEbNoLin, logEmpBER);

% Calculate BER from fminsearch output.
numPoly = coeffsPoly(1)*fitEbNoLin.^2 + coeffsPoly(2)*fitEbNoLin + ...
    coeffsPoly(3);
denPoly = fitEbNoLin.^3 + coeffsPoly(4)*fitEbNoLin.^2 + ...
    coeffsPoly(5)*fitEbNoLin + coeffsPoly(6);
fitBERPoly = numPoly ./ denPoly;

% If the best fit is desired, reject any results that fit the following
% criteria:
% 2. fitted BER points greater or equal to 1
% 3. fitted BER points less than or equal to 0
% 4. non-monotonic fitted BER
% 5. fitted BER with more than one inflection point
if ( any(fitBERPoly > 0.5) )
    rejectPoly = 2;
elseif ( any(fitBERPoly < 0) )
    rejectPoly = 3;
elseif ( nonMono(fitBERPoly) )
    rejectPoly = 4;
elseif ( numInflPts(fitEbNo, fitBERPoly)>1 )
    rejectPoly = 5;
else
    rejectPoly = 0;
end

%-------------------------------------------------------------------------------
function [fitBERDblExp, coeffsDblExp, sumSqErrDblExp, exitflagDblExp, fitPropsDblExp, rejectDblExp] = ...
    getDblExpFit(options, empEbNoLin, fitEbNoLin, logEmpBER, fitEbNo)
% Set up and execute the double exponential plus constant fit method.  Then
% calculate the fitted BER with the closed-form expression.
paramsDblExp = [0.5 0 1 1 0.1 0 1 1 0]';
[coeffsDblExp, sumSqErrDblExp, exitflagDblExp, fitPropsDblExp] = ...
    fminsearch(@fitErrDblExp, paramsDblExp, options, empEbNoLin, logEmpBER);

% Calculate BER from fminsearch output.
exp1 = (fitEbNoLin - coeffsDblExp(2)).^coeffsDblExp(3) / coeffsDblExp(4);
term1 = coeffsDblExp(1) * exp(-exp1);
exp2 = (fitEbNoLin - coeffsDblExp(6)).^coeffsDblExp(7) / coeffsDblExp(8);
term2 = coeffsDblExp(5) * exp(-exp2);
fitBERDblExp = term1 + term2 + coeffsDblExp(9);

% If the best fit is desired, reject any results that fit the following
% criteria:
% 2. fitted BER points greater or equal to 1
% 3. fitted BER points less than or equal to 0
% 4. non-monotonic fitted BER
% 5. fitted BER with more than one inflection point
% 6. fitted BER with excessive slope changes
if ( any(fitBERDblExp > 0.5) )
    rejectDblExp = 2;
elseif ( any(fitBERDblExp < 0) )
    rejectDblExp = 3;
elseif ( nonMono(fitBERDblExp) )
    rejectDblExp = 4;
elseif ( numInflPts(fitEbNo, fitBERDblExp)>1 )
    rejectDblExp = 5;
elseif ( tooMuchSlopeChange(fitEbNo, fitBERDblExp) )
    rejectDblExp = 6;
else
    rejectDblExp = 0;
end

%-------------------------------------------------------------------------------
function sumSqErr = fitErrExp(a, x, logEmpBER)
% This function uses an exponential fit to the empirical BER data.  The equation
% is
%                BER ~= a1 * exp(-((x-a2).^a3)/a4)
%
% where x = empEbNoLin.  This function is used as a function handle for
% fminsearch.

exponent = (x - a(2)).^a(3) / a(4);
fitBER = a(1) * exp(-exponent);
fitBER(fitBER<=0) = 1e-30;    % Ensure a real value of logFitBER and sumSqErr
logFitBER = log(fitBER);
sumSqErr = sum((logEmpBER - logFitBER).^2);

% If complex return inf to move away from this point
if ~isreal(sumSqErr)
    sumSqErr = inf;
end

%-------------------------------------------------------------------------------
function sumSqErr = fitErrExpConst(a, x, logEmpBER)
% This function uses an exponential plus a constant to model the BER curve.  The
% actual equation is
%
%             BER ~= a1 * exp(-((x-a2).^a3)/a4) + a5
%
% where x = empEbNoLin.  This function is used as a function handle for
% fminsearch.

exponent1 = (x - a(2)).^a(3) / a(4);
term1 = a(1) * exp(-exponent1);
fitBER = term1 + a(5);

fitBER(fitBER<=0) = 1e-30;    % Ensure a real value of logFitBER and sumSqErr
logFitBER = log(fitBER);
sumSqErr = sum((logEmpBER - logFitBER).^2);

% If complex return inf to move away from this point
if ~isreal(sumSqErr)
    sumSqErr = inf;
end

%-------------------------------------------------------------------------------
function sumSqErr = fitErrPoly(a, x, logEmpBER)
% This function uses a ratio of a second-degree polynomial to a third-degree
% polynomial to model the BER curve.  The actual equation is
%
%                            a1*x.^2 + a2*x + a3
%                 BER ~= ----------------------------
%                         x.^3 + a4*x.^2 + a5*x + a6
%
% where x = empEbNoLin.  This function is used as a function handle for
% fminsearch.

numPoly = a(1)*x.^2 + a(2)*x + a(3);
denPoly = x.^3 + a(4)*x.^2 + a(5)*x + a(6);
fitBER = numPoly ./ denPoly;
fitBER(fitBER<=0) = 1e-30;    % Ensure a real value of logFitBER and sumSqErr
logFitBER = log(fitBER);
sumSqErr = sum((logEmpBER - logFitBER).^2);

%-------------------------------------------------------------------------------
function sumSqErr = fitErrDblExp(a, x, logEmpBER)
% This function uses a double exponential plus constant fit to the empirical BER
% data.  The equation is
%
%                BER ~= a1 * exp(-((x-a2).^a3)/a4) + 
%                       a5 * exp(-((x-a6).^a7)/a8) + a9
%
% where x = empEbNoLin.  This function is used as a function handle for
% fminsearch.

exponent1 = (x - a(2)).^a(3) / a(4);
term1 = a(1) * exp(-exponent1);
exponent2 = (x - a(6)).^a(7) / a(8);
term2 = a(5) * exp(-exponent2);
fitBER = term1 + term2 + a(9);

fitBER(fitBER<=0) = 1e-30;    % Ensure a real value of logFitBER and sumSqErr
logFitBER = log(fitBER);
sumSqErr = sum((logEmpBER - logFitBER).^2);

% If complex return inf to move away from this point
if ~isreal(sumSqErr)
    sumSqErr = inf;
end

%-------------------------------------------------------------------------------
function numPts = numInflPts(fitEbNo, fitBER)
% This function determines if the log10 of the fitted BER curve has more than
% one inflection point.  Such a curve is unacceptable as a fit, and so must be
% rejected.  In such a case, the curve fit is rejected by raising its sum
% squared error to a very high value.

deriv1 = diff(log10(fitBER)) ./ diff(fitEbNo);
deriv2 = diff(deriv1) ./ diff(fitEbNo(2:end));
qDeriv2 = sign(deriv2);         % retain only the sign
qChange2 = diff(qDeriv2);       % find where the sign changes
numPts = length(find(qChange2~=0));     % # of inflection pts

%-------------------------------------------------------------------------------
function isNonMono = nonMono(fitBER)
% This function checks for a non-monotonic fitted BER.

[sortDim, sortDimIdx] = max(size(fitBER));
isNonMono = ~isequal(fitBER, sort(fitBER, sortDimIdx, 'descend'));

%-------------------------------------------------------------------------------
function tooMuch = tooMuchSlopeChange(fitEbNo, fitBER)
% This function checks whether the slope of the fitted BER has excessive
% changes, and if so, raises the sum squared error to a very high value so as to
% reject the fit.  The function checks whether the slope change is less than -10
% orders of magnitude per dB^2 at any instant, and greater than 10 orders of
% magnitude per dB^2 at some other instant.

deriv1 = diff(log10(fitBER)) ./ diff(fitEbNo);
deriv2 = diff(deriv1) ./ diff(fitEbNo(2:end));
tooMuch = any(deriv2<-10) && any(deriv2>10);

%-------------------------------------------------------------------------------
function [fitEbNo, options, fitType] = parseVarargin(varargin, empEbNo, valFitType)

% Set the default options structure prior to checking it in the varargin list
options = optimset('Display', 'off', 'MaxFunEvals', 10000, ...
    'MaxIter', 10000, 'TolFun', 1e-4, 'TolX', 1e-4);

% Varargin arguments
if (isempty(varargin))
    fitEbNo = empEbNo;
end

% Set the default value for fitType
fitType = '';       % This value of fitType is not part of the published API


for idx = 1 : length(varargin)
    switch(idx)
        case 1      % fitEbNo is being specified
            if (isempty(varargin{1}))
                fitEbNo = empEbNo;
            else
                fitEbNo = varargin{1};
                if (~isvector(fitEbNo) || ~isnumeric(fitEbNo) || ...
                    ~isreal(fitEbNo))
                    error('comm:berfit:RealFitEbNo', ...
                        'FITEbNo must be a vector of real values');
                end
                fitEbNo = sort(fitEbNo);
            end
            
            if (length(fitEbNo) < length(empEbNo))
                error('comm:berfit:lengthFitEbNo', ...
                    'The length of FITEbNo must be at least that of EMPEbNo');
            end
            
            % Warn if the user is extrapolating BER data
            if (min(fitEbNo) < min(empEbNo) || ...
                max(fitEbNo) > max(empEbNo))
                warning('comm:berfit:extrapolate', ...
                    ['BERFIT is being used to extrapolate BER data.  ' ...
                     'Results may be unreliable beyond an order of ' ...
                     'magnitude below the smallest empirical BER']);
            end
            
        case 2      % options is being specified
            if (~isempty(varargin{2}))
                newOpts = varargin{2};
                options = optimset(options, newOpts);  % optimset does the 
                                                       % error checking
            end
                
        case 3      % fitType is being specified
            fitType = varargin{3};
            if (~ischar(fitType) || ~ismember(fitType, valFitType))
                error('comm:berfit:invalidFitType', ...
                    ['When specified, FITTYPE must be one of the following:' ...
                     '\n     ''exp'', ''exp+const'', ''polyRatio'',' ...
                     ' ''doubleExp+const'', or ''all''']);
            end
    end
end

% [EOF]
