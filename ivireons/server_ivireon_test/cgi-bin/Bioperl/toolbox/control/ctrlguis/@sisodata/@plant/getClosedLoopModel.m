function [cList,G] = getClosedLoopModel(this,idxIn,idxOut,idxOpenings)
% Computes a structurally minimal model for the closed-loop transfer 
% function from input #idxIn to output #idxOut, taking into account  
% loop opening at the outputs of the compensators C(IDXOPENINGS).
%
% The resulting model is of the form
%    CL = lft(G , C(cList))
% where G is a structurally minimal state-space model and the index 
% vector CLIST indicates which compensators the closed-loop transfer 
% function depends on.
%
% This function is used to build @TunedLoop data structures for 
% closed-loop analysis.

%   Author(s): P. Gahinet, C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/26 17:22:21 $

nC = this.nLoop;  % number of compensators

% Get Plant
P = getP(this);

for ct = 1:length(P)
    [cList,G(ct)] = localComputeModel(P(ct),nC,idxIn,idxOut,idxOpenings);
end

end

function [cList,G] = localComputeModel(P,nC,idxIn,idxOut,idxOpenings)

if isa(P,'ltipack.frddata')
    [ny,nu] = iosize(P);
    
    indrow = [idxOut , ny-nC+1:ny];
    indcol = [idxIn , nu-nC+1:nu];
    
    M = any(P.Response(indrow,indcol,:),3);
    M(:,idxOpenings+1) = 0;
    
    idx = 2:size(M,1);
    
    [~,~,~,~,keep] = smreal(M(idx,idx),M(idx,1),M(1,idx),[]);
    
    cList = find(keep(1:nC));
    
    iokeep = [1 ; 1+cList];
    G = getsubsys(P,iokeep,iokeep);
    
else
    % Get plant data
    a = P.a;
    b = P.b;
    c = P.c;
    d = P.d;
    e = P.e;
    [ny,nu] = size(d);
    
    DelayStruct = P.Delay;
    nID = length(DelayStruct.Internal); % number of internal delays
    
    % Keep only (idxIn,idxOut) I/O pair
    indrow = [idxOut , ny-nC-nID+1:ny];
    indcol = [idxIn , nu-nC-nID+1:nu];
    d = d(indrow,indcol);
    b = b(:,indcol);
    c = c(indrow,:);
    DelayStruct.Input = DelayStruct.Input([idxIn,nu-nID-nC+1:nu-nID],:);
    DelayStruct.Output = DelayStruct.Output([idxOut,ny-nID-nC+1:ny-nID],:);
    
    % Perform structural analysis
    M = [d c;b a];
    M(:,idxOpenings+1) = 0;  % take loop openings into account
    idx = 2:size(M,1);
    if isempty(e); % Handle improper case
        [~,~,~,~,keep] = smreal(M(idx,idx),M(idx,1),M(1,idx),[]);
    else
        Me = blkdiag(eye(size(d)),e);
        [~,~,~,~,keep] = smreal(M(idx,idx),M(idx,1),M(1,idx),Me(idx,idx));
    end
    
    % Compensators this loop depends on
    cList = find(keep(1:nC));
    
    % Internal Delays this loop depends on
    idList = find(keep(nC+1:nC+nID));
    
    % States this loop depends on
    xkeep = find(keep(nC+nID+1:end));
    
    iokeep = [1 ; 1+cList; 1+nC+idList];
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

