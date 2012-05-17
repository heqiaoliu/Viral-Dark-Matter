classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) idnlfun 
    %IDNLFUN Abstract class for representing nonlinearity estimators.
    %   IDNLFUN represents the set of nonlinearity estimator objects used
    %   for creation and estimation of nonlinear black box models -
    %   Nonlinear ARX model and Hammerstein-Wiener model. Concrete
    %   implementations of various nonlinearity estimators are available as
    %   subclasses of IDNLFUN. These include: wavenet, treepartition,
    %   sigmoidnet, neuralnet, pwlinear, poly1d, deadzone, saturation,
    %   linear, unitgain and customnet.
    %
    %   Type "help wavenet", "idprops wavenet" etc to learn more about
    %   individual nonlinearities. Type "idprops idnlestimators" to view a
    %   summary of characteristics of these estimators.
    %   
    %   See also WAVENET, TREEPARTITION, CUSTOMNET, NEURALNET, SIGMOIDNET,
    %   SATURATION, DEADZONE, POLY1D, PWLINEAR, UNITGAIN, LINEAR, IDNLARX,
    %   IDNLHW, EVALUATE, NLARX, NLHW.

    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.11 $ $Date: 2008/12/04 22:34:43 $

    % Author(s): Qinghua Zhang, Rajiv Singh.
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE

    properties (Hidden = true)
        OptimMessenger = []; % GUI use 
        RegressorRange
    end

    properties (SetAccess = 'protected', GetAccess = 'protected', Hidden = true)
        NonlinearRegressors = 'all';
        Utility
    end

    properties(Hidden = true, GetAccess='protected')
        Version; %was 1.0 before R2008a
    end

    methods (Access = 'protected')
        function this = idnlfun(varargin)
            this.Version = idutils.ver;
        end

    end %methods

    methods (Access = 'public')
        % required to support recent MCOS changes that query SIZE for
        % isscalar/isvector, unless those methods are overloaded

        %------------------------------------------------------
        function status = isscalar(varargin)
            status = true;
        end
        
        %------------------------------------------------------
        function status = isvector(varargin)
            status = true;
        end

    end

    methods (Access = 'protected', Static = true)
        function P = getListOfVisibleProperties(m,varargin)

            p = m.Properties;
            pval = cellpvget(p, 'Hidden');
            pmark = [pval{:}];
            P = cellpvget(p(~pmark), 'Name');

            %call superclasses
            S = m.SuperClasses;
            for k = 1:length(S)
                Name = S{k}.Name;
                Sp = eval([Name,'.getListOfVisibleProperties(S{k});']);
                P = {P{:},Sp{:}};
            end
        end
    end %static methods

    methods (Abstract = true)
        % compute and return analytical Jacobians
        %function S = getSensitivity(this,varargin)
    end %abstract methods
end %class

% FILE END