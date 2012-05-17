function [N,ny,nu,ne]=sizedat(dat,dim)
% SIZEDAT  Size of IDDATA and IDFRD data sets
%
% [N,NY,NU,NE] = SIZEDAT(DAT)
%     Returns the number of data (N), the number of outputs (NY),
%     the number of inputs (NU), and the number of exeriments (NE).
%     For multiple expriments, N is a row vector, containing the number
%     of data in each experiment.
%
%     Nn = SIZE(DAT) returns Nn = [N,Ny,Nu] for single experiments and
%          Nn = [sum(N),Ny,Nu,Ne] for multiple experiments.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2008/10/02 18:52:00 $

if isa(dat,'iddata')
    [N,ny,nu,ne] = size(dat);
elseif isa(dat,'idfrd')
    [ny,nu,N] = size(dat);
    ne = 1;
else
    ctrlMsgUtils.error('Ident:utility:sizedat1')
end
if nargout==1
    N = sum(N);
end