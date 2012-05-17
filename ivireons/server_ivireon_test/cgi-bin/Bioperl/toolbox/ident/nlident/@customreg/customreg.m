classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) customreg 
    %CUSTOMREG class constructor for representing custom regressors.
    %
    %   C = CUSTOMREG(Fcn,Arguments)
    %   C = CUSTOMREG(Fcn,Arguments,Delays,Vectorized)
    %
    %   Fcn: Function handle or string representing a function
    %   Arguments: A cell array of strings representing the names of model
    %     inputs or outputs, coinciding with strings in the InputName and
    %     OutputName properties the IDNLARX object holding the custom
    %     regressor. The size of Arguments must match the number of inputs
    %     Fcn accepts. 
    %   Delays: A vector of positive integers representing the delays of
    %     argument variables. The size of Delays must match the size of
    %     Arguments. (default: all ones).
    %   Vectorized: A flag, true/false, that indicates whether the Fcn is
    %     written so that it supports vectorized computations, when applied
    %     to vector arguments. (Default: False).
    %
    %   The returned C is an object with the above properties.
    %
    %   %   The regressor custom regressor object C may be added to an
    %   IDNLARX model in several ways:
    %   (a) Appended to the existing set of custom regressors of the model
    %       using ADDREG (model = addreg(model, R))
    %   (b) Set as the value of CustomRegressors property (model.CustomReg
    %       = R, model.CustomReg(end) = R(1) etc.)
    %   (c) Specified in the estimation command as a property-value pair
    %   (model = nlarx(data, orders, NL, 'custom', R)). 
    % 
    %   Example: Creating two custom regressors as an object array:
    %   cr1 = @(x,y) x*sin(y); cr2 = @(x) x^3;
    %   C = [customreg(cr1,{'u1' 'y1'},[1 3]),customreg(cr2,{'u1'},2)]
    %       This customreg object array can then be used NLARX as in:
    %   m = NLARX(Data,Orders,'wavenet', 'CustomRegressor', C);
    %
    %   Simple custom regressors can also be created using strings or cell
    %   array of strings when creating or estimating IDNLARX models. The above 
    %   example is equivalent to:
    %   m = NLARX(Data,Orders,'wavenet', 'CustomRegressors', ...
    %       {'u1(t-1)*sin(y1(t-3))', 'u1(t-2)^3'});
    %   These strings are automatically converted to CUSTOMREG objects so
    %   that m.CustomRegressors will return CUSTOMREG objects.
    %
    %   Type "idprops customreg", "idprops idnlarx customreg" for more
    %   information.
    %
    %   See also POLYREG, ADDREG, IDNLARX, GETREG, NLARX.
    
    % Copyright 2005-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.12 $ $Date: 2009/07/09 20:52:24 $
    
    % Author(s): Qinghua Zhang, Rajiv Singh.
    
    properties
        Name = '';
        Function
    end
    
    properties(Dependent=true)
        Arguments
    end
    
    properties
        Delays
        Vectorized = false;
        TimeVariable = 't';
    end
    
    properties(Hidden = true)
        prvArguments
        Display
        ChannelIndices
    end
    
    properties(Hidden = true, SetAccess='protected')
        Version = idutils.ver; %was 1.0 before R2008a
    end
    
    methods
        
        function this = customreg(varargin)
            %disp('customreg constructor called')
            ni = nargin;
            error(nargchk(0, 5, ni, 'struct'))
            if ni>0
                this.Function = varargin{1};
                nfargs = nargin(this.Function);
            else
                nfargs = 0;
            end
            
            if ni>1
                this.Arguments = varargin{2};
            else
                EmptyStr = {''};
                this.Arguments = EmptyStr(1,ones(1,max(nfargs, 0)));
            end
            nArgs = numel(this.Arguments);
            
            if ni>2
                this.Delays = varargin{3};
            else
                this.Delays = ones(1, length(this.Arguments));
            end
            
            if ni>3
                this.Vectorized = varargin{4};
            end
            
            if ni>4
                this.Display = varargin{5};
            end
            ndelays = numel(this.Delays);
            
            % Consistency between the properties of customreg
            % is checked only in this constructor, not in the
            % the set methods
            if nfargs>=0 && nfargs~=nArgs
                ctrlMsgUtils.error('Ident:idnlmodel:customregInconsistentInputs1')
            end
            if ndelays~=nArgs
                ctrlMsgUtils.error('Ident:idnlmodel:customregInconsistentInputs2')
            end
        end
        
        %------------------------------------------------------------------
        function this = set.Function(this,value)
            %disp('set.Function called')
            if isa(value,'function_handle') && length(value)==1
                % do nothing
            elseif ischar(value)
                try
                    value = str2func(value);
                catch
                    ctrlMsgUtils.error('Ident:idnlmodel:customregFunc')
                end
            elseif isempty(value)
                value = [];
            else
                ctrlMsgUtils.error('Ident:idnlmodel:customregFunc')
            end
            this.Function = value;
        end
        
        %------------------------------------------------------------------
        function value = get.Arguments(this)
            value = this.prvArguments;
        end
        %------------------------------------------------------------------
        function this = set.Arguments(this,value)
            
            if ischar(value)
                value = strtrim(cellstr(value));
            end
            if ~iscellstr(value)
                ctrlMsgUtils.error('Ident:idnlmodel:customregArg')
            end
            this.prvArguments = value(:)';
            this.Display = []; % Clear Display whenever Arguments is set.
        end
        
        %------------------------------------------------------------------
        function this = set.Delays(this,value)
            
            if ~(isempty(value) || (isnonnegintmat(value) && min(size(value))<2))
                ctrlMsgUtils.error('Ident:idnlmodel:customregDelay')
            end
            this.Delays = value(:)';
        end
        
        %------------------------------------------------------------------
        function this = set.Vectorized(this,value)
            
            [value, msg] = trueorfalse(value, 'Vectorized');
            error(msg)
            this.Vectorized = value;
        end
        
        
        %------------------------------------------------------------------
        function this = set.Display(this,value)
            
            if ~ischar(value) && ~isempty(value)
                ctrlMsgUtils.error('Ident:idnlmodel:customregDisplay')
            end
            this.Display = value;
        end
        
    end %methods
    
    methods (Access = 'protected', Static = true)
        function P = getListOfVisibleProperties(m,varargin)
            
            p = m.Properties;
            pmark = cell2mat(cellpvget(p, 'Hidden'));
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
    
end %class

% FILE END
