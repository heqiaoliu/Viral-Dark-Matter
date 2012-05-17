function hBuffer = getMCodeBuffer(this, Hd)
%GETMCODEBUFFER Get the mCodeBuffer.
%   OUT = GETMCODEBUFFER(ARGS) <long description>

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 03:03:19 $

laState = get(this, 'LastAppliedState');
if isempty(laState), laState = this; end

hBuffer = sigcodegen.mcodebuffer;

switch lower(laState.Arithmetic)
    case 'double precision'
        % NO OP
    case 'single precision'
        if isa(Hd, 'dfilt.multistage')
           for indx = 1:numel(Hd.Stage)
               if isa(Hd.Stage(indx), 'dfilt.multistage')
                   hBuffer.add(['set(',sprintf('Hd.Stage(%d).Stage,', indx),'''Arithmetic'', ''single'');']);
                   hBuffer.cr;
               else
                   hBuffer.add(['set(',sprintf('Hd.Stage(%d),', indx),'''Arithmetic'', ''single'');']);
               end
           end
        else
            hBuffer.add('set(Hd, ''Arithmetic'', ''single'');');
        end

    case 'fixed point'
        if isa(Hd, 'dfilt.multistage')
            for indx = 1:numel(Hd.Stage)
                if isa(Hd.Stage(indx), 'dfilt.multistage')
                    for k = 1:numel(Hd.Stage(indx).Stage)
                        addFixedPoint(laState, hBuffer, ...
                            sprintf('Hd.Stage(%d).Stage(%d)', indx, k), ...
                            class(Hd.Stage(indx).Stage(k)));
                        hBuffer.cr;
                    end
                else
                    addFixedPoint(laState, hBuffer, ...
                        sprintf('Hd.Stage(%d)', indx),class(Hd.Stage(indx)));
                    hBuffer.cr;
                end
            end
        else
            addFixedPoint(laState, hBuffer, 'Hd',class(Hd));
        end
end

% -------------------------------------------------------------------------
function addFixedPoint(laState, hBuffer, variableName,classname)

% Add the arithmetic setting and the input information.
hBuffer.add('set(%s, ''Arithmetic'', ''fixed''', variableName);

addPair(hBuffer, 'InputWordLength', evaluatevars(laState.InputWordLength));
addPair(hBuffer, 'InputFracLength', evaluatevars(laState.InputFracLength1));

classname(1:findstr(classname,'.')) = [];
switch lower(classname)
    case 'df1'
        addCoeff(laState,  hBuffer, 'Num', 'Den');
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, false);
        addModes(laState,  hBuffer);
    case 'df2'
        addCoeff(laState,  hBuffer, 'Num', 'Den');
        addState(laState,  hBuffer, false, 1);
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, true);
        addModes(laState,  hBuffer);
    case 'df1t'
        addCoeff(laState,  hBuffer, 'Num', 'Den');
        addFormat(laState, hBuffer, 'Multiplicand');
        addState(laState,  hBuffer, true, 1, 'Num', 'Den');
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, true);
        addModes(laState,  hBuffer);
    case 'df2t'
        addCoeff(laState,  hBuffer, 'Num', 'Den');
        addState(laState,  hBuffer, true, 1);
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, false);
        addModes(laState,  hBuffer);
    case 'df1sos'
        addCoeff(laState,  hBuffer, 'Num', 'Den', 'ScaleValue');
        addState(laState,  hBuffer, false, 2, 'Num', 'Den');
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, true);
        addModes(laState,  hBuffer);
    case 'df2sos'
        addCoeff(laState,  hBuffer, 'Num', 'Den', 'ScaleValue');
        addFormat(laState, hBuffer, 'SectionInput', true);
        addFormat(laState, hBuffer, 'SectionOutput', true);
        addState(laState,  hBuffer, false, 1);
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, true);
        addModes(laState,  hBuffer);
    case 'df1tsos'
        addCoeff(laState,  hBuffer, 'Num', 'Den', 'ScaleValue');
        addState(laState,  hBuffer, true, 1, 'Num', 'Den');
        addFormat(laState, hBuffer, 'SectionInput', true);
        addFormat(laState, hBuffer, 'SectionOutput', true);
        addFormat(laState, hBuffer, 'Multiplicand');
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, true);
        addModes(laState,  hBuffer);
    case 'df2tsos'
        addCoeff(laState,  hBuffer, 'Num', 'Den', 'ScaleValue');
        addFormat(laState, hBuffer, 'SectionInput');
        addFormat(laState, hBuffer, 'SectionOutput');
        addState(laState,  hBuffer, true, 1);
        addProd(laState,   hBuffer, 'Num', 'Den');
        addAccum(laState,  hBuffer, 'Num', 'Den');
        addOutput(laState, hBuffer, true);
        addModes(laState,  hBuffer);
    case {'dffir', 'dffirt', 'dfsymfir', 'dfasymfir', 'firdecim', ...
            'firtdecim', 'firinterp', 'firsrc'}
        addCoeff(laState, hBuffer, 'Num');
        addFilterInternals(laState, hBuffer);
        if strcmpi(laState.FilterInternals, 'Specify precision')
            addFormat(laState, hBuffer, 'Product');
            addFormat(laState, hBuffer, 'Accum');
            addOutput(laState, hBuffer, false);
            addModes(laState,  hBuffer);
        end
    case 'linearinterp'
        addCoeff(laState, hBuffer, 'Num');
        addFilterInternals(laState, hBuffer);
        if strcmpi(laState.FilterInternals, 'Specify precision')
            addFormat(laState, hBuffer, 'Accum');
            addOutput(laState, hBuffer, false);
            addModes(laState,  hBuffer);
        end
    case {'delay','holdinterp'}
        % NO OP
    case {'fd', 'farrowfd', 'farrowsrc', 'farrowlinearfd'}
        if ~strcmpi(classname,'farrowlinearfd')
            addCoeff(laState,  hBuffer, 'Coeff');
        end
        addFormat(laState, hBuffer, 'FD', true);
        addFilterInternals(laState, hBuffer);
        if strcmpi(laState.FilterInternals, 'Specify precision')
            addFormat(laState, hBuffer, 'Product');
            addFormat(laState, hBuffer, 'Accum');
            addFormat(laState, hBuffer, 'Multiplicand');
            addFormat(laState, hBuffer, 'FDProd');
            addOutput(laState, hBuffer, false);
            addModes(laState,  hBuffer);
        end
    case {'cicdecim', 'cicinterp'}

        addFilterInternals(laState, hBuffer);

        switch lower(laState.FilterInternals)
            case 'full precision'
                % NO OP
            case 'minimum word lengths'
                addPair(hBuffer, 'OutputWordLength', ...
                    evaluatevars(laState.OutputWordLength));
            case 'specify word lengths'
                addPair(hBuffer, 'SectionWordLengths', ...
                    evaluatevars(laState.SectionsWordLength));
                addPair(hBuffer, 'OutputWordLength', ...
                    evaluatevars(laState.OutputWordLength));
            case 'specify precision'
                addPair(hBuffer, 'SectionWordLengths', ...
                    evaluatevars(laState.SectionsWordLength));
                addPair(hBuffer, 'SectionFracLengths', ...
                    evaluatevars(laState.SectionsFracLength1));
                addPair(hBuffer, 'OutputWordLength', ...
                    evaluatevars(laState.OutputWordLength));
                addPair(hBuffer, 'OutputFracLength', ...
                    evaluatevars(laState.OutputFracLength1));
        end
    otherwise
        error(generatemsgid('FixedPtErr'), 'Finish %s', laState.Structure);
