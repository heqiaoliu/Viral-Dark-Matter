function obj = fit(training, group, varargin)
%FIT Create a Naive Bayes classifier object by fitting training data. 
%   NB = NAIVEBAYES.FIT(TRAINING, C) builds a NaiveBayes classifier object
%   NB. TRAINING is an N-by-D numeric matrix of predictor data. Rows of
%   TRAINING correspond to observations; columns correspond to features. C
%   contains the known class labels for TRAINING, and it take one of K
%   possible levels. C is a grouping variable, i.e., it can be a
%   categorical, numeric, or logical vector; a cell vector of strings; or a
%   character matrix with each row representing a class label. Each element
%   of C defines which class the corresponding row of TRAINING belongs to.
%   TRAINING and C must have the same number of rows.
%
%   Type "help groupingvariable" for more information about grouping
%   variables.
%
%   NB = NAIVEBAYES.FIT(..., 'PARAM1',val1, 'PARAM2',val2, ...)
%   specifies one or more of the following name/value pairs:
%
%      'Distribution'  a string or a 1-by-D cell vector of strings,
%                      specifying which distributions FIT uses to model the
%                      data. If the value is a string, FIT models all the
%                      features using one type of distribution. FIT can
%                      also model different features using different types
%                      of distributions. If the value is a cell vector, its
%                      Jth element specifies the distribution FIT uses for
%                      the Jth feature.  The available types of
%                      distributions are:
%          'normal'  (default) Normal (Gaussian) distribution.
%          'kernel'  Kernel smoothing density estimate.
%          'mvmn'    Multivariate multinomial distribution for discrete
%                    data. FIT assumes each individual feature follows a
%                    multinomial model within a class. The parameters for a
%                    feature include the probabilities of all possible
%                    values that the corresponding feature can take.
%          'mn'      Multinomial distribution for classifying the count-
%                    based data such as the bag-of-tokens model. In the
%                    bag-of-tokens model, the value of the Jth feature is
%                    the number of occurrences of the Jth token in this
%                    observation, so it must be a non-negative integer.
%                    When 'mn' is used, FIT considers each observation as
%                    multiple trials of a Multinomial distribution, and
%                    considers each occurrence of a token as one trial.
%                    The number of categories(bins) in this multinomial
%                    model is the number of distinct tokens, i.e., the
%                    number of columns of TRAINING.
%                
%      'Prior'       The prior probabilities for the classes, specified as
%                    one of the following:
%          'empirical'   (default) FIT estimates the prior probabilities
%                        from the relative frequencies of the classes in
%                        TRAINING.
%          'uniform'     The prior probabilities are equal for all classes.
%          vector        A numeric vector of length K specifying the prior
%                        probabilities of the K possible values of C, in
%                        the order described in “help groupingvariable”.
%          structure     A structure S containing class levels and their
%                        prior probabilities.  S must have two fields:
%                  S.prob  A numeric vector of prior probabilities.
%                  S.group A vector of the same type as C, containing
%                          unique class levels indicating the class for the
%                          corresponding element of prob.
%                        S.group must contain all the K levels in C. It
%                        can also contain classes that do not appear in
%                        C. This can be useful if TRAINING is a subset
%                        of a larger training set. FIT ignores any classes
%                        that appear in S.group but not in C.
%      If the prior probabilities don't sum to one, they will be normalized.
%
%      'KSWidth'     The bandwidth of the kernel smoothing window.  The
%                    default is to select a default bandwidth automatically
%                    for each combination of feature and class, using a
%                    value that is optimal for a Gaussian distribution.
%                    The value can be specified as one of the following:
%          scalar         Width for all features in all classes.
%          row vector     1-by-D vector where the Jth element is the
%                         bandwidth for the Jth feature in all classes.
%          column vector  K-by-1 vector where the Ith element specifies the
%                         bandwidth for all features in the Ith class. K
%                         represents the number of class levels.
%          matrix         K-by-D matrix M where M(I,J) specifies the
%                         bandwidth for the Jth feature in the Ith class.
%          structure      A structure S containing class levels and their
%                         bandwidths.  S must have two fields:
%                  S.width A numeric array of bandwidths specified as a row
%                          vector, or a matrix with D columns.
%                  S.group A vector of the same type as C, containing
%                          unique class levels indicating the class for the
%                          corresponding row of width.
%
%      'KSSupport'   The regions where the density can be applied.  It can
%                    be a string, a two-element vector as shown below, or
%                    a 1-by-D cell array of these values:
%          'unbounded'    (default) The density can extend over the whole
%                         real line.
%          'positive'     The density is restricted to positive values.
%          [L,U]          A two-element vector specifying the finite lower
%                         bound L and upper bound U for the support of the
%                         density.
%
%      'KSType'      The type of kernel smoother to use. It can be a string
%                    or a 1-by-D cell array of strings.  Each string can be
%                    'normal' (default), 'box', 'triangle', or
%                    'epanechnikov'.
%
%  The 'KSWidth', 'KSSupport', and 'KSType' parameters are used only for
%  features with the 'kernel' distribution and are ignored for all others.
%
%  FIT treats NaNs, empty strings or 'undefined' values as missing values.
%  For missing values in C, FIT removes the corresponding rows of
%  TRAINING. For missing values in TRAINING, when distribution 'mn' is
%  used, FIT removes the corresponding rows of TRAINING, otherwise, FIT
%  only removes the missing values and uses the values of other features in
%  the corresponding rows of TRAINING.
%
%  See also NAIVEBAYES, PREDICT, POSTERIOR, PARAMS, GROUPINGVARIABLE,
%  FITDIST, PROBDISTUNIVKERNEL.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:50 $

