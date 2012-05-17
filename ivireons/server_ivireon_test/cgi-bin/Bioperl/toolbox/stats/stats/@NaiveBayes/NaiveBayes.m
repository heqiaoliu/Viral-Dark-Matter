classdef NaiveBayes
%NAIVEBAYES Naive Bayes classifier.
%   A NaiveBayes object defines a Naive Bayes classifier.  A Naive Bayes
%   classifier assigns a new observation to the most probable class,
%   assuming the features are conditionally independent given the class
%   value.
%
%   A NaiveBayes object can't be created by calling the constructor.
%   Use NAIVEBAYES.FIT to create a NaiveBayes object by fitting the
%   object to training data.
%   
%   NaiveBayes properties:
%       NClasses    - Number of classes.
%       NDims       - Number of dimensions.
%       ClassLevels - Class levels.
%       CIsNonEmpty - Flag for non-empty classes.
%       Params      - Parameter estimates.
%       Prior       - Class priors.
%       Dist        - Distribution names.
%
%   NaiveBayes methods:
%       fit (static) - Fit a Naive Bayes classifier to the training data.
%       predict      - Predicted class label for test data.
%       posterior    - Posterior probability of each class for test data.
%
%   Examples:
%      % Predict the class label using the Naive Bayes classifier
%      load fisheriris
%      % Use the default Gaussian distribution
%      O1 = NaiveBayes.fit(meas,species);
%      C1 = O1.predict(meas);
%      cMat1 = confusionmat(species,C1) % the confusion matrix
%      % Use the Gaussian distribution for feature 1 and 3 and use the
%      % kernel density estimation for feature 2 and 4.
%      O2 = NaiveBayes.fit(meas,species, ...
%             'dist',{'normal', 'kernel','normal','kernel'});
%      C2 = O2.predict(meas);
%      cMat2 = confusionmat(species,C2) % the confusion matrix
%
%      % Generate data from two classes with Normal distribution (the first
%      % feature) and Multinomial distribution(the second feature), then
%      % fit the data to the Naive Bayes classifier
%      n = 1000;                       % observations in each class
%      grp = [ones(n,1);2*ones(n,1)];  % two classes
%
%      % normally distributed feature
%      mu = [0;2];                     
%      train1 = normrnd(mu(grp),1);
%      test1  = normrnd(mu(grp),1);
%      % multinomial feature
%      prob = [.1 .4 .15 0.35; .4 0.2  0.3 0.1]; 
%      train2 = mnrnd(1,prob(grp,:)) * (1:4)';
%      test2  = mnrnd(1,prob(grp,:)) * (1:4)';
%
%      O = NaiveBayes.fit([train1 train2],grp,'dist',{'normal','mvmn'});
%      cidx = O.predict([test1 test2]);
%      err_rate = sum(grp~=cidx)/(2*n) %mis-classification rate
%
%   See also CLASSIFY, ProbDistUnivKernel.

%   References:
%      [1] Mitchell, T. (1997) Machine Learning, McGraw Hill.
%      [2] Vangelis M, Ion A and Geogios P.  Spam Filtering with Naive
%          Bayes - Which Naive Bayes?  (2006) Third Conference on Email
%          and Anti-Spam.
%      [3] George H. John  and Pat Langley  Estimating continuous
%          distributions in bayesian classifiers (1995) the Eleventh
%          Conference on Uncertainty in Artificial Intelligence 


%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:47 $
    
    properties(GetAccess = 'public', SetAccess = 'private')
        %Public properties
        
%NCLASSES Number of classes.
%    The NClasses property specifies the number of classes in the grouping
%    variable used to create the Naive Bayes classifier.
%
%    See also NAIVEBAYES.
        NClasses = 0;
        
%NDIMS Number of dimensions.
%    The NDims property specifies the number of dimensions, which is equal
%    to the number of features in the training data used to create the
%    Naive Bayes classifier.
%
%    See also NAIVEBAYES.
        NDims = 0;
               
%CLASSLEVELS Class levels.
%   The ClassLevels property is a vector of the same type as the grouping
%   variable, containing the unique levels of the grouping variable.
%
%    See also NAIVEBAYES.
        ClassLevels ={};

%CISNONEMPTY Flag for non-empty classes.
%   The CIsNonEmpty property is a logical vector of length NClasses
%   specifying which classes are not empty.  When the grouping variable is
%   categorical, it may contain categorical levels that don't appear in the
%   elements of the grouping variable. Those levels are empty and are
%   ignored for the purposes of training the classifier.
%
%    See also NAIVEBAYES.
        CIsNonEmpty =[];
        