end
hBuffer.add(');');

% -------------------------------------------------------------------------
function addFormat(laState, hBuffer, format, hasMode)

if nargin < 4
    hasMode = false;
end

wlStr = sprintf('%sWordLength', format);

addPair(hBuffer, wlStr, evaluatevars(laState.(wlStr)));

addFrac = true;
if hasMode

    isAuto = strcmpi(laState.(sprintf('%sMode', format)), 'specify word length');

    addPair(hBuffer, sprintf('%sAutoScale', format), isAuto);
    if isAuto
        addFrac = false;
    end
end

if addFrac
    addPair(hBuffer, sprintf('%sFracLength', format), ...
        evaluatevars(laState.(sprintf('%sFracLength1', format))));
end

% -------------------------------------------------------------------------
function addState(laState, hBuffer, hasMode, numberOfStates, varargin)

if nargin < 5
    varargin = {''};
end

if numberOfStates > 1
    for indx = 1:numberOfStates
        addPair(hBuffer, sprintf('%sStateWordLength', varargin{indx}), ...
            evaluatevars(laState.(sprintf('StateWordLength%d', indx))));
    end
else
    addPair(hBuffer, 'StateWordLength', evaluatevars(laState.StateWordLength1));
end

addFrac = true;

if hasMode
    addPair(hBuffer, 'StateAutoScale', ...
        strcmpi(laState.StateMode, 'specify word length'));
    if ~strcmpi(laState.StateMode, 'binary point scaling')
        addFrac = false;
    end