if nargin < 2
    error('stats:NaiveBayes:TooFewInputs',...
        'At least two input arguments are required.');
end

if ~isnumeric(training)
    error('stats:NaiveBayes:fit:TrainingBadType',...
        'TRAINING must be numeric.');
end

obj = NaiveBayes;

[gindex,obj.ClassNames, obj.ClassLevels] = grp2idx(group);
nans = isnan(gindex);
if ~isempty(nans)
    training(nans,:) = [];
    gindex(nans) = [];
end

obj.NClasses = length(obj.ClassNames);
obj.ClassSize = hist(gindex,1: obj.NClasses);
obj.CIsNonEmpty = (obj.ClassSize > 0)';
obj.NonEmptyClasses =find(obj.ClassSize>0);

obj.LUsedClasses = length(obj.NonEmptyClasses);
if obj.NClasses > obj.LUsedClasses
    warning('stats:NaiveBayes:fit:EmptyGroups',...
        ['C contains categorical levels that don''t appear in the elements of C. ',...
        'Those levels will be ignored for the purposes of training the classifier. ',...
        'If C is a random subsample from a larger dataset, ',...
        'the resulting classifier may not be comparable to other classifiers ',...
        'created using other randomly subsampled training sets.']);
end

[n, obj.NDims]= size(training);
if n == 0
    if ~isempty(nans)
        error('stats:NaiveBayes:fit:NoData',...
            'No data remaining in X and Y after removing missing values.');
    else
        error('stats:NaiveBayes:fit:NoData',...
            'Empty TRAINING or C are not allowed');
    end
end
if n ~= size(gindex,1);
    error('stats:NaiveBayes:fit:MismatchedSize',...
        'TRAINING and C must have the same number of rows.');
end



% Parse input and error check
pnames = {'distribution' 'prior'   'kswidth'    'kssupport' 'kstype'};
dflts =  {'normal'       'empirical' []         []           []};
[eid,errmsg, obj.Dist,prior, kernelWidth,obj.KernelSupport, obj.KernelType] ...
    = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:NaiveBayes:fit:%s',eid),errmsg);
    
end

if isempty(prior) || (ischar(prior) && ~isempty(strmatch(lower(prior), 'empirical')))
    obj.Prior = obj.ClassSize(:)' / sum(obj.ClassSize);
elseif ischar(prior) && ~isempty(strmatch(lower(prior), 'uniform'))
    obj.Prior = ones(1, obj.NClasses) / obj.NClasses;
    % Explicit prior
elseif isnumeric(prior)
    if ~isvector(prior) || length(prior) ~= obj.NClasses
        error('stats:NaiveBayes:fit:BadPrior',...
            'Numeric PRIOR must be a vector with one element for each class.');
    end
    obj.Prior = prior;
elseif isstruct(prior)
    if ~isfield(prior,'group') || ~isfield(prior,'prob')
        error('stats:NaiveBayes:fit:BadPrior',...
            'Structure PRIOR must have ''group'' and ''prob'' fields.');
    end
    [pgindex,pgroups] = grp2idx(prior.group);
    
    ord =NaN(1,obj.NClasses);
    for i = 1:obj.NClasses
        j = strmatch(obj.ClassNames(i), pgroups(pgindex), 'exact');
        if isempty(j)
            error('stats:NaiveBayes:fit:BadPrior',...
                'PRIOR.group must contain all the levels in C.');
        elseif numel(j) > 1
             error('stats:NaiveBayes:fit:BadPrior',...
                'PRIOR.group can''t contain duplicate groups.');
        else
            ord(i) = j;
        end
    end
    obj.Prior = prior.prob(ord);
    
