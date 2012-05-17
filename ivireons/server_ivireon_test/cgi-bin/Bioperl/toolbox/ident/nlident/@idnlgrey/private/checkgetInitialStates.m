function [errmsg, outInitialStates] = checkgetInitialStates(inInitialStates, nx, isInit)
%CHECKGETINITIALSTATES  Checks that the InitialStates information is
%   valid. PRIVATE FUNCTION.
%
%   [ERRMSG, OUTINITIALSTATES] = CHECKGETINITIALSTATES(ININITIALSTATES, NX, ISINIT);
%
%   NX is the number of state variables.
%
%   ININITIALSTATES is a NX-by-1 structure array with fields
%      Name   : name of the state (a string).
%      Unit   : unit of the state (a string).
%      Value  : value of the states (a finite real 1-by-Ne vector, where
%               Ne is the number of experiments).
%      Minimum: minimum values of the states (a real 1-by-Ne vector or a
%               real scalar, in which case all initial states have the
%               same minimum value).
%      Maximum: maximum values of the states (a real 1-by-Ne vector or a
%               real scalar, in which case all initial states have the
%               same maximum value).
%      Fixed  : a boolean 1-by-Ne vector, or a scalar boolean (applicable
%               for all states) specifying whether the initial state is
%               fixed or not.
%
%   If ISINIT is true (only so in the idnlgrey constructor), then
%   ININITIALSTATES can be [] or a real finite NX-by-Ne matrix. If it is
%   empty then OUTINITIALSTATES will be an NX-by-1 structure array with
%   fields
%      Name   : 'xi', i = 1, 2, ..., NX.
%      Unit   : ''.
%      Value  : 0
%      Minimum: -Inf.
%      Maximum: Inf.
%      Fixed  : true.
%   If it is a real finite NX-by-Ne matrix, then the Value of the i:th
%   structure array element will be ININITIALSTATES(i, Ne), i.e., a row
%   vector with Ne elements. Minimum, Maximum and Fixed will be -Inf, Inf
%   and true row vectors of the same size as ININITIALSTATES(i, Ne).
%
%   If ISINIT is true, then ININITIALSTATES can be {} (corresponds to [])
%   or a cell array with finite real vectors of size 1-by-Ne.
%
%   ERRMSG is a struct specifying the first error encountered during
%   object consistency checking (empty if no errors found).
%
%   OUTINITIALSTATES is the parsed and checked InitialStates, returned as
%   a NX-by-1 structure array.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $ $Date: 2008/12/04 22:34:52 $
%   Written by Peter Lindskog.

% Check that the function is called with 3 arguments.
nin = nargin;
error(nargchk(3, 3, nin, 'struct'));

% Initialize msg. No error checking of nx or isInit performed.
errmsg = struct([]);

% Create "zero" initial state.
outInitialStates = struct('Name',    defnum({}, 'x', nx),   ... % State names.
    'Unit',    '',                    ... % State units.
    'Value',   0,                     ... % Current value of the initial states.
    'Minimum', -Inf,                  ... % Minimum value of the states.
    'Maximum', Inf,                   ... % Minimum value of the states.
    'Fixed',   true                   ... % Fixed initial state or not.
    );

% Handle the special initialization case.
id0 = 'Ident:idnlmodel:idnlgreyIniFormat1';
msg0 = ctrlMsgUtils.message(id0);
id1 = 'Ident:idnlmodel:idnlgreyIniFormat2';
msg1 = ctrlMsgUtils.message(id1);
id2 = 'Ident:idnlmodel:idnlgreyIniFormat3';
msg2 = ctrlMsgUtils.message(id2);
id3 = 'Ident:idnlmodel:idnlgreyIniFields';
msg3 = ctrlMsgUtils.message(id3);
id4 = 'Ident:idnlmodel:idnlgreyIniFormat4';
msg4 = ctrlMsgUtils.message(id4);

if ((isInit) && isnumeric(inInitialStates))
    % Initialization using numeric data.
    if (isempty(inInitialStates) || isRealMatrix(inInitialStates, nx, NaN, -Inf, Inf, true))
        if ~isempty(inInitialStates)
            % Set Value, Minimum, Maximum and Fixed.
            value = num2cell(inInitialStates, 2);
            [outInitialStates.Value] = deal(value{:});
            [outInitialStates.Minimum] = deal(-Inf(1, size(inInitialStates, 2)));
            [outInitialStates.Maximum] = deal(Inf(1, size(inInitialStates, 2)));
            [outInitialStates.Fixed] = deal(true(1, size(inInitialStates, 2)));
        end
    else
        errmsg = struct('identifier',id0,'message',msg0);
    end
