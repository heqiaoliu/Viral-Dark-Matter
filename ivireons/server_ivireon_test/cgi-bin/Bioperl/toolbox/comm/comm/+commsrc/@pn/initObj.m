function initObj(h, varargin)
%INITOBJ  Private COMMSRC.PN object copy constructor and init function.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/02 18:37:44 $

% Check format of varargin (make sure it actually is P-V pairs)
% -------------------------------------------------------------
checkVararginPVPairsFormatOK(varargin);

% Get all possible varargin property arg values
% ---------------------------------------------
genPoly    = parseFromArgs('GenPoly',       varargin);
initStates = parseFromArgs('InitialStates', varargin);
currStates = parseFromArgs('CurrentStates', varargin);
numBitsOut = parseFromArgs('NumBitsOut',    varargin);
mask       = parseFromArgs('Mask',          varargin);
shift      = parseFromArgs('Shift',         varargin);

% Pre-check state properties specified in constructor
% ---------------------------------------------------
if isempty(initStates)
    % Force both to be equal, even if currStates is empty
    initStates = currStates;
elseif (~isempty(currStates) && ~isequal(initStates,currStates))
    % Initial and current states are both non-empty and not equal
    error('comm:commsrc:pn:ObjConstructorInitAndCurrStatesNotEqual', ...
        'InitialStates and CurrentStates must be equal at object construction.');
end

% Check and set all specified static properties
% ---------------------------------------------

% Always set GenPoly FIRST since it dictates
% many other property length restrictions
if ~isempty(genPoly)
    h.GenPoly = genPoly; % note: various side effects when GenPoly set
end

% Always set CurrStates BEFORE InitialStates since someone may try to
% construct an object with only CurrStates specified (which is supported)
if ~isempty(currStates)
    h.CurrentStates = currStates; % checking only (no other side effects)
end

if ~isempty(initStates)
    h.InitialStates = initStates; % side effect: also sets CurrentStates
end

if ~isempty(numBitsOut)
    h.NumBitsOut = numBitsOut; % checking only (no other side effects)
else
    h.NumBitsOut = 1;
end
    

% Check and set dynamic property
% ------------------------------
if ~isempty(mask) && ~isempty(shift)
    % BOTH mask and shift specified -> ERROR
    error('comm:commsrc:pn:BothMaskAndShiftSpecified', ...
        'Only one of the Mask or Shift properties can be specified (but not both).');
elseif isempty(mask) && isempty(shift)
    % NEITHER mask nor shift specified -> use default mask
    createMaskProperty(h, [zeros(1,length(h.GenPoly)-2) 1]);
elseif isempty(shift)
    createMaskProperty(h, mask);
else
    createShiftProperty(h,shift);
end


%---------------------------------------------------------------------
function checkVararginPVPairsFormatOK(varargin)
pvPairArgs = varargin{:};
numPVPairs = length(pvPairArgs) / 2;
if check_posint(numPVPairs)
    for count = 1:numPVPairs
        vIdx = 2*count; % Value index
        pIdx = vIdx-1;  % Param (string) index
        pStr = pvPairArgs{pIdx};
        if ~isParamStringOK(pStr)
            % EARLY EXIT
            if ischar(pStr)
                error('comm:commsrc:pn:ObjConstructorUnrecognizedParam', ...
                      ['There is no property named ''' pStr ...
                       ''' in the commsrc.pn class.']);
            else
                error('comm:commsrc:pn:ObjConstructorBadPVPairFormat', ...
                      'Input arguments must be parameter-value pairs.');
            end
        end
    end
else
    % EARLY EXIT
    error('comm:commsrc:pn:ObjConstructorBadPVPairFormat', ...
          'Input arguments must be parameter-value pairs.');
end


%---------------------------------------------------------------------
function success = isParamStringOK(pStr)
% OK as long as first character of property name matches
success = any(strncmpi(pStr, ...
                       {'GenPoly',       ...
                        'InitialStates', ...
                        'CurrentStates', ...
                        'NumBitsOut',    ...
                        'Mask',          ...
                        'Shift'}, ...
                        1));


% ---------------------------------------------------------------
function propValue = parseFromArgs(propStr, varargin)
pvPairArgs = varargin{:};
propValue  = []; % default return value
numPVPairs = floor(length(pvPairArgs)/2);
for count = 1:numPVPairs
    vIdx = 2*count; % Value index
    pIdx = vIdx-1;  % Param (string) index

    % OK as long as first character of property name matches
    if strncmpi(propStr, pvPairArgs{pIdx}, 1)
        propValue = pvPairArgs{vIdx};
        break;
    end
end


%---------------------------------------------------------------------
%CHECK_POSINT  Return true if input is a vector of positive integers.
%              Return false otherwise.
function success = check_posint(values)
% Integer valued, and only values greater than 0
success = ~any(rem(values, 1)) && (min(values) > 0);


% [EOF]
