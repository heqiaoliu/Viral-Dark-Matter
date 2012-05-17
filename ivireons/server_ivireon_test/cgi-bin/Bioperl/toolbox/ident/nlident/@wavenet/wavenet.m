classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) wavenet < idnlfun
    %WAVENET creates a wavelet network nonlinearity estimator object.
    %
    %   W = WAVENET(PVpairs)
    %
    %   creates a wavenet object, where PVpairs are Property/Value pairs of
    %   the object. W defines a nonlinear function y = F(x), where y is
    %   scalar and x an m-dimensional row vector. It is based on a
    %   wavelet-type expansion, with a possible linear term. See "idprops
    %   wavenet" for details.
    %
    %   The most important property  'NumberOfUnits' (default 10), the number
    %   of terms in the expansion. Its default value is 'auto', which means
    %   that the number is determined from data by an automatic procedure.
    %   Other possible values are:
    %     * a positive integer
    %     * 'interactive': number of units is selected interactively during
    %                      estimation
    %   The property is set as in:
    %         S = WAVENET('Number',10).
    %   For other properties and their values see "idprops wavenet".
    %   The value of the function defined by S is computed by evaluate(S,x).
    %
    %   WAVENET can be used as a nonlinearity estimator for both Nonlinear ARX
    %   and Hammerstein-Wiener models. For example, in order to estimate a
    %   Hammerstein-Wiener model using wavenet as input nonlinearity
    %   estimator and no output nonlinearities, use NLHW as follows:
    %         Model = NLHW(Data, Orders, wavenet, []);
    %
    %   Type "idprops idnlestimators" for more information on various
    %   nonlinearity estimators and their properties.
    %
    %   See also nlarx, nlhw, idnlfun/evaluate, idprops.
    
    % Copyright 2006-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.13 $ $Date: 2009/03/09 19:15:08 $
    
    % Author(s): Qinghua Zhang
    
    properties(Dependent=true)
        NumberOfUnits
        LinearTerm
        Parameters
        Options
    end
    
    properties(Hidden = true)
        prvNumberOfUnits = 'Auto';
        prvLinearTerm = 'On';
        prvParameters = pstructure([]);
        prvOptions =  struct('FinestCell','auto', 'MinCells',16,...
            'MaxCells',128, 'MaxLevels',10, 'DilationStep',2, ...
            'TranslationStep',1);
    end
    
    methods
        function this = wavenet(varargin)
            ni = nargin;
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax','wavenet','wavenet') 
            end
            
            proplist = {'NumberOfUnits', 'LinearTerm', 'Options', 'Parameters'};
            for ka=1:2:ni
                prop = strtrim(varargin{ka});
                prop = strchoice(proplist,  prop);
                if isempty(prop)
                    ctrlMsgUtils.error('Ident:general:invalidProperty', varargin{ka},'WAVENET')
                end
                this.(prop) = varargin{ka+1};
            end
        end
        
        %------------------------------------------------------------------
        function value = get.NumberOfUnits(this)
            value = this.prvNumberOfUnits;
        end
        %--------------------------------------------------------------
        function this = set.NumberOfUnits(this,value)
            
            if ~isnonnegintscalar(value)
                value = strchoice({'Auto', 'Interactive'}, value);
                if isempty(value)
                    ctrlMsgUtils.error('Ident:idnlfun:invalidWavenetNumUnits')
                end
            end
            this.prvNumberOfUnits = value;
            this.Parameters = []; % Clear Parameters which is no longer valid
        end
        
        %------------------------------------------------------------------
        function value = get.LinearTerm(this)
            value = this.prvLinearTerm;
        end
        %--------------------------------------------------------------
        function this = set.LinearTerm(this,value)
            
            [value, msg] = strchoice({'On','Off'}, value, 'LinearTerm');
            error(msg)
            this.prvLinearTerm = value;
            this.Parameters = []; % Clear Parameters which is no longuer valid
        end
        
        %------------------------------------------------------------------
        function value = get.Options(this)
            value = this.prvOptions;
        end
        %--------------------------------------------------------------
        function this = set.Options(this,value)
            
            opt = this.Options;
            if ~isstruct(value)
                ctrlMsgUtils.error('Ident:idnlfun:invalidOptions','wavenet')
            else
                fnames = fieldnames(value);
                if ~isempty(setdiff(lower(fnames),lower(fieldnames(opt))))
                    ctrlMsgUtils.error('Ident:idnlfun:invalidOptions','wavenet')
                end
            end
            
            for k = 1:length(fnames)
                thisname = fnames{k};
                val = value.(thisname);
                switch lower(thisname)
                    case 'finestcell'
                        if (ischar(val) && strcmpi(val,'auto')) || isposintscalar(val)
                            opt.FinestCell = val;
                        else
                            ctrlMsgUtils.error('Ident:idnlfun:invalidFinestCell')
                        end
                    case {'mincells', 'maxcells', 'maxlevels'}
                        if isposintscalar(val)
                            opt.(thisname) = val;
                        else
                            ctrlMsgUtils.error('Ident:general:PosIntVal',['Options.', thisname])
                        end
                    case 'dilationstep'
                        if isposrealscalar(val)
                            opt.DilationStep = val;
                        else
                            ctrlMsgUtils.error('Ident:idnlfun:invalidDilationStep')
                        end
                    case 'translationstep'
                        if isposrealscalar(val)
                            opt.TranslationStep = val;
                        else
                            ctrlMsgUtils.error('Ident:idnlfun:invalidTranslationStep')
                        end
                end
            end
            this.prvOptions = opt;
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
        
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            nt = this.NumberOfUnits;
            if ischar(nt)
                if strcmpi(nt,'auto')
                    str = 'Wavelet network with number of units chosen automatically';
                else
                    str = 'Wavelet network with number of units chosen interactively during estimation';
                end
            else
                str = sprintf('Wavelet network with %d units',nt);
            end
        end
        
    end %methods
end %class

% FILE END