else
    error('stats:NaiveBayes:fit:BadPriorType',...
        'PRIOR must be a vector, a structure, ''empirical'', or ''uniform''.');
end

obj.Prior(obj.ClassSize==0) = 0;
if any(obj.Prior < 0) || sum(obj.Prior) == 0
    error('stats:NaiveBayes:fit:BadPrior',...
        'PRIOR cannot contain negative values and the summation of PRIOR must be greater than zero.');
end
obj.Prior = obj.Prior(:)' / sum(obj.Prior); % normalize the row vector


if ischar(obj.Dist)
    obj.Dist = cellstr(obj.Dist);
elseif ~iscell(obj.Dist)
    error('stats:NaiveBayes:fit:BadDist',...
        '''Distribution'' must be a string or a cell vector of strings.');
end
% distribution list must be a vector
if ~isvector(obj.Dist)
      error('stats:NaiveBayes:fit:BadDist',...
        '''Distribution'' must be a string or a cell vector of strings.');
end
if ~isscalar(obj.Dist)
    if length(obj.Dist) ~= obj.NDims
        error('stats:NaiveBayes:fit:BadDistVec',...
            'The length of vector ''Distribution'' must be equal to the number of columns in TRAINING.');
    end
    
    try
        u = unique(obj.Dist);
    catch ME
        if isequal(ME.identifier,'MATLAB:CELL:UNIQUE:InputClass')
            error('stats:NaiveBayes:fit:BadDist',...
                '''Distribution'' must be a string or a cell vector of strings.');
        else
            rethrow(ME);
        end
    end
    %if all the distribution are same, make it a scalar cell
    if length(u) == 1 &&  isempty(strmatch(lower(u),'mn'))
        obj.Dist = u;
    end
else
     if ~ischar(obj.Dist{1})
        error('stats:NaiveBayes:fit:BadDist',...
            '''Distribution'' must be a string or a cell vector of strings.');
     end
end

distNames = {'normal','mvmn','kernel','mn'};
if isscalar(obj.Dist)
    i = strmatch(lower(obj.Dist),distNames);
    if isempty(i)
        error('stats:NaiveBayes:fit:UnknownDist', ...
            'Unknown ''Distribution'' value:  %s.',obj.Dist{1});
    elseif i == 1
        obj.GaussianFS = true(1,obj.NDims);
    elseif i ==2 %'mvmn'
        obj.MVMNFS = true(1,obj.NDims);
    elseif i == 3 %'kernel'
        obj.KernelFS = true(1,obj.NDims);
    end %
    obj.Dist = distNames(i);
    
else %obj.Dist is a vector
    obj.GaussianFS = false(1,obj.NDims); % flag for Gaussian features
    obj.MVMNFS = false(1,obj.NDims); % flag for multivariate multinomial features
    obj.KernelFS = false(1,obj.NDims);   % flag for kernel features

    for d = 1:obj.NDims
        curDist =obj.Dist{d};
        
        i = strmatch(lower(curDist),distNames);
        if isempty(i)
            error('stats:NaiveBayes:fit:UnknownDist', ...
                'Unknown ''Distribution'' value:  %s for feature %d.',curDist,d);
        elseif i==4
            error('stats:NaiveBayes:fit:BadDist', ...
                '''Distribution'' must be a string if ''mn'' is used.');
        elseif i==1
            obj.GaussianFS(d) = true;
        elseif i==2
            obj.MVMNFS(d) = true;
        elseif i==3
            obj.KernelFS(d) = true;
        end
        obj.Dist{d} = distNames{i};
    end %loop over d
    
 u = unique(obj.Dist);
    if length(u) == 1
        obj.Dist = u;
    end
end

if isscalar(obj.Dist) && strcmp(obj.Dist,'mn')
    nans = any(isnan(training),2);%remove rows with any NaN
    %remove rows with invalid values
    trBad =  any(training< 0 |  training ~= round(training), 2);
    if any(trBad)
        warning('stats:NaiveBayes:fit:BadDataforMN',...
            [ 'TRAINING can only contain non-negative integers when ''Distribution'' is set to ''mn''. ',...
            'Rows of TRAINING with invalid values will be removed.']);
    end
    t = nans | trBad;
    if any(t)
        training(t,:) = [];
        gindex(t) = [];
    end
else
    nans = all(isnan(training),2);%remove rows with all NaNs
    if any(nans)
        training(nans,:) = [];
        gindex(nans) = [];
    end
    
    for k = obj.NonEmptyClasses
        groupI = (gindex == k);
        if sum(groupI) == 0
            error('stats:NaiveBayes:fit:NoData',...
                'At least one observation in each class is required.');
            
        end
        nanCols =  all(isnan(training(groupI,:)),1);
        if any(nanCols)
            nanCols = strtrim(sprintf('%d ',find(nanCols)));
            error('stats:NaiveBayes:fit:TrainingAllNaN',...
                'Class %s has no non-missing values for feature(s): %s.',...
                obj.ClassNames{k}, nanCols );
        end
    end
end

%process the kernel options
if any(obj.KernelFS)
    if ~isempty(kernelWidth)
        if isnumeric(kernelWidth)
            %check the size of kernel width
            [wd1, wd2]=size(kernelWidth);
            if(wd1 ~= 1 && wd1 ~= obj.NClasses) || (wd2 ~= 1 && wd2 ~= obj.NDims)
                error('stats:NaiveBayes:fit:KernelWidthSizeBad',...
                    ['Numeric KSWidth must be a scalar, a vector or a 2D array. '...
                    'Its number of rows must be equal to one '...
                    'or the number of levels in C. '...
                    'Its number of columns must be equal to one '...
                    'or the number of columns in TRAINING.']);
            end
            obj.KernelWidth = kernelWidth;
            
        elseif isstruct(kernelWidth)
            if ~isfield(kernelWidth,'group') || ~isfield(kernelWidth,'width')
                error('stats:NaiveBayes:fit:BadKernelWidth',...
                    'Structure KSWidth must have ''group'' and ''width'' fields.');
            end
            
            if ~isnumeric(kernelWidth.width)
                error('stats:NaiveBayes:fit:BadKernelWidth',...
                    'KSWidth.width must be numeric.');
            end
            
            [kwgindex,kwgroups] = grp2idx(kernelWidth.group);
            if size(kernelWidth.width,1) ~= length(kwgroups);
                error('stats:NaiveBayes:fit:KernelWidthSizeBad',...
                    ['The number of rows in KSWidth.width must '...
                    'be equal to the number of classes in KSWidth.group.']);
            end
            if size(kernelWidth.width,2) ~= 1 &&...
                    size(kernelWidth.width,2) ~= obj.NDims;
                error('stats:NaiveBayes:fit:KernelWidthSizeBad',...
                    ['The number of columns in KSWidth.width must '...
                    'be equal to one or the number of columns in TRAINING.']);
            end
            ord = NaN(1,obj.NClasses);
            
            for i = 1:obj.NClasses
                j = strmatch(obj.ClassNames(i), kwgroups(kwgindex), 'exact');
                if isempty(j)
                    error('stats:NaiveBayes:fit:BadKernelWidth',...
                        'KSWidth.group must contain all of the levels in C.');
                elseif numel(j) > 1
                    error('stats:NaiveBayes:fit:BadKernelWidth',...
                        'KSWidth.group can''t contain duplicate classes.');
                else
                    ord(i) = j; 
                end
            end
            obj.KernelWidth = kernelWidth.width(ord,:);
        else
            error('stats:NaiveBayes:fit:BadKernelWidth',...
                'KSWidth must be a numeric variable or a struct.');
        end
        
        %check the validity of kernel width.
        if size(obj.KernelWidth,2) > 1
            kwtemp = obj.KernelWidth(:,obj.KernelFS);
        else
            kwtemp = obj.KernelWidth;
        end
        
        if size(obj.KernelWidth,1) > 1
            kwtemp = kwtemp(obj.NonEmptyClasses,:);
        end
        
        kwtemp = kwtemp(:);
        
        if  any(~isfinite(kwtemp)) || any(kwtemp <= 0)
                error('stats:NaiveBayes:BadKSWidth', 'Kernel width must be positive.');
        end
        
        
    end % ~isempty(kernelWidth)
    
    if ~isempty(obj.KernelSupport)
        
        if iscell(obj.KernelSupport) 
            if isscalar(obj.KernelSupport) %allow a cell with only one element
                obj.KernelSupport = validSupport(obj.KernelSupport{1});
            else
                if ~isvector(obj.KernelSupport) || length(obj.KernelSupport) ~= obj.NDims
                    error('stats:NaiveBayes:fit:BadSupport',...
                        ['KSSupport must be ''unbounded'', ''positive'', '...
                        'a two-element sorted numeric vector or a cell vector '...
                        'containing these values. The length of the cell vector '...
                        'must be equal to one or the number of columns in TRAINING. ']);
                end
                %check each kernelsupport
                supporttemp = obj.KernelSupport(obj.KernelFS);
                for i = 1: numel(supporttemp)
                    supporttemp{i}= validSupport(supporttemp{i});
                end
                obj.KernelSupport(obj.KernelFS) = supporttemp;
            end
        else
            obj.KernelSupport = validSupport(obj.KernelSupport);
        end
    else
        obj.KernelSupport = 'unbounded';
    end % ~isempty(obj.KernelSupport)
    
    if ~isempty(obj.KernelType)
        if ischar(obj.KernelType)
            obj.KernelType = cellstr(obj.KernelType);
        elseif ~iscell(obj.KernelType)
            error('stats:NaiveBayes:fit:BadKSType',...
                '''KSType'' must be a string or a cell vector of strings.');
        end
        if ~isvector(obj.KernelType)
            error('stats:NaiveBayes:fit:BadKSType',...
                '''KSType'' must be a string or a cell vector of strings.');
        end
        
        if isscalar(obj.KernelType)
            obj.KernelType = validKernelType(obj.KernelType{1});
        else
            %check the length of vector kernelType
            if length(obj.KernelType) ~= obj.NDims
                error('stats:NaiveBayes:fit:BadKSType',...
                    [ '''KSType'' must be a string or a cell vector with '...
                    'length equal to the number of columns in TRAINING.']);
            end
            
            kernelTypeTemp = obj.KernelType(obj.KernelFS);
            for i = 1: numel(kernelTypeTemp)
                kernelTypeTemp{i}= validKernelType(kernelTypeTemp{i});
            end
            obj.KernelType(obj.KernelFS) = kernelTypeTemp;
        end
    else
        obj.KernelType = 'normal';
    end
    
end

obj.Params = cell(obj.NClasses, obj.NDims);

%Start Fit
if isscalar(obj.Dist)
    switch obj.Dist{:}
        case 'mn'
            obj =  mnfit(obj,training, gindex);
        case 'normal'
            obj = gaussianFit(obj, training, gindex);
        case 'mvmn'
            obj = mvmnFit(obj, training,gindex);
        case 'kernel'
            obj = kernelFit(obj,training, gindex);
    end
else
    if any(obj.GaussianFS)
        obj = gaussianFit(obj, training, gindex);
    end
    if any(obj.MVMNFS)
        obj = mvmnFit(obj, training,gindex);
    end
    if any(obj.KernelFS)
        obj = kernelFit(obj,training, gindex);
    end
    
end

end %fit

%--------------------------------------
%estimate parameters using Gaussian distribution
function obj = gaussianFit(obj, training, gidx)
for i = obj.NonEmptyClasses
    groupI = (gidx == i);
    
    gsize = sum(~isnan(training(groupI,obj.GaussianFS)),1);
    if any(gsize <= 1)
        error('stats:NaiveBayes:fit:NoData',...
            'For Gaussian distribution, each class must have at least two non-missing values.');
    end
    mu = nanmean(training(groupI,obj.GaussianFS));
    sigma = nanstd(training(groupI,obj.GaussianFS));
    badCols = sigma <= gsize * eps(max(sigma));
    if any(badCols)
        badCols = sprintf('%d ',find(badCols));
        error('stats:NaiveBayes:fit:BadVariance',...
            ['The within-class variance in each feature of TRAINING must be positive. ',...
            'The within-class variance in feature %sin class %s are not positive.'],...
            badCols, obj.ClassNames{i});
    end
    obj.Params(i,obj.GaussianFS) = mat2cell([mu;sigma],2,...
        ones(1,sum(obj.GaussianFS)));
    %Each cell is a 2-by-1 vector, the first element is the mean,
    %and the second element is the standard deviation.
end
end %function gaussianFit

%-------------------------------------------
%Use kernel density estimate
function obj = kernelFit(obj, training,gidx)

kdfsidx = find(obj.KernelFS);
kw2=[];
if ~isempty(obj.KernelWidth)
    [kwrLen,kwcLen] = size(obj.KernelWidth);
    kw = obj.KernelWidth;
    if kwrLen == 1
        kw = repmat(kw, [obj.NClasses,1]);
    end
    if kwcLen == 1
        kw = repmat(kw, [1,obj.NDims]);
    end
end

for i = obj.NonEmptyClasses
    groupI = (gidx == i);
    
    for j = kdfsidx
        if iscell(obj.KernelSupport)
            kssupport = obj.KernelSupport{j};
        else
            kssupport = obj.KernelSupport;
        end
        if iscell(obj.KernelType)
            kstype = obj.KernelType{j};
        else
            kstype = obj.KernelType;
        end
        
        data = training(groupI,j);
        nans = isnan(data);
        if any(nans)
            data(nans)=[];
            if size(data,1) == 0
                error('stats:NaiveBayes:fit:NoData',...
                    'For Kernel distribution, each feature of TRAINING in each class must have at least one non-missing value.');
            end
        end
        
        if ~isempty(obj.KernelWidth)
            kw2 = kw(i, j);
        end
        
        obj.Params{i,j} = ...
            fitdist(data,'kernel', 'width',kw2,...
            'support',kssupport,'kernel',kstype);
        
    end
    
    
end
end


%---------------------------
%estimate the parameters using multivariate multinomial
function obj = mvmnFit(obj, training, gidx)

mvmnfsIdx = find(obj.MVMNFS);
d = sum(obj.MVMNFS);
mvmnParams = cell(obj.NClasses,d);
obj.UniqVal = cell(1,d);
for j = 1: d
    data = training(:,mvmnfsIdx(j));
    gidx2 = gidx;
    nans = isnan(data);
    if any(nans)
        data(nans)=[];
        gidx2(nans)=[];
        
    end
    obj.UniqVal{j} = unique(data);
    for i = obj.NonEmptyClasses
        groupI = (gidx2 == i);
        if sum(groupI) == 0
            error('stats:NaiveBayes:fit:NoData',...
                ['For multivariate multinomail distribution, '...
                'each feature of TRAINING in each class must have at least one non-missing value.']);
        end
        p = histc(data(groupI),obj.UniqVal{j});
        %Add one count for each discrete value of the training data to avoid zero probability
        p= (p+1)/(size(data(groupI),1) +length(obj.UniqVal{1,j}));
        mvmnParams(i,j) = {p(:)};
    end
end

obj.Params(:,obj.MVMNFS) = mvmnParams;

end

%-----------------------------------------------------
% perform Multinomial fit
function obj =  mnfit(obj,training, gidx)
d = size(training,2);
for k = obj.NonEmptyClasses
    groupI = (gidx == k);
    if sum(groupI) == 0
        error('stats:NaiveBayes:fit:NoData',...
            'At least one valid observation in each class is required.');
    end
    
    pw = sum(training(groupI,:),1);
    pw = (pw+1)/(sum(pw)+d);
    %Add one count for  each feature to avoid zero probability
    obj.Params(k,:)= mat2cell(pw,1,ones(1,d));
end
end

%-----------------------------------
%check the validity of kernelsupport
function  kssupport = validSupport(kssupport)

badSupport = false;
if ischar(kssupport) && size(kssupport,1)==1
    supportName = {'unbounded' 'positive'};
    i = strmatch(lower(kssupport), supportName );
    if isempty(i)
        badSupport = true;
    else
        kssupport = supportName{i};
    end
    
elseif ~(isnumeric(kssupport) && numel(kssupport)==2 ...
        && all(isfinite(kssupport)) && kssupport(1) < kssupport(2))
    badSupport = true;
end
if badSupport
    error('stats:NaiveBayes:fit:BadSupport',...
        ['KSSupport must be ''unbounded'', ''positive'', '...
        'a two-element sorted numeric vector or a cell vector '...
        'containing these values. The length of the cell vector '...
        'must be equal to one or the number of columns in TRAINING. ']);
end
end

%----------------------------------------------------------------
%check the validity of kernel Type
function type = validKernelType(type)
typeNames ={'normal' , 'box', 'triangle', 'epanechnikov'};

if ~ischar(type)
    error('stats:NaiveBayes:fit:UnknownKSType', ...
        '''KSType'' must be a string or a cell vector of strings.');
end
i = strmatch(lower(type),typeNames );
if isempty(i)
    error('stats:NaiveBayes:fit:UnknownKSType', ...
        'Unknown ''KSType'' value:  %s.',type);
    
end
type= typeNames{i};
end
