function [errmsg, outParameters] = checkgetParameters(inParameters, isInit)
%CHECKGETPARAMETERS  Checks that the Parameters information is valid.
%   PRIVATE FUNCTION.
%
%   [ERRMSG, OUTPARAMETERS] = CHECKGETPARAMETERS(INPARAMETERS, ISINIT);
%
%   INPARAMETERS is a Np-by-1 structure array with fields
%      Name   : name of the parameter (a string).
%      Unit   : unit of the parameter (a string).
%      Value  : value of the parameter (a finite real scalar, vector or
%               2-dimensional matrix).
%      Minimum: minimum values of the parameter (a real scalar, a vector or
%               a 2-dimensional matrix).
%      Maximum: maximum values of the parameter (a real scalar, a vector or
%               a 2-dimensional matrix).
%      Fixed  : a boolean, a boolean vector or a boolean 2-dimensional
%               matrix specifying whether the parameter is fixed or not.
%
%   If ISINIT is true (only so in the idnlgrey constructor), then
%   INPARAMETERS can be a real finite Np-by-1 vector. OUTPARAMETERS will
%   be a Np-by-1 structure array with fields
%      Name   : 'pi', i = 1, 2, ..., Np.
%      Unit   : ''.
%      Value  : INPARAMETERS(i), i = 1, 2, ..., Np.
%      Minimum: -Inf.
%      Maximum: Inf.
%      Fixed  : false.
%
%   If ISINIT is true, then INPARAMETERS can be a Np-by-1 cell array
%   containing finite real scalars, finite real vectors or finite real
%   2-dimensional matrices. Name and Unit will be as in the numeric case.
%   Minimum, Maximum and Fixed will be -Inf, Inf and false elements,
%   respectively, of the same size as the corresponding Value element.
%
%   ERRMSG is a struct specifying the first error encountered during
%   object consistency checking (empty if no errors found).
%
%   OUTPARAMETERS is the parsed and checked parameters, returned as
%   an Np-by-1 structure array.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $ $Date: 2009/12/05 02:04:38 $
%   Written by Peter Lindskog.

% Check that the function is called with 2 arguments.
nin = nargin;
error(nargchk(2, 2, nin, 'struct'));

% Initialize errmsg. No error checking of nx or isInit performed.
errmsg = struct([]);
outParameters = struct([]);

