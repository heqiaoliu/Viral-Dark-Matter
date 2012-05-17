function [A,B,C,D] = pertlinearizecont(this,model,xstruct,u,xpert,upert,t) 
% PERTLINEARIZECONT  Utility function to numerically perturb a model that
% is continuous.

%     [A,B,C,D]=PERTLINEARIZECONT('SYS',X,U,PARA,XPERT,UPERT) allows the perturbation
%     levels for all of the elements of X and U to be set. Any or all of PARA, 
%     XPERT, UPERT may be empty matrices in which case these parameters will be
%     assumed to be undefined and the default option will be used.  If X is
%     specified using the structure format, XPERT also must be specified
%     using the structure format.
% 
%     See also LINMOD, LINMOD2, DLINMOD, TRIM.

% Author(s): John W. Glass 08-Mar-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/03/13 17:39:18 $

% Initialization of nominal outputs and derivatives
oldu=u;
% force all rates in the model to have a hit
feval(model, [], [], [], 'all');
y = simulinkStructToVector(slcontrol.Utilities,...
    feval(model, t, xstruct ,u, 'outputs'));
dx = simulinkStructToVector(slcontrol.Utilities,...
        feval(model, t, xstruct, u, 'derivs'));
oldy=y; olddx=dx;

% Initialization of perturbation matrices
ny = length(y); nu=length(u); nx = length(dx);
A=zeros(nx,nx); B=zeros(nx,nu); C=zeros(ny,nx); D=zeros(ny,nu);

% A and C matrices. Loop over all of the states in the model
ctr = 1;
if ~isempty(xstruct)
    for ct1 = 1:length(xstruct.signals);
        for ct2 = 1:length(xstruct.signals(ct1).values)
            xpertval = xpert.signals(ct1).values(ct2);
            xval = xstruct.signals(ct1).values(ct2);
            xstruct.signals(ct1).values(ct2) = xval+xpertval;
            % Evaluate outputs and derivative and flatten to a vector
            y = simulinkStructToVector(slcontrol.Utilities,...
                feval(model, t, xstruct, u, 'outputs'));
            dx = simulinkStructToVector(slcontrol.Utilities,...
                feval(model, t, xstruct, u, 'derivs'));
            A(:,ctr)=(dx-olddx)./xpertval;
            if ny > 0
                C(:,ctr)=(y-oldy)./xpertval;
            end
            xstruct.signals(ct1).values(ct2) = xval;
            ctr = ctr + 1;
        end
    end
end

% B and D matrices
for ct1=1:nu
    u(ct1)=u(ct1)+upert(ct1);
    % Evaluate outputs and derivative and flatten to a vector
    y = simulinkStructToVector(slcontrol.Utilities,...
            feval(model, t, xstruct, u, 'outputs'));
    dx = simulinkStructToVector(slcontrol.Utilities,...
            feval(model, t, xstruct, u, 'derivs'));
    if ~isempty(B),
        B(:,ct1)=(dx-olddx)./upert(ct1);
    end
    if ny > 0
        D(:,ct1)=(y-oldy)./upert(ct1);
    end
    u=oldu;
end