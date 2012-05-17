function nlsys = pvset(nlsys, varargin)
%PVSET  Set properties of IDNLMODEL model.
%
%   NLSYS = PVSET(NLSYS, 'Property1', Value1, 'Property2', Value2, ...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2', ...
%
%   For more information on IDNLMODEL properties, type IDNLPROPS IDNLMODEL.
%
%   See also IDNLMODEL/SET.
%
% NOTE: PVSET is performing object specific property value setting
%       for the generic IDNLMODEL/SET method. It expects true property
%       names.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.7 $ $Date: 2008/10/02 18:54:34 $

% Author(s): Qinghua Zhang, Peter Lindskog.

% Check that the function is called with at least one input argument.
nin = nargin;
error(nargchk(1, Inf, nin, 'struct'));

% Check that the function is called with one output argument.
nout = nargout;
error(nargoutchk(1, 1, nout, 'struct'));

% Check that the function was called with an odd number of arguments.
if (rem(nin, 2) ~= 1)
    ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs',upper(class(nlsys)),class(nlsys));
end

% Assign properties.
[ny, nu] = size(nlsys);
uniquecheck = false;
for i = 1:2:nin-1,
    % Set each PV pair one after another.
    property = varargin{i};
    if ~ischar(property)
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    value = varargin{i+1};
    
    % Set property values.
    switch property
        case 'Name'
            if (~ischar(value) || (ndims(value) ~= 2))
                ctrlMsgUtils.error('Ident:general:strPropType','Name')
            end
            nlsys.Name = value(:)';
        case 'Ts'
            value = idutils.utValidateTs(value,false);
            nlsys.Ts = value;
        case 'TimeUnit'
            if ~ischar(value)
                ctrlMsgUtils.error('Ident:general:strPropType','TimeUnit')
            end
            nlsys.TimeUnit = value(:)';
        case 'TimeVariable'
            if ~isvarname(value)
                ctrlMsgUtils.error('Ident:idnlmodel:TimeVariableNotAVarName')
            end
            nlsys.TimeVariable = value(:)';
            uniquecheck = true;
        case 'InputName'
            value = ChannelNameCheck(value, property, nu, nlsys);
            nlsys.InputName(1:length(value)) = value; % Only the first length(value) names are changed.
            uniquecheck = true;
        case 'InputUnit'
            value = ChannelNameCheck(value, property, nu, nlsys);
            nlsys.InputUnit(1:length(value)) = value;
        case 'OutputName'
            value = ChannelNameCheck(value, property, ny, nlsys);
            nlsys.OutputName(1:length(value)) = value; % Only the first length(value) names are changed.
            uniquecheck = true;
        case 'OutputUnit'
            value = ChannelNameCheck(value, property, ny, nlsys);
            nlsys.OutputUnit(1:length(value)) = value;
        case 'NoiseVariance'
            if (~isempty(value) && isreal(value) && (ndims(value) == 2))
                if ~all(all(isfinite(value)))
                    ctrlMsgUtils.error('Ident:general:NoiseVarianceNotReal')
                elseif ((size(value, 1) ~= size(value, 2)) || (size(value , 1) ~= ny))
                    ctrlMsgUtils.error('Ident:general:NoiseVarianceNotSquare')
                elseif (~isequal(norm(value), 0) && (norm(value'-value)/norm(value) > sqrt(eps)))
                    ctrlMsgUtils.error('Ident:general:NoiseVarianceNotSymmetric')
                elseif ~all(diag(value) >= 0)
                    ctrlMsgUtils.error('Ident:general:NoiseVarianceNotPosSemidefinite')
                end
            elseif ~isempty(value)
                ctrlMsgUtils.error('Ident:general:NoiseVarianceNotPosSemidefinite')
            else
                value = [];
            end
            nlsys.NoiseVariance = value;
        case 'Notes'
            if ~(ischar(value) || iscellstr(value))
                ctrlMsgUtils.error('Ident:general:cellstrPropType','Notes',upper(class(nlsys)))
            end
            nlsys.Notes = value;
        case 'UserData'
            nlsys.UserData = value;
            % For developers: private properties.
        case {'Utility', 'Estimated', 'OptimMessenger', 'Version'}
            nlsys.(property) = value;
        otherwise
            % This should never happen!
            %             erro('Ident:idnlmodel:pvset:Invalididnlmodel', ...
            %                   ['Invalid property name specified: ' property '.']);
            ctrlMsgUtils.error('Ident:utility:unknownPropName',property,class(nlsys))
    end
end

% Exit checks!
if uniquecheck
    UniqueNameCheck(nlsys);
    
    % Check that InputName contains nu elements.
    if (length(nlsys.InputName) ~= nu)
        ctrlMsgUtils.error('Ident:general:incorrectUPropLen','InputName',nu)
    end
    
    % Check that InputName does not contain ''.
    if ismember('', nlsys.InputName)
        ctrlMsgUtils.error('Ident:general:nonEmptyStringsRequired','InputName')
    end
    
    % Check that InputName and InputUnit contain equally many elements.
    if (length(nlsys.InputUnit) ~=nu)
        ctrlMsgUtils.error('Ident:general:incorrectUPropLen','InputUnit',nu)
    end
    
    % Check that OutputName contains ny elements.
    if (length(nlsys.OutputName) ~= ny)
        ctrlMsgUtils.error('Ident:general:incorrectYPropLen','OutputName',ny)
    end
    
    % Check that OutputName does not contain ''.
    if ismember('', nlsys.OutputName)
        ctrlMsgUtils.error('Ident:general:nonEmptyStringsRequired','OutputName')
    end
    
    % Check that OutputName and OutputUnit contain equally many elements.
    if (length(nlsys.OutputUnit) ~= ny)
        ctrlMsgUtils.error('Ident:general:incorrectYPropLen','OutputUnit',ny)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isRealScalar(value, low, high, islimited)
% Check that value is a real scalar in the specified range.
result = true;
if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || isnan(value) ...
        || (islimited && ~isfinite(value)) || (value < low) || (value > high)
    result = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UniqueNameCheck(nlsys)
% Check uniqueness of names within InputName, OutputName and TimeVariable.
% Note: the uniqueness of names is important for custom regressor
% definitions.
inname = pvget(nlsys, 'InputName');
outname = pvget(nlsys, 'OutputName');
timevar = pvget(nlsys, 'TimeVariable');

allnames = [inname(:); outname(:); {timevar}];
[uniquenames, ind] = unique(allnames);
if (length(allnames) == length(uniquenames))
    return;
end

ambind = setdiff(1:length(allnames), ind);
ambname = allnames{ambind(1)};

if strcmp(ambname, timevar)
    ctrlMsgUtils.error('Ident:general:TimeVariableIONameClash')
else
    ctrlMsgUtils.error('Ident:general:IONameClash')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a, Name, nch, nlsys)
% Checks specified names.

if isempty(a),
    a = a(:);   % Make a 0x1.
    return;
end

% Determine if the first argument is an array or cell vector of single-line
% strings.
if (ischar(a) && (ndims(a) == 2))
    % A is a 2D array of padded strings.
    a = cellstr(a);
elseif (iscellstr(a) && (ndims(a) == 2) && (min(size(a)) == 1))
    % A is a cell vector of strings. Check that each entry is a single-line
    % string.
    a = a(:);
    if (any(cellfun('ndims', a) > 2) || (any(cellfun('size', a, 1) > 1)))
        ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(nlsys)))
    end
else
    ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(nlsys)))
end

if (length(a) > nch)
    a = a(1:nch);
end
a = strtrim(a);

% FILE END
