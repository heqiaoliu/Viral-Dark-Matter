classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) deadzone < idnlfun
    %DEADZONE: Deadzone nonlinearity estimator object constructor.
    %
    %   D = DEADZONE 
    %       Create a default dead zone nonlinearity object.
    %
    %   D = DEADZONE([a,b])
    %   D = DEADZONE('ZeroInterval',[a,b])
    %       Create a dead zone nonlinearity object with its zero interval
    %       defined by the 2-element row vector [a, b].  
    %
    %   D describes a function y = F(x), where y and x are scalars.
    %   F(x) = 0 for a<=x<b,  F(x) = x-a for x<a, and F(x) = x-b for
    %   x>=b. The value F(x) is computed by using the "evaluate" command,
    %   as in:  Values = evaluate(D,x).
    %
    %   Typical use in NLHW: model = NLHW(Data,Orders,deadzone([-1 1]),[])
    %   The deadzone will be initialized by the interval [-1 1], which
    %   is adjusted to data by NLHW.
    %
    %   The default value of ZeroInterval is [NaN NaN], which means that
    %   the initial value of [a b] should be determined from the estimation
    %   data range. 
    %  
    %   Type "idprops deadzone" for more information.
    %
    %   See also NLHW, EVALUATE, SATURATION, PWLINEAR, POLY1D.
    
    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:52:45 $
    
    % Author(s): Qinghua Zhang
    
    properties(Hidden = true)
        prvParameters = struct('Interval',[NaN, NaN], 'Center',[], 'Scale',[]);
    end
    
    properties(Dependent=true,Hidden = true)
        Parameters
    end
    
    properties(Dependent=true)
        ZeroInterval
    end
    
    properties(Hidden = true)
        Fixed
    end
    
    methods
        function this = deadzone(zerointerval, arg2)
            ni = nargin;
            error(nargchk(0,2, ni,'struct'))
            if ni==0
                zerointerval = [];
            elseif ni==2
                if ischar(zerointerval) && ~isempty(strmatch(lower(strtrim(zerointerval)), 'zerointerval'))
                    zerointerval = arg2;
                else
                    ctrlMsgUtils.error('Ident:general:InvalidSyntax','deadzone','deadzone')
                end
            end
            
            this.ZeroInterval = zerointerval;
        end
        
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            this.ZeroInterval = value;
        end
        
        %--------------------------------------------------------------
        function value = get.Parameters(this)
            value = this.ZeroInterval;
        end
        
        %--------------------------------------------------------------
        function this = set.ZeroInterval(this,value)
            if isempty(value)
                this.prvParameters = struct('Interval',[NaN, NaN], 'Center',[], 'Scale',[]);
                return
            end
            
            if isrealvec(value) && length(value)==2
                value = value(:)';
            else
                ctrlMsgUtils.error('Ident:idnlfun:invalidZeroInterval1')
            end
            
            if all(isfinite(value))
                param.Interval = [];
                param.Center = mean(value);
                param.Scale = 0.5*abs(value(2)-value(1));
            else
                if isinf(value(1)) && value(1)>0
                    ctrlMsgUtils.error('Ident:idnlfun:invalidZeroInterval2')
                end
                if isinf(value(2)) && value(2)<0
                    ctrlMsgUtils.error('Ident:idnlfun:invalidZeroInterval3')
                end
                param.Interval = value;
                param.Center = [];
                param.Scale = [];
            end
            this.prvParameters = param;
        end
        %--------------------------------------------------------------
        function value = get.ZeroInterval(this)
            param = this.prvParameters;
            if isempty(param.Interval)
                value = [(param.Center-abs(param.Scale)), (param.Center+abs(param.Scale))];
            else
                value = param.Interval;
            end
        end
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            bp = this.ZeroInterval;
            if isempty(bp)
                str = 'Deadzone with unspecified zero interval';
            else
                str = sprintf('Deadzone');
            end
        end
    end
end

% FILE END