function [th1,xi] = merge(varargin)
%MERGE Merge two models.
%
%   M = merge(M1,M2,M3,...)
%
%   The models Mi must be of the same model structure.
%   M is the statistical average of Mi and delivered in
%   the same format.
%
%   When two models are merged
%   [M, xi] = merge(M1,M2)  returns a test variable xi.
%   It is chi^2 distributed with  n = dim(Mi.ParameterVector) degrees
%   of freedom if the parameters of M1 and M2 have the same means.
%   A large value of xi thus indicates that it might be questionable
%   to merge the models.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.6 $ $Date: 2009/12/05 02:03:05 $

th1 = varargin{1};
ut1 = pvget(th1,'Utility');

switch class(th1)
    case 'idgrey'
    case 'idpoly'
        CellFormat = pvget(th1,'BFFormat');
    case 'idarx'
    case 'idss'
        if strcmp(pvget(th1,'SSParameterization'),'Free')
            if isfield(ut1,'Pmodel')
                th = ut1.Pmodel;
            else
                th = [];
            end
            if isempty(th)
                th1 = pvset(th1,'SSParameterization','Canonical');
            else
                th1 = th;
            end
        end
end

if isfield(ut1,'Idpoly')
    polymod1 = ut1.Idpoly;
else
    polymod1 = [];
end

for kj = 2:length(varargin)
    th2 = varargin{kj};
    ut2 = pvget(th2,'Utility');
    if isa(th2,'idpoly')
        CellFormat = max(CellFormat,pvget(th2,'BFFormat')); % double>cell>unspecified
    end
    if isa(th2,'idss') && strcmpi(pvget(th2,'SSParameterization'),'Free')
        if isfield(ut2,'Pmodel')
            th = ut2.Pmodel;
        else
            th = [];
        end
        if isempty(th)
            th2 = pvset(th2,'SSParameterization','Canonical');
        else
            th2 = th;
        end
    end
    
    if isfield(ut2,'Idpoly')
        polymod2 = ut2.Idpoly;
    else
        polymod2 = [];
    end
    % end
    %{
    if isa(th2,'idss')
        th2 = pvset(th2,'InitialState','z');
    end
    %}
    errFlag = samstruc(th2,th1);
    if ~isempty(errFlag.message), error(errFlag), end
    p1 = th1.ParameterVector;
    p2 = th2.ParameterVector;
    P1 = th1.CovarianceMatrix;
    P2 = th2.CovarianceMatrix;
    if ischar(P1) || ischar(P2) || norm(P1,1)==0 || norm(P2,1)==0
        ctrlMsgUtils.error('Ident:transformation:mergeWithNoCovar')
    end
    
    if length(p1)~=length(p2)
        ctrlMsgUtils.error('Ident:transformation:mergeModelOrderMismatch')
    end
    iP1 = inv(P1); iP2 = inv(P2);
    if length(iP1)~=length(iP2) % This could happen depending on initial
        % conditions
        mi = min(length(iP1),length(iP2));
        iP1 = iP1(1:mi,1:mi);
        iP2 = iP2(1:mi,1:mi);
    end
    P = inv(iP1+iP2);
    th1.CovarianceMatrix = P;
    th1.ParameterVector = (iP1+iP2)\(iP1*p1+iP2*p2);
    testvar = (p1-p2)'/(inv(iP1)+inv(iP2))*(p1-p2)/length(p1);
    if testvar>4 && nargout<2
        ctrlMsgUtils.warning('Ident:transformation:mergeCovDiff')
    end
    xi = testvar*length(p1);
    if ~isempty(polymod1) && ~isempty(polymod2)
        for kk = 1:length(polymod1)
            polymod1{kk} = merge(polymod1{kk},polymod2{kk});
        end
    else
        polymod1 = [];
    end
    ut1.Idpoly = polymod1;
    th1.Utility = ut1;
end

% update compatibility flag
if isa(th1,'idpoly')
    th1 = pvset(th1,'BFFormat',CellFormat);
end
