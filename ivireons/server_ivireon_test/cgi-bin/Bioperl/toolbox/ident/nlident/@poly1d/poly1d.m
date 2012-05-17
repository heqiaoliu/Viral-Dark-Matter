classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) poly1d < idnlfun
    %POLY1D one-dimensional polynomial estimator object constructor.
    % Usage:
    %   P = POLY1D(n)
    %   P = POLY1D('Degree',n)
    %   P = POLY1D('Coefficients',c)
    %
    %   n: the degree of the polynomial, a positive integer (default n=1).
    %   c: the polynomial coefficients, a 1-by-(n+1) real vector.
    %
    % Description:
    %   P is a nonlinearity object, describing the polynomial function
    %   F(x)= c(1)*x^n + c(2)*x^(n-1) + ... + c(n)*x + c(n+1)
    %
    %   The POLY1D object has two properties, 'Degree' and 'Coefficients' which
    %   can be set with the POLY1D constructor function arguments as shown
    %   above. They can also be get and set by subreferencing, like P.deg = n
    %   where 'deg' is an abbreviation  of 'Degree'. POLY1D is typically used
    %   as a nonlinearity estimator in Hammerstein-Wiener models.
    %
    %   Typical use in NLHW: m = NLHW(Data,Orders,poly1d('deg',3), []).
    %
    %   The value F(x) is computed by evaluate(P,x). Type "idprops poly1d"
    %   for more information on POLY1D object.
    %
    % See also NLHW, EVALUATE, SATURATION, DEADZONE, UNITGAIN, PWLINEAR,
    % WAVENET, SIGMOIDNET.
    
    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.6.6 $ $Date: 2008/10/02 18:55:01 $
    
    % Author(s): Qinghua Zhang
    
    properties(Hidden = true)
        prvDegree = 1;
        prvCoefficients
    end
    
    properties(Dependent=true)
        Degree
        Coefficients
    end
    
    properties(Dependent=true, Hidden = true)
        Parameters % synonym of BreakPoints
    end
    
    methods
        function this = poly1d(varargin)
            ni = nargin;
            
            % Handle the case this=poly1d(Degree)
            if ni==1 && isnonnegintscalar(varargin{1})
                this.Degree = varargin{1};
                return % Quick exit
            end
            
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax','poly1d','poly1d')
            end
            
            % Autofill of input arguments
            degreeka = 0;
            coefka = 0;
            for ka=1:2:ni
                prop = pnmatch(strtrim(varargin{ka}), {'Degree', 'Coefficients'});
                if strcmp(prop, 'Degree')
                    if degreeka>0
                        ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','Degree')
                    end
                    degreeka = ka;
                else
                    if coefka>0
                        ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','Coefficients')
                    end
                    coefka = ka;
                end
            end
            
            if degreeka>0
                this.Degree = varargin{degreeka+1};
            end
            %Note: Coefficients must be assigned after Degree
            if coefka>0
                this.Coefficients = varargin{coefka+1};
            end
            
            if degreeka>0 && coefka>0
                ctrlMsgUtils.warning('Ident:idnlfun:poly1dDegCoeffSpec')
            end
        end
        
        %--------------------------------------------------------------
        function this = set.Degree(this,value)
            
            if ~isnonnegintscalar(value)
                ctrlMsgUtils.error('Ident:general:positiveIntPropVal','Degree')
            end
            
            if isequal(value,this.prvDegree)
                return;
            end
            
            this.prvDegree = value;
            this.prvCoefficients = [];   % Clear Coefficients value which is no longer valid
        end
        %--------------------------------------------------------------
        function value = get.Degree(this)
            value = this.prvDegree;
        end
        
        %-------------------------------------------------------------
        function this = set.Coefficients(this,value)
            
            if isempty(value)
                this.prvCoefficients = [];
                return % Keep this.Degree unchanged.
            end
            
            if ~(isrealvec(value) && all(isfinite(value(:))))
                ctrlMsgUtils.error('Ident:idnlfun:poly1dInvalidCoefficients')
            end
            
            this.prvCoefficients = value(:)';
            this.prvDegree = length(value)-1;
        end
        %---------------------------------------------
        function value = get.Coefficients(this)
            
            value = this.prvCoefficients; %Stored assigned value
        end
        
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            this.Coefficients = value; % synonym of  Coefficients
        end
        
        %--------------------------------------------------------------
        function value = get.Parameters(this)
            value = this.Coefficients; % synonym of Coefficients
        end
        
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            str = sprintf('One-dimensional polynomial estimator of degree %d.',this.Degree);
        end
        
    end
end

% FILE END