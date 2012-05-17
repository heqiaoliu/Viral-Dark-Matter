function applySettings(this, Hd)
%APPLYSETTINGS   Apply the current settings to a DFILT.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:24:32 $

if isa(Hd, 'dfilt.multistage')
    
    % Assume homogeneous stages and apply to all.
    for indx = 1:nstages(Hd)
        applySettings(this, Hd.Stage(indx));
    end
    return;
end

if ~isSupportedStructure(this, Hd)
    return;
end

% Set the arithmetic.
set(Hd, 'Arithmetic', this.Arithmetic(1:4));

% If we are not in fixed-point, return early because there is nothing left
% to set.
if ~strcmpi(Hd.Arithmetic, 'fixed')
    return;
end

% Use the last applied state to set the filter.
source = get(this, 'LastAppliedState');
if isempty(source)
    source = this;
end

% All the objects have input formats, set them first.
set(Hd, ...
    'InputWordLength', evaluatevars(source.InputWordLength), ...
    'InputFracLength', evaluatevars(source.InputFracLength1));

% All objects except CICs have coefficients.
if ~any(strcmpi(class(Hd), {'mfilt.cicdecim', 'mfilt.cicinterp', 'dfilt.delay'}))
    set(Hd, ...
        'CoeffWordLength', evaluatevars(source.CoeffWordLength), ...
        'CoeffAutoscale',  ~strncmpi(source.CoeffMode, 'binary', 6), ...
        'Signed',          strcmpi(source.CoeffSigned, 'on'));
end

