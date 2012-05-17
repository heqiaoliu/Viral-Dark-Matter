classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) TrendInfo
    % TrendInfo represents offset and linear trend information in input/output data.
    %   T = idutils.TrendInfo(NU,NY)
    %   creates a TrendInfo object for an IDDATA object containing NU
    %   inputs and NY outputs. T encapsulates the input and output signal
    %   offset values and linear trend (slope) information.
    %
    %   T = idutils.TrendInfo(NU,NY,Nexp) creates a TrendInfo object whose
    %   properties are sized for storing trend information on Nexp data
    %   experiments.
    %
    %   Properties:
    %       DataName:     Name of source data (IDDATA object) the trend
    %                     info corresponds to. Default: ''.
    %       InputOffset:  Input offset levels. These may represent signal
    %                     equilibrium values (operating point) and/or the
    %                     mean of the data, such as values removed by the
    %                     DETREND command. Default: zeros(1, NU) (see note
    %                     below for multi-experiment case).
    %       OutputOffset: Same as InputOffset, but for output signals in
    %                     the data. Default: zeros(1,NY).
    %       InputSlope:   Slopes of a linear trends in the input signals of
    %                     the data (slope = du/dt = tan(theta), where u(t)
    %                     is the input signal, and theta is the slope
    %                     angle) Set this value if you want to remove or
    %                     add a linear trend to your data. If you use 
    %                     option 1 in DETREND command (for linear trend
    %                     removal), the information on removed trend from
    %                     input data will be returned as InputOffset and
    %                     InputSlope values. Default: zeros(1,NU).
    %      OutputSlope:   Same as InputSlope, but for output signals in the
    %                     data (slope = dy/dt, where y(t) is output
    %                     signal). Default: zeros(1,NY). 
    %
    %   NOTE: For multi-experiment data with Nexp experiments, the
    %   properties InputOffset, OutputOffset, InputSlope and OutputSlope
    %   become cell arrays of Nexp values (one for each experiment).
    %   
    %   Creating TrendInfo Object from IDDATA:
    %   Rather than using the constructor directly, this object can be
    %   derived from a given IDDATA object using the GETTREND or the
    %   DETREND method.
    %
    %   T = getTrend(DATA) creates a TrendInfo object T initialized to
    %   dimensions compatible with that of the IDDATA object DATA. All the
    %   properties have default values (zeros).
    %
    %   [newData, T] = detrend(DATA, ...) returns the TrendInfo object T as
    %   second output argument. In this case, T contains the offsets and
    %   linear slopes (if linear detreding is performed) that were removed
    %   from DATA.
    %
    %   Example:
    %   Suppose Dat is an IDDATA object containing I/O signals (2 input, 1
    %   output) with following offsets:
    %       Inputs: 12.5 Volts and 500 deg K respectively.
    %       Output: 600 m/s.
    %   For linear model identification, it is advisable to remove these
    %   offsets from the data. Use the TrendInfo object to store these
    %   offset levels and also remove them from data:
    %       T = getTrend(Dat);
    %       T.InputOffset  = [12.5 500];
    %       T.OutputOffset = 600;
    %       newDat = detrend(Dat, T);
    %
    %   To simulate a model that was estimated using newDat about the
    %   existing operating point, use SIM and RETREND functions:
    %   input = newDat(:,[],:)     %extract the input signal
    %   ylin = sim(model, input);  %simulation about zero equilibrium
    %   ytotal = retrend(ylin, T); %add output trend information
    %
    %   See also iddata/detrend, iddata/retrend, idmodel/sim, iddata/getTrend.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.8.3 $ $Date: 2009/04/21 03:22:59 $
    
    properties(Hidden = true)
        Version = idutils.ver; %original: R2009a version 3.
    end
    
    properties(GetAccess='private',SetAccess='private')
        ny = 0;
        nu = 0;
        nexp = 1;
    end
    
    properties
        DataName     = '';          %Name of source data the trend info corresponds to.
        InputOffset  = zeros(1,0);  %Input offset (mean from detrend)
        OutputOffset = zeros(1,0);  %Output offset (mean from detrend)
        InputSlope   = zeros(1,0);  %Slope of linear trend in input data
        OutputSlope  = zeros(1,0);  %Slope of linear trend in output data
    end
    
    methods
        function this = TrendInfo(nu,ny,nexp)
            if nargin==0
                % default constructor
                return
            end
            if isnonnegintscalar(nu) && isnonnegintscalar(ny)
                this.nu = nu;
                this.ny = ny;
            else
                ctrlMsgUtils.error('Ident:utility:TrendInfoCheck1')
            end
            
            if nargin==3 && ~isposintscalar(nexp)
                ctrlMsgUtils.error('Ident:utility:TrendInfoCheck2')
            end
            
            if nargin<3 || nexp==1
                this.InputOffset = zeros(1,nu);
                this.InputSlope = zeros(1,nu);
                this.OutputOffset = zeros(1,ny);
                this.OutputSlope = zeros(1,ny);
            else
                this.nexp = nexp;
                this.InputOffset  = repmat({zeros(1,nu)},1,nexp);
                this.InputSlope   = repmat({zeros(1,nu)},1,nexp);
                this.OutputOffset = repmat({zeros(1,ny)},1,nexp);
                this.OutputSlope  = repmat({zeros(1,ny)},1,nexp);
            end
        end
        
        function g = get(this)
            g = struct('DataName',this.DataName, ...
                'InputOffset',[],...
                'OutputOffset',[],...
                'InputSlope',[],...
                'OutputSlope',[]);
            g.InputOffset = this.InputOffset;
            g.OutputOffset = this.OutputOffset;
            g.InputSlope = this.InputSlope;
            g.OutputSlope = this.OutputSlope;
            
        end
        
        function display(this)
            g = get(this);
            if isempty(this.DataName)
                str1 = 'Trend specifications for data';
            else
                str1 = sprintf('Trend specifications for data ''%s''',this.DataName);
            end
            
            if this.nu==1
                inputnum = sprintf('%d input',this.nu);
            else
                inputnum = sprintf('%d inputs',this.nu);
            end
            
            if this.ny==1
                outputnum = sprintf('%d output',this.ny);
            else
                outputnum = sprintf('%d outputs',this.ny);
            end
            
            
            if this.nexp==1
                fprintf('%s with %s and %s:\n',str1,inputnum,outputnum)
            else
                fprintf('%s with %s, %s and %d experiments:\n',...
                    str1,inputnum,outputnum,this.nexp)
            end
            disp(g)
        end
        
        
        function this = set.DataName(this,value)
            % set DataName
            if ~ischar(value) || size(value,1)>1
                ctrlMsgUtils.error('Ident:general:strPropType','DataName')
            end
            this.DataName = value;
        end
        
        function this = set.InputOffset(this,value)
            % set InputOffset
            try
                value = LocalValidateValue(value,this.nu,this.nexp);
            catch E
                error(E.identifier,strrep(E.message,'PROPNAME','InputOffset'))
            end
            this.InputOffset = value;
        end
        
        function this = set.InputSlope(this,value)
            % set InputSlope
            try
                value = LocalValidateValue(value,this.nu,this.nexp);
            catch E
               error(E.identifier,strrep(E.message,'PROPNAME','InputSlope'))
            end
            this.InputSlope = value;
        end
        
        function this = set.OutputOffset(this,value)
            % set OutputOffset
            try
                value = LocalValidateValue(value,this.ny,this.nexp);
            catch E
                error(E.identifier,strrep(E.message,'PROPNAME','OutputOffset'))
            end
            
            this.OutputOffset = value;
        end
        
        function this = set.OutputSlope(this,value)
            % set OutputSlope
            
            try
                value = LocalValidateValue(value,this.ny,this.nexp);
            catch E
                error(E.identifier,strrep(E.message,'PROPNAME','OutputSlope'))
            end
            
            this.OutputSlope = value;
        end
        
    end
    
end %class

%--------------------------------------------------------------------------
function value = LocalValidateValue(value,N,nexp)
% check passed values

checkf = @(x)isa(x,'double') && isvector(x) && numel(x)==N && all(isfinite(x));
if nexp>1
    isValid = iscell(value) && all(cellfun(checkf,value)) && numel(value)==nexp;
else
    if iscell(value)
        value = value{1};
    end
    isValid = checkf(value);
end

if ~isValid
    if nexp>1
        ctrlMsgUtils.error('Ident:utility:finiteNumericCellArrayPropVal','PROPNAME',nexp,N)
    else
        ctrlMsgUtils.error('Ident:utility:finiteNumericPropVal','PROPNAME',N)
    end
elseif nexp>1
    value = cellfun(@(x)x(:).',value,'UniformOutput',false);
    value = value(:).';
else
    value = value(:).';
end
end
