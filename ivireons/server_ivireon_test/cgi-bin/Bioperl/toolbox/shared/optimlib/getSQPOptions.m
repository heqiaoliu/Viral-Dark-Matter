function [options,optionFeedback] = getSQPOptions(options,defaultopt,nVar)
%GETSQPOPTIONS read user options needed by the SQP algorithm of fmincon.
%
% getSQPOptions reads the options from the user-provided structure using
% optimget and overwrites the same fields in the same structure with the
% verified values.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/23 14:04:42 $

% Create optionFeedback structure for exit messages
optionFeedback = createOptionFeedback(options);

% Get options relevant for the SQP algorithm of fmincon that require no
% validation outside of that done in optimget
options.DerivativeCheck = optimget(options,'DerivativeCheck',defaultopt,'fast');
options.FinDiffType     = optimget(options,'FinDiffType',defaultopt,'fast');
options.GradConstr      = optimget(options,'GradConstr',defaultopt,'fast');
options.GradObj         = optimget(options,'GradObj',defaultopt,'fast');
options.MaxIter         = optimget(options,'MaxIter',defaultopt,'fast');
options.TolCon          = optimget(options,'TolCon',defaultopt,'fast');
options.TolFun          = optimget(options,'TolFun',defaultopt,'fast');
options.TolX            = optimget(options,'TolX',defaultopt,'fast');
options.ObjectiveLimit  = optimget(options,'ObjectiveLimit',defaultopt,'fast');
options.OutputFcn       = optimget(options,'OutputFcn',defaultopt,'fast');
options.PlotFcns        = optimget(options,'PlotFcns',defaultopt,'fast');
options.ScaleProblem    = optimget(options,'ScaleProblem',defaultopt,'fast');
options.UseParallel     = optimget(options,'UseParallel',defaultopt,'fast');

% Read options that require further validation
options.DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
options.DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
if options.DiffMinChange >= options.DiffMaxChange
    error('optim:getOptionsSQP:DiffChangesInconsistent', ...
         ['DiffMinChange options parameter is %0.5g, and DiffMaxChange is %0.5g.\n' ...
          'DiffMinChange must be strictly less than DiffMaxChange.'], ...
           options.DiffMinChange,options.DiffMaxChange)  
end

options.TypicalX = optimget(options,'TypicalX',defaultopt,'fast') ;
if ischar(options.TypicalX)
   if isequal(lower(options.TypicalX),'ones(numberofvariables,1)')
      options.TypicalX = ones(nVar,1);
   else
      error('optim:getOptionsSQP:InvalidTypicalX', ...
            'Option ''TypicalX'' must be a numeric value if not the default.')
   end
end
options.TypicalX = options.TypicalX(:);

options.MaxFunEvals = optimget(options,'MaxFunEvals',defaultopt,'fast');
% In case the defaults were gathered from calling: optimset('fmincon'):
if ischar(options.MaxFunEvals)
    if isequal(lower(options.MaxFunEvals),'100*numberofvariables')
        options.MaxFunEvals = 100*nVar;
    else
        error('optim:getOptionsSQP:InvalidMaxFunEvals', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

% Don't bother checking Hessian. Just set to 'bfgs' and continue
options.Hessian  = defaultopt.Hessian;
options.HessType = defaultopt.Hessian; % Set for the computeHessian utility