%PARAMS Parameter estimates
%   The Params property is an NClasses-by-NDims cell array containing the
%   the parameter estimates, excluding the class priors. Params{I,J}
%   contains the parameter estimates for the Jth feature in the Ith class.
%   Params(I,J) is empty if the Ith class is empty.
%
%   The entry in in Params(I,J) depends on the distribution type used for
%   the Jth feature, as follows:
%     'normal' - A vector of length two. The first element is the
%                mean, and the second element is standard deviation.
%     'kernel' - A ProbDistUnivKernel object
%     'mvmn'   - A vector containing the probability for each possible
%                value of the Jth feature in the Ith class. The
%                order of the probabilities is decided by the sorted
%                order of all the unique values of the Jth feature.
%                The probability of the Jth feature being value a in class
%                I, Prob(feature J = a | class I), is estimated as: 
%                  (1 + the number of observations for which feature J = a 
%                   in class I) /
%                  (the number of observations in class I + the number of
%                   distinct values in feature J)
%                
%     'mn'     - A scalar representing the probability of the Jth token
%                appearing in the Ith class, Prob(token J | class I). It is
%                estimated as: 
%                  (1 + the number of occurrence of token J in class I)/
%                  (NDims + the total number of token occurrence in class I)
% 
%    See also NAIVEBAYES.
        Params = [];
        
%PRIOR Class priors.
%   The Prior property is a vector of length NClasses containing the class
%   priors. The priors for empty classes are zero.
%
%    See also NAIVEBAYES.
        Prior = [];
        
%DIST Distribution names.
%    The Dist property is a string or a 1-by-NDims cell array of strings
%    indicating the types of distributions for all the features. If all the
%    features use the same type of distribution, Dist is a single string.
%    Otherwise Dist(J) indicates the distribution type used for the Jth
%    feature. 
%
%    The valid strings for this property are the following:
%
%       'normal' - Normal distribution.
%       'kernel' - Kernel smoothing density estimate.
%       'mvmn'    - Multivariate multinomial distribution.
%       'mn'     - Multinomial bag-of-tokens model.
%
%    See also NAIVEBAYES.
        Dist='';
        
    end
        properties(GetAccess ='protected', SetAccess = 'protected')