end

if addFrac
    for indx = 1:length(varargin)
        addPair(hBuffer, sprintf('%sStateFracLength', varargin{indx}), ...
            evaluatevars(laState.(sprintf('StateFracLength%d', indx))));
    end
end


% -------------------------------------------------------------------------
function addOutput(laState, hBuffer, hasMode)

addPair(hBuffer, 'OutputWordLength', evaluatevars(laState.OutputWordLength));

addFrac = true;

if hasMode
    addPair(hBuffer, 'OutputMode', strrep(laState.OutputMode, ' ', ''));
    if ~strcmpi(laState.OutputMode, 'specify precision')
        addFrac = false;
    end
end

if addFrac
    addPair(hBuffer, 'OutputFracLength', evaluatevars(laState.OutputFracLength1));
end

% -------------------------------------------------------------------------
function addModes(laState, hBuffer)

rmode = lower(laState.RoundMode);

switch lower(rmode)
    case 'ceiling'
        rmode = 'ceil';
    case 'zero'
        rmode = 'fix';
end

addPair(hBuffer, 'RoundMode', rmode);
addPair(hBuffer, 'OverflowMode', lower(laState.OverflowMode));

% -------------------------------------------------------------------------
function addProd(laState, hBuffer, varargin)

addProdAccum(laState, hBuffer, 'Product', 'Prod', varargin{:});

% -------------------------------------------------------------------------
function addAccum(laState, hBuffer, varargin)

addProdAccum(laState, hBuffer, 'Accum', 'Accum', varargin{:});

% Add the cast before sum.
if ~strcmpi(laState.AccumMode, 'full precision')
    addPair(hBuffer, 'CastBeforeSum', strcmpi(laState.CastBeforeSum, 'on'));
end

% -------------------------------------------------------------------------
function addProdAccum(laState, hBuffer, longstr, shortstr, varargin)

modestr = sprintf('%sMode', longstr);

addPair(hBuffer, modestr, strrep(laState.(modestr), ' ', ''));

switch lower(laState.(modestr))
    case 'full precision'
        % NO OP
    case {'keep lsb' 'keep msb'}
        addPair(hBuffer, sprintf('%sWordLength', longstr), ...
            evaluatevars(laState.(sprintf('%sWordLength', longstr))));
    case 'specify precision'
        addPair(hBuffer, sprintf('%sWordLength', longstr), ...
            evaluatevars(laState.(sprintf('%sWordLength', longstr))));
        for indx = 1:length(varargin)
            addPair(hBuffer, sprintf('%s%sFracLength', varargin{indx}, shortstr), ...
                evaluatevars(laState.(sprintf('%sFracLength%d', longstr, indx))));
        end
end


% -------------------------------------------------------------------------
function addCoeff(laState, hBuffer, varargin)

% Add the word length.
addPair(hBuffer, 'CoeffWordLength', evaluatevars(laState.CoeffWordLength));

if strcmpi(laState.CoeffMode, 'Specify word length')

    % If we are on autoscale, add it and return.
    addPair(hBuffer, 'CoeffAutoScale', true);
else

    % Turn off autoscale and add the fractional lengths and the signed.
    addPair(hBuffer, 'CoeffAutoScale', false);
    for indx = 1:length(varargin)
        addPair(hBuffer, sprintf('%sFracLength', varargin{indx}), ...
            evaluatevars(laState.(sprintf('CoeffFracLength%d', indx))));
    end
    addPair(hBuffer, 'Signed', strcmpi(laState.CoeffSigned, 'on'));
end

% -------------------------------------------------------------------------
function addFilterInternals(laState, hBuffer)

fi = strrep(laState.FilterInternals, ' ', '');
if strcmpi(fi, 'minimumwordlengths')
    fi = 'minwordlengths';
end

addPair(hBuffer, 'FilterInternals', fi);

% -------------------------------------------------------------------------
function addPair(hBuffer, property, value)

if ischar(value)
    value = ['''' value ''''];
else
    value = mat2str(value);
end

hBuffer.add(', ...\n    ''%s'', %s', property, value);

% [EOF]
