function [errmsg, varargin] = checkgetShortForm(nlsys, varargin)
%CHECKGETSHORTFORM  Converts Parameters or InitialStates values given on
%   numeric or cell array format to a structure array. PRIVATE FUNCTION.
%
%   [ERRMSG, ERRTYPE, PVPAIR] = CHECKGETSHORTFORM(NLSYS, 'PROPERTY1', ...
%                                  VALUE1, 'PROPERTY2', VALUE2, ...);
%
%   When PROPERTYN is Parameter or InitialStates and these are given as a
%   numeric or a cell array of numerics, the corresponding VALUEN is
%   changed to a structure array with the Value field set to VALUEN. The
%   converted property name-value pair list is returned in PVPAIR. The
%   function checks that the structure of Parameters and InitialStates
%   are not changed (number of parameters and initial states must coincide
%   with what is stored in NLSYS). Other consistency checks are assumed to
%   be done by a method/function that updates the properties of NLSYS
%   (e.g., setext).
%
%   ERRMSG is a struct specifying the first error encountered during
%   object consistency checking (empty if no errors found).
%
%
%   See also IDNLGREY/PEM.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/12/04 22:34:55 $

% Check that the function was called with at least three arguments.
nin = nargin;
error(nargchk(2, Inf, nin, 'struct'));

% Initialize errmsg and errtype.
errmsg = struct([]);

% Check that the function was called with an odd number of arguments.
if (rem(nin, 2) ~= 1)
    ctrlMsgUtils.error('Ident:general:InvalidSyntax','checkgetShortForm','checkgetShortForm')
end

