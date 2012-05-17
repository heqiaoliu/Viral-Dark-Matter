classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) linear < idnlfun
    %LINEAR Create linear nonlinearity estimator object.
    %
    % Usage:
    %   LIN = LINEAR
    %     Create a linear nonlinearity estimator with unknown parameters.
    %
    %   LIN = LINEAR('Parameters',Par)
    %     Create a linear nonlinearity estimator with its Parameters property
    %     set to Par. Par is a structure with fields LinearCoef (an m-by-1
    %     vector L) and OutputOffset (a scalar d). Type "idprops linear"
    %     for more information on the properties.
    %
    % Description:
    %   LIN is a nonlinearity object that describes a function that is a
    %   linear (affine) y = F(x), where y is scalar and x an m-dimensional
    %   row vector: F(x) = x*L + d. LIN is an object with the sole Property
    %   'Parameters'.
    %
    %   The value F(x) is computed by using the "evaluate" command, as in
    %   Value = evaluate(LIN,x);
    %
    %   The use of the LINEAR ''Nonlinearity'' in IDNLARX is to create
    %   nonlinear models that are linear in the regressors. The regressors
    %   themselves could could be a nonlinear function of inputs and outputs
    %   (see CUSTOMREG). LINEAR nonlinearity is used to indicate absence of
    %   the static nonlinearity function in IDNLARX models. When the IDNLARX
    %   model has no custom regressors and the nonlinearity is set to LINEAR,
    %   then the model becomes similar to a linear ARX model, except that it
    %   is also able to estimate the affine term (offset). An IDNLARX model
    %   with custom regressors and LINEAR nonlinearity represent the simplest
    %   nonlinear models where nonlinearity is confined to model regressors.
    %
    %   Example usage:
    %   m = NLARX(Data,Orders,linear,'custom',{'y1(t-1)*u1(t-2)'})
    %
    %   See also NLARX, UNITGAIN, GETREG, CUSTOMREG, EVALUATE,
    %   TREEPARTITION, WAVENET, SIGMOIDNET, NEURALNET.
    
    % Copyright 2006-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:54:41 $
    
    % Author(s): Qinghua Zhang
    
    properties
        Parameters = pstructure([]);;
    end
    
    methods
        function this = linear(varargin)
            ni = nargin;
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax','linear','linear')
            end
            
            % Note: this is to support autofil in the treepartition constructor's arguments
            % It may become useless when MCOS support automatically autofil
            proplist = {'Parameters'};
            for ka=1:2:ni
                prop = strtrim(varargin{ka});
                prop = strchoice(proplist,  prop);
                if isempty(prop)
                    ctrlMsgUtils.error('Ident:general:invalidProperty',varargin{ka},'LINEAR')
                end
                this.(prop) = varargin{ka+1};
            end
        end
        
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            [value, msg] = pstructure(value);
            if ~isempty(msg)
                msg = pmessage(this, msg);
                error(msg) %msg structure
            end
            this.Parameters = value;
        end
        
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            str = 'None';
        end
        
    end %methods
end %class

% FILE END
