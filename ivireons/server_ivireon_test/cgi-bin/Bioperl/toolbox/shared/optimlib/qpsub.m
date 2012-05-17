function [X,lambda,exitflag,output,how,ACTIND,msg] = ...
    qpsub(H,f,A,B,lb,ub,X,neqcstr,verbosity,caller,ncstr, ...
    numberOfVariables,options,ACTIND,phaseOneTotalScaling)
%QPSUB solves quadratic programming problems. 
%
%   X = QPSUB(H,f,A,b) solves the quadratic programming problem:
%
%            min 0.5*x'Hx + f'x   subject to:  Ax <= b 
%             x    
%

%   Copyright 1990-2009 The MathWorks, Inc. 
%   $Revision: 1.1.4.12 $  $Date: 2010/03/08 21:43:31 $

% Define constant strings
NewtonStep = 'Newton';
NegCurv = 'negative curvature chol';   
ZeroStep = 'zero step';
SteepDescent = 'steepest descent';
Conls = 'lsqlin';
Lp = 'linprog';
Qpsub = 'qpsub';
Nlconst = 'nlconst';
how = 'ok'; 

exitflag = 1;
output = struct('iterations',0,'constrviolation',[]);
msg = []; % initialize to ensure appending is successful
illCondWarningAlreadyDisplayed = false; % flag to prevent multiple display of warning

iterations = 0;
if nargin < 15
    phaseOneTotalScaling = false;
    if nargin < 14
        ACTIND = [];
    end
end

lb=lb(:); ub = ub(:);

if isempty(verbosity), verbosity = 1; end
if isempty(neqcstr), neqcstr = 0; end

LLS = 0;
if strcmp(caller, Conls)
    LLS = 1;
    [rowH,colH]=size(H);
    numberOfVariables = colH;
end
if strcmp(caller, Qpsub)
    normalize = -1;
else
    normalize = 1;
end

simplex_iter = 0;
if  norm(H,'inf')==0 || isempty(H)
    is_qp = 0; 
else
    is_qp=1; 
end

if LLS==1
    is_qp=0;
end

normf = 1;
if normalize > 0
    % Check for lp
    if ~is_qp && ~LLS
        normf = norm(f);
        if normf > 0
            f = f./normf;
        end
    end
end

% Handle bounds as linear constraints
arglb = ~eq(lb,-inf);
lenlb=length(lb); % maybe less than numberOfVariables due to old code
if nnz(arglb) > 0     
    lbmatrix = -eye(lenlb,numberOfVariables);
    A=[A; lbmatrix(arglb,1:numberOfVariables)]; % select non-Inf bounds
    B=[B;-lb(arglb)];
end

argub = ~eq(ub,inf);
lenub=length(ub);
if nnz(argub) > 0
    ubmatrix = eye(lenub,numberOfVariables);
    A=[A; ubmatrix(argub,1:numberOfVariables)];
    B=[B; ub(argub)];
end 

% Bounds are treated as constraints: Reset ncstr accordingly
ncstr=ncstr + nnz(arglb) + nnz(argub);

% Figure out max iteration count and constraint tolerance
maxiter = options.MaxIter;
tolCon  = options.TolCon;

% Used for determining threshold for whether a direction will violate
% a constraint.
normA = ones(ncstr,1);
if normalize > 0 
    for i=1:ncstr
        n = norm(A(i,:));
        if (n ~= 0)
            A(i,:) = A(i,:)/n;
            B(i) = B(i)/n;
            normA(i,1) = n;
        end
    end
else 
    normA = ones(ncstr,1);
end
errnorm = 0.01*sqrt(eps); 

tolDep = 100*numberOfVariables*eps;
% Save the original number of constraints in origncstr, since ncstr will change if dependent 
% constraints are eliminated in eqnsolve.
origncstr = ncstr;
lambda = zeros(origncstr,1);
eqix = 1:neqcstr;

% Modifications for warm-start.
% Do some error checking on the incoming working set indices.
ACTCNT = length(ACTIND);
if isempty(ACTIND)
    ACTIND = eqix;
elseif neqcstr > 0
    i = max(find(ACTIND<=neqcstr));
    if isempty(i) || i > neqcstr % safeguard which should not occur
        ACTIND = eqix;
    elseif i < neqcstr
        % A redundant equality constraint was removed on the last
        % SQP iteration.  We will go ahead and reinsert it here.
        numremoved = neqcstr - i;
        ACTIND(neqcstr+1:ACTCNT+numremoved) = ACTIND(i+1:ACTCNT);
        ACTIND(1:neqcstr) = eqix;
    end
