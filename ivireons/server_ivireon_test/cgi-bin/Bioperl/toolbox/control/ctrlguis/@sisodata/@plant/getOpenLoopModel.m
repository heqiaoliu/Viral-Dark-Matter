function [cList,G] = getOpenLoopModel(this,idxOL,idxOpenings)
% Computes a structurally minimal model for the open-loop transfer 
% function measured at the output of the compensator C(IDXOL), 
% taking into account loop opening at the outputs of the compensators
% C(IDXOPENINGS).
%
% The resulting model is of the form
%    OL = lft(G , C(cList))
% where G is a structurally minimal state-space model and the index 
% vector CLIST indicates which compensators the open-loop transfer 
% function depends on.
%
% This function is used to build @TunedLoop data structures for 
% open-loop analysis.

%   Author(s): P. Gahinet, C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/26 17:22:23 $



nC = this.nLoop;  % number of compensators

% Get Plant
P = getP(this);

for ct = 1:length(P)
    [cList,G(ct)] = localComputeModel(P(ct),nC,idxOL,idxOpenings);
end

end

function [cList,G] = localComputeModel(P,nC,idxOL,idxOpenings)

if isa(P,'ltipack.frddata')
    [ny,nu] = iosize(P);
    
    idx = [1:idxOL-1,idxOL+1:nC];
    
    indrow = ny-nC-1:ny;
    indcol = nu-nC+1:nu;
    % Eliminate External I/O
    % Determine hard zeros in I/O channels of P
    M = any(P.Response(indrow,indcol,:),3);
    M(:,idxOpenings) = 0;
    keep = false(nC,1);
    
    [~,~,~,~,keep(idx)] = smreal(M(idx,idx),M(idx,idxOL),M(idxOL,idx),[]);
    
    cList = find(keep(1:nC));
    
    iokeep = [idxOL ; cList];
    G = getsubsys(P,ny-nC+iokeep,nu-nC+iokeep);
    
else
    % Get plant data
    a = P.a;
    b = P.b;
    c = P.c;
    d = P.d;
    e = P.e;
    [ny,nu] = size(d);
    nx = size(a,1);
    
    DelayStruct = P.Delay;
    nID = length(DelayStruct.Internal); % number of internal delays
    
    % Eliminate external I/Os
    indrow = ny-nC-nID+1:ny;
    indcol = nu-nC-nID+1:nu;
    d = d(indrow,indcol);
    b = b(:,indcol);
    c = c(indrow,:);
    DelayStruct.Input = DelayStruct.Input(nu-nID-nC+1:nu-nID,:);
    DelayStruct.Output = DelayStruct.Output(ny-nID-nC+1:ny-nID,:);
    
    % Perform structural analysis
    M = [d c;b a];
    M(:,idxOpenings) = 0;  % take loop openings into account
    keep = false(nC+nID+nx,1);
    idx = [1:idxOL-1,idxOL+1:nC+nID+nx];
    if isempty(e); % Handle improper case
        [~,~,~,~,keep(idx)] = smreal(M(idx,idx),M(idx,idxOL),M(idxOL,idx),[]);
    else
        Me = blkdiag(eye(size(d)),e);
        [~,~,~,~,keep(idx)] = smreal(M(idx,idx),M(idx,idxOL),M(idxOL,idx),Me(idx,idx));
    end
    
    
    % Compensators this loop depends on
    cList = find(keep(1:nC));
    
    % Internal Delays this loop depends on
    idList = find(keep(nC+1:nC+nID));
    
    % States this loop depends on
    xkeep = find(keep(nC+nID+1:end));
    iokeep = [idxOL ; cList; nC+idList];
    if ~isempty(e); % Update E for improper case
        e = e(xkeep,xkeep);
    end
    
    
    DelayStruct.Input = DelayStruct.Input([1 ; cList],:);
    DelayStruct.Output = DelayStruct.Output([1 ; cList],:);
    DelayStruct.Internal = DelayStruct.Internal(idList,:);
    
    G = ltipack.ssdata(a(xkeep,xkeep),b(xkeep,iokeep),c(iokeep,xkeep),...
        d(iokeep,iokeep),e,P.Ts);
    
    G.Delay = DelayStruct;
end
end
