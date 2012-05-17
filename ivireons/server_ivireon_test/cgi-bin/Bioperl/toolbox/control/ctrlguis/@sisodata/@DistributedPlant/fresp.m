function h = fresp(this,w,Input,Output,SimFlag,idxM)
% Plant frequency response.
% 
% The index vectors INPUT and OUPT select the desired external 
% inputs and outputs.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/04/11 20:29:48 $

if nargin < 6
    idxM = this.getNominalModelIndex;
end

nw = length(w);
nG = length(this.G);
nC = this.nLoop;
if nargin==4 || all(this.LoopStatus)
   IC = this.Connectivity;
else
   % Frequency response for closed-loop analysis
   IC = this.loopIC(this.Configuration,this.LoopSign.*this.LoopStatus);
end

% Extract appropriate IC submatrix with 
%   1) fixed G's at the top
%   2) Selected I/Os in the middle
%   2) tuned C's at the bottom
[rs,cs] = size(IC);
indrow = [1:nG nG+Output rs-nC+1:rs];
indcol = [1:nG nG+Input cs-nC+1:cs];
IC = IC(indrow,indcol);

% Response of fixed components
F = zeros(nw,nG);
for ct=1:nG,
    if length(this.G(ct).ModelData) == 1
        GModelData = this.G(ct).ModelData;
    else
        GModelData = this.G(ct).ModelData(idxM);
    end
    fh = fresp(GModelData,w);
    F(:,ct) = fh(:);
end

% Desired plant response
[rs,cs] = size(IC);
h = zeros(rs-nG,cs-nG,nw);
for ctw=1:nw
   hw = IC;
   % Close upper loops around fixed components
   Fw = F(ctw,:);
   for ct=1:nG
      hw(ct+1:rs,ct+1:cs) = hw(ct+1:rs,ct+1:cs) + ...
         (hw(ct+1:rs,ct) * (Fw(ct)/(1-hw(ct,ct)*Fw(ct)))) * hw(ct,ct+1:cs);
   end
   h(:,:,ctw) = hw(nG+1:rs,nG+1:cs);
end