switch class(Hd)
    case {'mfilt.cicdecim', 'mfilt.cicinterp'}
        set(Hd, 'FilterInternals', mapFilterInternals(this.FilterInternals));
        switch lower(Hd.FilterInternals)
            case 'minwordlengths'
                set(Hd, 'OutputWordLength', evaluatevars(this.OutputWordLength));
            case 'specifywordlengths'
                swl = evaluatevars(this.SectionsWordLength);
                
                if length(swl) > 2*Hd.NumberOfSections
                    swl(2*Hd.NumberOfSections+1:end) = [];
                    set(this, 'SectionsWordLength', mat2str(swl));
                elseif length(swl) < 2*Hd.NumberOfSections
                    swl(end+1:2*Hd.NumberOfSections) = swl(end);
                    set(this, 'SectionsWordLength', mat2str(swl));
                end

                set(Hd, ...
                    'SectionWordLengths', evaluatevars(this.SectionsWordLength), ...
                    'OutputWordLength', evaluatevars(this.OutputWordLength));
            case 'specifyprecision'
                
                swl = evaluatevars(this.SectionsWordLength);
                sfl = evaluatevars(this.SectionsFracLength1);
                
                if length(swl) > 2*Hd.NumberOfSections
                    swl(2*Hd.NumberOfSections+1:end) = [];
                    set(this, 'SectionsWordLength', mat2str(swl));
                elseif length(swl) < 2*Hd.NumberOfSections
                    swl(end+1:2*Hd.NumberOfSections) = swl(end);
                    set(this, 'SectionsWordLength', mat2str(swl));
                end

                if length(sfl) > 2*Hd.NumberOfSections
                    sfl(2*Hd.NumberOfSections+1:end) = [];
                    set(this, 'SectionsFracLength1', mat2str(sfl));
                elseif length(sfl) < 2*Hd.NumberOfSections
                    sfl(end+1:2*Hd.NumberOfSections) = sfl(end);
                    set(this, 'SectionsFracLength1', mat2str(sfl));
                end

                set(Hd, ...
                    'SectionWordLengths', swl, ...
                    'SectionFracLengths', sfl, ...
                    'OutputWordLength', evaluatevars(this.OutputWordLength), ...
                    'OutputFracLength', evaluatevars(this.OutputFracLength1));
        end
    case 'dfilt.scalar'
        % A DFILT.SCALAR object can only be part of a larger cascade of
        % objects, so we will leave the OutputMode as "avoid overflow".
        set(Hd, 'OutputWordLength', evaluatevars(source.OutputWordLength), ...
            'RoundMode',    convertRoundMode(source), ...
            'OverflowMode', source.OverflowMode);
        
        if ~Hd.CoeffAutoScale
            set(Hd, 'CoeffFracLength', evaluatevars(source.CoeffFracLength1));
        end
        
    case {'dfilt.dffir', 'dfilt.dffirt', 'dfilt.dfsymfir', 'mfilt.firdecim', ...
            'dfilt.dfasymfir', 'mfilt.firtdecim', 'mfilt.firinterp', 'mfilt.firsrc'}

        set(Hd, ...
            'FilterInternals', source.FilterInternals(1:4));
        
        if ~Hd.CoeffAutoScale
            set(Hd, 'NumFracLength', evaluatevars(source.CoeffFracLength1));
        end

        if strncmpi(Hd.FilterInternals, 'spec', 4)
            set(Hd, ...
                'ProductWordLength', evaluatevars(source.ProductWordLength), ...
                'ProductFracLength', evaluatevars(source.ProductFracLength1), ...
                'AccumWordLength',   evaluatevars(source.AccumWordLength), ...
                'AccumFracLength',   evaluatevars(source.AccumFracLength1), ...
                'OutputWordLength',  evaluatevars(source.OutputWordLength), ...
                'OutputFracLength',  evaluatevars(source.OutputFracLength1), ...
                'OverflowMode',      source.OverflowMode, ...
                'RoundMode',         convertRoundMode(source));
        end
    case 'dfilt.df1sos'

        if ~Hd.CoeffAutoScale
            set(Hd, 'ScaleValueFracLength', evaluatevars(source.CoeffFracLength3));
        end
        
        set(Hd, ...
            'OutputMode',         strrep(source.OutputMode, ' ', ''), ...
            'NumStateWordLength', evaluatevars(source.StateWordLength1), ...
            'NumStateFracLength', evaluatevars(source.StateFracLength1), ...
            'DenStateWordLength', evaluatevars(source.StateWordLength2), ...
            'DenStateFracLength', evaluatevars(source.StateFracLength2));
        
        if strcmpi(Hd.OutputMode, 'SpecifyPrecision')
            set(Hd, 'OutputFracLength', evaluatevars(source.OutputFracLength1));
        end
        
        setIIRcommonProperties(source, Hd);
        
    case 'dfilt.df2sos'

        if ~Hd.CoeffAutoScale
            set(Hd, 'ScaleValueFracLength', evaluatevars(source.CoeffFracLength3));
        end
        
        set(Hd, ...
            'SectionInputWordLength',  evaluatevars(source.SectionInputWordLength), ...
            'SectionInputAutoscale',   strcmpi(source.SectionInputMode, 'specify word length'), ...
            'SectionOutputWordLength', evaluatevars(source.SectionOutputWordLength), ...
            'SectionOutputAutoscale',  strcmpi(source.SectionOutputMode, 'specify word length'), ...
            'OutputMode',              strrep(source.OutputMode, ' ', ''), ...
            'StateWordLength',         evaluatevars(source.StateWordLength1), ...
            'StateFracLength',         evaluatevars(source.StateFracLength1));
        
        if ~Hd.SectionInputAutoscale
            set(Hd, 'SectionInputFracLength', evaluatevars(source.SectionInputFracLength1));
        end

        if ~Hd.SectionOutputAutoscale
            set(Hd, 'SectionOutputFracLength', evaluatevars(source.SectionOutputFracLength1));
        end

        if strcmpi(Hd.OutputMode, 'SpecifyPrecision')
            set(Hd, 'OutputFracLength', evaluatevars(source.OutputFracLength1));
        end
        
        setIIRcommonProperties(source, Hd);

    case 'dfilt.df1tsos'

        if ~Hd.CoeffAutoScale
            set(Hd, 'ScaleValueFracLength', evaluatevars(source.CoeffFracLength3));
        end
        
        set(Hd, ...
            'SectionInputWordLength',  evaluatevars(source.SectionInputWordLength), ...
            'SectionInputAutoscale',   strcmpi(source.SectionInputMode, 'specify word length'), ...
            'SectionOutputWordLength', evaluatevars(source.SectionOutputWordLength), ...
            'SectionOutputAutoscale',  strcmpi(source.SectionOutputMode, 'specify word length'), ...
            'MultiplicandWordLength',  evaluatevars(source.MultiplicandWordLength), ...
            'MultiplicandFracLength',  evaluatevars(source.MultiplicandFracLength1), ...
            'OutputMode',              strrep(source.OutputMode, ' ', ''), ...
            'StateWordLength',         evaluatevars(source.StateWordLength1), ...
            'StateAutoscale',          strcmpi(source.StateMode, 'specify word length'));
        
        if ~Hd.SectionInputAutoscale
            set(Hd, 'SectionInputFracLength', evaluatevars(source.SectionInputFracLength1));
        end

        if ~Hd.SectionOutputAutoscale
            set(Hd, 'SectionOutputFracLength', evaluatevars(source.SectionOutputFracLength1));
        end

        if ~Hd.StateAutoscale
            set(Hd, ...
                'NumStateFracLength', evaluatevars(source.StateFracLength1), ...
                'DenStateFracLength', evaluatevars(source.StateFracLength2));
        end
        
        if strcmpi(Hd.OutputMode, 'SpecifyPrecision')
            set(Hd, 'OutputFracLength', evaluatevars(source.OutputFracLength1));
        end
        
        setIIRcommonProperties(source, Hd);
    case 'dfilt.df2tsos'

        if ~Hd.CoeffAutoScale
            set(Hd, 'ScaleValueFracLength', evaluatevars(source.CoeffFracLength3));
        end
        
        set(Hd, ...
            'SectionInputWordLength',  evaluatevars(source.SectionInputWordLength), ...
            'SectionInputFracLength',  evaluatevars(source.SectionInputFracLength1), ...
            'SectionOutputWordLength', evaluatevars(source.SectionOutputWordLength), ...
            'SectionOutputFracLength', evaluatevars(source.SectionOutputFracLength1), ...
            'OutputMode',              strrep(source.OutputMode, ' ', ''), ...
            'StateWordLength',         evaluatevars(source.StateWordLength1), ...
            'StateAutoscale',          strcmpi(source.StateMode, 'specify word length'));
        
        if ~Hd.StateAutoscale
            set(Hd, 'StateFracLength', evaluatevars(source.StateFracLength1));
        end
        
        if strcmpi(Hd.OutputMode, 'SpecifyPrecision')
            set(Hd, 'OutputFracLength', evaluatevars(source.OutputFracLength1));
        end
        
        setIIRcommonProperties(source, Hd);
    case 'dfilt.df1'
        
        set(Hd, 'OutputFracLength', evaluatevars(source.OutputFracLength1));
        
        setIIRcommonProperties(source, Hd);
        
    case 'dfilt.df2'

        set(Hd, ...
            'OutputMode',      strrep(source.OutputMode, ' ', ''), ...
            'StateWordLength', evaluatevars(source.StateWordLength1), ...
            'StateFracLength', evaluatevars(source.StateFracLength1));
        
        if strcmpi(Hd.OutputMode, 'SpecifyPrecision')
            set(Hd, 'OutputFracLength', evaluatevars(source.OutputFracLength1));
        end
        
        setIIRcommonProperties(source, Hd);
        
    case 'dfilt.df1t'
        
        set(Hd, ...
            'OutputMode',             strrep(source.OutputMode, ' ', ''), ...
            'StateWordLength',        evaluatevars(source.StateWordLength1), ...
            'MultiplicandWordLength', evaluatevars(source.MultiplicandWordLength), ...
            'MultiplicandFracLength', evaluatevars(source.MultiplicandFracLength1), ...
            'StateAutoscale',         strcmpi(source.StateMode, 'specify word length'));
        
        if ~Hd.StateAutoscale
            set(Hd, ...
                'NumStateFracLength', evaluatevars(source.StateFracLength1), ...
                'DenStateFracLength', evaluatevars(source.StateFracLength2));
        end
        
        setIIRcommonProperties(source, Hd);
        
    case 'dfilt.df2t'
        set(Hd, ...
            'OutputFracLength', evaluatevars(source.OutputFracLength1), ...
            'StateWordLength',  evaluatevars(source.StateWordLength1), ...
            'StateAutoscale',   strcmpi(source.StateMode, 'specify word length'));
        
        if ~Hd.StateAutoscale
            set(Hd, 'StateFracLength', evaluatevars(source.StateFracLength1));
        end
        
        setIIRcommonProperties(source, Hd);
    case 'dfilt.delay'
        % NO OP, delay only has input settings.
    case {'farrow.fd','dfilt.farrowfd'}
        set(Hd, ...
            'FilterInternals', source.FilterInternals(1:4), ...
            'FDWordLength', evaluatevars(source.FDWordLength),...
            'FDAutoScale', ~strncmpi(source.FDMode, 'binary', 6));
        
        if ~Hd.CoeffAutoScale
            set(Hd, 'CoeffFracLength', evaluatevars(source.CoeffFracLength1));
        end

        if ~Hd.FDAutoScale
            set(Hd, 'FDFracLength', evaluatevars(source.FDFracLength1));
        end
        
        if strncmpi(Hd.FilterInternals, 'spec', 4)
            set(Hd, ...
                'ProductWordLength', evaluatevars(source.ProductWordLength), ...
                'ProductFracLength', evaluatevars(source.ProductFracLength1), ...
                'AccumWordLength',   evaluatevars(source.AccumWordLength), ...
                'AccumFracLength',   evaluatevars(source.AccumFracLength1), ...
                'OutputWordLength',  evaluatevars(source.OutputWordLength), ...
                'OutputFracLength',  evaluatevars(source.OutputFracLength1), ...
                'MultiplicandWordLength', evaluatevars(source.MultiplicandWordLength), ...
                'MultiplicandFracLength', evaluatevars(source.MultiplicandFracLength1), ...
                'FDProdWordLength',  evaluatevars(source.FDProdWordLength), ...
                'FDProdFracLength',  evaluatevars(source.FDProdFracLength1), ...
                'OverflowMode',      source.OverflowMode, ...
                'RoundMode',         convertRoundMode(source));
        end
    otherwise
        disp(sprintf('''%s'' not supported yet.', class(Hd)));
end


% -------------------------------------------------------------------------
function setIIRcommonProperties(source, Hd)

if ~Hd.CoeffAutoScale
    set(Hd, ...
        'NumFracLength', evaluatevars(source.CoeffFracLength1), ...
        'DenFracLength', evaluatevars(source.CoeffFracLength2));
end

set(Hd, ...
    'OutputWordLength', evaluatevars(source.OutputWordLength), ...
    'RoundMode',        convertRoundMode(source), ...
    'OverflowMode',     source.OverflowMode, ...
    'ProductMode',      strrep(source.ProductMode, ' ', ''), ...
    'AccumMode',        strrep(source.AccumMode, ' ', ''));

if ~strcmpi(Hd.ProductMode, 'FullPrecision')
    set(Hd, 'ProductWordLength', evaluatevars(source.ProductWordLength));
    if strcmpi(Hd.ProductMode, 'SpecifyPrecision')
        set(Hd, ...
            'NumProdFracLength', evaluatevars(source.ProductFracLength1), ...
            'DenProdFracLength', evaluatevars(source.ProductFracLength2));
    end
end

if ~strcmpi(Hd.AccumMode, 'FullPrecision')
    set(Hd, ...
        'CastBeforeSum',   strcmpi(source.CastBeforeSum, 'on'), ...
        'AccumWordLength', evaluatevars(source.AccumWordLength));
    if strcmpi(Hd.AccumMode, 'SpecifyPrecision')
        set(Hd, ...
            'NumAccumFracLength', evaluatevars(source.AccumFracLength1), ...
            'DenAccumFracLength', evaluatevars(source.AccumFracLength2));
    end
end

% -------------------------------------------------------------------------
function FI = mapFilterInternals(FI)

switch lower(FI)
    case 'minimum word lengths'
        FI = 'minwordlengths';
    case 'specify word lengths'
        FI = 'specifywordlengths';
    case 'specify precision'
        FI = 'specifyprecision';
    case 'full precision'
        FI = 'fullprecision';
end

% -------------------------------------------------------------------------
function rMode = convertRoundMode(source)

rMode = source.RoundMode;

switch lower(rMode)
    case 'ceiling'
        rMode = 'ceil';
    case 'zero'
        rMode = 'fix';
end

% [EOF]
