function [neqn,nparam,nregions,atol,rtol,nmax,vectorized,printstats] = ...
        bvparguments(solver_name,odefun,bcfun,solinit,options,extras)
%BVPARGUMENTS  Helper function for processing arguments for BVP solvers.
%
%   See also BVP4C, BVP5C, BVPSET.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/08 12:55:28 $

    % Handle extra arguments
    if nargin < 6
        extras = {};
    end

    % error/warning introductory messages
    solverNameUpper = upper(solver_name);
    if isempty(options)
        optionalArgumentsStr = '';
    else
        optionalArgumentsStr = ',OPTIONS';
    end
    if ~isempty(extras)        
        optionalArgumentsStr = strcat(optionalArgumentsStr,',P1,P2...');
    end
    errIntro = sprintf('Error in calling %s(ODEFUN,BCFUN,SOLINIT%s): \n',...
                       solverNameUpper,optionalArgumentsStr);   
    warningIntro = sprintf('Warning in calling %s(ODEFUN,BCFUN,SOLINIT%s): \n',...
                           solverNameUpper,optionalArgumentsStr);       
    
    % Validate odefun and bcfun (and solver_name)    
    switch solver_name
        
      case 'bvp5c'  % BVP5C requires function_handles
        if ~isa(odefun,'function_handle')
            msg = sprintf('The derivative function ODEFUN must be a function_handle.');     
            error('MATLAB:bvparguments:ODEfunNotFunctionHandle','%s  %s',errIntro,msg);  
        end
        if ~isa(bcfun,'function_handle')
            msg = sprintf('The boundary condition function BCFUN must be a function_handle.'); 
            error('MATLAB:bvparguments:BCfunNotFunctionHandle','%s  %s',errIntro,msg);  
        end
        ode = odefun;
        bc  = bcfun;
        
      case 'bvp4c' 
        % avoid fevals
        ode = fcnchk(odefun);
        bc  = fcnchk(bcfun);
        
      otherwise
        error('MATLAB:bvparguments:SolverNameUnrecognized',...
              'Internal error -- unrecognized solver name: %s,',solver_name);
    end
    
    % Validate initial guess
    if ~isstruct(solinit)
        msg = sprintf('The initial profile SOLINIT must be provided as a structure.');  
        error('MATLAB:bvparguments:SolinitNotStruct','%s  %s',errIntro,msg);
    elseif ~isfield(solinit,'x')
        msg = sprintf('The field ''x'' not present in SOLINIT.');
        error('MATLAB:bvparguments:NoXInSolinit','%s  %s',errIntro,msg);
    elseif ~isfield(solinit,'y')
        msg = sprintf('The field ''y'' not present in SOLINIT.');
        error('MATLAB:bvparguments:NoYInSolinit','%s  %s',errIntro,msg);              
    end

    if isempty(solinit.x) || (length(solinit.x) < 2)
        msg = sprintf('SOLINIT.x must contain at least the two end points.');
        error('MATLAB:bvparguments:SolinitXNotEnoughPts','%s  %s',errIntro,msg);   
    end

    if any( sign(solinit.x(end)-solinit.x(1)) * diff(solinit.x) < 0)
        msg = sprintf('The entries in SOLINIT.x must increase or decrease.');
        error ('MATLAB:bvparguments:SolinitXNotMonotonic','%s  %s',errIntro,msg); 
    end
    
    if isempty(solinit.y)
        msg = sprintf('No initial guess provided in SOLINIT.y.');              
        error('MATLAB:bvparguments:SolinitYEmpty','%s  %s',errIntro,msg);  
    end
    
    if size(solinit.y,2) ~= length(solinit.x)
        msg = sprintf('SOLINIT.y not consistent with SOLINIT.x.');
        error('MATLAB:bvparguments:SolXSolYSizeMismatch','%s  %s',errIntro,msg); 
    end

    % Determine problem size
    neqn = size(solinit.y,1);
    % - unknown parameters
    if isfield(solinit,'parameters')
        nparam = numel(solinit.parameters);
    else
        nparam = 0;
    end
    % - multi-point BVPs 
    interfacePoints = find(diff(solinit.x) == 0); 
    nregions = 1 + length(interfacePoints);                      

    % Test the outputs of ODEFUN and BCFUN
    if nparam > 0
        extras = [solinit.parameters(:), extras];
    end                   
    x1 = solinit.x(1);
    y1 = solinit.y(:,1);    
    if nregions == 1
        odeExtras = extras;  
        bcExtras = extras;
        ya = solinit.y(:,1);
        yb = solinit.y(:,end);
    else
        odeExtras = [1, extras];  % region = 1 
        bcExtras = extras;
        ya = solinit.y(:,[1, interfacePoints + 1]); % pass internal interfaces to BC
        yb = solinit.y(:,[interfacePoints,length(solinit.x)]);        
    end
    testODE = ode(x1,y1,odeExtras{:});   
    testBC = bc(ya,yb,bcExtras{:});                        
    if length(testODE) ~= neqn
        msg = sprintf(['The derivative function ODEFUN should return ',...
                       'a column vector of length %i.'],neqn);          
        error('MATLAB:bvparguments:ODEfunOutputSize','%s  %s',errIntro,msg); 
    end    
    if length(testBC) ~= (neqn*nregions + nparam)
        msg = sprintf(['The boundary condition function BCFUN should return ',...
                       'a column vector of length %i.'],neqn*nregions + nparam);  
        error('MATLAB:bvparguments:BCfunOutputSize','%s  %s',errIntro,msg);         
    end
    
    % BVP5C cannot concatenate row vectors with equations for unknown parameters
    if strcmp(solver_name,'bvp5c') && (nparam > 0)
        if size(testODE,2) ~= 1
            msg = sprintf(['The derivative function ODEFUN should return ',...
                           'a column vector of length %i.'],neqn);          
            error('MATLAB:bvparguments:ODEfunOutputSize','%s  %s',errIntro,msg); 
        end
        if size(testBC,2) ~= 1
            msg = sprintf(['The boundary condition function BCFUN should return ',...
                           'a column vector of length %i.'],neqn*nregions + nparam);  
            error('MATLAB:bvparguments:BCfunOutputSize','%s  %s',errIntro,msg);         
        end
    end        
            
    % Extract/validate BVPSET options:
    % - tolerances
    rtol = bvpget(options,'RelTol',1e-3);      
    if ~(isscalar(rtol) && (rtol > 0))
        msg = sprintf('RelTol in OPTIONS must be a positive scalar.');  
        error('MATLAB:bvparguments:RelTolNotPos','%s  %s',errIntro,msg);    
    end
    if rtol < 100*eps
        rtol = 100*eps;
        msg = sprintf('RelTol in OPTIONS has been increased to %g.',rtol);
        warning('MATLAB:bvparguments:RelTolIncrease','%s  %s',warningIntro,msg);
    end  
    atol = bvpget(options,'AbsTol',1e-6);
    if isscalar(atol)
        atol = atol(ones(neqn,1));
    else
        if length(atol) ~= neqn
            msg = sprintf(['For this problem AbsTol in OPTIONS must be ' ...
                           'a scalar or a vector of length %d.'],neqn);
            error('MATLAB:bvparguments:SizeAbsTol','%s  %s',errIntro,msg);  
        end  
        atol = atol(:);
    end
    if any(atol<=0)
        msg = sprintf('AbsTol in OPTIONS must be positive.');
        error('MATLAB:bvparguments:AbsTolNotPos','%s  %s',errIntro,msg);   
    end  
 
    % - max number of meshpoints
    nmax = bvpget(options,'Nmax',floor(10000/neqn));  

    % - vectorized
    vectorized = strcmp(bvpget(options,'Vectorized','off'),'on');

    % 'vectorized' ODEFUN must return column vectors
    if vectorized
        if size(testODE,2) ~= 1
            msg = sprintf(['The derivative function ODEFUN should return ',...
                           'a column vector of length %i.'],neqn);          
            error('MATLAB:bvparguments:ODEfunOutputSize','%s  %s',errIntro,msg); 
        end
    end
        
    % - printstats
    printstats = strcmp(bvpget(options,'Stats','off'),'on');
    
end  % bvparguments
