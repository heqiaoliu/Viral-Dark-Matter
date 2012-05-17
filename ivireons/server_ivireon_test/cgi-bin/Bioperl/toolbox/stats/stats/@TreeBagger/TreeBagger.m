classdef TreeBagger
%TREEBAGGER Bootstrap aggregation for an ensemble of decision trees.
%   TreeBagger bags an ensemble of decision trees for either classification
%   or regression. 'Bagging' stands for 'bootstrap aggregation'. Every tree
%   in the ensemble is grown on an independently-drawn bootstrap replica of
%   input data. Observations not included in this replica are "out of bag"
%   for this tree. To compute prediction of an ensemble of trees for unseen
%   data, TREEBAGGER takes an average of predictions from individual trees.
%   
%   To estimate the prediction error of the bagged ensemble, you can compute
%   predictions for each tree on its out-of-bag observations, average these
%   predictions over the entire ensemble for each observation and then
%   compare the predicted out-of-bag response with the true value at this
%   observation.
%
%   TreeBagger relies on functionality of CLASSREGTREE for growing
%   individual trees. In particular, CLASSREGTREE accepts the number of
%   features selected at random for each decision split as an
%   optional input argument.
%
%   The 'Compact' property contains another class, CompactTreeBagger, with
%   sufficient information to make predictions using new data. This
%   information includes the tree ensemble, variable names, and class
%   names (for classification).  CompactTreeBagger requires less memory
%   than TreeBagger, but only TreeBagger has methods for growing more trees
%   for the ensemble.  Once you grow an ensemble of trees using TreeBagger,
%   if you no longer need access to the training data, you can opt to work
%   with the compact version of the trained ensemble from then on.
%
%   TreeBagger properties:
%      X             - X data used to create the ensemble.
%      Y             - Y data used to create the ensemble.
%      W             - Weights of observations used to create the ensemble.
%      FBoot         - Fraction of in-bag observations.
%      SampleWithReplacement - Flag to sample with replacement.
%      TreeArgs      - Cell array of arguments for CLASSREGTREE.
%      ComputeOOBPrediction - Flag to compute out-of-bag predictions.
%      ComputeOOBVarImp - Flag to compute out-of-bag variable importance.
%      Prune         - Flag to prune trees.
%      MergeLeaves   - Flag to merge leaves that do not improve risk.
%      NVarToSample  - Number of variables for random feature selection.
%      MinLeaf       - Minimum number of observations per tree leaf.
%      OOBIndices    - Indicator matrix for out-of-bag observations.
%      Trees         - Decision trees in the ensemble.
%      NTrees        - Number of decision trees in the ensemble.
%      ClassNames    - Names of classes.
%      Prior         - Prior class probabilities.
%      Cost          - Misclassification costs.
%      VarNames      - Variable names.
%      Method        - Method used by trees (classification or regression).
%      OOBInstanceWeight - Count of out-of-bag trees for each observation.
%      OOBPermutedVarDeltaError       - Variable importance for classification error.
%      OOBPermutedVarDeltaMeanMargin  - Variable importance for classification margin.
%      OOBPermutedVarCountRaiseMargin - Variable importance for raising margin.
%      DeltaCritDecisionSplit         - Split criterion contributions for each predictor.
%      NVarSplit      - Number of decision splits on each predictor.
%      VarAssoc       - Variable associations.
%      Proximity      - Proximity matrix for observations.
%      OutlierMeasure - Measure for determining outliers.
%      DefaultYfit    - Default value returned by PREDICT and OOBPREDICT.
%
%   TreeBagger methods:
%      TreeBagger/TreeBagger - Create an ensemble of bagged decision trees.
%      append           - Append new trees to ensemble.
%      compact          - Compact ensemble of decision trees.
%      error            - Error (misclassification probability or MSE).
%      fillProximities  - Fill proximity matrix for training data.
%      growTrees        - Train additional trees and add to ensemble.
%      margin           - Classification margin.
%      mdsProx          - Multidimensional scaling of proximity matrix.
%      meanMargin       - Mean classification margin per tree.
%      oobError         - Out-of-bag error.
%      oobMargin        - Out-of-bag margins.
%      oobMeanMargin    - Out-of-bag mean margins.
%      oobPredict       - Ensemble predictions for out-of-bag observations.
%      predict          - Predict response.
%
%   Example:
%      load fisheriris
%      b = TreeBagger(50,meas,species,'oobpred','on')
%      plot(oobError(b))
%      xlabel('number of grown trees')
%      ylabel('out-of-bag classification error')
% 
%    See also TREEBAGGER/TREEBAGGER, COMPACTTREEBAGGER, CLASSREGTREE.
    

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3.2.1 $


    properties(SetAccess=protected,GetAccess=public)
        %X X data used to create the ensemble.
        %   The X property is a numeric matrix of size Nobs-by-Nvars, where Nobs is
        %   the number of observations (rows) and Nvars is the number of variables
        %   (columns) in the training data.  This matrix contains the predictor (or
        %   feature) values.
        %
        %   See also TREEBAGGER.
        X = [];
        
        %Y Y data used to create the ensemble.
        %   The Y property is an array of true class labels for classification, or
        %   response values for regression. Y is a numeric column vector for
        %   regression and a cell array of strings for classification.
        %
        %   See also TREEBAGGER.
        Y = [];
        
        %W Weights of observations used to create the ensemble.
        %   The W property is a numeric vector of size Nobs, where Nobs is the
        %   number of observations. These weights are used for growing every
        %   decision tree in the ensemble.
        %
        %   See also TREEBAGGER, CLASSREGTREE.
        W = [];
        
        %FBOOT Fraction of in-bag observations.
        %   The FBoot property is the fraction of observations to be randomly
        %   selected with replacement for each bootstrap replica. The size of each
        %   replica is given by N*FBOOT, where N is the number of observations in
        %   the training set.  The default value is 1.
        %
        %   See also TREEBAGGER.
        FBoot = 1;
                
        %SAMPLEWITHREPLACEMENT Flag to sample with replacement.
        %   The SampleWithReplacement property is a logical flag specifying if data
        %   are sampled for each decision tree with replacement. True if data are
        %   sampled with replacement and false otherwise. True by default.
        %
        %   See also TREEBAGGER.
        SampleWithReplacement = true;
        
        %TREEARGS Cell array of arguments for classregtree.
        %   The TreeArgs property is a cell array of arguments for the classregtree
        %   constructor.  These arguments are used by TreeBagger in growing new
        %   trees for the ensemble.
        %
        %   See also TREEBAGGER.
        TreeArgs = {};
        
        %COMPUTEOOBPREDICTION Flag to compute out-of-bag predictions.
        %   The ComputeOOBPrediction property is a logical flag specifying whether out-of-bag
        %   predictions for training observations should be computed.  The default is
        %   false.
        %
        %   If this flag is true, the following properties are available:
        %       OOBIndices, OOBInstanceWeight.
        %   If this flag is true, the following methods can be called:
        %       oobError, oobMargin, oobMeanMargin.
        %
        %   See also TREEBAGGER, OOBERROR, OOBMARGIN, OOBMEANMARGIN, OOBINDICES,
        %   OOBINSTANCEWEIGHT.
        ComputeOOBPrediction = false;
        
        %COMPUTEOOBVARIMP Flag to compute out-of-bag variable importance.
        %   The ComputeOOBVarImp property is a logical flag specifying whether out-of-bag
        %   estimates of variable importance should be computed.  The default is
        %   false. If this flag is true, COMPUTEOOBPREDICTION is true as well.
        %
        %   If this flag is true, the following properties are available:
        %      OOBPermutedVarDeltaError, OOBPermutedVarDeltaMeanMargin,
        %      OOBPermutedVarCountRaiseMargin
        %
        %   See also TREEBAGGER, COMPUTEOOBPREDICTION, OOBPERMUTEDVARDELTAERROR,
        %   OOBPERMUTEDVARDELTAMEANMARGIN, OOBPERMUTEDVARCOUNTRAISEMARGIN.
        ComputeOOBVarImp = false;
        
        %PRUNE Flag to prune trees.
        %   The Prune property is true if decision trees are pruned and false if
        %   they are not. Pruning decision trees is not recommended for ensembles.
        %   The default value is false.
        %
        %   See also TREEBAGGER, CLASSREGTREE, CLASSREGTREE/PRUNE.
        Prune = false;
        
        %MERGELEAVES Flag to merge leaves that do not improve risk.
        %   The MergeLeaves property is true if decision trees have their leaves
        %   with the same parent merged for splits that do not decrease the total
        %   risk, and false otherwise. The default value is false.
        %
        % See also TREEBAGGER, CLASSREGTREE.
        MergeLeaves = false;
                
        %NVARTOSAMPLE Number of variables for random feature selection.
        %   The NVarToSample property specifies the number of predictor or feature
        %   variables to select at random for each decision split. By default, it
        %   is set to the square root of the total number of variables for
        %   classification and one third of the total number of variables for
        %   regression.
        %
        %   See also TREEBAGGER, CLASSREGTREE.
        NVarToSample = [];
        
        %MINLEAF Minimum number of observations per tree leaf.
        %   The MinLeaf property specifies the minimum number of observations per
        %   tree leaf. By default it is 1 for classification and 5 for regression.
        %   For CLASSREGTREE training, the 'MinParent' value is set to 2*MinLeaf.
        %
        %   See also TREEBAGGER, CLASSREGTREE.
        MinLeaf = [];
        
        %OOBINDICES Indicator matrix for out-of-bag observations.
        %   The OOBIndices property is a logical array of size Nobs-by-NTrees where
        %   Nobs is the number of observations in the training data and NTrees is
        %   the number of trees in the ensemble.  The (I,J) element is true if
        %   observation I is out-of-bag for tree J and false otherwise.  In other
        %   words, a true value means observation I was not selected for the
        %   training data used to grow tree J.
        %
        %   See also TREEBAGGER.
        OOBIndices = [];
    end
    
    properties(SetAccess=public,GetAccess=public,Dependent=true,Hidden=true)
        DefaultScore;
    end
    
    properties(SetAccess=protected,GetAccess=protected,Hidden=true)
        Compact = [];
        PrivOOBPermutedVarDeltaError = [];% NTrees-by-Nvars
        PrivOOBPermutedVarDeltaMeanMargin = [];
        PrivOOBPermutedVarCountRaiseMargin = [];
        PrivProx = [];% Proximity matrix in the form of a 1D array
        PriorStruct = [];% Prior saved as a structure
        CostStruct = [];% Cost saved as a struct
    end
    
    properties(SetAccess=protected,GetAccess=public,Dependent=true)
        %TREES Decision trees in the ensemble.
        %   The Trees property is a cell array of size NTrees-by-1 containing the
        %   trees in the ensemble.
        %
        %   See also TREEBAGGER, NTREES.
        Trees;
        
        %NTREES Number of decision trees in the ensemble.
        %   The NTrees property is a scalar equal to the number of decision trees
        %   in the ensemble.
        %
        %   See also TREEBAGGER, TREES.
        NTrees;
        
        %CLASSNAMES Names of classes.
        %   The ClassNames property is a cell array containing the class names for
        %   the response variable Y.  This property is empty for regression trees.
        %
        %   See also TREEBAGGER.
        ClassNames;
        
        %PRIOR Prior class probabilities.
        %   The Prior property is a vector with prior probabilities for
        %   classes.  This property is empty for ensembles of regression trees.
        %
        %   See also TREEBAGGER, CLASSREGTREE.
        Prior = [];
        
        %COST Misclassification costs.
        %   The Cost property is a matrix with misclassification costs.
        %   This property is empty for ensembles of regression trees.
        %
        %   See also TREEBAGGER, CLASSREGTREE.
        Cost = [];
        
        %VARNAMES Variable names.
        %   The VarNames property is a cell array containing the names of the
        %   predictor variables (features).  These names are taken from the
        %   optional 'names' parameter.  The default names are 'x1', 'x2', etc.
        %
        %   See also TREEBAGGER.
        VarNames;
        
        %METHOD Method used by trees (classification or regression).
        %   The Method property is 'classification' for classification ensembles
        %   and 'regression' for regression ensembles.
        %
        %   See also TREEBAGGER.
        Method;
        
        %OOBINSTANCEWEIGHT Count of out-of-bag trees for each observation.
        %   The OOBInstanceWeight property is a numeric array of size Nobs-by-1
        %   containing the number of trees used for computing OOB response for each
        %   observation.  Nobs is the number of observations in the training data
        %   used to create the ensemble.
        %
        %   See also TREEBAGGER.
        OOBInstanceWeight;
                
        %OOBPERMUTEDVARDELTAERROR Variable importance for classification error.
        %   The OOBPermutedVarDeltaError property is a numeric array of size
        %   1-by-Nvars containing a measure of importance for each predictor
        %   variable (feature).  For any variable, the measure is the increase in
        %   classification if the values of that variable are permuted across the
        %   out-of-bag observations. This measure is computed for every tree,
        %   then averaged over the entire ensemble and divided by the standard
        %   deviation over the entire ensemble.
        %
        %   See also TREEBAGGER.
        OOBPermutedVarDeltaError;
        
        %OOBPERMUTEDVARDELTAMEANMARGIN Variable importance for classification
        %   margin. The OOBPermutedVarDeltaMeanMargin property is a numeric array
        %   of size 1-by-Nvars containing a measure of importance for each
        %   predictor variable (feature).  For any variable, the measure is the
        %   decrease in the classification margin if the values of that variable
        %   are permuted across the out-of-bag observations. This measure is
        %   computed for every tree, then averaged over the entire ensemble and
        %   divided by the standard deviation over the entire ensemble. This
        %   property is empty for regression trees.
        %
        %   See also TREEBAGGER.
        OOBPermutedVarDeltaMeanMargin;
        
        %OOBPERMUTEDVARCOUNTRAISEMARGIN Variable importance for raising margin.
        %   The OOBPermutedVarCountRaiseMargin property is a numeric array of size
        %   1-by-Nvars containing a measure of variable importance for each
        %   predictor.  For any variable, the measure is the difference between the
        %   number of raised margins and the number of lowered margins if the
        %   values of that variable are permuted across the out-of-bag
        %   observations. This measure is computed for every tree, then averaged
        %   over the entire ensemble and divided by the standard deviation over the
        %   entire ensemble. This property is empty for regression trees.
        %
        %   See also TREEBAGGER.
        OOBPermutedVarCountRaiseMargin;
        
        %DELTACRITDECISIONSPLIT Split criterion contributions for each predictor.
        %   The DeltaCritDecisionSplit property is a numeric array of size
        %   1-by-Nvars of changes in the split criterion summed over splits on each
        %   variable, averaged across the entire ensemble of grown trees.
        %
        % See also TREEBAGGER, COMPACTTREEBAGGER/DELTACRITDECISIONSPLIT,
        % CLASSREGTREE/VARIMPORTANCE. 
        DeltaCritDecisionSplit;
        
        %NVARSPLIT Number of decision splits for each predictor.
        %   The NVarSplit property is a numeric array of size 1-by-Nvars, where
        %   every element gives a number of splits on this predictor summed over
        %   all trees.
        %
        %   See also TREEBAGGER, COMPACTTREEBAGGER/NVARSPLIT.
        NVarSplit;

        %VARASSOC Variable associations.
        %   The VarAssoc property is a matrix of size Nvars-by-Nvars with
        %   predictive measures of variable association, averaged across the entire
        %   ensemble of grown trees. If you grew the ensemble setting 'surrogate'
        %   to 'on', this matrix for each tree is filled with predictive measures
        %   of association averaged over the surrogate splits. If you grew the
        %   ensemble setting 'surrogate' to 'off' (default), VarAssoc is diagonal.
        %
        % See also COMPACTTREEBAGGER, COMPACTTREEBAGGER/VARASSOC,
        % CLASSREGTREE/MEANSURRVARASSOC.
        VarAssoc;

        %PROXIMITY Proximity matrix for observations.
        %   The Proximity property is a numeric matrix of size Nobs-by-Nobs, where
        %   Nobs is the number of observations in the training data, containing
        %   measures of the proximity between observations.  For any two
        %   observations, their proximity is defined as the fraction of trees for
        %   which these observations land on the same leaf.  This is a symmetric
        %   matrix with 1's on the diagonal and off-diagonal elements ranging from
        %   0 to 1.
        %
        %   See also TREEBAGGER, COMPACTTREEBAGGER/PROXIMITY.
        Proximity;
        
        %OUTLIERMEASURE Measure for determining outliers.
        %   The OutlierMeasure property is a numeric array of size Nobs-by-1, where
        %   Nobs is the number of observations in the training data, containing
        %   outlier measures for each observation.
        %
        %   See also TREEBAGGER, COMPACTTREEBAGGER/OUTLIERMEASURE.
        OutlierMeasure;
    end

        
    properties(SetAccess=public,GetAccess=public,Dependent=true)
        %DEFAULTYFIT Default value returned by PREDICT and OOBPREDICT.
        %   The DefaultYfit property controls what predicted value is returned when
        %   no prediction is possible, for example when the OOBPREDICT method needs
        %   to predict for an observation that is in-bag for all trees in the
        %   ensemble.  For classification, you can set this property to either ''
        %   or 'MostPopular'.  If you choose 'MostPopular' (default), the property
        %   value becomes the name of the most probable class in the training data.
        %   For regression, you can set this property to any numeric scalar.  The
        %   default is the mean of the response for the training data.  If you set
        %   this property to '' for classification or NaN for regression, the
        %   in-bag observations are excluded from computation of the out-of-bag
        %   error and margin.
        %
        %   See also TREEBAGGER, OOBPREDICT, PREDICT, OOBINDICES,
        %   COMPACTTREEBAGGER/DEFAULTYFIT.
        DefaultYfit;
    end
    

    methods
        function bagger = TreeBagger(NTrees,X,Y,varargin)
            %TREEBAGGER Create an ensemble of bagged decision trees.
            %   B = TREEBAGGER(NTREES,X,Y) creates an ensemble B of NTREES decision
            %   trees for predicting response Y as a function of predictors X. By
            %   default TREEBAGGER builds an ensemble of classification trees. The
            %   function can build an ensemble of regression trees by setting the
            %   optional input argument 'method' to 'regression'.
            %
            %   X is a numeric matrix of training data. Each row represents an
            %   observation and each column represents a predictor or feature. Y is an
            %   array of true class labels for classification or numeric function
            %   values for regression. True class labels can be a numeric vector,
            %   character matrix, vector cell array of strings or categorical vector
            %   (see help for groupingvariable). TREEBAGGER converts labels to a cell
            %   array of strings for classification.
            %
            %   B = TREEBAGGER(NTREES,X,Y,'PARAM1',val1,'PARAM2',val2,...) specifies
            %   optional parameter name/value pairs:
            %
            %     'fboot'       Fraction of input data to sample with replacement
            %                   from the input data for growing each new tree.
            %                   By default set to 1.
            %     'samplewithreplacement'   'on' to sample with replacement or 'off' to
            %                               sample without replacement. If you sample
            %                               without replacement, you need to set
            %                               'fboot' to a value less than one. Default
            %                               is 'on'.
            %     'oobpred'     'on' to store info on what observations are out of bag
            %                   for each tree. This info can be used by OOBPREDICT to
            %                   compute the out-of-bag predicted class probabilities
            %                   for each tree in the ensemble.  Default is 'off'.
            %     'oobvarimp'   'on' to store out-of-bag estimates of feature
            %                   importance in the ensemble.  Default is 'off'.
            %                   Specifying 'on' also sets the 'oobpred' value to 'on'.
            %     'method'      Either 'classification' or 'regression'. Regression
            %                   requires a numeric Y.
            %     'nvartosample' Number of variables to select at random for each
            %                   decision split. Default is the square root of the
            %                   number of variables for classification and one third of
            %                   the number of variables for regression. Valid values
            %                   are 'all' or a positive integer. Setting this argument
            %                   to any valid value but 'all' invokes Breiman's 'random
            %                   forest' algorithm.
            %     'nprint'      Number of training cycles (grown trees) after which
            %                   TREEBAGGER displays a diagnostic message showing training
            %                   progress. Default is no diagnostic messages.
            %     'minleaf'     Minimum number of observations per tree leaf. Default
            %                   is 1 for classification and 5 for regression.
            %     'options'     A struct that contains options specifying whether to use
            %                   parallel computation when growing the ensemble of decision
            %                   trees, and options specifying how to use random numbers 
            %                   when drawing replicates of the original data. This argument 
            %                   can be created by a call to STATSET. TREEBAGGER uses the 
            %                   following fields:
            %                    'UseParallel'
            %                    'UseSubstreams'
            %                    'Streams'
            %                   For information on these fields see PARALLELSTATS.
            %                   NOTE: if 'UseParallel' is 'always' and 'UseSubstreams' 
            %                   is 'never', then the length of Streams must equal the number 
            %                   of processors used by TREEBAGGER. There are two possibilities. 
            %                   If a MATLAB pool is open, then Streams is the same length as
            %                   the size of the MATLAB pool. If a MATLAB pool is not open,
            %                   then Streams must supply a single random number stream.
            % 
            %
            %   In addition to the optional arguments above, this method accepts all
            %   optional CLASSREGTREE arguments with the exception of 'minparent'.
            %   Refer to the documentation for CLASSREGTREE for more detail.
            %
            %   See also TREEBAGGER, OOBPREDICT, CLASSREGTREE, GROUPINGVARIABLE,
            %   RANDSTREAM, STATSET, STATGET, PARFOR, PARALLELSTATS.

            % Process inputs for the bagger
            growTreeArgs = {'nprint' 'options'};
            growTreeDefs = {0 statset('TreeBagger')};
            [~,emsg,nprint,parallelOptions,makeArgs] ...
                = internal.stats.getargs(growTreeArgs,growTreeDefs,varargin{:});

            % Check status and inputs
            if ~isempty(emsg)
                error('stats:TreeBagger:TreeBagger:InvalidInput',...
                    'Invalid input arguments: %s',emsg);
            end

            % Make an empty bagger
            bagger = init(bagger,X,Y,makeArgs{:});
            
            % Add trees
            bagger = growTrees(bagger,NTrees,'Options', parallelOptions, 'nprint', nprint);
        end
        
        function bagger = growTrees(bagger,NTrees,varargin)
            %GROWTREES Train additional trees and add to ensemble.
            %   B = GROWTREES(B,NTREES) grows NTREES new trees and appends them to
            %   those already stored in the ensemble B.
            %
            %   B = GROWTREES(B,NTREES,'PARAM1',val1,'PARAM2',val2,...) specifies
            %   optional parameter name/value pairs:
            %
            %     'nprint'      Specifies that a diagnostic message showing training
            %                   progress should display after every VALUE training
            %                   cycles (grown trees). Default is no diagnostic messages.
            %
            %     'options'     A struct that contains options specifying whether to use
            %                   parallel computation when growing the ensemble of decision
            %                   trees, and options specifying how to use random numbers 
            %                   when drawing replicates of the original data. This argument 
            %                   can be created by a call to STATSET. TREEBAGGER uses the 
            %                   following options:
            %                    'UseParallel'
            %                    'UseSubstreams'
            %                    'Streams'
            %                   For information on these options see PARALLELSTATS.
            %                   NOTE: if 'UseParallel' is 'always' and 'UseSubstreams' 
            %                   is 'never', then the length of Streams must equal the number 
            %                   of processors used by TREEBAGGER. There are two possibilities. 
            %                   If a MATLAB pool is open, then Streams is the same length as
            %                   the size of the MATLAB pool. If a MATLAB pool is not open,
            %                   then Streams must supply a single random number stream.
            %
            %   See also TREEBAGGER, CLASSREGTREE, RANDSTREAM, STATSET, STATGET, 
            %   PARFOR, PARALLELSTATS.
            
            % Process inputs for the bagger
            baggerArgs = {'nprint'   'options'};
            baggerDefs = {       0   statset('TreeBagger')};
            [~,emsg,nprint,parallelOptions] ...
                = internal.stats.getargs(baggerArgs,baggerDefs,varargin{:});
            
            % Check status and inputs
            if ~isempty(emsg)
                error('stats:TreeBagger:growTrees:InvalidInput',...
                    'Invalid input arguments: %s',emsg);
            end
            
            % Check print-out frequency
            if isempty(nprint) || ~isnumeric(nprint) || numel(nprint)~=1 || nprint<0
                warning('stats:TreeBagger:growTrees:InvalidInput',...
                    'Print-out frequency must be a positive integer.');
            end
            
            % Check number of trees
            if ~isnumeric(NTrees) || NTrees<1
                error('stats:TreeBagger:growTrees:InvalidInput',...
                    'Number of trees must be a positive integer.');
            end
            
            % Process options for parallel execution and random number control
            %            [useParallel, usePool, useSubstreams, streams, substreamOffset] = ...
            %                                            processOptions(parallelOptions);
            [useParallel, RNGscheme, poolsz] = ...
                internal.stats.parallel.processParallelAndStreamOptions(parallelOptions,true);
            usePool = useParallel && poolsz>0;
            
            % Determine data size and number of vars
            [N,Nvars] = size(bagger.X);
            
            % How many trees have been grown, so far?
            NTreesBefore = bagger.NTrees;
            
            % Prepare oob arrays
            if bagger.ComputeOOBPrediction
                % Expand array of oob indices
                if isempty(bagger.OOBIndices)
                    bagger.OOBIndices = false(N,NTrees);
                else
                    bagger.OOBIndices(1:N,end+1:end+NTrees) = false;
                end
                
                % Expand array with delta error and delta margin
                if bagger.ComputeOOBVarImp
                    bagger.PrivOOBPermutedVarDeltaError(end+1:end+NTrees,1:Nvars) ...
                        = zeros(NTrees,Nvars);
                    if bagger.Method(1)=='c'
                        bagger.PrivOOBPermutedVarDeltaMeanMargin(end+1:end+NTrees,1:Nvars) ...
                            = zeros(NTrees,Nvars);
                        bagger.PrivOOBPermutedVarCountRaiseMargin(end+1:end+NTrees,1:Nvars) ...
                            = zeros(NTrees,Nvars);
                    end
                end
            end
            
            % Prepare prune and mergeleaves args
            prune = 'off';
            if bagger.Prune
                prune = 'on';
            end
            mergeleaves = 'off';
            if bagger.MergeLeaves
                mergeleaves = 'on';
            end
            
            % Allocate a cell array for the trees
            trees = cell(NTrees,1);
            
            % Preallocate storage for temporary variables
            slicedOOBIndices = zeros(N,NTrees);
            slicedPrivOOBPermutedVarDeltaError = zeros(NTrees,Nvars);
            slicedPrivOOBPermutedVarDeltaMeanMargin = zeros(NTrees,Nvars);
            slicedPrivOOBPermutedVarCountRaiseMargin = zeros(NTrees,Nvars);
            
            % Set up running counts for optional progress reports
            if nprint>0
                if usePool
                    % We are asked for a periodic tally of progress in growing
                    % the ensemble. On each worker, we maintain a running count
                    % of the number of trees created during this function
                    % invocation. This count is on an individual worker basis,
                    % not a cumulative count across all the workers.
                    % Here we initialize the count on each worker.
                    parfor i=1:matlabpool('size')
                        internal.stats.parallel.statParallelStore('mylabindex', i);
                        internal.stats.parallel.statParallelStore('ntreesGrown',0);
                    end
                else
                    % Initialize running count variables on the client
                    internal.stats.parallel.statParallelStore('mylabindex', 1);
                    internal.stats.parallel.statParallelStore('ntreesGrown',0);
                end
            end
            
            % Grow the trees
            if bagger.ComputeOOBPrediction
                if bagger.ComputeOOBVarImp
                    if bagger.Method(1)=='c'
                        [trees, ...
                            slicedOOBIndices, ...
                            slicedPrivOOBPermutedVarDeltaError ...
                            slicedPrivOOBPermutedVarDeltaMeanMargin, ...
                            slicedPrivOOBPermutedVarCountRaiseMargin] = ...
                            internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
                    else
                        [trees, ...
                            slicedOOBIndices, ...
                            slicedPrivOOBPermutedVarDeltaError] = ...
                            internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
                    end
                else
                        [trees, slicedOOBIndices] = ...
                            internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);                    
                end
            else
                trees = internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
            end
            
            % Append scores for the newly grown trees to the accumulated list
            if bagger.ComputeOOBPrediction
                bagger.OOBIndices(:,NTreesBefore+1:NTreesBefore+NTrees) = slicedOOBIndices;
                
                if bagger.ComputeOOBVarImp
                    bagger.PrivOOBPermutedVarDeltaError(NTreesBefore+1:NTreesBefore+NTrees,:) = ...
                        slicedPrivOOBPermutedVarDeltaError;
                    if bagger.Method(1)=='c'
                        bagger.PrivOOBPermutedVarDeltaMeanMargin(NTreesBefore+1:NTreesBefore+NTrees,:) = ...
                            slicedPrivOOBPermutedVarDeltaMeanMargin;
                        bagger.PrivOOBPermutedVarCountRaiseMargin(NTreesBefore+1:NTreesBefore+NTrees,:) = ...
                            slicedPrivOOBPermutedVarCountRaiseMargin;
                    end
                end
            end
            
            % Store grown trees in the Compact object
            bagger.Compact = addTrees(bagger.Compact,trees);
            
            % --------- Nested within growTrees ----------
            %
            % Grow one tree and optional metrics. This is the body of iterative loops.
            function [slicedTree, ...
                    slicedOOBIndices, ...
                    slicedPrivOOBPermutedVarDeltaError, ...
                    slicedPrivOOBPermutedVarDeltaMeanMargin, ...
                    slicedPrivOOBPermutedVarDeltaCountRaiseMargin] = loopBody(it,s)
                
                if isempty(s)
                    s = RandStream.getDefaultStream;
                end
                
                % Draw instances for training
                idxtrain = TreeBagger.plainSample(s,N,bagger.FBoot,...
                    bagger.SampleWithReplacement);
                
                % Grow the tree
                tree = ...
                    classregtree(bagger.X(idxtrain,:),bagger.Y(idxtrain),...
                    'weights',bagger.W(idxtrain),...
                    'method',bagger.Method,'prune',prune,...
                    'cost',bagger.CostStruct,'priorprob',bagger.PriorStruct,...
                    'nvartosample',bagger.NVarToSample,...
                    'minparent',2*bagger.MinLeaf,'minleaf',bagger.MinLeaf,...
                    'mergeleaves',mergeleaves, ...
                    'stream',s,bagger.TreeArgs{:});
                                
                %
                % Optional stuff
                %
                
                % Out of bag estimates
                if bagger.ComputeOOBPrediction
                    % Record indices of OOB instances
                    oobtf = true(N,1);
                    oobtf(idxtrain) = false;
                    slicedOOBIndices = oobtf;  % assign to bagger.OOBIndices
                    % outside the parfor loop
                    
                    
                    % Make a compact object with a single tree for predictions
                    localcompact = CompactTreeBagger({tree},...
                        bagger.ClassNames,bagger.VarNames);
                    
                    % Update scores for feature importance
                    if bagger.ComputeOOBVarImp
                        % Collect the quantities in the loop.
                        % Assign to TreeBagger class variables (ie, Properties)
                        % on exit from the loop.
                        if bagger.Method(1)=='c'
                            [slicedPrivOOBPermutedVarDeltaError ...
                                slicedPrivOOBPermutedVarDeltaMeanMargin ...
                                slicedPrivOOBPermutedVarDeltaCountRaiseMargin ] = ...
                                oobPermVarUpdate(bagger,it + NTreesBefore,localcompact,1,oobtf,s);
                        else
                            slicedPrivOOBPermutedVarDeltaError = ...
                                oobPermVarUpdate(bagger,it + NTreesBefore,localcompact,1,oobtf,s);
                        end
                    end
                end
                
                % Report progress
                if nprint>0
                    ntreesGrown = internal.stats.parallel.statParallelStore('ntreesGrown') + 1;
                    internal.stats.parallel.statParallelStore('ntreesGrown',ntreesGrown);
                    if floor(ntreesGrown/nprint)*nprint==ntreesGrown
                        if usePool
                            fprintf(1,'%i Trees done on worker %i.\n', ...
                                ntreesGrown, ...
                                internal.stats.parallel.statParallelStore('mylabindex'));
                        else
                            fprintf(1,'Tree %i done.\n',it);
                        end
                    end
                end
                
                slicedTree{1} = tree;
                
            end %-nested function loopBody
            
        end %-growTrees

        function cmp = compact(bagger)
            %COMPACT Compact ensemble of decision trees.
            %   Return an object of class CompactTreeBagger holding the structure of
            %   the trained ensemble.  The class is more compact than the full
            %   TreeBagger class because it does not contain information for growing
            %   more trees for the ensemble. In particular it does not contain X and Y
            %   used for training.
            %
            % See also COMPACTTREEBAGGER.

            cmp = bagger.Compact;
        end
        
        function bagger = fillProximities(bagger,varargin)
            %FILLPROXIMITIES Proximity matrix for training data.
            %   B = FILLPROXIMITIES(B) computes a proximity matrix for the training data
            %   and stores it in the Properties field of B.
            %
            %   B = FILLPROXIMITIES(B,'PARAM1',val1,'PARAM2',val2,...) specifies
            %   optional parameter name/value pairs:
            %
            %     'trees'       Either 'all' or a vector of indices of the trees in the
            %                   ensemble to be used in computing the proximity matrix.
            %                   Default is 'all'.
            %     'nprint'      Number of training cycles (grown trees) after which
            %                   TREEBAGGER displays a diagnostic message showing training
            %                   progress. Default is no diagnostic messages.
            %
            % See also TREEBAGGER, COMPACTTREEBAGGER/PROXIMITY,
            % COMPACTTREEBAGGER/OUTLIERMEASURE.
            
            bagger.PrivProx = flatprox(bagger.Compact,bagger.X,varargin{:});
        end
        
        function bagger = append(bagger,other)
            %APPEND Append new trees to ensemble.
            %   B = APPEND(B,OTHER) appends the trees from the OTHER ensemble to those
            %   in B.  This method check for consistency of the X and Y properties of
            %   the two ensembles, as well as consistency of their compact objects and
            %   out-of-bag indices, before appending the trees.  The output ensemble B
            %   takes the training parameters such as FBoot, Prior, Cost, and other
            %   from the B input. There is no attempt to check if these training
            %   parameters are consistent between the two objects.
            %
            % See also TREEBAGGER, COMPACTTREEBAGGER/COMBINE.
            
            % Check X
            if ~isequalwithequalnans(bagger.X,other.X)
                error('stats:TreeBagger:append:IncompatibleObjects',...
                    'The two objects have incompatible X data.');
            end
            
            % Check Y
            if ~isequalwithequalnans(bagger.Y,other.Y)
                error('stats:TreeBagger:append:IncompatibleObjects',...
                    'The two objects have incompatible Y data.');
            end
            
            % Check ensemble type
            if ~strcmpi(bagger.Method,other.Method)
                error('stats:TreeBagger:append:IncompatibleObjects',...
                    'The two objects have incompatible methods.');
            end
            
            % Check OOB info
            if bagger.ComputeOOBPrediction~=other.ComputeOOBPrediction ...
                    || bagger.ComputeOOBVarImp~=other.ComputeOOBVarImp
                error('stats:TreeBagger:append:IncompatibleObjects',...
                    'The two objects have incompatible out-of-bag flags.');
            end
            
            % Combine Compact objects
            bagger.Compact = combine(bagger.Compact,other.Compact);
            
            % Combine OOB indices
            NTrees = other.NTrees;
            if NTrees>0 && other.ComputeOOBPrediction
                if size(other.OOBIndices,1)~=size(bagger.OOBIndices,1) || ...
                        size(other.OOBIndices,2)~=NTrees
                    error('stats:TreeBagger:append:BadObject',...
                        'Inconsistent size of OOBIndices.');
                end
                bagger.OOBIndices(:,end+1:end+NTrees) = other.OOBIndices;
            end
            
            % Combine OOB permuted info
            if NTrees>0 && other.ComputeOOBVarImp
                % Error
                if size(bagger.PrivOOBPermutedVarDeltaError,2) ...
                        ~=size(other.PrivOOBPermutedVarDeltaError,2) || ...
                        size(other.PrivOOBPermutedVarDeltaError,1)~=NTrees
                    error('stats:TreeBagger:append:BadObject',...
                        'Inconsistent size of PrivOOBPermutedVarDeltaError.');
                end
                bagger.PrivOOBPermutedVarDeltaError(end+1:end+NTrees,:) = ...
                    other.PrivOOBPermutedVarDeltaError;

                % Mean margin
                if size(bagger.PrivOOBPermutedVarDeltaMeanMargin,2) ...
                        ~=size(other.PrivOOBPermutedVarDeltaMeanMargin,2) || ...
                        size(other.PrivOOBPermutedVarDeltaMeanMargin,1)~=NTrees
                    error('stats:TreeBagger:append:BadObject',...
                        'Inconsistent size of PrivOOBPermutedVarDeltaMeanMargin.');
                end
                bagger.PrivOOBPermutedVarDeltaMeanMargin(end+1:end+NTrees,:) = ...
                    other.PrivOOBPermutedVarDeltaMeanMargin;

                % Raised margins
                if size(bagger.PrivOOBPermutedVarCountRaiseMargin,2) ...
                        ~=size(other.PrivOOBPermutedVarCountRaiseMargin,2) || ...
                        size(other.PrivOOBPermutedVarCountRaiseMargin,1)~=NTrees
                    error('stats:TreeBagger:append:BadObject',...
                        'Inconsistent size of PrivOOBPermutedVarCountRaiseMargin.');
                end
                bagger.PrivOOBPermutedVarCountRaiseMargin(end+1:end+NTrees,:) = ...
                    other.PrivOOBPermutedVarCountRaiseMargin;
            end
            
            % Combine proximities
            if isempty(other.PrivProx)
                bagger.PrivProx = [];
            else
                if ~isempty(bagger.PrivProx)
                    if numel(bagger.PrivProx)~=numel(other.PrivProx)
                        error('stats:TreeBagger:append:BadObject',...
                            'Inconsistent size of PrivProx.');
                    end
                    bagger.PrivProx = ...
                        (bagger.NTrees*bagger.PrivProx + NTrees*other.PrivProx) / ...
                        (bagger.NTrees + NTrees);
                end
            end
        end
    end
    
    
    methods(Hidden=true,Static=true)
        function a = empty(varargin),      throwUndefinedError(); end
    end
    
    
    methods(Hidden=true)
        function a = subsindex(varargin),  throwUndefinedError(); end
        function a = ctranspose(varargin), throwUndefinedError(); end
        function a = transpose(varargin),  throwUndefinedError(); end
        function a = permute(varargin),    throwUndefinedError(); end
        function a = reshape(varargin),    throwUndefinedError(); end
        function a = cat(varargin),        throwUndefinedError(); end
        function a = horzcat(varargin),    throwUndefinedError(); end
        function a = vertcat(varargin),    throwUndefinedError(); end

        function [varargout] = subsref(bagger,s)
            % List of protected properties
            privProps = {'Compact' 'PrivOOBPermutedVarDeltaError' ...
                'PrivOOBPermutedVarDeltaMeanMargin' 'PrivOOBPermutedVarCountRaiseMargin' ...
                'PrivProx' 'PriorStruct' 'CostStruct'};
                
            % Dispatch
            if strcmp(s(1).type,'()')
                error('stats:TreeBagger:subsref:InvalidOperation',...
                    'Subscripting into TreeBagger using () is not allowed.');
            elseif strcmp(s(1).type,'.') && ismember(s(1).subs,privProps)
                error('stats:TreeBagger:subsref:InvalidOperation',...
                    'This property is private.');
            else
                % Return default subsref to this object
                [varargout{1:nargout}] = builtin('subsref',bagger,s);
            end
        end
        
        function [varargout] = subsasgn(bagger,s,data)
            % List of protected properties
            privProps = {'Compact' 'PrivOOBPermutedVarDeltaError' ...
                'PrivOOBPermutedVarDeltaMeanMargin' ...
                'PrivOOBPermutedVarCountRaiseMargin' 'PrivProx' ...
                'PriorStruct' 'CostStruct' ...
                'X' 'Y' 'FBoot' 'SampleWithReplacement' ...
                'TreeArgs' 'ComputeOOBPrediction' 'ComputeOOBVarImp' ...
                'Prune' 'MergeLeaves' 'Prior' 'Cost' 'NVarToSample' ...
                'MinLeaf' 'OOBIndices'};

            % Dispatch
            if strcmp(s(1).type,'()')
                error('stats:TreeBagger:subsasgn:InvalidOperation',...
                    'Assigning to TreeBagger using () is not allowed.');
            elseif strcmp(s(1).type,'.') && ismember(s(1).subs,privProps)
                error('stats:TreeBagger:subsasgn:InvalidOperation',...
                    'This property is private.');
            else
                % Return default subsasgn to this object
                [varargout{1:nargout}] = builtin('subsasgn',bagger,s,data);
            end
        end
        
        function disp(obj)
            fprintf(1,'Ensemble with %i bagged decision trees:\n',obj.NTrees);
            sx = ['[' num2str(size(obj.X,1)) 'x' num2str(size(obj.X,2)) ']'];
            sy = ['[' num2str(size(obj.Y,1)) 'x' num2str(size(obj.Y,2)) ']'];
            fprintf(1,'%25s: %20s\n','Training X',sx);
            fprintf(1,'%25s: %20s\n','Training Y',sy);
            fprintf(1,'%25s: %20s\n','Method',obj.Method);
            fprintf(1,'%25s: %20i\n','Nvars',length(obj.VarNames));
            fprintf(1,'%25s: %20s\n','NVarToSample',num2str(obj.NVarToSample));
            fprintf(1,'%25s: %20i\n','MinLeaf',obj.MinLeaf);
            fprintf(1,'%25s: %20g\n','FBoot',obj.FBoot);
            fprintf(1,'%25s: %20i\n','SampleWithReplacement',obj.SampleWithReplacement);
            fprintf(1,'%25s: %20i\n','ComputeOOBPrediction',obj.ComputeOOBPrediction);
            fprintf(1,'%25s: %20i\n','ComputeOOBVarImp',obj.ComputeOOBVarImp);
            if ~isempty(obj.PrivProx)
                sprox = ['[' num2str(size(obj.X,1)) 'x' num2str(size(obj.X,1)) ']'];
            else
                sprox = '[]';
            end
            fprintf(1,'%25s: %20s\n','Proximity',sprox);
            if obj.Method(1)=='c'
                sform = ' %s';
                if ~isempty(obj.Prior) || ~isempty(obj.Cost)
                    sform = ' %15s';
                end
                fprintf(1,'%25s:','ClassNames');
                for i=1:length(obj.ClassNames)
                    fprintf(1,sform,['''' obj.ClassNames{i} '''']);
                end
                fprintf(1,'\n');
            end
        end
    end
    
    
    methods
        function trees = get.Trees(bagger)
            trees = bagger.Compact.Trees;
        end
        
        function n = get.NTrees(bagger)
            n = length(bagger.Trees);
        end
        
        function cnames = get.ClassNames(bagger)
            cnames = bagger.Compact.ClassNames;
        end

        function prior = get.Prior(bagger)
            if isempty(bagger.PriorStruct)
                prior = [];
            else
                prior = bagger.PriorStruct.prob;
            end
        end
        
        function cost = get.Cost(bagger)
            cost = bagger.CostStruct.cost;
        end
        
        function vnames = get.VarNames(bagger)
            vnames = bagger.Compact.VarNames;
        end
        
        function meth = get.Method(bagger)
            meth = bagger.Compact.Method;
        end
        
        function weights = get.OOBInstanceWeight(bagger)
            % Check if OOB info was filled
            if ~bagger.ComputeOOBPrediction
                error('stats:TreeBagger:OOBInstanceWeight:InvalidProperty',...
                    'Out-of-bag information was not saved. Run with ''oobpred'' set to ''on''.');
            end
            
            % Get weights
            weights = sum(bagger.OOBIndices,2);
        end
        
        function deltacrit = get.DeltaCritDecisionSplit(bagger)
            deltacrit = bagger.Compact.DeltaCritDecisionSplit;
        end
        
        function nsplit = get.NVarSplit(bagger)
            nsplit = bagger.Compact.NVarSplit;
        end
        
        function assoc = get.VarAssoc(bagger)
            assoc = bagger.Compact.VarAssoc;
        end

        function delta = get.OOBPermutedVarDeltaError(bagger)
            % Check if permutation info was filled
            if ~bagger.ComputeOOBVarImp
                error('stats:TreeBagger:OOBPermutedVarDeltaError:InvalidProperty',...
                    'Out-of-bag permutations were not saved. Run with ''oobvarimp'' set to ''on''.');
            end
            
            % Get error shifts due to variable permutation
            delta = bagger.normalizedMean1(bagger.PrivOOBPermutedVarDeltaError);
        end
        
        function delta = get.OOBPermutedVarDeltaMeanMargin(bagger)
            % Check if permutation info was filled
            if ~bagger.ComputeOOBVarImp
                error('stats:TreeBagger:OOBPermutedVarDeltaMeanMargin:InvalidProperty',...
                    'Out-of-bag permutations were not saved. Run with ''oobvarimp'' set to ''on''.');
            end
            
            % Get shifts in mean margin due to variable permutations
            delta = bagger.normalizedMean1(bagger.PrivOOBPermutedVarDeltaMeanMargin);
        end
        
        function delta = get.OOBPermutedVarCountRaiseMargin(bagger)
            % Check if permutation info was filled
            if ~bagger.ComputeOOBVarImp
                error('stats:TreeBagger:OOBPermutedVarCountRaiseMargin:InvalidProperty',...
                    'Out-of-bag permutations were not saved. Run with ''oobvarimp'' set to ''on''.');
            end
            
            % Get shifts in raised-lowered margin counts due to variable
            % permutations
            delta = bagger.normalizedMean1(bagger.PrivOOBPermutedVarCountRaiseMargin);
        end
        
        function prox = get.Proximity(bagger)
            % Check if proximities were computed
            if isempty(bagger.PrivProx)
                error('stats:TreeBagger:Proximity:InvalidProperty',...
                    'Proximities were not computed. Call fillProximities() first.');
            end
            
            % Get proximities
            prox = squareform(bagger.PrivProx);
            N = size(bagger.X,1);
            prox(1:N+1:end) = 1;
        end
        
        function outlier = get.OutlierMeasure(bagger)
            % Check if proximities have been computed
            if isempty(bagger.PrivProx)
                error('stats:TreeBagger:OutlierMeasure:InvalidProperty',...
                    'Proximities were not computed. Call fillProximities() first.');
            end
            
            % Compute outliers
            if bagger.Method(1)=='c'
                outlier = outlierMeasure(bagger.Compact,bagger.Proximity,...
                    'data','proximity','labels',bagger.Y);
            else
                outlier = outlierMeasure(bagger.Compact,bagger.Proximity,...
                    'data','proximity');
            end
        end
        
        function yfit = get.DefaultYfit(bagger)
            yfit = bagger.Compact.DefaultYfit;
        end
        
        function bagger = set.DefaultYfit(bagger,yfit)
            bagger.Compact = setDefaultYfit(bagger.Compact,yfit);
        end
        
        function sc = get.DefaultScore(bagger)
            sc = bagger.Compact.DefaultScore;
        end
        
        function bagger = set.DefaultScore(bagger,score)
            bagger.Compact.DefaultScore = score;
        end
    end

   
    methods(Access=protected,Hidden=true,Static=true)
        function nm = normalizedMean1(A)
            % Init
            nm = zeros(1,size(A,2));
            
            % Get mean and stdev
            m = mean(A,1);
            s = std(A,1,1);
            
            % Get deltas
            above0 = s>0;
            nm(above0) = m(above0)./s(above0);
        end
        
        function rdseq = plainSample(s,N,fsample,replace)
            % Get number of instances to draw
            Nsample = ceil(N*fsample);
            if Nsample==0
                error('stats:TreeBagger:plainSample:NoData',...
                    'Not enough observations for sampling.')
            end
            
            % Sample
            if isempty(s)
                rdseq = randsample(N,Nsample,replace);
            else
                rdseq = randsample(s,N,Nsample,replace);
            end
        end
    end
    
    
    methods(Access=protected,Hidden=true)
        function bagger = init(bagger,x,y,varargin)
            % Process inputs for the bagger
            baggerArgs = {'fboot' ...
                          'samplewithreplacement' 'oobpred' 'oobvarimp' ...
                          'method' 'prune' 'mergeleaves' 'names' 'cost' ...
                          'priorprob' 'nvartosample' 'minleaf' ...
                          'minparent' 'splitmin' 'weights'};
            baggerDefs = {      1 ...
                                             'on'    'off'       'off' ...
                  'classification'   'off'         'off'      {}     [] ...
                                   []             []        [] ...
                                   []         []        []};
            [~,emsg,bagger.FBoot,...
                samplemethod,oobpred,oobvarimp, ...
                method,prune,merge,varnames,cost, ...
                prior,nvartosample,minleaf, ...
                minparent,splitmin,w,bagger.TreeArgs] ...
                = internal.stats.getargs(baggerArgs,baggerDefs,varargin{:});
            
            % Check status and inputs
            if ~isempty(emsg)
                error('stats:TreeBagger:init:InvalidInput',...
                    'Invalid input arguments: %s',emsg);
            end
            
            checkOnOff = ...
                @(x) ischar(x) && (strcmpi(x,'off') || strcmpi(x,'on'));

            if ~isnumeric(bagger.FBoot) ...
                    || bagger.FBoot<=0 || bagger.FBoot>1
                error('stats:TreeBagger:init:InvalidInput',...
                    'Input fraction of observations for bootstrapping must be between 0 and 1.');
            end
                        
            if ~checkOnOff(samplemethod)
                error('stats:TreeBagger:init:InvalidInput',...
                    '''samplewithreplacement'' argument must be set to either on or off.');
            end
            bagger.SampleWithReplacement = strcmpi(samplemethod,'on');
            
            if ~checkOnOff(oobpred)
                error('stats:TreeBagger:init:InvalidInput',...
                    '''oobpred'' argument must be set to either on or off.');
            end
            bagger.ComputeOOBPrediction = strcmpi(oobpred,'on');

            if ~checkOnOff(oobvarimp)
                error('stats:TreeBagger:init:InvalidInput',...
                    '''oobvarimp'' argument must be set to either on or off.');
            end
            bagger.ComputeOOBVarImp = strcmpi(oobvarimp,'on');

            if isempty(method) || ~ischar(method) ...
                    || ~(method(1)=='c' || method(1)=='r')
                error('stats:TreeBagger:init:InvalidInput',...
                    '''method'' argument must be set to either ''classification'' or ''regression''.');
            end

            if ~checkOnOff(prune)
                error('stats:TreeBagger:init:InvalidInput',...
                    '''prune'' argument must be set to either on or off.');
            end
            bagger.Prune = strcmpi(prune,'on');
            if bagger.Prune
                warning('stats:TreeBagger:init:BadPruneValue',...
                    'Pruning bagged trees is not recommended.');
            end
            
            if ~checkOnOff(merge)
                error('stats:TreeBagger:init:InvalidInput',...
                    '''mergeleaves'' argument must be set to either on or off.');
            end
            bagger.MergeLeaves = strcmpi(merge,'on');
            if bagger.MergeLeaves
                warning('stats:TreeBagger:init:BadMergeLeavesValue',...
                    'Merging leaves for bagged trees is not recommended.');
            end
            
            if isempty(w)
                w = ones(size(x,1),1);
            end
            if ~isfloat(w) || length(w)~=size(x,1)
                error('stats:TreeBagger:init:InvalidInput',...
                    'Weights must be a floating-point vector with as many elements as there are observations in input data.');
            end
            
            % Figure out logic for input params
            bagger.ComputeOOBPrediction = ...
                bagger.ComputeOOBPrediction || bagger.ComputeOOBVarImp;

            % Prepare data
            [bagger.X,ynum,bagger.W,classnames,bagger.Y] ...
                = classregtree.preparedata(x,y,w,method(1)=='c');
            if islogical(bagger.Y)
                bagger.Y = double(bagger.Y);
            end

            % Have enough observations for OOB error?
            N = size(bagger.X,1);
            if bagger.ComputeOOBPrediction && ~bagger.SampleWithReplacement ...
                    && N*(1-bagger.FBoot)<1
                error('stats:TreeBagger:init:NotEnoughOOBobservations',...
                    'If you sample without replacement and need to compute out-of-bag predictions, you must provide a smaller value for ''fboot''.');
            end
                
            % Convert response to strings for classification
            if method(1)=='c' && ~iscellstr(bagger.Y)
                bagger.Y = cellstr(nominal(bagger.Y));
            end

            % Get number of predictors and their names
            Nvars = size(bagger.X,2);
            varnames = classregtree.preparevars(varnames,Nvars);
            if isempty(varnames)
                error('stats:TreeBagger:init:BadVariableValue',...
                    'No variables are found in the input data.');
            end
            
            % Make Compact object
            bagger.Compact = CompactTreeBagger({},classnames,varnames);

            % If prior or cost are supplied, convert them into structures
            % with correct names
            if method(1)=='c'
                Nclasses = length(bagger.ClassNames);
                C = false(N,Nclasses);
                C(sub2ind([N Nclasses],(1:N)',ynum)) = 1;
                WC = bsxfun(@times,C,bagger.W);
                Wj = sum(WC,1);
                [newprior,newcost,removerows] = ...
                    classregtree.priorandcost(prior,cost,bagger.ClassNames,Wj,ynum);
                if any(removerows)
                    bagger.X(removerows,:) = [];
                    bagger.Y(removerows) = [];
                    bagger.W(removerows) = [];
                end
                % By default every tree must figure out prior from
                % resampled class frequencies
                if ~isempty(prior)
                    bagger.PriorStruct.group = bagger.ClassNames;
                    bagger.PriorStruct.prob = newprior;
                end
                % Unlike prior, cost is always filled
                bagger.CostStruct.group = bagger.ClassNames;
                bagger.CostStruct.cost = newcost;
            end
                
            % Check number of variables to sample at random
            if isempty(nvartosample)
                if     method(1)=='c'
                    bagger.NVarToSample = ceil(sqrt(length(varnames)));
                elseif method(1)=='r'
                    bagger.NVarToSample = ceil(length(varnames)/3);
                end
            else
                bagger.NVarToSample = nvartosample;
            end
            
            % Check tree leaf size
            if isempty(minleaf)
                if     method(1)=='c'
                    bagger.MinLeaf = 1;
                elseif method(1)=='r'
                    bagger.MinLeaf = 5;
                end
            else
                bagger.MinLeaf = minleaf;
            end
            
            % Catch user attempts to set leaf size through classregtree
            if ~isempty(minparent) || ~isempty(splitmin)
                error('stats:TreeBagger:init:InvalidInput',...
                    'TreeBagger does not accept ''minparent'' and ''splitmin'' input parameters. Use ''minleaf''.');
            end
            
            % Compute default scores
            if method(1)=='c'
                if ~isempty(bagger.PriorStruct) % use supplied priors
                    bagger.Compact.ClassProb = bagger.PriorStruct.prob;
                else % get default scores from class frequencies
                    [idx,grp] = grp2idx(bagger.Y);
                    Nclass = max(idx);
                    unmapped = zeros(Nclass,1);
                    for c=1:Nclass
                        unmapped(c) = sum(bagger.W(idx==c));
                    end
                    unmapped = unmapped / sum(unmapped);
                    [~,pos] = ismember(bagger.ClassNames,grp);
                    bagger.Compact.ClassProb = unmapped(pos);
                end
                bagger.DefaultYfit = 'mostpopular';
            else
                % For regression, NaN's were removed by classregtree/preparedata
                bagger.DefaultYfit = dot(bagger.W,bagger.Y)/sum(bagger.W);
            end
        end
    end    
    
    methods(Access=protected)
        function [slicedPrivOOBPermutedVarDeltaError ...
                  slicedPrivOOBPermutedVarDeltaMeanMargin ...
                  slicedPrivOOBPermutedVarCountRaiseMargin] = ... 
                oobPermVarUpdate(bagger,~,compact,compactInd,oobtf,s)

            % oobPermVarUpdate:
            % The output arguments correspond to TreeBagger Properties
            % PrivOOBPermutedVarDeltaError, PrivOOBPermutedVarDeltaMeanMargin,
            % and PrivOOBPermutedVarCountRaiseMargin, respectively.
            % They are supplied as return values because in situ assignments
            % to class properties cannot be done in a parfor context.

            % Get oob data
            Xoob = bagger.X(oobtf,:);
            
            % Get size of oob data
            Noob = size(Xoob,1);
            if Noob<=1
                return;
            end
            
            % Get weights
            Woob = bagger.W(oobtf);
            Wtot = sum(Woob);
            if Wtot<=0
                return;
            end
            
            % Get non-permuted scores and labels
            [sfit,~,yfit] = treeEval(compact,compactInd,Xoob);

            % Get error
            if bagger.Method(1)=='c'
                err = dot(Woob,~strcmp(bagger.Y(oobtf),yfit))/Wtot;
            else
                err = dot(Woob,(bagger.Y(oobtf)-yfit).^2)/Wtot;
            end
            
            % Get margins; for classification only
            if bagger.Method(1)=='c'
                % Get positions of true classes in the scores matrix
                [~,truepos] = ismember(bagger.Y(oobtf),bagger.ClassNames);

                % Get margins
                margin = CompactTreeBagger.getmargin(1:Noob,sfit,truepos);
            end
            
            % Permute values across each input variable
            % and estimate decrease in margin due to permutation
            Nvars = size(bagger.PrivOOBPermutedVarDeltaError,2);

            % Preallocate the output arguments
            slicedPrivOOBPermutedVarDeltaError = zeros(1,Nvars);
            slicedPrivOOBPermutedVarDeltaMeanMargin = zeros(1,Nvars);
            slicedPrivOOBPermutedVarCountRaiseMargin = zeros(1,Nvars);

            for ivar=1:Nvars
                % Get permuted scores and labels
                permuted = randsample(s,Noob,Noob);
                xperm = Xoob;
                xperm(:,ivar) = xperm(permuted,ivar);
                wperm = Woob(permuted);
                [sfitvar,~,yfitvar] = ...
                    treeEval(compact,compactInd,xperm);
                
                % Get the change in error
                if bagger.Method(1)=='c'
                    permErr = dot(wperm,~strcmp(bagger.Y(oobtf),yfitvar))/Wtot;
                else
                    permErr = dot(wperm,(bagger.Y(oobtf)-yfitvar).^2)/Wtot;
                end
                slicedPrivOOBPermutedVarDeltaError(ivar) = permErr-err;
                
                % Get shifts in margins; for classification only
                if bagger.Method(1)=='c'
                    permMargin = ...
                        CompactTreeBagger.getmargin(1:Noob,sfitvar,truepos);
                    deltaMargin = margin-permMargin;
                    slicedPrivOOBPermutedVarDeltaMeanMargin(ivar) = ...
                        dot(wperm,deltaMargin)/Wtot;
                    slicedPrivOOBPermutedVarCountRaiseMargin(ivar) = ...
                        sum(deltaMargin>0) - sum(deltaMargin<0);
                end                
            end
        end
    end
    
    
    methods
        function [varargout] = predict(bagger,varargin)
            %PREDICT Predict response.
            %   Y = PREDICT(B,X) computes predicted response of the trained ensemble B
            %   for data X.  The output has one prediction for each row of X. The
            %   returned Y is a cell array of strings for classification and a numeric
            %   array for regression.
            %
            %   For regression, [YFIT,STDEVS] = PREDICT(B,X) also returns standard
            %   deviations of the computed responses over the ensemble of the grown
            %   trees.
            %
            %   For classification, [YFIT,SCORES] = PREDICT(B,X) returns scores for all
            %   classes. SCORES is a matrix with one row per observation and one column
            %   per class. The order of the columns is given by ClassNames property. For
            %   each observation and each class, the score generated by each tree is
            %   the probability of this observation originating from this class
            %   computed as the fraction of observations of this class in a tree leaf.
            %   These scores are averaged over all trees in the ensemble.
            %
            %   [YFIT,SCORES,STDEVS] = PREDICT(B,X) also returns standard deviations of
            %   the computed scores for classification. STDEVS is a matrix with one row
            %   per observation and one column per class, with standard deviations
            %   taken over the ensemble of the grown trees.
            %
            %   Y = PREDICT(B,X,'PARAM1',val1,'PARAM2',val2,...) specifies optional
            %   parameter name/value pairs:
            %
            %      'trees'     Array of tree indices to use for computation of
            %                  responses.  Default is 'all'.
            %      'treeweights'  Array of NTrees weights for weighting votes from the
            %                  specified trees.
            %      'useifort'  Logical matrix of size Nobs-by-NTrees indicating which
            %                  trees to use to make predictions for each observation.
            %                  By default all trees are used for all observations.
            %
            %   See also TREEBAGGER, COMPACTTREEBAGGER/PREDICT.
            
            [varargout{1:nargout}] = predict(bagger.Compact,varargin{:});
        end

        function [varargout] = oobPredict(bagger,varargin)
            %OOBPREDICT Ensemble predictions for out-of-bag observations.
            %   Y = OOBPREDICT(B) computes predicted responses using the trained bagger
            %   B for out-of-bag observations in the training data.  The output has one
            %   prediction for each observation in the training data. The returned Y is
            %   a cell array of strings for classification and a numeric array for
            %   regression. For observations that are in bag for all trees, OOBPREDICT
            %   returns the default prediction, most popular class for classification
            %   or sample mean for regression.
            %
            %   Y = OOBPREDICT(B,'PARAM1',val1,'PARAM2',val2,...) specifies optional
            %   parameter name/value pairs:
            %
            %      'trees'     Array of tree indices to be used for computation of
            %                  responses.  Default is 'all'.
            %      'treeweights'  Array of NTrees weights for weighting votes from the
            %                  specified trees.
            %
            % See also TREEBAGGER, COMPACTTREEBAGGER/PREDICT, OOBINDICES.
            
            % Check if OOB info was filled
            if ~bagger.ComputeOOBPrediction
                error('stats:TreeBagger:oobPredict:InvalidOperation',...
                    'Out-of-bag information was not saved. Run with ''oobpred'' set to ''on''.');
            end
            
            % Get OOB predictions
            [varargout{1:nargout}] = predict(bagger.Compact,bagger.X,...
                'useifort',bagger.OOBIndices,varargin{:});
        end
        
        function err = oobError(bagger,varargin)
            %OOBERROR Out-of-bag error.
            %   ERR = OOBERROR(B) computes the misclassification probability (for
            %   classification trees) or mean squared error (for regression trees) for
            %   out-of-bag observations in the training data, using the trained bagger
            %   B.  ERR is a vector of length NTrees, where NTrees is the number of
            %   trees in the ensemble.
            %
            %   ERR = OOBERROR(B,'PARAM1',val1,'PARAM2',val2,...) specifies optional
            %   parameter name/value pairs:.
            %
            %     'mode'     String indicating how OOBERROR computes errors. If set to
            %                'cumulative' (default), the method computes cumulative
            %                errors and ERR is a vector of length NTrees, where the 1st
            %                element gives error from tree 1, 2nd element gives error
            %                from trees 1:2 etc, up to 1:NTrees. If set to 'individual',
            %                ERR is a vector of length NTrees, where each element is an
            %                error from each tree in the ensemble. If set to
            %                'ensemble', ERR is a scalar showing the cumulative error
            %                for the entire ensemble.
            %     'weights'  Vector of observation weights to use for error
            %                averaging. By default the weight of every observation
            %                is set to 1. The length of this vector must be equal
            %                to the number of rows in X.
            %     'trees'    Vector of indices indicating what trees to include
            %                in this calculation. By default, this argument is set to
            %                'all' and the method uses all trees. If 'trees' is a numeric
            %                vector, the method returns a vector of length NTrees for
            %                'cumulative' and 'individual' modes, where NTrees is the
            %                number of elements in the input vector, and a scalar for
            %                'ensemble' mode. For example, in the 'cumulative' mode,
            %                the first element gives error from trees(1), the second
            %                element gives error from trees(1:2) etc.
            %     'treeweights' Vector of tree weights. This vector must have the same
            %                length as the 'trees' vector. OOBERROR uses these weights to
            %                combine output from the specified trees by taking a
            %                weighted average instead of the simple non-weighted
            %                majority vote. You cannot use this argument in the
            %                'individual' mode.
            %
            %   See also TREEBAGGER, COMPACTTREEBAGGER/ERROR.
            
            % Check if OOB info was filled
            if ~bagger.ComputeOOBPrediction
                error('stats:TreeBagger:oobError:InvalidOperation',...
                    'Out-of-bag information was not saved. Run with ''oobpred'' set to ''on''.');
            end

            % Get errors
            err = error(bagger.Compact,bagger.X,bagger.Y,...
                'weights',bagger.W,'useifort',bagger.OOBIndices,varargin{:});
        end
        
        function mar = oobMargin(bagger,varargin)
            %OOBMARGIN Out-of-bag margins.
            %   MAR = OOBMARGIN(B) computes an Nobs-by-NTrees matrix of classification
            %   margins for out-of-bag observations in the training data, using the
            %   trained bagger B.
            %
            %   MAR = OOBMARGIN(B,'PARAM1',val1,'PARAM2',val2,...) specifies optional
            %   parameter name/value pairs.
            %
            %     'mode'     String indicating how OOBMARGIN computes errors. If set to
            %                'cumulative' (default), the method computes cumulative
            %                margins and MAR is an Nobs-by-NTrees matrix, where the 1st
            %                column gives margins from tree 1, 2nd column gives margins
            %                from trees 1:2 etc, up to 1:NTrees. If set to 'individual',
            %                MAR is an Nobs-by-NTrees matrix, where each column gives
            %                margins from each tree in the ensemble. If set to
            %                'ensemble', MAR is a single column of length Nobs showing
            %                the cumulative margins for the entire ensemble.
            %     'trees'    Vector of indices indicating what trees to include
            %                in this calculation. By default, this argument is set to
            %                'all' and the method uses all trees. If 'trees' is a numeric
            %                vector, the method returns an Nobs-by-NTrees matrix for
            %                'cumulative' and 'individual' modes, where NTrees is the
            %                number of elements in the input vector, and a single
            %                column for 'ensemble' mode. For example, in the
            %                'cumulative' mode, the first column gives margins from
            %                trees(1), the second column gives margins from
            %                trees(1:2) etc.
            %     'treeweights' Vector of tree weights. This vector must have the same
            %                length as the 'trees' vector. OOBMARGIN uses these weights
            %                to combine output from the specified trees by taking a
            %                weighted average instead of the simple non-weighted
            %                majority vote. You cannot use this argument in the
            %                'individual' mode.
            %
            %   See also TREEBAGGER, COMPACTTREEBAGGER/MARGIN.
            
            % Check if OOB info was filled
            if ~bagger.ComputeOOBPrediction
                error('stats:TreeBagger:oobMargin:InvalidOperation',...
                    'Out-of-bag information was not saved. Run with ''oobpred'' set to ''on''.');
            end
            
            % Get margins
            mar = margin(bagger.Compact,bagger.X,bagger.Y,...
                'useifort',bagger.OOBIndices,varargin{:});
        end
        
        function mar = oobMeanMargin(bagger,varargin)
            %OOBMEANMARGIN Out-of-bag mean margins.
            %   MAR = OOBMEANMARGIN(B) computes average classification margins for
            %   out-of-bag observations in the training data, using the trained bagger
            %   B. OOBMEANMARGIN averages the margins over all out-of-bag observations.
            %   MAR is a row-vector of length NTrees, where NTrees is the number of
            %   trees in the ensemble.
            %
            %   MAR = OOBMEANMARGIN(B,'PARAM1',val1,'PARAM2',val2,...) specifies
            %   optional parameter name/value pairs:
            %
            %     'mode'     String indicating how the method computes
            %                errors. If set to 'cumulative' (default), OOBMEANMARGIN
            %                computes cumulative errors and MAR is a vector of length
            %                NTrees, where the 1st element gives mean margin from tree
            %                1, 2nd element gives mean margin from trees 1:2 etc, up to
            %                1:NTrees. If set to 'individual', MAR is a vector of
            %                length NTrees, where each element is a mean margin from
            %                each tree in the ensemble. If set to 'ensemble', MAR is a
            %                scalar showing the cumulative mean margin for the entire
            %                ensemble.
            %     'weights'  Vector of observation weights to use for margin
            %                averaging. By default the weight of every observation
            %                is set to 1. The length of this vector must be equal
            %                to the number of rows in X.
            %     'trees'    Vector of indices indicating what trees to
            %                include in this calculation. By default, this argument is
            %                set to 'all' and the method uses all trees. If 'trees' is
            %                a numeric vector, the method returns a vector of length
            %                NTrees for 'cumulative' and 'individual' modes, where
            %                NTrees is the number of elements in the input vector, and
            %                a scalar for 'ensemble' mode. For example, in the
            %                'cumulative' mode, the first element gives mean margin
            %                from trees(1), the second element gives mean margin from
            %                trees(1:2) etc.
            %     'treeweights' Vector of tree weights. This vector must
            %                have the same length as the 'trees' vector. OOBMEANMARGIN
            %                uses these weights to combine output from the specified
            %                trees by taking a weighted average instead of the simple
            %                non-weighted majority vote. You cannot use this argument
            %                in the 'individual' mode.
            %
            % See also TREEBAGGER, COMPACTTREEBAGGER/MEANMARGIN.
            
            % Check if OOB info was filled
            if ~bagger.ComputeOOBPrediction
                error('stats:TreeBagger:oobMeanMargin:InvalidOperation',...
                    'Out-of-bag information was not saved. Run with ''oobpred'' set to ''on''.');
            end
            
            % Get margins
            mar = meanMargin(bagger.Compact,bagger.X,bagger.Y,...
                'weights',bagger.W,'useifort',bagger.OOBIndices,varargin{:});
        end
        
         function err = error(bagger,X,Y,varargin)
             %ERROR Error (misclassification probability or MSE).
             %   ERR = ERROR(B,X,Y) computes the misclassification probability (for
             %   classification trees) or mean squared error (MSE, for regression
             %   trees) for each tree, for predictors X given true response Y. For
             %   classification, Y can be either a numeric vector, character matrix,
             %   cell array of strings, categorical vector or logical vector. For
             %   regression, Y must be a numeric vector. ERR is a vector with one error
             %   measure for each of the NTrees trees in the ensemble B.
             %
             %   ERR = ERROR(B,X,Y,'PARAM1',val1,'PARAM2',val2,...) specifies optional
             %   parameter name/value pairs:
             %
             %     'mode'     String indicating how the method computes errors. If set
             %                to 'cumulative' (default), ERROR computes cumulative
             %                errors and ERR is a vector of length NTrees, where the
             %                1st element gives error from tree 1, 2nd element gives
             %                error from trees 1:2 etc, up to 1:NTrees. If set to
             %                'individual', ERR is a vector of length NTrees, where
             %                each element is an error from each tree in the ensemble.
             %                If set to 'ensemble', ERR is a scalar showing the
             %                cumulative error for the entire ensemble.
             %     'weights'  Vector of observation weights to use for error
             %                averaging. By default the weight of every observation
             %                is set to 1. The length of this vector must be equal
             %                to the number of rows in X.
             %     'trees'    Vector of indices indicating what trees to include
             %                in this calculation. By default, this argument is set to
             %                'all' and the method uses all trees. If 'trees' is a
             %                numeric vector, the method returns a vector of length
             %                NTrees for 'cumulative' and 'individual' modes, where
             %                NTrees is the number of elements in the input vector, and
             %                a scalar for 'ensemble' mode. For example, in the
             %                'cumulative' mode, the first element gives error from
             %                tree trees(1), the second element gives error from trees
             %                trees(1:2) etc.
             %     'treeweights' Vector of tree weights. This vector must have the same
             %                length as the 'trees' vector. The method uses these
             %                weights to combine output from the specified trees by
             %                taking a weighted average instead of the simple
             %                non-weighted majority vote. You cannot use this argument
             %                in the 'individual' mode.
             %     'useifort' Logical matrix of size Nobs-by-NTrees indicating which
             %                trees should be used to make predictions for each
             %                observation.  By default the method uses all trees for
             %                all observations.
             %
             % See also TREEBAGGER, COMPACTTREEBAGGER/ERROR.

            % Get errors
            err = error(bagger.Compact,X,Y,varargin{:});
         end

         function mar = margin(bagger,X,Y,varargin)
             %MARGIN Classification margin.
             %   MAR = MARGIN(B,X,Y) computes the classification margins for predictors
             %   X given true response Y. The Y can be either a numeric vector,
             %   character matrix, cell array of strings, categorical vector or logical
             %   vector.  MAR is a numeric array of size Nobs-by-NTrees, where Nobs is
             %   the number of rows of X and Y, and NTrees is the number of trees in the
             %   ensemble B.  For observation I and tree J, MAR(I,J) is the difference
             %   between the score for the true class and the largest score for other
             %   classes.  This method is available for classification ensembles only.
             %
             %   MAR = MARGIN(B,X,Y,'PARAM1',val1,'PARAM2',val2,...) specifies optional
             %   parameter name/value pairs:
             %
             %     'mode'     String indicating how the method computes errors. If set
             %                to 'cumulative' (default), the method computes cumulative
             %                margins and MAR is an Nobs-by-NTrees matrix, where the 1st
             %                column gives margins from tree 1, 2nd column gives margins
             %                from trees 1:2 etc, up to 1:NTrees. If set to
             %                'individual', MAR is an Nobs-by-NTrees matrix, where each
             %                column gives margins from each tree in the ensemble. If
             %                set to 'ensemble', MAR is a single column of length Nobs
             %                showing the cumulative margins for the entire ensemble.
             %     'trees'    Vector of indices indicating what trees to include
             %                in this calculation. By default, this argument is set to
             %                'all' and the method uses all trees. If 'trees' is a
             %                numeric vector, the method returns a vector of length
             %                NTrees for 'cumulative' and 'individual' modes, where
             %                NTrees is the number of elements in the input vector, and
             %                a scalar for 'ensemble' mode. For example, in the
             %                'cumulative' mode, the first element gives error from tree
             %                trees(1), the second element gives error from trees
             %                trees(1:2) etc.
             %     'treeweights' Vector of tree weights. This vector must have the same
             %                length as the 'trees' vector. The method uses these
             %                weights to combine output from the specified trees by
             %                taking a weighted average instead of the simple
             %                non-weighted majority vote. You cannot use this argument
             %                in the 'individual' mode.
             %     'useifort' Logical matrix of size Nobs-by-NTrees indicating which
             %                trees to use to make predictions for each observation.  By
             %                default the method uses all trees for all observations.
             %
             % See also TREEBAGGER, COMPACTTREEBAGGER/MARGIN.

            % Get margins
            mar = margin(bagger.Compact,X,Y,varargin{:});
        end
        
        function [varargout] = meanMargin(bagger,X,Y,varargin)
            %MEANMARGIN Mean classification margin.
            %   MAR = MEANMARGIN(B,X,Y) computes average classification margins for
            %   predictors X given true response Y. The Y can be either a numeric
            %   vector, character matrix, cell array of strings, categorical vector or
            %   logical vector. MEANMARGIN averages the margins over all observations
            %   (rows) in X for each tree.  MAR is a matrix of size 1-by-NTrees, where
            %   NTrees is the number of trees in the ensemble B. This method is
            %   available for classification ensembles only.
            %
            %   MAR = MEANMARGIN(B,X,Y,'PARAM1',val1,'PARAM2',val2,...) specifies
            %   optional parameter name/value pairs:
            %
            %     'mode'     String indicating how MEANMARGIN computes errors. If set
            %                to 'cumulative' (default), the method computes cumulative
            %                errors and MAR is a vector of length NTrees, where the 1st
            %                element gives mean margin from tree 1, 2nd element gives
            %                mean margin from trees 1:2 etc, up to 1:NTrees. If set to
            %                'individual', MAR is a vector of length NTrees, where each
            %                element is a mean margin from each tree in the ensemble.
            %                If set to 'ensemble', MAR is a scalar showing the
            %                cumulative mean margin for the entire ensemble.            
            %     'weights'  Vector of observation weights to use for margin
            %                averaging. By default the weight of every observation
            %                is set to 1. The length of this vector must be equal
            %                to the number of rows in X.
            %     'trees'    Vector of indices indicating what trees to include
            %                in this calculation. By default, this argument is set to
            %                'all' and the method uses all trees. If 'trees' is a
            %                numeric vector, the method returns a vector of length
            %                NTrees for 'cumulative' and 'individual' modes, where
            %                NTrees is the number of elements in the input vector, and
            %                a scalar for 'ensemble' mode. For example, in the
            %                'cumulative' mode, the first element gives error from tree
            %                trees(1), the second element gives error from trees
            %                trees(1:2) etc.
            %     'treeweights' Vector of tree weights. This vector must have the same
            %                length as the 'trees' vector. The method uses these
            %                weights to combine output from the specified trees by
            %                taking a weighted average instead of the simple
            %                non-weighted majority vote. You cannot use this argument
            %                in the 'individual' mode.
            %     'useifort' Logical matrix of size Nobs-by-NTrees indicating which
            %                trees to use to make predictions for each observation.  By
            %                default the method uses all trees for all observations.
            %
            %   See also TREEBAGGER, COMPACTTREEBAGGER/MEANMARGIN.

            [varargout{1:nargout}] = meanMargin(bagger.Compact,X,Y,varargin{:});
        end
        
        function [varargout] = mdsProx(bagger,varargin)
            %MDSPROX Multidimensional scaling of proximity matrix.
            %   [S,E] = MDSPROX(B) returns scaled coordinates S and eigenvalues E for
            %   the proximity matrix in the ensemble B.  The proximity matrix must be
            %   created by an earlier call to FILLPROXIMITIES(B).
            %
            %   [S,E] = MDSPROX(B,'PARAM1',val1,'PARAM2',val2,...) specifies optional
            %   parameter name/value pairs:
            %
            %    'keep'   Array of indices of observations in the training data to
            %             use for multidimensional scaling. By default, this argument
            %             is set to 'all'. If you provide numeric or logical indices,
            %             the method uses only the subset of the training data specified
            %             by these indices to compute the scaled coordinates and
            %             eigenvalues.
            %    'colors' If you supply this argument, MDSPROX makes overlaid scatter
            %             plots of two scaled coordinates using specified colors for
            %             different classes. You must supply the colors as a string
            %             with one character for each color.  If there are more classes
            %             in the data than characters in the supplied string, MDSPROX
            %             only plots the first C classes, where C is the length of the
            %             string. For regression or if you do not provide the vector of
            %             true class labels, the method uses the first color for all
            %             observations in X.
            %    'mdscoords' Indices of the two or three scaled coordinates to be
            %             plotted. By default, MDSPROX makes a scatter plot of the 1st
            %             and 2nd scaled coordinates which correspond to the two
            %             largest eigenvalues.  You can specify any other two or three
            %             indices not exceeding the dimensionality of the scaled data.
            %             This argument has no effect unless you also supply the
            %             'colors' argument.
            %
            %   See also TREEBAGGER, COMPACTTREEBAGGER/MDSPROX, CMDSCALE,
            %   FILLPROXIMITIES.
            
            % Check if proximities have been computed
            if isempty(bagger.PrivProx)
                error('stats:TreeBagger:mdsProx:InvalidProperty',...
                    'Proximities were not computed. Call fillProximities() first.');
            end
            
            % Process inputs
            args = {'keep'};
            defs = { 'all'};
            [~,emsg,keep,compactArgs] = ...
                internal.stats.getargs(args,defs,varargin{:});

            % Check status and inputs
            if ~isempty(emsg)
                error('stats:TreeBagger:mdsProx:InvalidInput',...
                    'Invalid input arguments: %s',emsg);
            end
            
            % Check indices to be kept
            N = size(bagger.X,1);
            if strcmpi(keep,'all')
                keep = 1:N;
            end
            if ~isnumeric(keep) && (~islogical(keep) || length(keep)~=N)
                error('stats:TreeBagger:mdsProx:InvalidInput',...
                    '''keep'' argument must be either numeric or logical of length equal to the number of observations in the training data or ''all''.');
            end
            
            % Get scaled coordinates
            [varargout{1:nargout}] = mdsProx(bagger.Compact,...
                bagger.Proximity(keep,keep),'labels',bagger.Y(keep),...
                'data','proximity',compactArgs{:});
        end
    end
    
end

function throwUndefinedError()
error('stats:TreeBagger:UndefinedFunction','Undefined Method.');
end

