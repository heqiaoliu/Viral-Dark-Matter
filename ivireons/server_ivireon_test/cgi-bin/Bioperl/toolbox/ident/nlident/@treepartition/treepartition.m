classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) treepartition < idnlfun
    %TREEPARTITION Create a tree-partitioned nonlinearity estimator object.
    %
    %   T = TREEPARTITION(PVpairs)
    %   creates a treepartition object, where PVpairs are Property/Value
    %   pairs of the object. T defines a nonlinear function y = F(x), where y
    %   is scalar and x an m-dimensional row vector. It is a local linear
    %   mapping with the partitioning of the x-space determined by a binary
    %   tree. See "idprops treepartition" for more details.
    %
    %   The number of leaves of the tree is  2^(J+1)-1, where J is the number
    %   of levels. This number is indicated by the property NumberOfUnits.
    %   Its default value 'auto' means that the number is determined from
    %   data by an automatic procedure.
    %
    %   Note: Unlike other nonlinearity estimators (such as WAVENET),
    %   NumberOfUnits in TREEPARTITION only sets an upper limit on the actual
    %   number of leaves used by the estimator. NumberOfUnits can be set
    %   explicitly to an integer, as in: T = TREEPARTITION('NumberOfUnits',N)
    %   When a model containing T is estimated, the value of NumberOfUnits in
    %   T is automatically changed to show the actual number of leaves used,
    %   which is the largest integer of the form 2^n-1 (<=N).
    %
    %   For other properties and their value see "idprops treepartition".
    %   The value of the function defined by T is computed by evaluate(T,x).
    %
    %   TREEPARTITION is used as a nonlinearity estimator in Nonlinear ARX
    %   (IDNLARX) models. For example, in order to estimate an IDNLARX model
    %   using treepartition, use NLARX as follows:
    %         Model = NLARX(Data, Orders, treepartition);
    %
    %   Advanced properties of treepartition estimator are stored in its
    %   Options property. Example:
    %     t = treepartition('num',100);
    %     t.Options.Threshold = 2; % change the threshold to 2
    %     m = nlarx(Data,Orders,t);
    %
    %   Type "idprops idnlestimators" for more information on
    %   various nonlinearity estimators and their properties.
    %
    %   See also NLARX, NLHW, EVALUATE, WAVENET, SIGMOIDNET, CUSTOMNET,
    %   NEURALNET.
    
    % Copyright 2006-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.13 $ $Date: 2009/10/16 04:57:07 $
    
    % Author(s): Anatoli Iouditski
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE
    
    properties(Dependent=true)
        NumberOfUnits
        Parameters
        Options
    end
    
    properties(Hidden = true)
        prvNumberOfUnits = 'Auto';
        prvParameters = pstructure([]);
        prvOptions =  struct('FinestCell', 'Auto',...
            'Threshold', 'Auto',...
            'Stabilizer', 1e-6);
    end
    
    properties(Dependent=true, Hidden = true)
        LinearTerm
    end
    
    methods
        function this = treepartition(varargin)
            ni = nargin;
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax','treepartition','treepartition')
            end
            
            % Note: this is to support autofil in the treepartition constructor's arguments
            % It may become useless when MCOS support automatically autofil
            proplist = {'NumberOfUnits',...
                'Options', 'Parameters'};
            for ka=1:2:ni
                prop = strtrim(varargin{ka});
                prop = strchoice(proplist,  prop);
                if isempty(prop)
                    ctrlMsgUtils.error('Ident:general:invalidProperty',varargin{ka},'TREEPARTITION')
                end
                this.(prop) = varargin{ka+1};
            end
        end
        
        %------------------------------------------------------------------
        function value = get.LinearTerm(this)
            value = 'on';
        end
        %--------------------------------------------------------------
        function this = set.LinearTerm(this,value)
            if ~strcmpi(value, 'on')
                ctrlMsgUtils.warning('Ident:idnlfun:treeLTAlwaysOn')
            end
        end
        
        %------------------------------------------------------------------
        function value = get.NumberOfUnits(this)
            value = this.prvNumberOfUnits;
        end
        %--------------------------------------------------------------
        function this = set.NumberOfUnits(this,value)
            
            if ~isnonnegintscalar(value)
                if ~(ischar(value) && strcmpi(value, 'auto'))
                    ctrlMsgUtils.error('Ident:general:positiveIntOrAutoPropVal','NumberOfUnits')
                end
            end
            this.prvNumberOfUnits = value;
            this.Parameters = []; % Clear Parameters which is no longer valid
        end
        
        %------------------------------------------------------------------
        function value = get.Options(this)
            value = this.prvOptions;
        end
        %--------------------------------------------------------------
        function this = set.Options(this,value)
            
            opt = this.Options;
            if ~isstruct(value)
                ctrlMsgUtils.error('Ident:idnlfun:invalidOptions','treepartition')
            else
                fnames = fieldnames(value);
                if ~isempty(setdiff(lower(fnames),lower(fieldnames(opt))))
                    ctrlMsgUtils.error('Ident:idnlfun:invalidOptions','treepartition')
                end
            end
            
            for k = 1:length(fnames)
                thisname = fnames{k};
                val = value.(thisname);
                switch lower(thisname)
                    case 'finestcell'
                        if (ischar(val) && strcmpi(val,'Auto')) || (isposintscalar(val) && val>1)
                            opt.FinestCell = val;
                        else
                            ctrlMsgUtils.error('Ident:idnlfun:invalidFinestCell')
                        end
                    case 'threshold'
                        if (ischar(val) && strcmpi(val,'auto')) || isposrealscalar(val)
                            opt.Threshold = val;
                        else
                            ctrlMsgUtils.error('Ident:idnlfun:invalidTreeThreshold')
                        end
                        
                    case 'stabilizer'
                        if isposrealscalar(val)
                            opt.Stabilizer = val;
                        else
                            ctrlMsgUtils.error('Ident:idnlfun:invalidTreeStabilizer')
                        end
                end
            end
            this.prvOptions = opt;
            this.Parameters = []; % Clear Parameters which is no longuer valid
        end
        
        %------------------------------------------------------------------
        function value = get.Parameters(this)
            value = this.prvParameters;
        end
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            [value, msg] = pstructure(value);
            if ~isempty(msg)
                % add some text on how to modify Parameters struct
                msg = pmessage(this, msg);
                error(msg.identifier,msg.message) %msg in structure format
            end
            this.prvParameters = value;
        end
        
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            nt = this.NumberOfUnits;
            if ischar(nt)
                str = 'Tree Partition with number of units chosen automatically';
            else
                str = sprintf('Tree Partition with %d units',nt);
            end
        end
        
    end %methods
end %class

% FILE END
