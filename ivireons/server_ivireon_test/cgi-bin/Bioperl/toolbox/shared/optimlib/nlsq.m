function [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = nlsq(funfcn,x,verbosity,options,defaultopt,CostFunction,JAC,caller,varargin)
%NLSQ Helper function that solves non-linear least squares problems.
%   NLSQ is the core code for solving problems of the form:
%   min sum {FUN(X).^2} where FUN and X may be vectors or matrices.   
%             x

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/02 06:46:27 $

% ------------Initialization----------------
XOUT = x(:);
% Store original shape
[sizes.xRows,sizes.xCols] = size(x);
% numberOfVariables must be the name of this variable
numberOfVariables = length(XOUT);
msg = [];
how = [];
OUTPUT = [];
iter = 0;
EXITFLAG = 1;  %assume convergence
currstepsize = 0;

% Handle the output
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Parse OutputFcn which is needed to support cell array syntax for OutputFcn.
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end
stop = false;

% Handle the output
plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Parse PlotFcns which is needed to support cell array syntax for PlotFcns.
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end

formatstrFirstIter = ' %5.0f       %5.0f   %13.6g';
formatstr = ' %5.0f       %5.0f   %13.6g %12.3g    %12.3g';

% options
gradflag =  strcmp(optimget(options,'Jacobian',defaultopt,'fast'),'on');
tolX = optimget(options,'TolX',defaultopt,'fast');
lineSearchType = strcmp(optimget(options,'LineSearchType',defaultopt,'fast'),'cubicpoly');
% If caller is fsolve, LevenbergMarquardt is not a member of the defaultopt structure,
% but options.LevenbergMarquardt will exist and will have been set to either 'on' or 'off'
% in fsolve. Thus, the call to optimget below will work as expected. 
levMarq = strcmp(optimget(options,'LevenbergMarquardt',defaultopt,'fast'),'on');
tolFun = optimget(options,'TolFun',defaultopt,'fast');
finDiffOpts.DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
finDiffOpts.DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
finDiffOpts.TypicalX = optimget(options,'TypicalX',defaultopt,'fast') ;
if ischar(finDiffOpts.TypicalX)
   if isequal(lower(finDiffOpts.TypicalX),'ones(numberofvariables,1)')
      finDiffOpts.TypicalX = ones(numberOfVariables,1);
   else
      error('optim:nlsq:InvalidTypicalX','Option ''TypicalX'' must be a numerical value if not the default.')
   end
end
finDiffOpts.FinDiffType = 'forward';
checkoptionsize('TypicalX', size(finDiffOpts.TypicalX), numberOfVariables);
maxFunEvals = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxIter = optimget(options,'MaxIter',defaultopt,'fast');
if ischar(maxFunEvals)
   if isequal(lower(maxFunEvals),'100*numberofvariables')
      maxFunEvals = 100*numberOfVariables;
   else
      error('optim:nlsq:MaxFunEvals','Option ''MaxFunEvals'' must be a numeric value if not the default.')
   end
end

% Create structure of flags for finitedifferences
finDiffFlags.fwdFinDiff = true; % Always forward fin-diff
finDiffFlags.scaleObjConstr = false; % No scaling
finDiffFlags.chkFunEval = false; % Don't validate function values
finDiffFlags.isGrad = false; % Compute Jacobian, not gradient
finDiffFlags.hasLBs = false(numberOfVariables,1); % No lower bounds
finDiffFlags.hasUBs = false(numberOfVariables,1); % No upper bounds

% Convert values to full to avoid unnecessary sparse operation overhead
CostFunction = full(CostFunction); 
nfun=length(CostFunction);
numFunEvals = 1;
numGradEvals = 0;
MATX=zeros(3,1);
MATL=[CostFunction'*CostFunction;0;0];
FIRSTF=CostFunction'*CostFunction;
PCNT = 0;
EstSum=0.5;
% system of equations or overdetermined
if nfun >= numberOfVariables
   GradFactor = 0;  
else % underdetermined: singularity in JAC'*JAC or GRAD*GRAD' 
   GradFactor = 1;
end
done = false;
NewF = CostFunction'*CostFunction;


while ~done  
   % Work Out Gradients
   if ~(gradflag) || DerivativeCheck
      JACFD = zeros(nfun, numberOfVariables);  % set to correct size
      [JACFD,~,~,numEvals] = finitedifferences(XOUT,funfcn{3},[],[],[], ...
          CostFunction,[],[],1:numberOfVariables,finDiffOpts,sizes,JACFD, ...
          [],[],finDiffFlags,[],varargin{:});       
      numFunEvals=numFunEvals+numEvals;
      % Gradient check
      if DerivativeCheck && gradflag         
         if isa(funfcn{3},'inline') 
            % if using inlines, the gradient is in funfcn{4}
            graderr(JACFD, JAC, formula(funfcn{4})); %
         else 
            % otherwise fun/grad in funfcn{3}
            graderr(JACFD, JAC,  funfcn{3});
         end
         DerivativeCheck = 0;
      else
         JAC = JACFD;
      end
   else
      x(:) = XOUT;
   end
   GradF = 2*(CostFunction'*JAC)'; %2*GRAD*CostFunction;
   
   %---------------Initialization of Search Direction------------------
   JacTJac = JAC'*JAC;
   if iter == 0
       OLDX = XOUT;
       OLDF = CostFunction;
       displayHeaders(verbosity,levMarq);
       
       % Initialize the output function.
       if haveoutputfcn || haveplotfcn
           [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,XOUT,xOutputfcn,'init',iter,numFunEvals, ...
               CostFunction,NewF,[],[],GradF,[],[],varargin{:});
           if stop
               [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues,levMarq,caller);
               return;
           end
       end
       
       if verbosity > 1
           disp(sprintf(formatstrFirstIter,iter,numFunEvals,NewF)); 
       end
       
       % 0th iteration
       if haveoutputfcn || haveplotfcn
           [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,XOUT,xOutputfcn,'iter',iter,numFunEvals, ...
               CostFunction,NewF,[],[],GradF,[],[],varargin{:});
           if stop
               [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues,levMarq,caller);
               return;
           end
       end

      % Disable the warnings about conditioning for singular and
      % nearly singular matrices
      warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
      warningstate2 = warning('off', 'MATLAB:singularMatrix');
      
      if condest(JacTJac)>1e16 
         SD=-(JacTJac+(norm(full(JAC))+1)*(eye(numberOfVariables,numberOfVariables)))\(CostFunction'*JAC)';
         if levMarq 
            GradFactor=norm(full(JAC))+1; 
         end
         how='COND';
      else
         SD=-(JacTJac+GradFactor*(eye(numberOfVariables,numberOfVariables)))\(CostFunction'*JAC)';
      end
      FIRSTF=NewF;
      OLDJ = JAC;
      GDOLD=GradF'*SD;
      % currstepsize controls the initial starting step-size.
      % If currstepsize has been set externally then it will
      % be non-zero, otherwise set to 1. Right now it's not
      % possible to set it externally.
      if currstepsize == 0, 
         currstepsize=1; 
      end
      LMorSwitchFromGNtoLM = false;
      if levMarq
         newf=JAC*SD+CostFunction;
         GradFactor=newf'*newf;
         SD=-(JacTJac+GradFactor*(eye(numberOfVariables,numberOfVariables)))\(CostFunction'*JAC)'; 
         LMorSwitchFromGNtoLM = true;
      end

      % Restore the warning states to their original settings
      warning(warningstate1)
      warning(warningstate2)

      newf=JAC*SD+CostFunction;
      EstSum=newf'*newf;
      status=0;
      if lineSearchType==0; 
         PCNT=1; 
      end
     
  else % iter >= 1
      gdnew=GradF'*SD;
      if verbosity > 1 
          num=sprintf(formatstr,iter,numFunEvals,NewF,currstepsize,gdnew);
          if LMorSwitchFromGNtoLM
              num=[num,sprintf('   %12.6g ',GradFactor)]; 
          end
          if isinf(verbosity)
              disp([num,'       ',how])
          else
              disp(num)
          end
      end
      
      if haveoutputfcn || haveplotfcn
          [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,XOUT,xOutputfcn,'iter',iter,numFunEvals, ...
              CostFunction,NewF,currstepsize,gdnew,GradF,SD,GradFactor,varargin{:});
          if stop
              [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues,levMarq,caller);
              return;
          end
      end
      
      %-------------Direction Update------------------


      if gdnew>0 && NewF>FIRSTF
         % Case 1: New function is bigger than last and gradient w.r.t. SD -ve
         % ... interpolate. 
         how='inter';
         [stepsize]=cubici1(NewF,FIRSTF,gdnew,GDOLD,currstepsize);
         currstepsize=0.9*stepsize;
      elseif NewF<FIRSTF
         %  New function less than old fun. and OK for updating 
         %         .... update and calculate new direction. 
         [newstep,fbest] =cubici3(NewF,FIRSTF,gdnew,GDOLD,currstepsize);
         if fbest>NewF,
            fbest=0.9*NewF; 
         end 
         if gdnew<0
            how='incstep';
            if newstep<currstepsize,  
               newstep=(2*currstepsize+1e-4); how=[how,'IF']; 
            end
            currstepsize=abs(newstep);
         else 
            if currstepsize>0.9
               how='int_step';
               currstepsize=min([1,abs(newstep)]);
            end
         end
         % SET DIRECTION.      
         % Gauss-Newton Algorithm    
         LMorSwitchFromGNtoLM = true ;

         % Disable the warnings about conditioning for singular and
         % nearly singular matrices
         warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
         warningstate2 = warning('off', 'MATLAB:singularMatrix');

         if ~levMarq
            if currstepsize>1e-8 && condest(JacTJac)<1e16
               SD=JAC\(JAC*XOUT-CostFunction)-XOUT;
               if SD'*GradF>eps,
                  how='ERROR- GN not descent direction';
               end
               LMorSwitchFromGNtoLM = false;
            else
               if verbosity > 1
                   if currstepsize <= 1e-8
                       fprintf('Step size too small - Switching to LM algorithm.\n');
                   else % condest(JacTJac) >= 1e16
                       fprintf('Iteration matrix ill-conditioned - Switching to LM algorithm.\n');
                   end
               end
               how='CHG2LM';
               levMarq = true;
               currstepsize=abs(currstepsize);               
            end
         end
         
         if (LMorSwitchFromGNtoLM)      
            % Levenberg_marquardt Algorithm N.B. EstSum is the estimated sum of squares.
            %                                 GradFactor is the value of lambda.
            % Estimated Residual:
            if EstSum>fbest
               GradFactor=GradFactor/(1+currstepsize);
            else
               GradFactor=GradFactor+(fbest-EstSum)/(currstepsize+eps);
            end
            SD=-(JacTJac+GradFactor*(eye(numberOfVariables,numberOfVariables)))\(CostFunction'*JAC)'; 
            currstepsize=1; 
            estf=JAC*SD+CostFunction;
            EstSum=estf'*estf;
         end
         gdnew=GradF'*SD;

         % Restore the warning states to their original settings
         warning(warningstate1)
         warning(warningstate2)
         
         OLDX=XOUT;
         % Save Variables
         FIRSTF=NewF;
         OLDG=GradF;
         GDOLD=gdnew;    
         
         % If quadratic interpolation set PCNT
         if lineSearchType==0, 
            PCNT=1; MATX=zeros(3,1); MATL(1)=NewF; 
         end
      else 
         % Halve Step-length
         how='Red_Step';
         if NewF==FIRSTF,
            msg = sprintf('No improvement in search direction: Terminating.');
            done = true;
            EXITFLAG = -4;
         else
            currstepsize=currstepsize/8;
            if currstepsize<1e-8
               currstepsize=-currstepsize;
            end
         end
      end
   end % if iter==0 
   
   %----------End of Direction Update-------------------
   iter = iter + 1;

   if lineSearchType==0, 
      PCNT=1; MATX=zeros(3,1);  MATL(1)=NewF; 
   end
   % Check Termination 
   if (GradF'*SD) < tolFun && ...
           max(abs(GradF)) < 10*(tolFun+tolX)
       msg = sprintf(['Optimization terminated: directional derivative along\n' ... 
                          ' search direction less than TolFun and infinity-norm of\n' ...
                          ' gradient less than 10*(TolFun+TolX).']);
       done = true; EXITFLAG = 1;
   elseif max(abs(SD))< tolX 
       msg = sprintf('Optimization terminated: magnitude of search direction less than TolX.');     
       done = true; EXITFLAG = 4;

   elseif numFunEvals > maxFunEvals
      msg = sprintf(['Maximum number of function evaluations exceeded.',...
                 ' Increase OPTIONS.MaxFunEvals.']);
      done = true;
      EXITFLAG = 0;
   elseif iter > maxIter
      msg = sprintf(['Maximum number of iterations exceeded.', ...
                        ' Increase OPTIONS.MaxIter.']);
      done = true;
      EXITFLAG = 0;
   else % continue
      XOUT=OLDX+currstepsize*SD;
      % Line search using mixed polynomial interpolation and extrapolation.
      if PCNT~=0
         % initialize OX and OLDF 
         OX = XOUT; OLDF = CostFunction;
         while PCNT > 0 && numFunEvals <= maxFunEvals
              % Call output functions (we don't call plot functions with
              % 'interrupt' flag)
             if haveoutputfcn
                 [unused1, unused2, stop] = callOutputAndPlotFcns(outputfcn,{},caller,XOUT,xOutputfcn,'interrupt',iter,numFunEvals, ...
                     CostFunction,NewF,[],[],GradF,[],[],varargin{:});
                 if stop
                     [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues,levMarq,caller);
                     return;
                 end
             end

            x(:) = XOUT; 
            CostFunction = feval(funfcn{3},x,varargin{:});
            CostFunction = full(CostFunction(:));
            numFunEvals=numFunEvals+1;
            NewF = CostFunction'*CostFunction;
            % <= used in case when no improvement found.
            if NewF <= OLDF'*OLDF, 
               OX = XOUT; 
               OLDF=CostFunction; 
            end
            [PCNT,MATL,MATX,steplen,NewF,how]=searchq(PCNT,NewF,OLDX,MATL,MATX,SD,GDOLD,currstepsize,how);
            currstepsize=steplen;
            XOUT=OLDX+steplen*SD;
            if NewF==FIRSTF,  
               PCNT=0; 
            end
         end % end while
         XOUT = OX;
         CostFunction=OLDF;
         if numFunEvals>maxFunEvals 
            msg = sprintf(['Maximum number of function evaluations exceeded.',...
                            ' Increase OPTIONS.MaxFunEvals.']);
            done = true; 
            EXITFLAG = 0;
         end
      end % if PCNT~=0
   
      % Evaluate objective
      x(:)=XOUT;
      switch funfcn{1}
          case 'fun'
              CostFunction = feval(funfcn{3},x,varargin{:});
              CostFunction = full(CostFunction(:));
              nfun=length(CostFunction);
              % JAC will be updated when it is finite-differenced
          case 'fungrad'
              [CostFunction,JAC] = feval(funfcn{3},x,varargin{:});
              CostFunction = full(CostFunction(:));
              numGradEvals=numGradEvals+1;
          case 'fun_then_grad'
              CostFunction = feval(funfcn{3},x,varargin{:});
              CostFunction = full(CostFunction(:));
              JAC = feval(funfcn{4},x,varargin{:});
              numGradEvals=numGradEvals+1;
          otherwise
              error('optim:nlsq:InvalidCalltype','Undefined calltype in LSQNONLIN.')
      end
      numFunEvals=numFunEvals+1;
      NewF = CostFunction'*CostFunction;

   end % Convergence testing
end  % while

NewF = CostFunction'*CostFunction;
gdnew=GradF'*SD;

if haveoutputfcn || haveplotfcn
    [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,XOUT,xOutputfcn,'iter',iter,numFunEvals, ...
        CostFunction,NewF,currstepsize,GDOLD,GradF,SD,GradFactor,varargin{:});
    if stop
        [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues,levMarq,caller);
        return;
    end
end

x(:)=XOUT;

OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.stepsize=currstepsize;
OUTPUT.cgiterations = [];
OUTPUT.firstorderopt = [];

if levMarq
   OUTPUT.algorithm='medium-scale: Levenberg-Marquardt, line-search';
else
   OUTPUT.algorithm='medium-scale: Gauss-Newton, line-search';
end

if haveoutputfcn || haveplotfcn
    [xOutputfcn, optimValues] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,XOUT,xOutputfcn,'done',iter,numFunEvals, ...
        CostFunction,NewF,currstepsize,GDOLD,GradF,SD,GradFactor,varargin{:});
    % Optimization done, so ignore "stop"
end

%--------------------------------------------------------------------------
function [pcnt, matl,matx,stepsize,fnew,how]=searchq(pcnt,fnew,oldx,matl,matx,sd,gdold,stepsize,how) 
%   Line search procedure for least squares optimization. 
%   Uses Quadratic Interpolation. When finished pcnt returns 0.

if pcnt==1
% Case 1: Next point less than initial point. 
%     Increase step-length based on last gradient evaluation
    if fnew<matl(1)
% Quadratic Extrapolation using gradient of first point and 
% values of two other points.
        matl(2)=fnew;
        matx(2)=stepsize;
        newstep=-0.5*gdold*stepsize*stepsize/(fnew-gdold*stepsize-matl(1)+eps);
        if newstep<stepsize,how=[how,'QEF ']; newstep=1.2*stepsize; end
        stepsize=1.2*newstep;
        pcnt=2;
    else
% Case 2: New point greater than initial point. Decrease step-length.
        matl(3)=fnew;
        matx(3)=stepsize;
%Interpolate to get stepsize
        stepsize=max([1e-8*stepsize,-gdold*0.5*stepsize^2/(fnew-gdold*stepsize-matl(1)+eps)]);
        how=[how,'r'];
        pcnt=3;
    end
% Case 3: Last run was Case 1 (pcnt=2) and new point less than 
%     both of other 2. Replace. 
elseif pcnt==2  && fnew< matl(2)
    newstep=cubici2(gdold,[matl(1);matl(2);fnew],[matx(1);matx(2);stepsize]);
    if newstep<stepsize,how=[how, 'CEF ']; end
        matl(1)=matl(2);
        matx(1)=matx(2);
        matl(2)=fnew;
        matx(2)=stepsize;
        stepsize=min([newstep,1])+1.5*stepsize;
        stepsize=max([1.2*newstep,1.2*stepsize]);
        how=[how,'i'];
% Case 4: Last run was Case 2: (pcnt=3) and new function still 
%     greater than initial value.
elseif pcnt==3 && fnew>=matl(1)
    matl(2)=fnew;
    matx(2)=stepsize;
    if stepsize<1e-6
        newstep=-stepsize/2;
        % Give up if the step-size gets too small 
        % Stops infinite loops if no improvement is possible.
        if abs(newstep) < (eps * eps), pcnt = 0; end
    else
        newstep=cubici2(gdold,[matl(1);matl(3);fnew],[matx(1);matx(3);stepsize]);
    end
    matx(3)=stepsize;
    if isnan(newstep), stepsize=stepsize/2; else stepsize=newstep; end
    matl(3)=fnew;
    how=[how,'R'];
% Otherwise must have Bracketed Minimum so do quadratic interpolation.
%  ... having just increased step.
elseif pcnt==2 && fnew>=matl(2)
    matx(3)=stepsize;
    matl(3)=fnew;
    [stepsize]=cubici2(gdold,matl,matx);
    pcnt=4;
% ...  having just reduced step.
elseif  pcnt==3  && fnew<matl(1)
    matx(2)=stepsize;
    matl(2)=fnew;
    [stepsize]=cubici2(gdold,matl,matx);
    pcnt=4;
% Have just interpolated - Check to see whether function is any better 
% - if not replace.
elseif pcnt==4 
    pcnt=0;
    stepsize=abs(stepsize);
% If interpolation failed use old point.
    if fnew>matl(2),
        fnew=matl(2);
        how='f';
        stepsize=matx(2);       
    end
end %if pcnt==1

%--------------------------------------------------------------------------
function r = cubici1(f2,f1,c2,c1,dx)
%CUBICI1 Cubicly interpolates 2 points and gradients to estimate minimum.
%
%   This function uses cubic interpolation and the values of two 
%   points and their gradients in order to estimate the minimum of a 
%   a function along a line.

if isinf(f2), f2 = 1/eps; end
z = 3*(f1-f2)/dx+c1+c2;
w = real(sqrt(z*z-c1*c2));
r = dx*((z+w-c1)/(c2-c1+2*w));

%--------------------------------------------------------------------------
function step = cubici2(c,f,x)
%CUBICI2 Determine optimizer step from three points and one gradient.
%   STEP = CUBICI2(c,f,x)
%   Finds the cubic p(x) with p(x(1:3)) = f(1:3) and p'(0) = c.
%   Returns the minimizer of p(x) if it is positive.
%   Calls QUADI if the minimizer is negative.
%
% p(x) = a/3*x^3 - b*x^2 + c*x + d.
% c = p'(0) is the first input parameter.
% Solve [1/3*x.^3 -1/2*x^2 ones(3,1)]*[a b d]' = f - c*x.
% Compute a and b; don't need d.
%    a = 3*(x1^2*(f2-f3) + x2^2*(f3-f1) + x3^2*(f1-f2))/h
%    b = (x1^3*(f2-f3) + x2^3*(f3-f1) + x3^3*(f1-f2))/h
%    where h = (x1-x2)*(x2-x3)*(x3-x1)*(x1*x2 + x2*x3 + x3*x1).
% Local min and max where p'(s) = a*s^2 - 2*b*s + c = 0
% Local min always comes from plus sign in the quadratic formula.
% If p'(x) has no real roots, step = b/a.
% If step < 0, use quadi instead.

x = x(:);
f = f(:);
g = f - c*x;
g = g([2 3 1]) - g([3 1 2]);
y = x([2 3 1]);
h = prod(x-y)*(x'*y);
a = 3*(x.^2)'*g/h;
b = (x.^3)'*g/h;

% Find minimizer.
step = (b + real(sqrt(b^2-a*c)))/a;

% Is step acceptable?
if step < 0 | ~isfinite(step)
   step = abs(quadi(x,f));
end
if isnan(step)
   step = x(2)/2;
end

%--------------------------------------------------------------------------
function [s,f] = cubici3(f2,f1,c2,c1,dx)
%CUBICI3 Cubicly interpolates 2 points and gradients to find step and min.
%   This function uses cubic interpolation and the values of 
%   two points and their gradients in order to estimate the minimum s of a 
%   a function along a line and returns s and f = F(s);
%
%
%  The equation is F(s) = a/3*s^3 + b*s^2 + c1*s + f1
%      and F'(s) = a*s^2+2*b*s + c1
%  where we know that 
%          F(0) = f1
%          F'(0) = c1  
%          F(dx) = f2   implies: a/3*dx^3 + b*dx^2 + c1*dx + f1 = f2
%          F'(dx) = c2  implies: a*dx^2+2*b*dx + c1 = c2

if isinf(f2), 
    f2 = 1/eps; 
end
a = (6*(f1-f2)+3*(c1+c2)*dx)/dx^3;
b = (3*(f2-f1)-(2*c1+c2)*dx)/dx^2;
disc = b^2 - a*c1;
if a==0 & b==0 
    % F(s) is linear: F'(s) = c1, which is never zero;
    % minimum is s=Inf or -Inf (we return s always positive so s=Inf).
    s = inf; 
elseif a == 0 
    % F(s) is quadratic so we know minimum s
    s = -c1/(2*b);
elseif disc <= 0
    % If disc = 0 this is exact. 
    % If disc < 0 we ignore the complex component of the root.
    s = -b/a;  
else
    s = (-b+sqrt(disc))/a;
end
if s<0,  s = -s; end
if isinf(s)
    f = inf;
else
    % User Horner's rule
    f = ((a/3*s + b)*s + c1)*s + f1;
end

%--------------------------------------------------------------------------
function step = quadi(x,f)
%QUADI Determine optimizer step from three points.
%   STEP = QUADI(x,f)
%   Finds the quadratic p(x) with p(x(1:3)) = f(1:3).
%   Returns the minimizer (or maximizer) of p(x).

% p(x) = a*x^2 + b*x + c.
% Solve [x.^2 x ones(3,1)]*[a b c]' = f.
% Minimum at p'(s) = 0,
% s = -b/(2*a) = (x1^2*(f2-f3) + x2^2*(f3-f1) + x3^2*(f1-f2))/ ...
%                 (x1*(f2-f3) + x2*(f3-f1) + x3*(f1-f2))/2

x = x(:); 
f = f(:);
g = f([2 3 1]) - f([3 1 2]);
step = ((x.*x)'*g)/(x'*g)/2;

%--------------------------------------------------------------------------
function displayHeaders(verbosity,levMarq)

if verbosity>1
   if ~levMarq
      if isinf(verbosity)
         header = sprintf(['\n                                                     Directional \n',...
                             ' Iteration  Func-count    Residual     Step-size      derivative   Line-search']);
      else
         header = sprintf(['\n                                                     Directional \n',...
                             ' Iteration  Func-count    Residual     Step-size      derivative ']);
      end
   else
      if isinf(verbosity)
         header = sprintf(['\n                                                     Directional \n',...
                             ' Iteration  Func-count    Residual     Step-size      derivative   Lambda       Line-search']);
      else
         header = sprintf(['\n                                                     Directional \n',...
                             ' Iteration  Func-count    Residual     Step-size      derivative    Lambda']);
      end
   end
   disp(header)
end
%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,x,xOutputfcn,state,iter,numFunEvals, ...
    CostFunction,NewF,currstepsize,gdnew,GradF,SD,GradFactor,varargin)
% CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then calls the
% outputfcn/plotfcns.  
%
% state - can have the values 'init','iter','interrupt', or 'done'. 

% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.
optimValues.iteration = iter;
optimValues.funccount = numFunEvals;
optimValues.stepsize = currstepsize;
optimValues.directionalderivative = gdnew;
optimValues.gradient = GradF;
optimValues.firstorderopt = norm(GradF,Inf);
optimValues.searchdirection = SD;
optimValues.lambda = GradFactor;
if isequal(caller,'fsolve') 
   optimValues.fval = CostFunction; 
else % lsqnonlin, lsqcurvefit 
   optimValues.residual = CostFunction; 
   optimValues.resnorm = NewF; 
end 
xOutputfcn(:) = x;  % Set x to have user expected size
stop = false;
% Call output function
if ~isempty(outputfcn)
    switch state
        case {'iter','init','interrupt'}
            stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
        otherwise
            error('optim:nlsq:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
% Call plot functions
if ~isempty(plotfcns)
    switch state
        case {'iter','init'}
            stop = callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:});
        otherwise
            error('optim:nlsq:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
%--------------------------------------------------------------------------
function [x,CostFunction,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues,levMarq,caller)

x = xOutputfcn;
% CostFunction can be either 'fval' (fsolve) or 'residual'
if isequal(caller,'fsolve') 
    CostFunction = optimValues.fval;
else 
    CostFunction = optimValues.residual;
end
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.stepsize = optimValues.stepsize;
OUTPUT.cgiterations = [];
OUTPUT.firstorderopt = [];

if levMarq
   OUTPUT.algorithm='medium-scale: Levenberg-Marquardt, line-search';
else
   OUTPUT.algorithm='medium-scale: Gauss-Newton, line-search';
end

JAC = []; % May be in an inconsistent state
msg = 'Optimization terminated prematurely by user.';
