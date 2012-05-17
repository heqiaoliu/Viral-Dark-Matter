classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) customnet < ridgenet
    %CUSTOMNET Creates a nonlinearity estimator object with a user-defined unit function.
    %
    %   C = CUSTOMNET(H, PVpairs)
    %
    %   H: user defined function handle of the unit function of the custom net.
    %   H must point to a function of the form [f, g, a] = function_name(x)
    %   where f is the value of the function, g=df/dx and a indicates the unit
    %   function active range (g is significantly non zero in the interval [-a a]).
    %   This function must be "vectorized": for a vector or matrix x, the output
    %   arguments f and g must have the same size as x, computed
    %   element-by-element.
    %
    %   PVpairs: Optional Property/Value pairs of the object. See "idprops
    %   customnet" for more information on applicable properties.
    %
    %   The CUSTOMNET object defines a nonlinear function y = F(x), where y
    %   is scalar and x an m-dimensional row vector. It is based on
    %   function expansion, with a
    %   possible linear term:
    %
    %   F(x) = (x-r)*P*L + a_1 f((x-r)*Q*b_1+c_1) + ...
    %           ... + a_n f((x-r)*Q*b_n+c_n) + d
    %
    %   where f is the unit function defined with the function handle H.
    %
    %   The most important property to set is NumberOfUnits (default 10),
    %   assigned as in: C = CUSTOMNET(H,'Num',10).
    %
    %   For other properties and notations used in F(x), see "idprops
    %   customnet".
    %
    %   The value of the function defined by C is computed by evaluate(C,x).
    %
    %   The typical use of CUSTOMNET is in NLARX and NLHW as in
    %   h = @gaussunit;
    %       model1 = NLARX(Data, Orders, customnet(h,'num',5)); % Nonlinear ARX model estimation
    %       model2 = NLHW(Data, Orders, customnet(h), []);      % Hammerstein-Wiener model estimation
    %   where an example of unit function defined in the file gaussunit.m is
    %   used. Type "edit gaussunit" to view this example file.
    %
    %   See also NLARX, NLHW, EVALUATE, GETREG, SIGMOIDNET, WAVENET,
    %   NEURALNET, TREEPARTITION, PWLINEAR, POLY1D, SATURATION, DEADZONE.
    
    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:52:37 $
    
    % Author(s): Qinghua Zhang
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE
    
    properties
        UnitFcn;
    end
    
    methods
        function this = customnet(ufcn, varargin)
            this = this@ridgenet(varargin{:});
            ni = nargin;
            
            if ni>0
                if ~isa(ufcn, 'function_handle')
                    ctrlMsgUtils.error('Ident:idnlfun:customnet1')
                end
                
                this.UnitFcn = ufcn;
                
                if rem(ni-1, 2)
                    ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs','CUSTOMNET','customnet')
                end
            end
        end
        
        %--------------------------------------------------------------
        function this = set.UnitFcn(this,ufcn)
            
            if ~isa(ufcn,'function_handle')
                ctrlMsgUtils.error('Ident:idnlfun:invalidUnitFcn1')
            end
            
            No = nargout(ufcn);
            if No>=0 && No~=3
                ctrlMsgUtils.error('Ident:idnlfun:invalidUnitFcn2',func2str(ufcn));
            end
            this.UnitFcn = ufcn;
        end
        
        
        
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            nt = this.NumberOfUnits;
            unitf = this.UnitFcn;
            if isempty(unitf)
                unitf = 'unspecified';
            else
                unitf = func2str(unitf);
            end
            str = sprintf('Custom Network with %d units and ''%s'' unit function',nt,unitf);
        end
        
    end %methods
end

% FILE END