%CLASSNAMES class names.
%    The ClassNames property is an NClasses-by-1 cell array containing the
%    class names, where NClasses is number of classes in the grouping
%    variable used to create the Naive Bayes classifier.
        ClassNames = {};
        ClassSize=[]; %The size of each class
        LUsedClasses = 0; %The number of non-empty classes.
        GaussianFS=[]; % A logical vector indicating whether the features are modeled by Gaussian
        MVMNFS =[]; % A logical vector indicating whether the features are modeled by multivariate multinomial
        KernelFS =[]; % A logical vector indicating whether the features are modeled by Kernel estimation
        KernelWidth = [];  %the kernel width
        KernelSupport = 'unbounded'; % The support values for the features modeled by kernel
        KernelType = 'normal';% The kernel type for the features modeled by kernel
        UniqVal ={}; % The possible levels for features modeled by 'mvmn'
        NonEmptyClasses = []; % The index of non-empty classes
        
    end
    
    methods (Access = 'protected')
        function obj = NaiveBayes()
        end %
    end
    
    methods(Access = 'public', Static)
        obj = fit(training, group, varargin)
    end
    
    methods(Access = 'private')
        %-------------------------------------------
        % Computer the log of class conditional PDF
        function   logCondPDF=getlogCondPDF(obj,test, handleNaNs)
            nTest= size(test,1);

            %log of conditional class density (P(x_i| theta))
            %Initialize to NaNs
            logCondPDF = NaN(nTest, obj.NClasses);
            
            if  isscalar(obj.Dist) && strcmp(obj.Dist,'mn')
                %The fitted probabilities are guaranteed to be non-zero.
                logpw = log(cell2mat(obj.Params));
                %cell2mat discards empty rows corresponding to empty classes
                if strcmp(handleNaNs,'on')
                    test(isnan(test)) = 0;
                end
                len = sum(test,2);
                lnCoe = gammaln(len+1) - sum(gammaln(test+1),2);
                logCondPDF(:,obj.NonEmptyClasses) = bsxfun(@plus,test * logpw', lnCoe);
                
            else % 'normal', 'kernel' or 'mvmn'
                if any(obj.MVMNFS)
                    mvmnfsidx = find(obj.MVMNFS);
                    tempIdx = zeros(nTest,length(mvmnfsidx));
                    if strcmp(handleNaNs,'on')
                        for j = 1: length(mvmnfsidx)
                            [tf,tempIdx(:,j)]=ismember(test(:,mvmnfsidx(j)),obj.UniqVal{j});
                            isNaNs = isnan(test(:,mvmnfsidx(j)));
                            tempIdx(isNaNs,j) = length(obj.UniqVal{j})+1;
                        end
                    else % handleNaNs is 'off',
                        for j = 1: length(mvmnfsidx)
                            [tf,tempIdx(:,j)]=ismember(test(:,mvmnfsidx(j)),obj.UniqVal{j});
                        end
                    end
                    
                    testUnseen = any(tempIdx==0,2); % rows with unseen values
                    if any(testUnseen)
                        %remove rows with invalid input
                        warning('stats:NaiveBayes:BadDataforMVMN',...
                            [ 'For ''mvmn'' distribution, TEST values must appear ',...
                            'in the training set. ',...
                            'Rows of TEST with unseen values will be considered as outliers.']);
                        test(testUnseen,:)=[];
                        tempIdx (testUnseen,:)=[];
                    end
                else
                    testUnseen = false(nTest,1);
                end
                
                ntestValid = size(test,1);
                
                for k = obj.NonEmptyClasses
                    logPdf =zeros(ntestValid,1);
                    if any(obj.GaussianFS)
                        param_k=cell2mat(obj.Params(k,obj.GaussianFS));
                        templogPdf = bsxfun(@plus, -0.5* (bsxfun(@rdivide,...
                            bsxfun(@minus,test(:,obj.GaussianFS),param_k(1,:)),param_k(2,:))) .^2,...
                            -log(param_k(2,:))) -0.5 *log(2*pi);
                        if strcmp(handleNaNs,'off')
                            logPdf = logPdf + sum(templogPdf,2);
                        else
                            logPdf = logPdf + nansum(templogPdf,2);
                        end
                    end%
                    
                    if any(obj.KernelFS)
                        kdfsIdx = find(obj.KernelFS);
                        for j = 1:length(kdfsIdx);
                            tempLogPdf = log(obj.Params{k,kdfsIdx(j)}.pdf(test(:,kdfsIdx(j))));
                            if strcmp(handleNaNs,'on')
                                tempLogPdf(isnan(tempLogPdf)) = 0;
                            end
                            logPdf = logPdf + tempLogPdf;
                            
                        end
                    end
                    
                    if any(obj.MVMNFS)
                        for j = 1: length(mvmnfsidx)
                            curParams = [obj.Params{k,mvmnfsidx(j)}; 1];
                            %log(1)=0;
                            tempP = curParams(tempIdx(:,j));
                            logPdf = logPdf + log(tempP);
                        end
                    end
                    
                    if any(testUnseen)
                        % saves the log of class conditional PDF for
                        % the kth class
                        logCondPDF(~testUnseen,k)= logPdf;
                        %set to -inf for unseen test value.
                        logCondPDF(testUnseen,k)=-inf;
                    else
                        logCondPDF(:,k)= logPdf;
                    end
                    
                end %loop for k
                
            end
            
        end
        %-------------------------------------------
        %Compute class index, posterior probability and log of PDf
        function [cidx, postP, logPdf] = getClassIdx(obj,log_condPdf)
          
            log_condPdf =bsxfun(@plus,log_condPdf, log(obj.Prior));
            [maxll, cidx] = max(log_condPdf,[],2);
            %set cidx to NaN if it is outlier
            cidx(maxll == -inf |isnan(maxll)) = NaN;
            %minus maxll to avoid underflow
            if nargout >= 2
                postP = exp(bsxfun(@minus, log_condPdf, maxll));
                %density(i) is \sum_j \alpha_j P(x_i| \theta_j)/ exp(maxll(i))
                density = nansum(postP,2); %ignore the empty classes
                %normalize posteriors
                postP = bsxfun(@rdivide, postP, density);
                if nargout >= 3
                    logPdf = log(density) + maxll;
                end
                
            end
            
        end %function getClassIdx
        
    end %private methods block
    
    methods(Hidden, Static)
        function a = empty(varargin)
            error(['stats:' mfilename ':NoEmptyAllowed'], ...
                'Creation of empty %s objects is not allowed.',upper(mfilename));
        end
    end
    
    methods(Hidden)
        function a = cat(varargin),        throwNoCatError(); end
        function a = horzcat(varargin),    throwNoCatError(); end
        function a = vertcat(varargin),    throwNoCatError(); end
    end
end %classdef

%----------------------------------------------
function throwNoCatError()
error(['stats:' mfilename ':NoCatAllowed'], ...
    'Concatenation of %s objects is not allowed.  Use a cell array to contain multiple objects.',upper(mfilename));
end

