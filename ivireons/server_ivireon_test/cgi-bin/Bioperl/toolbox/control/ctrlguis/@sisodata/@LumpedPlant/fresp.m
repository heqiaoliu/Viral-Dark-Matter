function h = fresp(this,w,Input,Output,~,idxM)
% Plant frequency response.
% 
% The index vectors INPUT and OUPT select the desired external 
% inputs and outputs.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:29:50 $

if nargin < 6
    idxM = this.getNominalModelIndex;
end

[ny,nu] = iosize(this.P);
nC = this.nLoop;
% Select plant I/Os of interest
indrow = [Output ny-nC+1:ny];
indcol = [Input nu-nC+1:nu];
h = fresp(getsubsys(this.Pfr(:,:,idxM),indrow,indcol),w);