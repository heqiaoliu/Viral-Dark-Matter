classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) saturation < idnlfun
    %SATURATION: Saturation nonlinearity estimator object constructor.
    %
    %   S = SATURATION
    %       Create a default saturation nonlinearity object.
    %
    %   S = SATURATION([a,b])
    %   S = SATURATION('LinearInterval',[a,b])
    %       Create a saturation nonlinearity object with its linear interval
    %       defined by the 2-element row vector [a,b]. To remove the lower
    %       saturation limit, set a to -Inf. Similarly, to remove the upper
    %       limit use b = Inf.
    %
    %   S describes a function y = F(x), where y and x are scalars.
    %   F(x) = x for a<=x<b,  F(x) = a for a>x, and F(x) = b for b<=x. The
    %   value F(x) is computed by using the "evaluate" command, as in:
    %   Values = evaluate(S,x).
    %
    %   Typical use in NLHW: model = NLHW(Data,Orders,saturation([-1 1]),[])
    %   The saturation will the be initialized by the interval [-1 1], which
    %   is adjusted to data by NLHW.
    %
    %   The default value of LinearInterval is [NaN NaN], which means that
    %   the initial value of [a b] should be determined from the estimation
    %   data range.
    %
    %   Type "idprops saturation" for more information.
    %
    %   See also NLHW, EVALUATE, DEADZONE, PWLINEAR, POLY1D.
    
    
    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:55:30 $
    
    % Author(s): Qinghua Zhang
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE
    
    properties(Hidden = true, SetAccess = 'protected')
        prvParameters = struct('Interval',[NaN, NaN], 'Center',[], 'Scale',[]);
    end
    
    properties(Dependent=true,Hidden = true)
        Parameters % synonymous of LinearInterval
    end
    
    properties(Dependent=true)
        LinearInterval
    end
    
    properties(Hidden = true)
        Fixed
    end
    
    methods
        function this = saturation(lininterval, arg2)
            ni = nargin;
            error(nargchk(0,2, ni,'struct'))
            if ni==0
                lininterval = [];
            elseif ni==2
                if ischar(lininterval) && ~isempty(strmatch(lower(strtrim(lininterval)), 'linearinterval'))
                    lininterval = arg2;
                else
                    ctrlMsgUtils.error('Ident:general:InvalidSyntax','saturation','saturation')
                end
            end
            
            this.LinearInterval = lininterval;
        end
        
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            this.LinearInterval = value;
        end
        
        %--------------------------------------------------------------
        function value = get.Parameters(this)
            value = this.LinearInterval;
        end
        
        %--------------------------------------------------------------
        function this = set.LinearInterval(this,value)
            if isempty(value)
                this.prvParameters = struct('Interval',[NaN, NaN], 'Center',[], 'Scale',[]);
                return
            end
            
            if ~(isrealvec(value) && length(value)==2)
                ctrlMsgUtils.error('Ident:idnlfun:invalidLinearInterval1')
            end
            
            if all(isfinite(value))
                param.Interval = [];
                param.Center = mean(value);
                param.Scale = 0.5*abs(value(2)-value(1));
            else
                if isinf(value(1)) && value(1)>0
                    ctrlMsgUtils.error('Ident:idnlfun:invalidLinearInterval2')
                end
                if isinf(value(2)) && value(2)<0
                    ctrlMsgUtils.error('Ident:idnlfun:invalidLinearInterval3')
                end
                
                param.Interval = value;
                param.Center = [];
                param.Scale = [];
            end
            this.prvParameters = param;
            
        end
        %--------------------------------------------------------------
        function value = get.LinearInterval(this)
            param = this.prvParameters;
            if isempty(param.Interval)
                value = [(param.Center-abs(param.Scale)), (param.Center+abs(param.Scale))];
            else
                value = param.Interval;
            end
        end
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            bp = this.LinearInterval;
            if isempty(bp)
                str = 'Saturation with unspecified linear interval';
            else
                str = sprintf('Saturation');
            end
        end
    end
end

% FILE END