% Handle the special initialization case.
if ((isInit) && isnumeric(inParameters))
    % Initialization using numeric data.
    if (ndims(inParameters) ~= 2)
        ID = 'Ident:idnlmodel:idnlgreyParFormat1'; msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
    elseif (   isempty(inParameters)                               ...
            || isRealMatrix(inParameters, 1, NaN, -Inf, Inf, true) ...
            || isRealMatrix(inParameters', 1, NaN, -Inf, Inf, true))
        outParameters = struct('Name',    defnum({}, 'p', length(inParameters)),   ... % Parameter names.
            'Unit',    '',                                      ... % Parameter units.
            'Value',   0,                                       ... % Current value of the parameters.
            'Minimum', -Inf,                                    ... % Minimum value of the parameters.
            'Maximum', Inf,                                     ... % Minimum value of the parameters.
            'Fixed', false                                      ... % Fixed parameters or not.
            );
        if ~isempty(inParameters)
            % Set Value.
            value = num2cell(inParameters(:)', 1);
            [outParameters.Value] = deal(value{:});
        end
    else
        ID = 'Ident:idnlmodel:idnlgreyParFormat1'; msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
    end
elseif ((isInit) && iscell(inParameters))
    inParameters = inParameters(:);
    outParameters = struct('Name',    defnum({}, 'p', length(inParameters)),   ... % Parameter names.
        'Unit',    '',                                      ... % Parameter units.
        'Value',   0,                                       ... % Current value of the parameters.
        'Minimum', -Inf,                                    ... % Minimum value of the parameters.
        'Maximum', Inf,                                     ... % Minimum value of the parameters.
        'Fixed', false                                      ... % Fixed parameters or not.
        );
    for i = 1:length(inParameters)
        if ~isRealMatrix(inParameters{i}, NaN, NaN, -Inf, Inf, true)
            ID = 'Ident:idnlmodel:idnlgreyParFormat2'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        else
            if ((size(inParameters, 1) == 1) && (size(inParameters, 2) > 1))
                % Convert row vector to column vector.
                inParameters{i} = inParameters{i}';
            end
            
            % Everything went fine. Set Value, Minimum, Maximum and Fixed.
            outParameters(i).Value = inParameters{i};
            outParameters(i).Minimum = -Inf(size(inParameters{i}));
            outParameters(i).Maximum = Inf(size(inParameters{i}));
            outParameters(i).Fixed = false(size(inParameters{i}));
        end
    end
elseif isstruct(inParameters)
    if (  (length(fieldnames(inParameters)) ~= 6) ...
            || ~all(ismember(fieldnames(inParameters), {'Name' 'Unit' 'Value' 'Minimum' 'Maximum' 'Fixed'})))
        ID = 'Ident:idnlmodel:idnlgreyParFields'; msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
    elseif ~isempty(inParameters)
        % Loop through the elements of inParameters and check their values.
        np = length(inParameters);
        for i = 1:np
            % Check that inParameters(i).Name is a non-empty single-line
            % string.
            [errmsg, inParameters(i).Name] = ParameterNameCheck(inParameters(i).Name, i);
            if ~isempty(errmsg)
                return;
            end
            
            % Check that inParameters(i).Unit is a single-line string.
            [errmsg, inParameters(i).Unit] = ParameterUnitCheck(inParameters(i).Unit, i);
            if ~isempty(errmsg)
                return;
            end
            
            % Check that Parameters(i).Value is a finite real scalar, a
            % finite real vector or a finite real 2-dimensional matrix.
            if ~isRealMatrix(inParameters(i).Value, NaN, NaN, -Inf, Inf, true)
                ID = 'Ident:idnlmodel:idnlgreyParValue'; msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif isempty(inParameters(i).Value)
                ID = 'Ident:idnlmodel:idnlgreyParValue'; msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (   (size(inParameters(i).Value, 1) == 1) ...
                    && (size(inParameters(i).Value, 2) > 1))
                % Convert row vector to column vector.
                inParameters(i).Value = inParameters(i).Value';
            end
            npe = size(inParameters(i).Value);
            
            % Check that Parameters(i).Minimum is a real scalar, a real
            % vector or a real 2-dimensional matrix.
            if ~isRealMatrix(inParameters(i).Minimum, NaN, NaN, -Inf, Inf, false)
                ID = 'Ident:idnlmodel:idnlgreyParMin'; msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (   (size(inParameters(i).Minimum, 1) == 1) ...
                    && (size(inParameters(i).Minimum, 2) > 1))
                % Convert row vector to column vector.
                inParameters(i).Minimum = inParameters(i).Minimum';
            end
            
            % Check that the size of inParameters(i).Minimum is consistent
            % with inParameters(i).Value.
            if (length(unique(inParameters(i).Minimum)) == 1)
                inParameters(i).Minimum = inParameters(i).Minimum(1)*ones(npe);
            elseif ~all(size(inParameters(i).Minimum) == npe)
                ID = 'Ident:idnlmodel:idnlgreyParMinSize'; msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that inParameters(i).Minimum <= inParameters(i).Value.
            if any(any(inParameters(i).Minimum > inParameters(i).Value))
                ID = 'Ident:idnlmodel:idnlgreyParMinVal'; msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that Parameters(i).Maximum is a real scalar, a real
            % vector or a real 2-dimensional matrix.
            if ~isRealMatrix(inParameters(i).Maximum, NaN, NaN, -Inf, Inf, false)
                ID = 'Ident:idnlmodel:idnlgreyParMax'; msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (   (size(inParameters(i).Maximum, 1) == 1) ...
                    && (size(inParameters(i).Maximum, 2) > 1))
                % Convert row vector to column vector.
                inParameters(i).Maximum = inParameters(i).Maximum';
            end
            
            % Check that the size of inParameters(i).Maximum is consistent
            % with inParameters(i).Value.
            if (length(unique(inParameters(i).Maximum)) == 1)
                inParameters(i).Maximum = inParameters(i).Maximum(1)*ones(npe);
            elseif ~all(size(inParameters(i).Maximum) == npe)
                ID = 'Ident:idnlmodel:idnlgreyParMaxSize'; msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that inParameters(i).Value <= inParameters(i).Maximum.
            if any(inParameters(i).Value > inParameters(i).Maximum)
                ID = 'Ident:idnlmodel:idnlgreyParMaxVal'; msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that Parameters(i).Fixed is a logical scalar, vector
            % or 2-dimensional matrix.
            if (ndims(inParameters(i).Fixed) ~= 2)
                ID = 'Ident:idnlmodel:idnlgreyParFixed'; msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif isnumeric(inParameters(i).Fixed)
                if ~all(ismember(unique(inParameters(i).Fixed), [0 1]))
                    ID = 'Ident:idnlmodel:idnlgreyParFixed'; msg = ctrlMsgUtils.message(ID,i);
                    errmsg = struct('identifier',ID,'message',msg);
                    return;
                else
                    inParameters(i).Fixed = logical(inParameters(i).Fixed);
                end
            elseif ~islogical(inParameters(i).Fixed)
                ID = 'Ident:idnlmodel:idnlgreyParFixed'; msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            if (   (size(inParameters(i).Fixed, 1) == 1) ...
                    && (size(inParameters(i).Fixed, 2) > 1))
                % Convert row vector to column vector.
                inParameters(i).Fixed = inParameters(i).Fixed';
            end
            
            % Check that the size of inParameters(i).Fixed is
            % consistent with inParameters(i).Value.
            if (length(unique(inParameters(i).Fixed)) == 1)
                if (inParameters(i).Fixed(1))
                    inParameters(i).Fixed = true(npe);
                else
                    inParameters(i).Fixed = false(npe);
                end
            elseif ~all(size(inParameters(i).Fixed) == npe)
                ID = 'Ident:idnlmodel:idnlgreyParFixedSize'; msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
        end
        
        % Check uniqueness of inParameters.Name.
        value = {inParameters.Name};
        if (length(value) ~= length(unique(value)))
            ID = 'Ident:idnlmodel:idnlgreyParNames'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % inParameters is valid. Return it.
        outParameters = inParameters(:);
    end
else
    if isInit
        ID = 'Ident:idnlmodel:idnlgreyParFormat3'; 
    else
        ID = 'Ident:idnlmodel:idnlgreyParFormat4';
    end
    msg = ctrlMsgUtils.message(ID);
    errmsg = struct('identifier',ID,'message',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isRealMatrix(value, rows, cols, low, high, islimited)
% Check that value is a real matrix of appropriate size in the specified
% range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif (~isnan(rows) && (size(value, 1) ~= rows))
    result = false;
elseif (~isnan(cols) && (size(value, 2) ~= cols))
    result = false;
elseif (~isreal(value) || any(any(isnan(value))))
    result = false;
elseif (islimited && ~all(all(isfinite(value))))
    result = false;
elseif (any(any(value < low)))
    result = false;
elseif (any(any(value > high)))
    result = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errmsg, Name] = ParameterNameCheck(Name, Element)
% Checks specified name.

ID = 'Ident:idnlmodel:idnlgreyStrCheck2'; 

if ischar(Name)
    if (~isempty(Name) && (ndims(Name) == 2))
        errmsg = '';
        Name = strtrim(Name(:)');
    else
        msg = ctrlMsgUtils.message(ID,['Parameters(' num2str(Element) ').Name']);
        errmsg = struct('identifier',ID,'message',msg);
    end
else
    msg = ctrlMsgUtils.message(ID,['Parameters(' num2str(Element) ').Name']);
    errmsg = struct('identifier',ID,'message',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errmsg, Name] = ParameterUnitCheck(Name, Element)
% Checks specified unit.

ID = 'Ident:idnlmodel:idnlgreyStrCheck1'; 

if ischar(Name)
    if isempty(Name)
        errmsg = '';
        Name = '';
    elseif (ndims(Name) == 2)
        errmsg = '';
        Name = strtrim(Name(:)');
    else
        msg = ctrlMsgUtils.message(ID,['Parameters(' num2str(Element) ').Unit']);
        errmsg = struct('identifier',ID,'message',msg);
    end
else
    msg = ctrlMsgUtils.message(ID,['Parameters(' num2str(Element) ').Unit']);
    errmsg = struct('identifier',ID,'message',msg);
end
