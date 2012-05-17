classdef  ( CaseInsensitiveProperties = true, TruncatedProperties = true ) sigmoidnet < ridgenet
    %SIGMOIDNET creates a sigmoid network nonlinearity estimator object.
    %
    %   S = SIGMOIDNET(PVpairs)
    %
    %   creates a sigmoidnet object, where PVpairs are Property/Value pairs
    %   of the object. S defines a nonlinear function y = F(x), where y is
    %   scalar and x an m-dimensional row vector. It is based on function
    %   expansion, with a possible linear term:
    %
    %   F(x) = (x-r)*P*L + a_1 f((x-r)*Q*b_1+c_1) + ...
    %   ... + a_n f((x-r)*Q*b_n+c_n) + d,
    %
    %   where f is the sigmoid function f(z) = 1/(exp(-z)+1).
    %
    %   The most important property is n, the NumberOfUnits (default 10), set
    %   as in:
    %         S = SIGMOIDNET('Number',10).
    %   For other properties and their value see "idprops sigmoidnet".
    %   The value of the function defined by S is computed by evaluate(S,x).
    %
    %   SIGMOIDNET can be used as a nonlinearity estimator for both Nonlinear
    %   ARX and Hammerstein-Wiener models. For example, in order to estimate
    %   a Nonlinear ARX model using sigmoidnet estimator, use NLARX as follows:
    %         Model = NLARX(Data, Orders, sigmoidnet('num',5)); % (sigmoid network with 5 units)
    %
    %   Type "idprops idnlestimators" for more information on various
    %   nonlinearity estimators and their properties.
    %
    %   See also nlarx, nlhw, idnlfun/evaluate, idprops.
    
    % Copyright 2005-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.9 $ $Date: 2010/05/10 17:17:54 $
    
    % Author(s): Qinghua Zhang
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE
    
    methods
        function this = sigmoidnet(varargin)
            ni = nargin;
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax','sigmoidnet','sigmoidnet') 
            end
            this = this@ridgenet(varargin{:});
        end
        
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            nt = this.NumberOfUnits;
            str = sprintf('Sigmoid network with %d units',nt);
        end
        
    end % methods
end

% FILE END