elseif ((isInit) && iscell(inInitialStates))
    % Initialization using cell arrays of numeric vectors.
    if ~isempty(inInitialStates)
        if (length(inInitialStates) ~= nx)
            errmsg = struct('identifier',id1,'message',msg1);
        else
            inInitialStates = {inInitialStates{:}};
            ne = zeros(nx, 1);
            for i = 1:nx
                if (ndims(inInitialStates{i}) ~= 2)
                    errmsg = struct('identifier',id1,'message',msg1);
                    return;
                elseif ~isRealMatrix(inInitialStates{i}, 1, NaN, -Inf, Inf, true)
                    if ~isRealMatrix(inInitialStates{i}', 1, NaN, -Inf, Inf, true)
                        errmsg = struct('identifier',id1,'message',msg1);
                        return;
                    else
                        inInitialStates{i} = inInitialStates{i}';
                    end
                end
                ne(i) = length(inInitialStates{i});
            end
            
            % Check that all elements of inInitialStates has the same
            % length.
            if (length(unique(ne)) ~= 1)
                errmsg = struct('identifier',id1,'message',msg1);
                return;
            end
            
            % Everything went fine. Set Value, Minimum, Maximum and Fixed.
            [outInitialStates.Value] = deal(inInitialStates{:});
            [outInitialStates.Minimum] = deal(-Inf(1, length(inInitialStates{1})));
            [outInitialStates.Maximum] = deal(Inf(1, length(inInitialStates{1})));
            [outInitialStates.Fixed] = deal(true(1, length(inInitialStates{1})));
        end
    end
elseif isstruct(inInitialStates)
    if ((nx == 0) && isempty(inInitialStates))
        % Do nothing.
    elseif ~(all(size(inInitialStates) == [nx 1]) || all(size(inInitialStates) == [1 nx]))
        errmsg = struct('identifier',id2,'message',msg2);
    elseif (   (length(fieldnames(inInitialStates)) ~= 6) ...
            || ~all(ismember(fieldnames(inInitialStates), {'Name' 'Unit' 'Value' 'Minimum' 'Maximum' 'Fixed'})))
        errmsg = struct('identifier',id3,'message',msg3);
    else
        % Loop through the elements of inInitialStates and check their
        % values.
        ne = zeros(nx, 1);
        for i = 1:nx
            % Check that inInitialStates(i).Name is a non-empty single-line
            % string.
            [errmsg, inInitialStates(i).Name] = StateNameCheck(inInitialStates(i).Name, i);
            if ~isempty(errmsg)
                return;
            end
            
            % Check that inInitialStates(i).Unit is a single-line string.
            [errmsg, inInitialStates(i).Unit] = StateUnitCheck(inInitialStates(i).Unit, i);
            if ~isempty(errmsg)
                return;
            end
            
            % Check that inInitialStates(i).Value is a 1-by-ne finite real
            % vector.
            if (ndims(inInitialStates(i).Value) ~= 2)
                ID = 'Ident:idnlmodel:idnlgreyIniValue';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif isempty(inInitialStates(i).Value)
                ID = 'Ident:idnlmodel:idnlgreyIniValue';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif ~isRealMatrix(inInitialStates(i).Value, 1, NaN, -Inf, Inf, true)
                if ~isRealMatrix(inInitialStates(i).Value', 1, NaN, -Inf, Inf, true)
                    ID = 'Ident:idnlmodel:idnlgreyIniValue';
                    msg = ctrlMsgUtils.message(ID,i);
                    errmsg = struct('identifier',ID,'message',msg);
                    return;
                else
                    inInitialStates(i).Value = inInitialStates(i).Value';
                end
            end
            ne(i) = length(inInitialStates(i).Value);
            
            % Check that inInitialStates(i).Minimum is a 1-by-ne real
            % vector.
            if (ndims(inInitialStates(i).Minimum) ~= 2)
                ID = 'Ident:idnlmodel:idnlgreyIniMin';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif ~isRealMatrix(inInitialStates(i).Minimum, 1, NaN, -Inf, Inf, false)
                if ~isRealMatrix(inInitialStates(i).Minimum', 1, NaN, -Inf, Inf, false)
                    ID = 'Ident:idnlmodel:idnlgreyIniMin';
                    msg = ctrlMsgUtils.message(ID,i);
                    errmsg = struct('identifier',ID,'message',msg);
                    return;
                else
                    inInitialStates(i).Minimum = inInitialStates(i).Minimum';
                end
            end
            
            % Check that the size of inInitialStates(i).Minimum is
            % consistent with inInitialStates(i).Value.
            if (length(unique(inInitialStates(i).Minimum)) == 1)
                inInitialStates(i).Minimum = inInitialStates(i).Minimum(1)*ones(1, ne(i));
            elseif (length(inInitialStates(i).Minimum) ~= ne(i))
                ID = 'Ident:idnlmodel:idnlgreyIniMin';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that inInitialStates(i).Minimum <= inInitialStates(i).Value.
            if any(inInitialStates(i).Minimum > inInitialStates(i).Value)
                ID = 'Ident:idnlmodel:idnlgreyIniMinVal';
                msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that inInitialStates(i).Maximum is a 1-by-ne real
            % vector.
            if (ndims(inInitialStates(i).Maximum) ~= 2)
                ID = 'Ident:idnlmodel:idnlgreyIniMax';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif ~isRealMatrix(inInitialStates(i).Maximum, 1, NaN, -Inf, Inf, false)
                if ~isRealMatrix(inInitialStates(i).Maximum', 1, NaN, -Inf, Inf, false)
                    ID = 'Ident:idnlmodel:idnlgreyIniMax';
                    msg = ctrlMsgUtils.message(ID,i);
                    errmsg = struct('identifier',ID,'message',msg);
                    return;
                else
                    inInitialStates(i).Maximum = inInitialStates(i).Maximum';
                end
            end
            
            % Check that the size of inInitialStates(i).Maximum is
            % consistent with inInitialStates(i).Value.
            if (length(unique(inInitialStates(i).Maximum)) == 1)
                inInitialStates(i).Maximum = inInitialStates(i).Maximum(1)*ones(1, ne(i));
            elseif (length(inInitialStates(i).Maximum) ~= ne(i))
                ID = 'Ident:idnlmodel:idnlgreyIniMax';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that inInitialStates(i).Value <=
            % inInitialStates(i).Maximum.
            if any(inInitialStates(i).Value > inInitialStates(i).Maximum)
                ID = 'Ident:idnlmodel:idnlgreyIniMaxVal';
                msg = ctrlMsgUtils.message(ID,i,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            
            % Check that inInitialStates(i).Fixed is a logical 1-by-ne
            % vector.
            if (ndims(inInitialStates(i).Fixed) ~= 2)
                ID = 'Ident:idnlmodel:idnlgreyIniFixed';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif isnumeric(inInitialStates(i).Fixed)
                if ~all(ismember(unique(inInitialStates(i).Fixed), [0 1]))
                    ID = 'Ident:idnlmodel:idnlgreyIniFixed';
                    msg = ctrlMsgUtils.message(ID,i);
                    errmsg = struct('identifier',ID,'message',msg);
                    return;
                end
            elseif ~islogical(inInitialStates(i).Fixed)
                ID = 'Ident:idnlmodel:idnlgreyIniFixed';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            inInitialStates(i).Fixed = logical(inInitialStates(i).Fixed(:)');
            
            % Check that the size of inInitialStates(i).Fixed is
            % consistent with inInitialStates(i).Value.
            if (length(unique(inInitialStates(i).Fixed)) == 1)
                if (inInitialStates(i).Fixed(1))
                    inInitialStates(i).Fixed = true(1, ne(i));
                else
                    inInitialStates(i).Fixed = false(1, ne(i));
                end
            elseif (length(inInitialStates(i).Fixed) ~= ne(i))
                ID = 'Ident:idnlmodel:idnlgreyIniFixed';
                msg = ctrlMsgUtils.message(ID,i);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
        end
        
        % Check uniqueness of inInitialStates.Name.
        value = {inInitialStates.Name};
        if (length(value) ~= length(unique(value)))
            ID = 'Ident:idnlmodel:idnlgreyStateNames';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % Check that all elements of inInitialStates.Value has the same
        % length.
        if (length(unique(ne)) ~= 1)
            ID = 'Ident:idnlmodel:idnlgreyIniValue';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % inInitialStates is valid. Return it.
        outInitialStates = inInitialStates(:);
    end
else
    errmsg = struct('identifier',id4,'message',msg4);
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
function [errmsg, Name] = StateNameCheck(Name, Element)
% Checks specified name.
if ischar(Name)
    if (~isempty(Name) && (ndims(Name) == 2))
        errmsg = struct([]);
        Name = strtrim(Name(:)');
    else
        ID = 'Ident:idnlmodel:idnlgreyStrCheck2';
        msg = ctrlMsgUtils.message(ID,['InitialStates(' num2str(Element) ').Name']);
        errmsg = struct('identifier',ID,'message',msg);
    end
else
    ID = 'Ident:idnlmodel:idnlgreyStrCheck2';
    msg = ctrlMsgUtils.message(ID,['InitialStates(' num2str(Element) ').Name']);
    errmsg = struct('identifier',ID,'message',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsg, Name] = StateUnitCheck(Name, Element)
% Checks specified unit.

if ischar(Name)
    if isempty(Name)
        errmsg = struct([]);
        Name = '';
    elseif (ndims(Name) == 2)
        errmsg = struct([]);
        Name = strtrim(Name(:)');
    else
        ID = 'Ident:idnlmodel:idnlgreyStrCheck1';
        msg = ctrlMsgUtils.message(ID,['InitialStates(' num2str(Element) ').Unit']);
        errmsg = struct('identifier',ID,'message',msg);
    end
else
    ID = 'Ident:idnlmodel:idnlgreyStrCheck1';
    msg = ctrlMsgUtils.message(ID,['InitialStates(' num2str(Element) ').Unit']);
    errmsg = struct('identifier',ID,'message',msg);
end
