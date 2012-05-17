function validateFirstDerivatives(funfcn,confcn,x,fval,cIneq,cEq,grad, ...
    JacCineqTrans,JacCeqTrans,lb,ub,fscale,options,finDiffFlags,sizes,varargin)
% validateFirstDerivatives Helper function that validates first derivatives of
% objective, nonlinear inequality, and nonlinear equality gradients against
% finite differences. The finite-difference calculation is done according to
% options.FinDiffType.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/22 04:17:54 $

tol = 1e-6; % component-wise relative difference in gradients checked against this tolerance
mNonlinIneq = sizes.mNonlinIneq;  
mNonlinEq = sizes.mNonlinEq;
nVar = sizes.nVar;

if strcmpi(options.GradObj,'on') 
    grad_fd = zeros(nVar,1); % input to finitedifferences()
    grad_fd = finitedifferences(x,funfcn{3},[],lb,ub,fval,[],[],1:nVar, ...
        options,sizes,grad_fd,[],[],finDiffFlags,fscale,varargin{:});
    % Unscale gradients
    if strcmpi(options.ScaleProblem,'obj-and-constr')
        grad = grad / fscale.obj;        
        grad_fd = grad_fd / fscale.obj;
    end

    % Vector of objective gradient relative error
    relGradError = full(abs(grad_fd - grad)./max(1.0,abs(grad)));    
    [maxDiff,grad_idx] = max(relGradError);
    fprintf('Objective function derivatives:\n')
    fprintf('Maximum relative discrepancy between derivatives = %g\n',maxDiff)
    if any(relGradError > tol)
        fprintf('Caution: user-supplied and %s finite-difference derivatives do\n',options.FinDiffType)
        fprintf(' not match within %g relative tolerance.\n',tol)
        fprintf('Maximum relative difference occurs in element %i of gradient:\n',grad_idx)
        fprintf('  User-supplied gradient:     % g\n',full(grad(grad_idx)))
        fprintf('  Finite-difference gradient: % g\n',full(grad_fd(grad_idx)))
        disp('Strike any key to continue or Ctrl-C to abort.')
        pause
        disp(' ') % blank line
    end
end

% If there are nonlinear constraints and their derivatives are provided,
% validate them
if strcmpi(options.GradConstr,'on') && sizes.mNonlinIneq + sizes.mNonlinEq > 0
    JacCineqTrans_fd = zeros(nVar,mNonlinIneq); % input to finitedifferences()
    JacCeqTrans_fd = zeros(nVar,mNonlinEq); % input to finitedifferences()
    [~,JacCineqTrans_fd,JacCeqTrans_fd] = finitedifferences(x,[],confcn{3}, ...
        lb,ub,[],-cIneq(:),cEq(:),1:nVar,options,sizes,[],JacCineqTrans_fd, ...
        JacCeqTrans_fd,finDiffFlags,fscale,varargin{:});
    if sizes.mNonlinIneq > 0
        % Unscale Jacobian
        if strcmpi(options.ScaleProblem,'obj-and-constr')
            JacCineqTrans = JacCineqTrans * spdiags(1.0./fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
            JacCineqTrans_fd = JacCineqTrans_fd * spdiags(1.0./fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
        end

        % Matrix of nonlinear inequality constraint gradient relative error
        % JacCineqTrans_fd is full so JacCineqError will be full - store it as a full matrix        
        relJacCineqError = full(abs(JacCineqTrans - JacCineqTrans_fd))./max(1.0,abs(JacCineqTrans));
        [maxDiff,i,j] = findRowColIndicesOfMaxElement(relJacCineqError);
        fprintf('Nonlinear inequality constraint derivatives:\n')
        fprintf('Maximum relative discrepancy between derivatives = %g\n',maxDiff)
        if any(any( relJacCineqError > tol ))
            fprintf('Caution: user-supplied and %s finite-difference derivatives do\n',options.FinDiffType)
            fprintf(' not match within %g relative tolerance.\n',tol)
            fprintf('Maximum relative difference occurs in element (%i,%i):\n',i,j)
            fprintf('  User-supplied constraint gradient:     % g\n',full(JacCineqTrans(i,j)))
            fprintf('  Finite-difference constraint gradient: % g\n',full(JacCineqTrans_fd(i,j)))
            disp('Strike any key to continue or Ctrl-C to abort.')
            pause
            disp(' ') % blank line
        end
    end
    
    if sizes.mNonlinEq > 0
        % Unscale Jacobian
        if strcmpi(options.ScaleProblem,'obj-and-constr')
            JacCeqTrans = JacCeqTrans * spdiags(1.0./fscale.cEq,0,mNonlinEq,mNonlinEq);
            JacCeqTrans_fd = JacCeqTrans_fd * spdiags(1.0./fscale.cEq,0,mNonlinEq,mNonlinEq);
        end
        % Matrix of nonlinear equality constraint gradient relative error
        % JacCeqTrans_fd is full so JacCeqError will be full - store it as a full matrix
        relJacCeqError = full(abs(JacCeqTrans - JacCeqTrans_fd))./max(1.0,abs(JacCeqTrans)); 
        [maxDiff,i,j] = findRowColIndicesOfMaxElement(relJacCeqError);
        fprintf('Nonlinear equality constraint derivatives:\n')
        fprintf('Maximum relative discrepancy between derivatives = %g\n',maxDiff)
        if any(any( relJacCeqError > tol ))
            fprintf('Caution: user-supplied and %s finite-difference derivatives do\n',options.FinDiffType)
            fprintf(' not match within %g relative tolerance.\n',tol)
            fprintf('Maximum relative difference occurs in element (%i,%i):\n',i,j)
            fprintf('  User-supplied constraint gradient:     % g\n',full(JacCeqTrans(i,j)))
            fprintf('  Finite-difference constraint gradient: % g\n',full(JacCeqTrans_fd(i,j)))
            fprintf('Strike any key to continue or Ctrl-C to abort.')
            pause
            disp(' ') % blank line
        end
    end
end

%-------------------------------------------------------------------------
function [maxVal,i,j] = findRowColIndicesOfMaxElement(A)
% Helper function that finds indices (i,j) of the maximum element of matrix A.
% It also returns the maximum element, maxVal

% Find max element by columns
[col_max_val,row_idx] = max(A,[],1);
% Find max element by rows
[maxVal,col_idx] = max(col_max_val);
i = row_idx(col_idx);
j = col_idx;





