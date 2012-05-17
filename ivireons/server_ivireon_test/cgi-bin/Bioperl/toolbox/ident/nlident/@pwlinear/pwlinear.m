classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) pwlinear < idnlfun
    %PWLINEAR Piecewise linear nonlinearity estimator object constructor.
    %
    % Usage:
    %   P = PWLINEAR
    %       Create a piecewise linear nonlinearity estimator object with
    %       default number of units (10) and unknown breakpoints.
    %
    %   P = PWLINEAR('BreakPoints',BP)
    %       Create a piecewise linear nonlinearity estimator object with
    %       break points specified by matrix BP. The number of units is
    %       equal to the number of columns in BP.
    %
    %       BP: Can be specified as a row vector or a matrix with two rows.
    %       When specified as a 2-by-n matrix: [x_1,...x_n;y_1,...y_n], the
    %       first row specifies the initial input values, while the second
    %       row specifies the corresponding initial values of the
    %       nonlinearity. When BP is specified as a single row, it is taken
    %       to represent the input values [x_1,...x_n], while the
    %       nonlinearity values are initialized using zeros:
    %       y_1 = y_2 = ... = y_n = 0.
    %
    %   P = PWLINEAR('NumberOfUnits',n)
    %       Create a piecewise linear nonlinearity estimator object with
    %       number of units (= number of breakpoints) = n.
    %
    % Properties:
    %       NumberOfUnits: stores the number of units in the nonlinearity
    %       estimator. This is equal to the numberof breakpoints (default: 10).
    %
    %       BreakPoints: stores the breakpoints and the corresponding
    %       nonlonearity values. If empty (= []), the values are
    %       initialized using estimation data during model estimation.
    %
    %       The nonlinearity properties can be get and set by
    %       subreferencing, as in: P.br = BP. If BP here is a row vector,
    %       the values are interpreted as new x-values (input breakpoints),
    %       while the y-values (nonlinearity values) are set to zero.
    %
    % Description:
    %       P is a nonlinearity object, describing the piece-wise linear
    %       function y = F(x), where y and x are scalars and y_k = F(x_k),
    %       k=1,...,n and linearly interpolated between these values. The
    %       value F(x) is computed by using the "evaluate" command, as in:
    %       Values = evaluate(P,x).
    %
    %       Note that F(x) is linear also to the left and right of the
    %       extreme breakpoints. The slope of these extensions can be a
    %       complicated function of x_i, y_i. Note also the internal
    %       representation of the breakpoints is different, which may
    %       explain minor deviations from the set values in some cases.
    %
    % Typical use: Piecewise linear nonlinearity is employed typically in
    %   Hammerstein-Wiener (IDNLHW) models. Example:
    %   model = NLHW(Data,Orders,pwlinear('Br',[-1:0.1:1]),[])
    %   estimates an IDNLHW model using pwlinear as its input nonlinearity.
    %   The nonlinearity is initialized at the given breakpoints, which are
    %   then adjusted to data by the estimation function NLHW.
    %
    %   Type "idprops pwlinear" for more information.
    %
    % See also NLHW, EVALUATE, SATURATION, DEADZONE, POLY1D.
    
    % Copyright 2005-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.9 $ $Date: 2009/03/09 19:15:05 $
    
    % Author(s): Qinghua Zhang
    %   Technology created in colloboration with INRIA and University Joseph
    %   Fourier of Grenoble - FRANCE
    
    properties(Hidden = true)
        prvNumberOfUnits = 10;
        internalParameter
        assignedBreakPoints
    end
    
    properties(Dependent=true)
        NumberOfUnits
        BreakPoints
    end
    
    properties(Dependent=true, Hidden = true)
        Parameters % synonym of BreakPoints
    end
    
    
    methods
        function this = pwlinear(varargin)
            ni = nargin;
            if rem(ni, 2)
                ctrlMsgUtils.error('Ident:general:InvalidSyntax','pwlinear','pwlinear')
            end
            
            % Autofill of input arguments
            unitka = 0;
            brkpka = 0;
            for ka=1:2:ni
                prop = pnmatch(strtrim(varargin{ka}), {'NumberOfUnits', 'BreakPoints'});
                if strcmp(prop, 'NumberOfUnits')
                    if unitka>0
                        ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','NumberOfUnits')
                    end
                    unitka = ka;
                else
                    if brkpka>0
                        ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','BreakPoints')
                    end
                    brkpka = ka;
                end
            end
            
            if unitka>0
                this.NumberOfUnits = varargin{unitka+1};
            end
            %Note: BreakPoints must be assigned after NumberOfUnits
            if brkpka>0
                this.BreakPoints = varargin{brkpka+1};
            end
            
            % NOTE: auto-fil should be globally reconsidered.
            %propind = 1:ni;
            bpflag = 0;
            for ka=1:2:ni
                prop = strtrim(varargin{ka});
                if length(prop)>1 && ~isempty(strmatch(lower(prop), 'breakpoints'))
                    value = varargin{ka+1};
                    bpflag = 1;
                    %propind([ka, ka+1]) = [];
                    break
                end
            end
            %this = this@ridgenet(varargin{propind});
            if bpflag
                this.BreakPoints = value;
            end
        end
        
        %--------------------------------------------------------------
        function this = set.Parameters(this,value)
            this.BreakPoints = value; % synonym of BreakPoints
        end
        
        %--------------------------------------------------------------
        function value = get.Parameters(this)
            value = this.BreakPoints; % synonym of BreakPoints
        end
        %--------------------------------------------------------------
        function this = set.NumberOfUnits(this,value)
            
            if ~isnonnegintscalar(value)
                ctrlMsgUtils.error('Ident:general:positiveIntPropVal','NumberOfUnits')
            end
            this.prvNumberOfUnits = value;
            this.internalParameter = [];   % Clear internalParameter which is no longer valid
            this.assignedBreakPoints = []; % Clear also last assigned value.
        end
        %--------------------------------------------------------------
        function value = get.NumberOfUnits(this)
            value = this.prvNumberOfUnits;
        end
        
        %-------------------------------------------------------------
        function this = set.BreakPoints(this,value)
            if isempty(value) && isreal(value) && max(size(value))==0
                value = zeros(2,0);
            end
            nrows = size(value,1);
            if ~(isrealmat(value) && all(isfinite(value(:))) && any(nrows==[1 2]))
                ctrlMsgUtils.error('Ident:idnlfun:pwlinearBPformat')
            end
            numunits = size(value,2);
            param = this.internalParameter;
            
            % Special case of empty value
            if numunits==0
                if isempty(param)
                    param.LinearCoef = 0;
                    param.OutputOffset = 0;
                end
                param.OutputCoef = zeros(0,1);
                param.Translation = zeros(1,0);
                % Set related properties
                this.NumberOfUnits = numunits;
                this.internalParameter =  param;
                
                % Store assigned value to assignedBreakPoints
                % (see also end of this function)
                this.assignedBreakPoints = zeros(2,0);
                
                return
            end
            
            if nrows==1
                % Only Xvalue is given
                Xvalue = value;
                Yvalue = zeros(1, numunits); % always set Yvalue to zeros if nrows==1
                Xvalue = sort(Xvalue);
            else
                % Both Xvalue and Yvalue are given
                Xvalue = value(1,:);
                Yvalue = value(2,:);
                [Xvalue, ind] = sort(Xvalue);
                Yvalue = Yvalue(ind);
            end
            
            % Extra side values
            if numunits==1
                xwidth = 1;
            else
                xwidth = Xvalue(end) - Xvalue(1);
            end
            % Extended Xvalue
            Xext = [Xvalue(1)-xwidth, Xvalue, Xvalue(end)+xwidth]'; %Column vector
            
            if isempty(param) || numel(param.Translation)==0
                % zero slope at both sides
                Yext = [Yvalue(1), Yvalue, Yvalue(end)]'; %Column vector
            else
                %Keep old side slopes
                oldXvalue = sort(-param.Translation);
                oldYsides = soevaluate(this, ...
                    [oldXvalue(1)-xwidth; oldXvalue(1); oldXvalue(end); oldXvalue(end)+xwidth]);
                oldExtLH = oldYsides(1)-oldYsides(2);
                oldExtRH = oldYsides(4)-oldYsides(3);
                Yext = [Yvalue(1)+oldExtLH, Yvalue, Yvalue(end)+oldExtRH]'; %Column vector
            end
            
            Translation = -Xvalue;
            basemat = [abs(Xext(:,ones(1,numunits))+Translation(ones(numunits+2,1),:)), Xext, ones(numunits+2,1)];
            if rank(basemat, eps*numunits)<numunits+2
                ctrlMsgUtils.error('Ident:idnlfun:pwlinearNonUniqueBP')
            end
            allcoef = basemat\Yext;
            OutputCoef = allcoef(1:numunits);
            LinearCoef = allcoef(numunits+1);
            OutputOffset = allcoef(numunits+2);
            
            param.LinearCoef = LinearCoef;
            param.OutputCoef = OutputCoef;
            param.OutputOffset = OutputOffset;
            param.Translation = Translation;
            
            % Set related properties
            this.NumberOfUnits = numunits;
            this.internalParameter =  param;
            
            % Store assigned value to assignedBreakPoints
            % (see also special case of empty value above)
            this.assignedBreakPoints = [Xvalue; Yvalue];
        end
        %---------------------------------------------
        function value = get.BreakPoints(this)
            
            value = this.assignedBreakPoints; %Stored assigned value
            if ~isempty(value)
                return
            end
            
            param = this.internalParameter;
            if isempty(param)
                value = [];
            else
                Xvalue = sort(-param.Translation);
                Xvalue = Xvalue(:);
                Yvalue = soevaluate(this, Xvalue);
                value = [Xvalue'; Yvalue'];
            end
        end
        %----------------------------------------------------------------------
        function str = getInfoString(this)
            bp = this.BreakPoints;
            if isempty(bp)
                str = sprintf('Piecewise linear with %d units and unspecified break-points',this.NumberOfUnits);
            else
                str = sprintf('Piecewise linear with %d break-points',size(bp,2));
            end
        end
        
    end
end

% FILE END