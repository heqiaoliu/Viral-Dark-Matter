classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) ridgenet < idnlfun
    %RIDGENET Abstract class implementing general ridge-type nonlinearity estimators.
    %  A ridge function is a linear combination of multiple variables
    %  followed by a scalar nonlinear function. A ridge-type nonlinearity
    %  estimator is in the form of a sum of ridge functions. Such
    %  estimators are used in Nonlinear ARX models and Hammerstein-Wiener
    %  models. Concrete  implementations of ridge-type nonlinearity
    %  estimators are available as subclasses of RIDGENET. These
    %  include SIGMOIDNET and CUSTOMNET.  Type "help customnet",
    %  "idprops customnet" etc to learn more about them. Type "idprops
    %  idnlestimators" to view a summary of characteristics of all
    %  available nonlinearity estimators (ridge-type and others).
    %
    %   See also CUSTOMNET, SIGMOIDNET, IDNLARX, IDNLHW, EVALUATE, NLARX,
    %   NLHW.
    
    % Copyright 2006-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.10 $ $Date: 2008/10/02 18:55:20 $
    
    % Author(s): Qinghua Zhang
    
    properties(Dependent=true)
        NumberOfUnits
        LinearTerm
        Parameters
    end
    
    properties(Hidden = true)
        prvNumberOfUnits = 10;
        prvLinearTerm = 'on';
        prvParameters = pstructure([]);
    end
    
    methods (Access = 'protected')
        function this = ridgenet(varargin)
            command = class(this);
            ni = nargin;
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax',command,command)
            end
            proplist = {'NumberOfUnits', 'LinearTerm', 'Parameters'};
            pn = '';
            for ka=1:2:ni
                prop = strtrim(varargin{ka});
                prop = strchoice(proplist,  prop);
                if isempty(prop)
                    ctrlMsgUtils.error('Ident:general:invalidProperty',varargin{ka},upper(command))
                end
                if strcmpi(prop,'parameters')
                    pn = 'Parameters';
                    pv = varargin{ka+1};
                    continue;
                end
                this.(prop) = varargin{ka+1};
            end
            if ~isempty(pn)
                this.(pn) = pv;
            end
        end
        %------------------------------------------------------------------
    end
    
    methods
        function value = get.NumberOfUnits(this)
            value = this.prvNumberOfUnits;
        end
        %--------------------------------------------------------------
        function this = set.NumberOfUnits(this,value)
            
            if ~isnonnegintscalar(value)
                ctrlMsgUtils.error('Ident:general:positiveIntPropVal','NumberOfUnits')
            end
            this.prvNumberOfUnits = value;
            this.Parameters = []; % Clear Parameters which is no longuer valid
        end
        
        %------------------------------------------------------------------
        function value = get.LinearTerm(this)
            value = this.prvLinearTerm;
        end
        %--------------------------------------------------------------
        function this = set.LinearTerm(this,value)
            
            [value, msg] = strchoice({'on','off'}, value, 'LinearTerm');
            error(msg)
            this.prvLinearTerm = value;
            this.Parameters = []; % Clear Parameters which is no longer valid
        end
        
        %------------------------------------------------------------------
        function value = get.Parameters(this)
            value = this.prvParameters;
        end
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            
            [value, msg] = pstructure(value);
            if ~isempty(msg)
                msg = pmessage(this, msg);
                error(msg) %msg structure
            end
            this.prvParameters = value;
        end
        
    end %methods
end %class

% FILE END