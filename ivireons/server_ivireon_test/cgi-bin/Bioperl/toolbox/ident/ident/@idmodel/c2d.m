function [thd,G] = c2d(thc,T,varargin)
%C2D  Converts a continuous time model to discrete time.
%   MD = C2D(MC,T,METHOD)
%
%   MC: The continuous time model as an IDMODEL object.
%
%   T: The sampling interval
%   MD: The discrete time model, an IDMODEL model object.
%   METHOD: 'zoh' (default) or 'foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewise linear).
%
%   IDPOLY models are returned as IDPOLY.
%   IDSS models are returned as IDSS, but the 'Structured' parameterization
%        is changed to 'Free'.
%   IDGREY models are returned as IDGREY if 'CDmfile' == 'cd', otherwise as IDSS.
%   IDPROC models are returned as IDGREY.
%
%   InputDelay in MC is carried over to MD.
%
%   [MD,G] = C2D(MC,T,METHOD) also returns a matrix G that transforms the
%   initial state X0 according to X0d = G * [X0c;u(0)], where u(0) is the input
%   at time 0 and X0c is the continuous time state at time 0. For IDPROC models
%   the state variables correspond to those of IDGREY(THC).
%
%   For IDPOLY models, the covariance matrix P of MC is translated by the
%   use of numerical derivatives. The step sizes used for the differences are
%   given by the MATLAB file NUDERST.M. For IDSS, IDPROC and IDGREY models,
%   the covariance matrix is not translated, but covariance information
%   about the input-output properties are included.
%
%   To inhibit the translation of covariance information (which may take
%   some time), use C2D(MC,T,Method,'CovarianceMatrix','None'). (Any abbreviations
%   will do.) (The same effect is obtained by first doing SET(MC,'Cov','No').)
%
%   If you have Control System Toolbox, the third input METHOD can also be
%   set to 'tustin', or 'matched'. With these options, the transformation
%   is performed using the corresponding method from Control System
%   Toolbox. See HELP LTI/C2D for more information.
%
%   NOTE: The covariance information is not transformed when one of these
%   options is used.
%
%   See also IDMODEL/D2C, LTI/C2D.

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.12.4.14 $  $Date: 2010/03/22 03:48:49 $

error(nargchk(2,Inf,nargin,'struct'))
usecstb = 0;
method = 'zoh';
if ~isa(T,'double') || T<=0
    ctrlMsgUtils.error('Ident:transformation:c2dCheck1')
end

V = varargin;
varg = {};
if ~isempty(V)
    val  = {'tustin','prewarp','matched','zoh','foh'};
    Ind = strncmpi(V{1},val,length(method));
    if ~any(Ind)
        ctrlMsgUtils.error('Ident:transformation:c2dCheck2')
    else
        method = val{Ind};
        V = V(2:end);
        if ~any(strcmp(method,{'zoh','foh'}))
            usecstb = 1;
        end
    end
    
    if usecstb && strcmp(method, 'prewarp')
        if isempty(V) || ~isa(V{1},'double') || ~isscalar(V{1})
            ctrlMsgUtils.error('Ident:transformation:prewarpCheck')
        else
            varg = V(1);
            V = V(2:end);
        end
    end
end

% Check for CovarianceMatrix
if ~isempty(V)
    if length(V)==2 && strncmpi(V{1},'covariancematrix',length(V{1})) &&...
            strncmpi(V{2},'none',length(V{2}))
        thc =  pvset(thc,'CovarianceMatrix','None');
    else
        ctrlMsgUtils.error('Ident:transformation:c2dCheck4')
    end
end

if usecstb
    if ~iscstbinstalled
        ctrlMsgUtils.error('Ident:transformation:c2dCstbRequired',method);
    end
    was = ctrlMsgUtils.SuspendWarnings;
    ths = ss(thc);
    delete(was)

    [ths,G] = c2d(ths,T,method,varg{:});

    switch class(thc)
        case 'idpoly'
            thd = idpoly(ths);
            thd = pvset(thd,'BFFormat',pvget(thc,'BFFormat'));
        otherwise
            thd = idss(ths);
            stn = pvget(thd,'StateName');
            kk = strcmp(stn,'');
            if any(kk)
                ns = length(find(kk==0));
                stn = defnum(stn(1:ns),'xe',length(kk));
                thd = pvset(thd,'StateName',stn);
            end
    end
    thd = pvset(thd,'EstimationInfo',pvget(thc,'EstimationInfo'));
    return
end

try
    if nargout == 2
        if isa(thc,'idpoly')
            ctrlMsgUtils.warning('Ident:transformation:c2dCheck5')
        end
        [thd,G] = c2daux(thc,T,method);
    else
        thd = c2daux(thc,T,method);
    end
catch E
    throw(E)
end