% Loop over the property names and find Parameters and InitialStates for
% which short forms are supported.
for i = 1:2:nin-1
    if strncmpi(varargin{i}, 'Parameters', length(varargin{i}))
        % Parameters.
        if isstruct(varargin{i+1})
            % Do nothing. Leave error checking to set function/method.
        elseif strncmpi(varargin{i+1}, 'Zero', length(varargin{i+1}))
            Parameters = nlsys.Parameters;
            for j = 1:length(Parameters)
                Parameters(j).Value = zeros(size(Parameters(j).Value));
                Parameters(j).Fixed = true(size(Parameters(j).Fixed));
            end
            varargin{i+1} = Parameters;
        elseif strncmpi(varargin{i+1}, 'Fixed', length(varargin{i+1}))
            Parameters = nlsys.Parameters;
            for j = 1:length(Parameters)
                Parameters(j).Fixed = true(size(Parameters(j).Fixed));
            end
            varargin{i+1} = Parameters;
        elseif strncmpi(varargin{i+1}, 'Estimate', length(varargin{i+1}))
            Parameters = nlsys.Parameters;
            for j = 1:length(Parameters)
                Parameters(j).Fixed = false(size(Parameters(j).Fixed));
            end
            varargin{i+1} = Parameters;
        elseif strncmpi(varargin{i+1}, 'Model', length(varargin{i+1}))
            varargin{i+1} = nlsys.Parameters;
        elseif ischar(varargin{i+1})
            ID = 'Ident:estimation:idnlgreyShortFormPar1';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif isnumeric(varargin{i+1})
            % Numeric case.
            Parameters = nlsys.Parameters;
            if ((ndims(varargin{i+1}) ~= 2) || (~any(size(varargin{i+1}) == [1 1]) && ~isempty(varargin{i+1})))
                ID = 'Ident:estimation:idnlgreyShortFormPar2';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (length(varargin{i+1}) ~= length(Parameters))
                ID = 'Ident:estimation:idnlgreyShortFormPar3';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (   any(cellfun('size', getpar(nlsys), 1) ~= 1) ...
                    || any(cellfun('size', getpar(nlsys), 2) ~= 1))
                ID = 'Ident:estimation:idnlgreyShortFormPar3';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            value = num2cell(varargin{i+1}(:)', 1);
            if ~isempty(value)
                [Parameters.Value] = deal(value{:});
            end
            varargin{i+1} = Parameters;
        elseif iscell(varargin{i+1})
            % Cell array case.
            Parameters = nlsys.Parameters;
            if (~any(size(varargin{i+1}) == [1 1]) && ~isempty(varargin{i+1}))
                ID = 'Ident:estimation:idnlgreyShortFormPar4';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif any(cellfun('ndims', varargin{i+1}) ~= 2)
                ID = 'Ident:estimation:idnlgreyShortFormPar4';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (length(varargin{i+1}) ~= length(Parameters))
                ID = 'Ident:estimation:idnlgreyShortFormPar3';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif ~all(cellfun(@(x)(isnumeric(x)), varargin{i+1}))
                ID = 'Ident:estimation:idnlgreyShortFormPar4';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (   any(cellfun('size', getpar(nlsys), 1) ~= cellfun('size', varargin{i+1}(:), 1)) ...
                    || any(cellfun('size', getpar(nlsys), 2) ~= cellfun('size', varargin{i+1}(:), 2)))
                ID = 'Ident:estimation:idnlgreyShortFormPar3';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            value = varargin{i+1}(:);
            if ~isempty(value)
                [Parameters.Value] = deal(value{:});
            end
            varargin{i+1} = Parameters;
        else
            % Incorrect Parameters type. Leave the error checking to set
            % function/method.
        end
    elseif strncmpi(varargin{i}, 'InitialStates', max(length(varargin{i}), 3))
        % InitialStates.
        if isstruct(varargin{i+1})
            % Do nothing. Leave error checking to set function/method.
        elseif strncmpi(varargin{i+1}, 'Zero', length(varargin{i+1}))
            InitialStates = nlsys.InitialStates;
            for j = 1:length(InitialStates)
                InitialStates(j).Value = zeros(size(InitialStates(j).Value));
                InitialStates(j).Fixed = true(size(InitialStates(j).Fixed));
            end
            varargin{i+1} = InitialStates;
        elseif strncmpi(varargin{i+1}, 'Fixed', length(varargin{i+1}))
            InitialStates = nlsys.InitialStates;
            for j = 1:length(InitialStates)
                InitialStates(j).Fixed = true(size(InitialStates(j).Fixed));
            end
            varargin{i+1} = InitialStates;
        elseif strncmpi(varargin{i+1}, 'Estimate', length(varargin{i+1}))
            InitialStates = nlsys.InitialStates;
            for j = 1:length(InitialStates)
                InitialStates(j).Fixed = false(size(InitialStates(j).Fixed));
            end
            varargin{i+1} = InitialStates;
        elseif strncmpi(varargin{i+1}, 'Model', length(varargin{i+1}))
            varargin{i+1} = nlsys.InitialStates;
        elseif ischar(varargin{i+1})
            ID = 'Ident:estimation:idnlgreyShortFormIni1';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif isnumeric(varargin{i+1})
            % Numeric case.
            InitialStates = nlsys.InitialStates;
            if (isempty(InitialStates) && isempty(varargin{i+1}))
                % Do nothing.
            elseif (ndims(varargin{i+1}) ~= 2) || (length(varargin{i+1}) ~= length(InitialStates))
                ID = 'Ident:estimation:idnlgreyShortFormIni2';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                if all(size(varargin{i+1}) == [1 length(InitialStates)])
                    varargin{i+1} = varargin{i+1}(:);
                end
                nem = size(nlsys, 'ne');
                if (size(varargin{i+1}, 2) == nem)
                    value = num2cell(varargin{i+1}, 2);
                    [InitialStates.Value] = deal(value{:});
                else
                    nei = size(varargin{i+1}, 2);
                    for j = 1:length(InitialStates)
                        Minimum = unique(InitialStates(j).Minimum);
                        Maximum = unique(InitialStates(j).Maximum);
                        Fixed = unique(InitialStates(j).Fixed);
                        if all([length(Minimum) length(Maximum) length(Fixed)] == [1 1 1])
                            InitialStates(j).Value = varargin{i+1}(j, :);
                            InitialStates(j).Minimum = Minimum*ones(1, nei);
                            InitialStates(j).Maximum = Maximum*ones(1, nei);
                            InitialStates(j).Fixed = Fixed.*true(1, nei);
                        else
                            ID = 'Ident:estimation:idnlgreyShortFormIni3';
                            msg = ctrlMsgUtils.message(ID);
                            errmsg = struct('identifier',ID,'message',msg);
                            return;
                        end
                    end
                end
            end
            varargin{i+1} = InitialStates;
        elseif iscell(varargin{i+1})
            % Cell array case.
            InitialStates = nlsys.InitialStates;
            if (isempty(InitialStates) && isempty(varargin{i+1}))
                % Do nothing.
            elseif (~any(size(varargin{i+1}) == [1 1]) && ~isempty(varargin{i+1})) ||...
                    any(cellfun('ndims', varargin{i+1}) ~= 2) || ...
                    (length(varargin{i+1}) ~= length(InitialStates)) || ...
                    ~all(cellfun(@(x)(isnumeric(x)), varargin{i+1})) || ...
                    (length(unique(cellfun('size', varargin{i+1}, 1))) ~= 1) || ...
                    (length(unique(cellfun('size', varargin{i+1}, 2))) ~= 1)
                ID = 'Ident:estimation:idnlgreyShortFormIni4';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                for j = 1:length(varargin{i+1})
                    varargin{i+1}{j} = varargin{i+1}{j}(:)';
                end
                nem = size(nlsys, 'ne');
                if (size(varargin{i+1}{1}, 2) == nem)
                    value = varargin{i+1};
                    [InitialStates.Value] = deal(value{:});
                else
                    nei = size(varargin{i+1}{1}, 2);
                    for j = 1:length(InitialStates)
                        Minimum = unique(InitialStates(j).Minimum);
                        Maximum = unique(InitialStates(j).Maximum);
                        Fixed = unique(InitialStates(j).Fixed);
                        if all([length(Minimum) length(Maximum) length(Fixed)] == [1 1 1])
                            InitialStates(j).Value = varargin{i+1}{j};
                            InitialStates(j).Minimum = Minimum*ones(1, nei);
                            InitialStates(j).Maximum = Maximum*ones(1, nei);
                            InitialStates(j).Fixed = Fixed.*true(1, nei);
                        else
                            ID = 'Ident:estimation:idnlgreyShortFormIni3';
                            msg = ctrlMsgUtils.message(ID);
                            errmsg = struct('identifier',ID,'message',msg);
                            return;
                        end
                    end
                end
            end
            varargin{i+1} = InitialStates;
        else
            % Incorrect InitialStates type. Leave the error checking to set
            % function/method.
        end
    end
end