end
aix = zeros(ncstr,1);
aix(ACTIND) = 1;
ACTCNT = length(ACTIND);
ACTSET = A(ACTIND,:);

% Check that the constraints in the initial working set are
% not dependent and find an initial point which satisfies the
% initial working set.
indepInd = 1:ncstr;
remove = [];
if ACTCNT > 0 && normalize ~= -1
    % call constraint solver
    [Q,R,A,B,X,Z,how,ACTSET,ACTIND,ACTCNT,aix,eqix,neqcstr,ncstr, ...
            remove,exitflag,msg]= ...
        eqnsolv(A,B,eqix,neqcstr,ncstr,numberOfVariables,LLS,H,X,f, ...
        normf,normA,verbosity,aix,ACTSET,ACTIND,ACTCNT,how,exitflag); 
    
    if ~isempty(remove)
        indepInd(remove)=[];
        normA = normA(indepInd);
    end
    
    if strcmp(how,'infeasible')
        % Equalities are inconsistent, so X and lambda have no valid values
        % Return original X and zeros for lambda.
        ACTIND = indepInd(ACTIND);
        output.iterations = iterations;
        exitflag = -2;
        return
    end
    
    err = 0;
    if neqcstr >= numberOfVariables
        err = max(abs(A(eqix,:)*X-B(eqix)));
        if (err > 1e-8)  % Equalities not met
            how='infeasible';
            exitflag = -2;
            msg = sprintf(['Exiting: the equality constraints are overly stringent;\n' ...
                                  ' there is no feasible solution.']);
            if verbosity > 0 
                disp(msg)
            end
            % Equalities are inconsistent, X and lambda have no valid values
            % Return original X and zeros for lambda.
            ACTIND = indepInd(ACTIND);
            output.iterations = iterations;
            return
        else % Check inequalities
            if (max(A*X-B) > 1e-8)
                how = 'infeasible';
                exitflag = -2;
                msg = sprintf(['Exiting: the constraints or bounds are overly stringent;\n' ...
                                      ' there is no feasible solution. Equality constraints have been met.']);
                if verbosity > 0
                    disp(msg)
                end
            end
        end
        % Disable the warnings about conditioning for singular and
        % nearly singular matrices
        warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
        warningstate2 = warning('off', 'MATLAB:singularMatrix');
        if is_qp
            actlambda = -R\(Q'*(H*X+f));
        elseif LLS
            actlambda = -R\(Q'*(H'*(H*X-f)));
        else
            actlambda = -R\(Q'*f);
        end
        % Restore the warning states to their original settings
        warning(warningstate1)
        warning(warningstate2)
        lambda(indepInd(ACTIND)) = normf * (actlambda ./normA(ACTIND));
        ACTIND = indepInd(ACTIND);
        output.iterations = iterations;
        return
    end
else 
    if ACTCNT == 0 % initial working set is empty 
        Q = eye(numberOfVariables,numberOfVariables);
        R = [];
        Z = 1;
    else % in Phase I and working set not empty
        [Q,R] = qr(ACTSET');
        Z = Q(:,ACTCNT+1:numberOfVariables);
    end   
end

% Find Initial Feasible Solution
cstr = A*X-B;
output.constrviolation = 0;
tolCon_scaled = eps;
if ncstr > neqcstr
    [output.constrviolation,id] = max(cstr(neqcstr+1:ncstr));
    % tolCon option is used only by nlconst.m. Other callers use tolcon = eps
    if ~isempty(tolCon)
       % Constraint tolerance need to be unscaled by the
       % norm of the constraint that is violated by the 
       % largest amount.
       tolCon_scaled = tolCon/normA(neqcstr+id);
    end
end

if output.constrviolation > tolCon_scaled
     quiet = -2;
    % Feasible point finding phase for qpsub
    % Use default options for qpsub in phase 1 
    qpoptionsPhase1.MaxIter = 10*max(numberOfVariables,ncstr-neqcstr);
    qpoptionsPhase1.TolCon = options.TolCon;
    ACTIND2 = 1:neqcstr;
    if ~phaseOneTotalScaling 
      A2=[[A;zeros(1,numberOfVariables)],[zeros(neqcstr,1);-ones(ncstr+1-neqcstr,1)]];
    else
      % Scale the slack variable as well
      A2 = [[A [zeros(neqcstr,1);-ones(ncstr-neqcstr,1)]./normA]; ...
            [zeros(1,numberOfVariables) -1]];
    end

    [XS,lambdaS,exitflagS,outputS,howS,ACTIND2] = ...
        qpsub([],[zeros(numberOfVariables,1);1],A2,[B;1e-5], ...
        [],[],[X;output.constrviolation+1],neqcstr,quiet,Qpsub,size(A2,1),numberOfVariables+1, ...
        qpoptionsPhase1,ACTIND2);
    slack = XS(numberOfVariables+1);
    X = XS(1:numberOfVariables);
    cstr = A*X-B;
    [output.constrviolation,id] = max(cstr(neqcstr+1:ncstr));
    if ~isempty(tolCon)
       % Constraint tolerance need to be unscaled by the
       % norm of the constraint that is violated by the 
       % largest amount.
       tolCon_scaled = tolCon/normA(neqcstr+id);
    else
        tolCon_scaled = eps;
    end
    if slack > tolCon_scaled
        if slack > 1e-8 
            how='infeasible';
            exitflag = -2;
            msg = sprintf(['Exiting: the constraints are overly stringent;\n' ...
                                  ' no feasible starting point found.']);
            if verbosity > 0
                disp(msg)
            end
        else
            how = 'overly constrained';
            exitflag = -2;
            msg = sprintf(['Exiting: the constraints are overly stringent;\n' ...
                                  ' initial feasible point found violates constraints\n' ...
                                  ' by more than eps.']);
            if verbosity > 0
                disp(msg)
            end
        end
        
        lambda(indepInd) = normf * (lambdaS((1:ncstr)')./normA);
        ACTIND = 1:neqcstr;
        ACTIND = indepInd(ACTIND);
        output.iterations = iterations;
        output.constrviolation = [];
        return
    else
        ACTIND = 1:neqcstr;
        % Uncomment the next line if you want to initialize active set 
        % info based on solution of Phase I.
        % ACTIND = ACTIND2(find(ACTIND2<=ncstr));
        ACTSET = A(ACTIND,:);
        ACTCNT = length(ACTIND);
        aix = zeros(ncstr,1);
        aix(ACTIND) = 1;
        if ACTCNT == 0
            Q = zeros(numberOfVariables,numberOfVariables);
            R = [];
            Z = 1;
        else
            [Q,R] = qr(ACTSET');
            Z = Q(:,ACTCNT+1:numberOfVariables);
        end
    end
end

if ACTCNT >= numberOfVariables - 1  
    simplex_iter = 1; 
end
[m,n]=size(ACTSET);

% Disable the warnings about conditioning for singular and
% nearly singular matrices
warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
warningstate2 = warning('off', 'MATLAB:singularMatrix');

if (is_qp)
    gf=H*X+f;
    %  SD=-Z*((Z'*H*Z)\(Z'*gf));
    [SD, dirType] = compdir(Z,H,gf,numberOfVariables,f);

    % Check for -ve definite problems:
    %  if SD'*gf>0, is_qp = 0; SD=-SD; end
elseif (LLS)
    HXf=H*X-f;
    gf=H'*(HXf);
    HZ= H*Z;
    [mm,nn]=size(HZ);
    if mm >= nn
        %   SD =-Z*((HZ'*HZ)\(Z'*gf));
        [QHZ, RHZ] =  qr(HZ,0);
        Pd = QHZ'*HXf;
        % Now need to check which is dependent
        if min(size(RHZ))==1 % Make sure RHZ isn't a vector
            depInd = find( abs(RHZ(1,1)) < tolDep);
        else
            depInd = find( abs(diag(RHZ)) < tolDep );
        end  
    end
    if mm >= nn && isempty(depInd) % Newton step
        SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
        dirType = NewtonStep;
    else % steepest descent direction
        SD = -Z*(Z'*gf);
        dirType = SteepDescent;
    end
else % lp
    gf = f;
    SD = -Z*Z'*gf;
    dirType = SteepDescent; 
    if norm(SD) < 1e-10 && neqcstr
        % This happens when equality constraint is perpendicular
        % to objective function f.x.
        actlambda = -R\(Q'*(gf));
        lambda(indepInd(ACTIND)) = normf * (actlambda ./ normA(ACTIND));
        ACTIND = indepInd(ACTIND);
        output.iterations = iterations;
        % Restore the warning states to their original settings
        warning(warningstate1)
        warning(warningstate2)
        return;
    end
end
% Restore the warning states to their original settings
warning(warningstate1)
warning(warningstate2)

oldind = 0; 

% The maximum number of iterations for a simplex type method is when ncstr >=n:
% maxiters = prod(1:ncstr)/(prod(1:numberOfVariables)*prod(1:max(1,ncstr-numberOfVariables)));

%--------------Main Routine-------------------

while iterations < maxiter
    iterations = iterations + 1;
    if isinf(verbosity)
      curr_out = sprintf('Iter: %5.0f, Active: %5.0f, step: %s, max(cstr): %g, proc: %s', ...
          iterations,ACTCNT,dirType,max(0,output.constrviolation),how);
        disp(curr_out); 
    end
    
    % Find the blocking constraint
    [indf, ind, STEPMIN] = findBlockingConstr(A,SD,cstr,errnorm,aix);
    
    %----------------Update X---------------------
    
    % Assume we do not delete a constraint
    delete_constr = 0;   
    
    if ~isempty(indf) && isfinite(STEPMIN) % Hit a constraint
        if strcmp(dirType, NewtonStep)
            % Newton step and hit a constraint: LLS or is_qp
            if STEPMIN > 1  % Overstepped minimum; reset STEPMIN
                STEPMIN = 1;
                delete_constr = 1;
            end
            X = X+STEPMIN*SD;
        else
            % Not a Newton step and hit a constraint: is_qp or LLS or maybe lp
            X = X+STEPMIN*SD;  
        end              
    else %  isempty(indf) | ~isfinite(STEPMIN)
        % did not hit a constraint
        if strcmp(dirType, NewtonStep)
            % Newton step and no constraint hit: LLS or maybe is_qp
            STEPMIN = 1;   % Exact distance to the solution. Now delete constr.
            X = X + SD;
            delete_constr = 1;
        else % Not a Newton step: is_qp or lp or LLS
            
            if (~is_qp && ~LLS) || strcmp(dirType, NegCurv) % LP or neg def (implies is_qp)
                % neg def -- unbounded
                if norm(SD) > errnorm
                    if normalize < 0
                        STEPMIN = abs((X(numberOfVariables)+1e-5)/(SD(numberOfVariables)+eps));
                    else 
                        STEPMIN = 1e16;
                    end
                    X = X + STEPMIN*SD;
                    how='unbounded'; 
                    exitflag = -3;
                    msg = sprintf(['Exiting: the solution is unbounded and at infinity;\n' ...
                                          ' the constraints are not restrictive enough.']);
                    if verbosity > 0
                      disp(msg)
                    end
                else % norm(SD) <= errnorm
                    how = 'ill posed';
                    exitflag = -7;
                    msg = ...
                      sprintf(['Exiting: magnitude of search direction is close to zero; no further\n' ... 
                                ' progress can be made. The problem may be ill-posed or badly conditioned.']);
                      if verbosity > 0
                        disp(msg)
                      end
                end
                ACTIND = indepInd(ACTIND);
                output.iterations = iterations;
                return
            else % singular: solve compatible system for a solution: is_qp or LLS
                if is_qp
                    projH = Z'*H*Z; 
                    Zgf = Z'*gf;
                    projSD = pinv(projH)*(-Zgf);
                else % LLS
                    projH = HZ'*HZ; 
                    Zgf = Z'*gf;
                    projSD = pinv(projH)*(-Zgf);
                end
                
                % Check if compatible
                if norm(projH*projSD+Zgf) > 10*eps*(norm(projH) + norm(Zgf))
                    % system is incompatible --> it's a "chute": use SD from compdir
                    % unbounded in SD direction
                    if norm(SD) > errnorm
                        if normalize < 0
                            STEPMIN=abs((X(numberOfVariables)+1e-5)/(SD(numberOfVariables)+eps));
                        else 
                            STEPMIN = 1e16;
                        end
                        X = X + STEPMIN*SD;
                        how = 'unbounded'; 
                        exitflag = -3;
                        msg = sprintf(['Exiting: the solution is unbounded and at infinity;\n' ...
                                          ' the constraints are not restrictive enough.']);
                        if verbosity > 0
                          disp(msg)
                        end
                    else % norm(SD) <= errnorm
                        how = 'ill posed';
                        exitflag = -7;
                        msg = ...
                            sprintf(['Exiting: magnitude of search direction is close to zero; no further\n' ... 
                                     ' progress can be made. The problem may be ill-posed or badly conditioned.']);
                        if verbosity > 0
                          disp(msg)
                        end                        
                    end
                    
                    ACTIND = indepInd(ACTIND);
                    output.iterations = iterations;
                    return
                else % Convex -- move to the minimum (compatible system)
                    SD = Z*projSD;
                    if gf'*SD > 0
                        SD = -SD;
                    end
                    dirType = 'singular';
                    
                    % Find the blocking constraint
                    [indf, ind, STEPMIN] = findBlockingConstr(A,SD,cstr,errnorm,aix);

                    if STEPMIN > 1  % Overstepped minimum; reset STEPMIN
                        STEPMIN = 1;
                        delete_constr = 1;
                    end
                    X = X + STEPMIN*SD; 
                end
            end % if ~is_qp | smallRealEig < -eps
        end % if strcmp(dirType, NewtonStep)
    end % if ~isempty(indf)& isfinite(STEPMIN) % Hit a constraint
    
    % Calculate gradient w.r.t objective at this point
    if is_qp
        gf=H*X+f;
    elseif LLS % LLS
        gf=H'*(H*X-f);
        % else gf=f still true.
    end
    
    % Update constraints
    cstr = A*X-B;
    cstr(eqix) = abs(cstr(eqix));
    output.constrviolation = max(cstr(neqcstr+1:ncstr));
    
    %----Check if reached minimum in current subspace-----
    
    if delete_constr
        % Note: only reach here if a minimum in the current subspace found
        % LP's do not enter here.
        if ACTCNT>0
            % Disable the warnings about conditioning for singular and
            % nearly singular matrices
            warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
            warningstate2 = warning('off', 'MATLAB:singularMatrix');
            
            rlambda = -R\(Q'*gf);
            actlambda = rlambda;
            actlambda(eqix) = abs(rlambda(eqix));
            indlam = find(actlambda < 0);
            if (~length(indlam)) 
                lambda(indepInd(ACTIND)) = normf * (rlambda./normA(ACTIND));
                ACTIND = indepInd(ACTIND);
                output.iterations = iterations;
                % Restore the warning states to their original settings
                warning(warningstate1)
                warning(warningstate2)
                return
            end
            % Remove constraint
            lind = find(ACTIND == min(ACTIND(indlam)));
            lind = lind(1);
            ACTSET(lind,:) = [];
            aix(ACTIND(lind)) = 0;
            [Q,R]=qrdelete(Q,R,lind);
            ACTIND(lind) = [];
            ACTCNT = length(ACTIND);
            simplex_iter = 0;
            ind = 0;
            % Restore the warning states to their original settings
            warning(warningstate1)
            warning(warningstate2)
        else % ACTCNT == 0
            output.iterations = iterations;
            return
        end
        delete_constr = 0;
    end
    
    % If we are in the Phase-1 procedure check if the slack variable
    % is zero indicating we have found a feasible starting point.
    if normalize < 0
        if X(numberOfVariables,1) < eps
            ACTIND = indepInd(ACTIND);
            output.iterations = iterations;
            return;
        end
    end
       
    if output.constrviolation > 1e5*errnorm
        if output.constrviolation > norm(X) * errnorm
            % Display a message to the command window
            if exitflag == 1 && verbosity > 0 && ~illCondWarningAlreadyDisplayed
                warning('optim:qpsub:SolUnreliable', ...
                    'The problem is badly conditioned; the solution may not be reliable.')
                illCondWarningAlreadyDisplayed = true; % do not display warning multiple times
            end
        end
        how='unreliable';
        exitflag = -2;
    else
        % This is not likely to happen because active-set does not have any
        % strategy to become infeasible once it is infeasible. However,
        % this can happen due to inaccuracy in QR updates when the
        % constraints in active-set are not well conditioned.
        exitflag = 1;
        how = 'ok';
    end

    %----Add blocking constraint to working set----
    
    if ind % Hit a constraint
        aix(ind)=1;
        CIND = length(ACTIND) + 1;
        ACTSET(CIND,:)=A(ind,:);
        ACTIND(CIND)=ind;
        [m,n]=size(ACTSET);
        [Q,R] = qrinsert(Q,R,CIND,A(ind,:)');
        ACTCNT = length(ACTIND);
    end
    if ~simplex_iter
        % Z = null(ACTSET);
        [m,n]=size(ACTSET);
        Z = Q(:,m+1:n);
        if ACTCNT == numberOfVariables - 1, simplex_iter = 1; end
        oldind = 0; 
    else
        % Disable the warnings about conditioning for singular and
        % nearly singular matrices
        warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
        warningstate2 = warning('off', 'MATLAB:singularMatrix');

        %---If Simplex Alg. choose leaving constraint---
        rlambda = -R\(Q'*gf);

        % Restore the warning states to their original settings
        warning(warningstate1)
        warning(warningstate2)
       
        if isinf(rlambda(1)) && rlambda(1) < 0 
            fprintf('         Working set is singular; results may still be reliable.\n');
            [m,n] = size(ACTSET);
            rlambda = -(ACTSET + sqrt(eps)*randn(m,n))'\gf;
        end
        actlambda = rlambda;
        actlambda(eqix)=abs(actlambda(eqix));
        indlam = find(actlambda<0);
        if length(indlam)
            if STEPMIN > errnorm
                % If there is no chance of cycling then pick the constraint 
                % which causes the biggest reduction in the cost function. 
                % i.e the constraint with the most negative Lagrangian 
                % multiplier. Since the constraints are normalized this may 
                % result in less iterations.
                [minl,lind] = min(actlambda);
            else
                % Bland's rule for anti-cycling: if there is more than one 
                % negative Lagrangian multiplier then delete the constraint
                % with the smallest index in the active set.
                lind = find(ACTIND == min(ACTIND(indlam)));
            end
            lind = lind(1);
            ACTSET(lind,:) = [];
            aix(ACTIND(lind)) = 0;
            [Q,R]=qrdelete(Q,R,lind);
            Z = Q(:,numberOfVariables);
            oldind = ACTIND(lind);
            ACTIND(lind) = [];
            ACTCNT = length(ACTIND);
        else
            lambda(indepInd(ACTIND))= normf * (rlambda./normA(ACTIND));
            ACTIND = indepInd(ACTIND);
            output.iterations = iterations;
            return
        end
    end %if ACTCNT<numberOfVariables
    
    %----------Compute Search Direction-------------      
    
    if (is_qp)
        Zgf = Z'*gf; 
        if ~isempty(Zgf) && (norm(Zgf) < 1e-15)
            SD = zeros(numberOfVariables,1); 
            dirType = ZeroStep;
        else
            [SD, dirType] = compdir(Z,H,gf,numberOfVariables,f);
        end
    elseif (LLS)
        Zgf = Z'*gf;
        HZ = H*Z;
        if (norm(Zgf) < 1e-15)
            SD = zeros(numberOfVariables,1);
            dirType = ZeroStep;
        else
            HXf=H*X-f;
            gf=H'*(HXf);
            [mm,nn]=size(HZ);
            if mm >= nn
                [QHZ, RHZ] =  qr(HZ,0);
                Pd = QHZ'*HXf;
                % SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
                % Now need to check which is dependent
                if min(size(RHZ))==1 % Make sure RHZ isn't a vector
                    depInd = find( abs(RHZ(1,1)) < tolDep);
                else
                    depInd = find( abs(diag(RHZ)) < tolDep );
                end  
            end
            if mm >= nn && isempty(depInd) % Newton step
                % Disable the warnings about conditioning for singular and
                % nearly singular matrices
                warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
                warningstate2 = warning('off', 'MATLAB:singularMatrix');
                SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
                % Restore the warning states to their original settings
                warning(warningstate1)
                warning(warningstate2)
                dirType = NewtonStep;
            else % steepest descent direction
                SD = -Z*(Z'*gf);
                dirType = SteepDescent;
            end
        end
    else % LP
        if ~simplex_iter
            SD = -Z*(Z'*gf);
            gradsd = norm(SD);
        else
            gradsd = Z'*gf;
            if  gradsd > 0
                SD = -Z;
            else
                SD = Z;
            end
        end
        if abs(gradsd) < 1e-10 % Search direction null
            % Check whether any constraints can be deleted from active set.
            % rlambda = -ACTSET'\gf;
            if ~oldind
                % Disable the warnings about conditioning for singular and
                % nearly singular matrices
                warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
                warningstate2 = warning('off', 'MATLAB:singularMatrix');
                rlambda = -R\(Q'*gf);
                % Restore the warning states to their original settings
                warning(warningstate1)
                warning(warningstate2)
                ACTINDtmp = ACTIND; Qtmp = Q; Rtmp = R;
            else
                % Reinsert just deleted constraint.
                ACTINDtmp = ACTIND;
                ACTINDtmp(lind+1:ACTCNT+1) = ACTIND(lind:ACTCNT);
                ACTINDtmp(lind) = oldind;
                [Qtmp,Rtmp] = qrinsert(Q,R,lind,A(oldind,:)');
            end
            actlambda = rlambda;
            actlambda(1:neqcstr) = abs(actlambda(1:neqcstr));
            indlam = find(actlambda < errnorm);
            lambda(indepInd(ACTINDtmp)) = normf * (rlambda./normA(ACTINDtmp));
            if ~length(indlam)
                ACTIND = indepInd(ACTIND);
                output.iterations = iterations;
                return
            end
            cindmax = length(indlam);
            cindcnt = 0;
            m = length(ACTINDtmp);
            while (abs(gradsd) < 1e-10) && (cindcnt < cindmax)
                cindcnt = cindcnt + 1;
                lind = indlam(cindcnt);
                [Q,R]=qrdelete(Qtmp,Rtmp,lind);
                Z = Q(:,m:numberOfVariables);
                if m ~= numberOfVariables
                    SD = -Z*Z'*gf;
                    gradsd = norm(SD);
                else
                    gradsd = Z'*gf;
                    if  gradsd > 0
                        SD = -Z;
                    else
                        SD = Z;
                    end
                end
            end
            if abs(gradsd) < 1e-10  % Search direction still null
                ACTIND = indepInd(ACTIND);
                output.iterations = iterations;
                return;
            else
                ACTIND = ACTINDtmp;
                ACTIND(lind) = [];
                aix = zeros(ncstr,1);
                aix(ACTIND) = 1;
                ACTCNT = length(ACTIND);
                ACTSET = A(ACTIND,:);
            end
            lambda = zeros(origncstr,1);
        end
    end % if is_qp
end % while 

if iterations >= maxiter
    exitflag = 0;
    how = 'MaxSQPIter';
    msg = ...
        sprintf(['Maximum number of iterations exceeded; increase options.MaxIter.\n' ...
                 'To continue solving the problem with the current solution as the\n' ...
                 'starting point, set x0 = x before calling ' caller '.']);
    if verbosity > 0
      disp(msg)
    end
end

output.iterations = iterations;

%=========================================================================

function [Q,R,A,B,X,Z,how,ACTSET,ACTIND,ACTCNT,aix,eqix,neqcstr, ...
        ncstr,remove,exitflag,msg]= ...
    eqnsolv(A,B,eqix,neqcstr,ncstr,numberOfVariables,LLS,H,X,f,normf, ...
    normA,verbosity,aix,ACTSET,ACTIND,ACTCNT,how,exitflag)
% EQNSOLV Helper function for QPSUB.
%    Checks whether the working set is linearly independent and
%    finds a feasible point with respect to the working set constraints.
%    If the equalities are dependent but not consistent, warning
%    messages are given. If the equalities are dependent but consistent, 
%    the redundant constraints are removed and the corresponding variables 
%    adjusted.

% set tolerances
tolDep = 100*numberOfVariables*eps;      
tolCons = 1e-10;

Z=[]; remove =[];
msg = []; % will be given a value only if appropriate

% First see if the equality constraints form a consistent system.
[Qa,Ra,Ea]=qr(A(eqix,:));

% Form vector of dependent indices.
if min(size(Ra))==1 % Make sure Ra isn't a vector
    depInd = find( abs(Ra(1,1)) < tolDep);
else
    depInd = find( abs(diag(Ra)) < tolDep );
end
if neqcstr > numberOfVariables
    depInd = [depInd; ((numberOfVariables+1):neqcstr)'];
end      

if ~isempty(depInd)    % equality constraints are dependent
    msg = sprintf('The equality constraints are dependent.');
    how='dependent';
    exitflag = 1;
    bdepInd =  abs(Qa(:,depInd)'*B(eqix)) >= tolDep ;
        
    if any( bdepInd ) % Not consistent
        how='infeasible';   
        exitflag = -2;
        msg = sprintf('%s\nThe system of equality constraints is not consistent.',msg);
        if ncstr > neqcstr
            msg = sprintf('%s\nThe inequality constraints may or may not be satisfied.',msg);
        end
        msg = sprintf('%s\nThere is no feasible solution.',msg);
    else % the equality constraints are consistent
        % Delete the redundant constraints
        % By QR factoring the transpose, we see which columns of A'
        %   (rows of A) move to the end
        [Qat,Rat,Eat]=qr(A(eqix,:)');        
        [i,j] = find(Eat); % Eat permutes the columns of A' (rows of A)
        remove = i(depInd);
        numDepend = nnz(remove);
        if verbosity > 0
            disp('The system of equality constraints is consistent.');
            disp('Removing the following dependent constraints before continuing:');
            disp(remove)
        end
        A(eqix(remove),:)=[];
        % Even though B is a vector, we use two-index syntax when
        % removing elements so that, if all constraints end up being removed,
        % it will have size 0-by-1, and be commensurate with the empty
        %, 0-by-1 matrix A. Similarly with the active set Boolean indicator aix.
        B(eqix(remove),:)=[];
        neqcstr = neqcstr - numDepend;
        ncstr = ncstr - numDepend;
        eqix = 1:neqcstr;
        aix(remove,:) = [];
        ACTIND(1:numDepend) = [];
        ACTIND = ACTIND - numDepend;      
        ACTSET = A(ACTIND,:);
        ACTCNT = ACTCNT - numDepend;
    end % consistency check
end % dependency check
if verbosity > 0
  disp(msg)
end

% Now that we have done all we can to make the equality constraints
% consistent and independent we will check the inequality constraints
% in the working set.  First we want to make sure that the number of 
% constraints in the working set is only greater than or equal to the
% number of variables if the number of (non-redundant) equality 
% constraints is greater than or equal to the number of variables.
if ACTCNT >= numberOfVariables
    ACTCNT = max(neqcstr, numberOfVariables-1);
    ACTIND = ACTIND(1:ACTCNT);
    ACTSET = A(ACTIND,:);
    aix = zeros(ncstr,1);
    aix(ACTIND) = 1;
end

% Now check to see that all the constraints in the working set are
% linearly independent.
if ACTCNT > neqcstr
    [Qat,Rat,Eat]=qr(ACTSET');
    
    % Form vector of dependent indices.
    if min(size(Rat))==1 % Make sure Rat isn't a vector
        depInd = find( abs(Rat(1,1)) < tolDep);
    else
        depInd = find( abs(diag(Rat)) < tolDep );
    end
    
    if ~isempty(depInd)
        [i,j] = find(Eat); % Eat permutes the columns of A' (rows of A)
        remove2 = i(depInd);
        removeEq   = remove2(find(remove2 <= neqcstr));
        removeIneq = remove2(find(remove2 > neqcstr));
        
        if ~isempty(removeEq)
            % Just take equalities as initial working set.
            ACTIND = 1:neqcstr; 
        else
            % Remove dependent inequality constraints.
            ACTIND(removeIneq) = [];
        end
        aix = zeros(ncstr,1);
        aix(ACTIND) = 1;
        ACTSET = A(ACTIND,:);
        ACTCNT = length(ACTIND);
    end  
end

[Q,R]=qr(ACTSET');
Z = Q(:,ACTCNT+1:numberOfVariables);

% Disable the warnings about conditioning for singular and
% nearly singular matrices
warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
warningstate2 = warning('off', 'MATLAB:singularMatrix');

if ~strcmp(how,'infeasible') && ACTCNT > 0
    % Find point closest to the given initial X which satisfies
    % working set constraints.
    minnormstep = Q(:,1:ACTCNT) * ...
        ((R(1:ACTCNT,1:ACTCNT)') \ (B(ACTIND) - ACTSET*X));
    X = X + minnormstep; 
    % Sometimes the "basic" solution satisfies Aeq*x= Beq 
    % and A*X < B better than the minnorm solution. Choose the one
    % that the minimizes the max constraint violation.
    err = A*X - B;
    err(eqix) = abs(err(eqix));
    if any(err > eps)
        Xbasic = ACTSET\B(ACTIND);
        errbasic = A*Xbasic - B;
        errbasic(eqix) = abs(errbasic(eqix));
        if max(errbasic) < max(err) 
            X = Xbasic;
        end
    end
end

% Restore the warning states to their original settings
warning(warningstate1)
warning(warningstate2)

% End of eqnsolv.m

%=========================================================================
function [indf, ind, STEPMIN] = findBlockingConstr(A,SD,cstr,errnorm,aix)
%findBlockingConstr Find distance we can move in search direction SD before 
% an inactive inequality constraint is violated.
    
% Gradient with respect to search direction.
GSD=A*SD;

% Note: we consider only constraints whose gradients are greater
% than some threshold. If we considered all gradients greater than
% zero then it might be possible to add a constraint which would lead to
% a singular (rank deficient) working set. The gradient (GSD) of such
% a constraint in the direction of search would be very close to zero.
indf = find((GSD > errnorm * norm(SD))  &  ~aix);

if isempty(indf) % No constraints to hit
    STEPMIN = 1e16;
    ind = [];
else
    % Find distance to the nearest blocking constraint. It is
    % calculated as min [ -(Ax-b)./GSD ]. The distance STEPMIN will be
    % nonnegative if (Ax-b) < 0 (because GSD > 0). However, in cases when
    % 0 < (Ax-b) <= tolcon the STEPMIN will be negative so it is calculated
    % as abs((Ax-b))./GSD and it may violate constraints.
    dist = abs(cstr(indf))./GSD(indf);
    STEPMIN = min(dist);
    ind2 = find(dist == STEPMIN);
    % Bland's rule for anti-cycling: if there is more than one
    % blocking constraint then add the one with the smallest index.
    ind = indf(min(ind2));
end

