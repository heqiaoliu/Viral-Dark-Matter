function msg = diagnose(caller,OUTPUT,gradflag,hessflag,constflag,gradconstflag,line_search,...
    OPTIONS,defaultopt,XOUT,non_eq,...
    non_ineq,lin_eq,lin_ineq,LB,UB,funfcn,confcn,f,GRAD,HESS,c,ceq,cGRAD,ceqGRAD)
%DIAGNOSE prints diagnostic information about the function to be minimized
%    or solved.
%
% This is a helper function.

%   Copyright 1990-2009 The MathWorks, Inc. 
%   $Revision: 1.1.4.3 $ $Date: 2009/08/29 08:31:53 $

msg = [];

beginStr = sprintf('Diagnostic Information');
separatorTxt = repmat('_',60,1);
fprintf('\n%s\n   %s\n\n',separatorTxt,beginStr);

if ~isempty(funfcn{1})
    funformula =  getformula(funfcn{3});
    gradformula = getformula(funfcn{4});
    hessformula = getformula(funfcn{5});
else
    funformula =  '';
    gradformula = '';
    hessformula = '';
end

if ~isempty(confcn{1})
    conformula = getformula(confcn{3});
    gradcformula = getformula(confcn{4});
else
    conformula = '';
    gradcformula = '';
end    

fprintf('Number of variables: %i\n\n',length(XOUT))
if ~isempty(funfcn{1})
    fprintf('Functions \n')
    switch funfcn{1}
    case 'fun'
        % display 
        fprintf(' Objective:                            %s\n',funformula);
        
    case 'fungrad'
        if gradflag
            fprintf(' Objective and gradient:               %s\n',funformula);
        else
            fprintf(' Objective:                            %s\n',funformula);
            fprintf('   (set OPTIONS.GradObj=''on'' to use user provided gradient function)\n') 
        end
        
    case 'fungradhess'
        if gradflag && hessflag
            fprintf(' Objective, gradient and Hessian:      %s\n',funformula);
        elseif gradflag
            fprintf(' Objective and gradient:               %s\n',funformula);
            fprintf('   (set OPTIONS.Hessian to ''on'' to use user provided Hessian function)\n') 
        else
            fprintf(' Objective:                            %s\n',funformula);
            fprintf('   (set OPTIONS.GradObj=''on'' to use user provided gradient function)\n')
            fprintf('   (set OPTIONS.Hessian to ''on'' to use user provided Hessian function)\n') 
        end
        
        
    case 'fun_then_grad'
        fprintf(' Objective:                            %s\n',funformula);
        if gradflag
            fprintf(' Gradient:                             %s\n',gradformula);
        end
        if hessflag
            fprintf('-->Ignoring OPTIONS.Hessian --no user Hessian function provided\n')
        end
        
    case 'fun_then_grad_then_hess'
        fprintf(' Objective:                            %s\n',funformula);
        if gradflag && hessflag
            fprintf(' Gradient:                             %s\n',gradformula);
            fprintf(' Hessian:                              %s\n',hessformula);
        elseif gradflag
            fprintf(' Gradient:                             %s\n',gradformula);
        end   
    otherwise
        
    end
    
    if ~gradflag
        fprintf(' Gradient:                             finite-differencing\n')
    end
    % shape of grad
    
    if ~hessflag && (isequal('fmincon',caller) || isequal('constrsh',caller) || isequal('fminunc',caller))
        fprintf(' Hessian:                              finite-differencing (or Quasi-Newton)\n')
    end
    % shape of hess
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(confcn{1})
    switch confcn{1}
        
    case 'fun'
        fprintf(' Nonlinear constraints:                %s\n',conformula);
    case 'fungrad'
        if gradconstflag
            fprintf(' Nonlinear constraints and gradient:   %s\n',conformula);
        else
            fprintf(' Nonlinear constraints:                %s\n',conformula);
            fprintf('   (set OPTIONS.GradConstr to ''on'' to use user provided gradient of constraints function)\n') 
        end
        
    case 'fun_then_grad'
        fprintf(' Nonlinear constraints:                %s\n',conformula);
        if gradconstflag
            fprintf(' Nonlinear constraints gradient:       %s\n',gradcformula);
        end
        
    otherwise
        
    end
    
    if ~constflag
        fprintf(' Nonlinear constraints:                finite-differencing\n')
    end
    if ~gradconstflag
        fprintf(' Gradient of nonlinear constraints:    finite-differencing\n')
    end
    fprintf('\nConstraints\n')  
    fprintf(' Number of nonlinear inequality constraints: %i\n',non_ineq)
    fprintf(' Number of nonlinear equality constraints:   %i\n',non_eq)
    
elseif isequal(caller,'fmincon') || isequal(caller,'constrsh') || isequal(caller,'fminimax') || ...
        isequal(caller,'fgoalattain') || isequal(caller,'fseminf')
    fprintf('\nConstraints\n')
    fprintf(' Nonlinear constraints:             do not exist\n')
    
end

fprintf(' \n')

switch caller
case {'fmincon','constrsh','linprog','quadprog','lsqlin','fminimax','fseminf','fgoalattain'}
    fprintf(' Number of linear inequality constraints:    %i\n',lin_ineq)
    fprintf(' Number of linear equality constraints:      %i\n',lin_eq)
    fprintf(' Number of lower bound constraints:          %i\n',nnz(~isinf(LB)))
    fprintf(' Number of upper bound constraints:          %i\n',nnz(~isinf(UB)))
case {'lsqcurvefit','lsqnonlin'}
    fprintf(' Number of lower bound constraints:          %i\n',nnz(~isinf(LB)))
    fprintf(' Number of upper bound constraints:          %i\n',nnz(~isinf(UB)))
case {'bintprog'}
    fprintf(' Number of 0-1 binary integer variables:     %i\n',length(XOUT))
    fprintf(' Number of linear inequality constraints:    %i\n',lin_ineq)
    fprintf(' Number of linear equality constraints:      %i\n',lin_eq)
case {'fsolve','fminunc','fsolves'}
otherwise
end

if ~isempty(OUTPUT)
    fprintf('\nAlgorithm selected\n   %s\n\n',OUTPUT.algorithm);
end

endStr = sprintf('End diagnostic information');
fprintf('\n%s\n   %s\n',separatorTxt,endStr);


%--------------------------------------------------------------------------------
function funformula = getformula(fun)
% GETFORMULA Convert FUN to a string.

if isempty(fun)
    funformula = '';
    return;
end

if ischar(fun) % already a string
    funformula = fun;
elseif isa(fun,'function_handle')  % function handle
    funformula = func2str(fun);
elseif isa(fun,'inline')   % inline object
    funformula = formula(fun);
else % something else with a char method
    try
        funformula = char(fun);
    catch
        funformula = '';
    end
end
