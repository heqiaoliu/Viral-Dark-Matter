function [A,B,C,D] = pertlinearizedisc(this,model,st,xstruct,u,xpert,upert,t)
% PERTLINEARIZEDISC  Utility function to numerically perturb a model that
% is discrete.

%     [A,B,C,D]=PERTLINEARIZEDISC('SYS',TS,X,U,PARA,XPERT,UPERT) allows the perturbation
%     levels for all of the elements of X and U to be set. Any or all of PARA, 
%     XPERT, UPERT may be empty matrices in which case these parameters will be
%     assumed to be undefined and the default option will be used.  If X is
%     specified using the structure format, XPERT also must be specified
%     using the structure format.

% Author(s): John W. Glass 08-Mar-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2008/03/13 17:39:19 $

% Get the model sample times
[sizes x0 x_str ts]=feval(model,[],[],[],'sizes');
ts = [0 0; ts];

% Eliminate sample times that are the same with different offsets.
tsnew = unique(ts(:,1));
nts = length(tsnew);   

% Get the state sample times
tsx = simulinkStructToVector(slcontrol.Utilities,xstruct,'sampleTime'); 
tsx = tsx(:,1);

% Compute unperturbed values (must occur each time through the loop,
% after the call to 'all' with a given sampling time.  Otherwise,
% linearizations about nonzero initial states might get munged.
oldx = xstruct; oldu=u;
% force all rates in the model to have a hit
feval(model, [], [], [], 'all');
oldy = simulinkStructToVector(slcontrol.Utilities,...
        feval(model, t, xstruct ,u, 'outputs'));
olddall = simulinkStructToVector(slcontrol.Utilities,...
    getDerivsUpdate(model,t,xstruct,u));

% Initialize perturbation matrices
nu=length(u); nxz = numel(olddall);
A = zeros(nxz,nxz); B = zeros(nxz, nu); Acd = A; Bcd = B;
Aeye = eye(nxz,nxz);

ny = length(oldy);
C=zeros(ny,nxz); D=zeros(ny,nu);

% Starting with smallest sample time, convert those models to the
% next smallest sample time.  Each pass through the loop removes a
% sample time from the list (and from the model).  Stop when the
% system is single-rate.
for m = 1:nts
    % Choose the next sample time
    if length(tsnew) > 1
        stnext = min(st, tsnew(2));
    else
        stnext = st;
    end
    storig = tsnew(1);
    index = find(tsx == storig);		% states with Ts = storig
    nindex = find(tsx ~= storig);		% states with another Ts
    oldA = Acd; oldB = Bcd;

    %% This code block performs the simple linearization based on perturbations
    %% about x0, u0.  A sample time is specified not as the time at which the
    %% linearization occurs, but rather as a "granularity" or sampling time over
    %% which we are interested.  Thus, states with long sampling times will not
    %% change due to perturbations/linearization around shorter sampling times.
    
    %% Here t really is the time at which linearization occurs, same as linmod.
    %% storig is the sampling time for the current linearization.
    feval(model, storig, [], [], 'all');  % update blocks with Ts <= storig
    Acd=zeros(nxz,nxz); Bcd=zeros(nxz,nu);
        
    % A and C matrices. Loop over all of the states in the model
    ctr = 1;
    if ~isempty(xstruct)
        for ct1 = 1:length(xstruct.signals);
            for ct2 = 1:length(xstruct.signals(ct1).values)
                %% Perturb the states
                xpertval = xpert.signals(ct1).values(ct2);
                xval = xstruct.signals(ct1).values(ct2);
                xstruct.signals(ct1).values(ct2) = xval+xpertval;
                % Evaluate outputs and derivative and flatten to a vector
                y = simulinkStructToVector(slcontrol.Utilities,...
                    feval(model, t, xstruct ,u, 'outputs'));
                dall = simulinkStructToVector(slcontrol.Utilities,...
                    getDerivsUpdate(model,t,xstruct,u));
                xstruct = oldx;
                Acd(:,ctr)=(dall-olddall)./xpertval;
                if ny > 0
                    C(:,ctr)=(y-oldy)./xpertval;
                end
                ctr = ctr + 1;
            end
        end
    end
    
    % B and D matrices
    for ct=1:nu
        u(ct)=u(ct)+upert(ct);
        y = simulinkStructToVector(slcontrol.Utilities,...
                    feval(model, t, xstruct ,u, 'outputs'));
        dall = simulinkStructToVector(slcontrol.Utilities,...
                    getDerivsUpdate(model,t,xstruct,u));
        if ~isempty(Bcd),
            Bcd(:,ct)=(dall-olddall)./upert(ct);
        end
        if ny > 0
            D(:,ct)=(y-oldy)./upert(ct);
        end
        u=oldu;
    end
    % Update A, B matrices with any new information
    % Any differences between this linearization (Acd) and the last (oldA)
    % get premultiplied by the ZOH B-matrix associated with those states..
    % see the update method for Aeye below.
    A = A + Aeye * (Acd - oldA);
    B = B + Aeye * (Bcd - oldB);
    n = length(index);

    % Convert states at Ts=storig to sample time stnext
    % States with Ts > storig are treated as inputs (since they are constant
    % over one period at storig..) so the relevant columns of A are treated
    % as columns of B instead, via premultiplication by bd2.
    if n && storig ~= stnext
        sysold = ss(A(index,index),eye(n,n),ones(1,length(index)),ones(1,n),storig);
        if storig ~=  0
            if stnext ~= 0
                sysnew = d2d(sysold,stnext);
            else
                sysnew = d2c(sysold);
            end
            if length(sysold.a) ~= length(sysnew.a)
                ctrlMsgUtils.error('Slcontrol:linearize:ErrorConvertingNegativeRealSampleTime')
            end
        else
            sysnew = c2d(sysold,stnext);
        end
        ad2 = sysnew.A;
        bd2 = sysnew.B;
        A(index, index)  =  ad2;

        if ~isempty(nindex)
            A(index, nindex) = bd2*A(index,nindex);
        end
        if nu
            B(index,:) = bd2*B(index,:);
        end

        % Any further updates to these states also get hit with bd2
        Aeye(index,index) = bd2*Aeye(index,index);
        tsx(index) =  stnext(ones(length(index),1));
    end

    % Remove this sample time (storig) from the list
    tsnew(1) = [];
end

if norm(imag(A), 'inf') < sqrt(eps), A = real(A); end
if norm(imag(B), 'inf') < sqrt(eps), B = real(B); end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xk1 = getDerivsUpdate(model,t,xstruct,u)
% getDerivsUpdate  Compute the derivatives and the update using the
% structure format.  The return argument is a structure with the updates
% and derivatives
 
% Author(s): John W. Glass 01-Mar-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2008/03/13 17:39:19 $

% Compute model update and derivatives
dx = feval(model, t, xstruct, u, 'derivs');
xk1 = feval(model, t, xstruct, u, 'update');

% Eliminate unsupported states
xk1 = removeUnsupportedStates(slcontrol.Utilities,xk1); 

% Loop over each of the derivatives and replace the update values in ds
% with the values of the derivated.
if ~isempty(dx)
    for ct = 1:length(dx.signals)        
        if ~isempty(dx.signals(ct).stateName)
            ind = find(strcmp(dx.signals(ct).stateName,{xk1.signals.stateName}));
        else
            ind = find(strcmp(dx.signals(ct).blockName,{xk1.signals.blockName}));
        end
        
        % Filter by label to get the continuous states.  There can be discrete states
        % with zero sample time.
        ind = ind(strcmp('CSTATE',{xk1.signals(ind).label}));
        xk1.signals(ind).values = dx.signals(ct).values;
    end
end
