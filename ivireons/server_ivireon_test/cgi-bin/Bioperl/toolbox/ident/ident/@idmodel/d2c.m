function thc = d2c(th,varargin)
%D2C  converts a model to continuous-time form.
%   MC = D2C(MD)
%
%   MD: A discrete time model given as an IDMODEL object.
%   MC: The continuous-time counterpart, an IDMODEL model object.
%
%   The translation is done using 'Zero-order-hold' or 'First-order-hold'
%   depending on the input intersample behaviour of the data for which
%   the model was estimated. (Property 'InterSample' of the IDDATA object,
%   recorded in the field 'DataInterSample' of MD.EstimationInfo).
%   For a non-estimated model, 'zoh' is used.
%
%   MC = D2C(MD, METHOD)
%   where METHOD = 'ZOH' or 'FOH' allows overriding the default
%   handling of the transformation method.
%
%   If the model MD has extra delays from some inputs (nk>1), these are
%   first removed and appended as 'InputDelay' (a pure dead-time) to MC.
%
%   IDPOLY models are returned as IDPOLY.
%   IDSS models are returned as IDSS, but the 'Structured' parameterization
%   is changed to 'Free'.
%   IDGREY models are returned as IDGREY if 'CDmfile' == 'cd', otherwise as
%   IDSS. IDARX models are returned as IDSS.
%
%   For IDPOLY models, the covariance matrix P of MD is translated by the
%   use of numerical derivatives. The step sizes used for the differences are
%   given by the file NUDERST.M.  For IDSS, IDARX and IDGREY models, the
%   covariance matrix is not translated, but covariance information about
%   the input-output properties are included.
%
%   To inhibit the translation of covariance information (which may take
%   some time), use D2C(MD,'CovarianceMatrix','None'). (Any abbreviations
%   will do.) (The same effect is obtained by first doing SET(MD,'Cov','No').)
%
%   To approximate the delays, rather than appending them as a dead-time, use
%   D2C(MD,'InputDelay',0). (Combine in any way with ('Cov','None').)
%
%   If you have Control System Toolbox, then the second input argument
%   (METHOD) can take additional values of 'tustin' or 'matched'. The
%   transformation will then use the corresponding algorithm from Control
%   System Toolbox. With these METHOD options, the covariance information
%   is not translated. See HELP SS/D2C for more information on these
%   transformation techniques.
%
%   CAUTION: The transformation could be ill-conditioned. Negative
%   real poles, poles at the origin and at 1 may cause problems.
%
%   See also IDMODEL/C2D, IDMODEL/D2D.

%   L. Ljung 10-1-86,4-20-87,8-27-94
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.7.4.12 $  $Date: 2010/03/22 03:48:50 $

speczof = 0;
inters = 'zoh';
if ~isempty(varargin)
    val = {'zoh','foh','tustin','prewarp','matched'};
    try
        [Value,status] = pnmatchd(lower(varargin{1}),val);
    catch
        Value = [];
    end
    if ~isempty(Value)
        if ~strcmpi(Value,'zoh')&&~strcmpi(Value,'foh')
            if ~iscstbinstalled
                ctrlMsgUtils.error('Ident:transformation:c2dCstbRequired',Value);
            end
            ths = ss(th);
            if strcmp(Value,'prewarp')
                if length(varargin)<2
                    ctrlMsgUtils.error('Ident:transformation:prewarpCheck')
                end
                ths = d2c(ths,'prewarp',varargin{2});
            else
                ths = d2c(ths,Value);
            end
            
            switch class(th)
                case 'idpoly'
                    thc = idpoly(ths);
                    thc = pvset(thc,'BFFormat',pvget(th,'BFFormat'));
                otherwise
                    thc = idss(ths);
            end
            thc = pvset(thc,'EstimationInfo',pvget(th,'EstimationInfo'));
            return
        else
            varargin = varargin(2:end); % remove zoh
            inters = Value;
            speczof = 1;
        end
    end
end
if ~speczof
    try
        es = pvget(th,'EstimationInfo');
        int = es.DataInterSample;
        if ~isempty(int)
            inters = int{1}; %why first value only?
        end
    end
end
try
    if ~isempty(varargin)
        thc = d2caux(th,inters,varargin{:});
    else
        thc = d2caux(th,inters);
    end
catch E
    throw(E)
end
