function varargout = siguddutils(varargin)
%SIGUDDUTILS   Utilities for UDD.
%   SIGUDDUTILS(FCN, VARARGIN)
%
%SETUPOBSOLETE(P, WARN)  SetFunction to be used for obsolete properties.
%   Throws a warning if WARN is true.  WARN is true by default.
%
%SETUPOBSOLETE(P, NEWPROP, WARN)  SetFunction to be used for obsolete
%   properties.  Warning is changed to tell users to use the NEWPROP.
%   NEWPROP is automatically set.
%
%SETUPOBSOLETE(P, NEWPROP, WARN, ERR) SetFunction to be used for obsolete
%   properties.  Throws an error telling users to use the NEWPROP if ERR is
%   true.  ERR is false by default. 
%
%DISPSTR(H, PROPS, SPACING)  Display for UDD classes.  
%
%READONLYERROR   Returns an error string.
%   READONLYERROR(PROP) Returns a readonly error for the property passed in
%   PROP.
%
%   READONLYERROR(PROP, ENABPROP, ENABVALUE) Returns a conditional readonly
%   error for the property PROP.  The message indicates how to enable the
%   property for writing.
%
%   READONLYERROR(PROP, ENABPROP, ENABVALUE, B) Returns a conditional
%   readonly error.  If B is FALSE, the message indicates which property
%   value does NOT allow the property can be set.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/08/11 15:48:40 $

if nargout
    [varargout{1:nargout}] = feval(varargin{:});
else
    feval(varargin{:});
end

% -------------------------------------------------------------------------
function varargout = abstractmethod(hObj)

d = dbstack;
name = d(3).name;

errormsg.identifier = generatemsgid('abstractMethod');
errormsg.message    = sprintf('The %s method is abstract', upper(name));

% If we are given the object, tell the caller what class is missing the
% method.
if nargin
    errormsg.message = sprintf('%s and must be overloaded by the ''%s'' class.', ...
        errormsg.message, class(hObj));
else
    errormsg.message = sprintf('%s.', errormsg.message);
end

if nargout
    varargout = {errormsg};
else
    error(errormsg.identifier,errormsg.message); 
end

% -------------------------------------------------------------------------
function varargout = obsoletemethod(altname)

d = dbstack;
name = d(3).name;

warnmsg.identifier = generatemsgid('obsoleteMethod');
warnmsg.message    = sprintf('The %s method is obsolete.', upper(name));

if nargin
    warnmsg.message = sprintf('%s  Use %s instead.', warnmsg.message, upper(altname));
end

if nargout
    varargout = {warnmsg};
else
    warning(warnmsg.identifier, warnmsg.message);
end

% -------------------------------------------------------------------------
function varargout = readonlyerror(prop, enabprop, enabvalue, b)

if nargin < 2
    errmsg.identifier = generatemsgid('readOnly');
    errmsg.message    = sprintf('Changing the ''%s'' property is not allowed.', ...
        prop);
else
    if nargin < 4
        modstr = '';
    else
        if b, modstr = '';
        else modstr = 'not ';
        end
    end

    % If the "enable value" is a string, wrap it in extra quotation marks.
    if ischar(enabvalue)
        enabvalue = sprintf('''%s''', enabvalue);
    else
        enabvalue = mat2str(enabvalue);
    end
    
    errmsg.identifier = generatemsgid('readOnly');
    errmsg.message    = sprintf('%s\n%s', ...
        sprintf('Changing the ''%s'' property is only allowed when the', prop), ...
        sprintf('''%s'' property is %sset to %s.', enabprop, modstr, enabvalue));
end

if nargout
    varargout = {errmsg};
else
    error(errmsg.identifier,errmsg.message); 
end

% -------------------------------------------------------------------------
function varargout = dispstr(hObj, props, spacing)

defaultpadding = 4;

% If the caller did not pass in props, show all public properties.
if nargin < 2
    props = fieldnames(hObj);
end

% The caller can pass just a spacing a we should show all public props.
if isnumeric(props)
    spacing = props;
    props   = fieldnames(hObj);
elseif nargin < 3
    spacing = getspacing(props)+defaultpadding;
end

% Make sure we have a cell of string vectors for easy looping.
if ~iscell(props{1})
    props = {props};
end

maxwidth = get(0, 'CommandWindowSize');
maxwidth = max(60, maxwidth(1)-2);

% If MATLAB is set to use LOOSE formating add extra spaces between property
% groups.
if strcmpi(get(0, 'formatspacing'), 'loose')
    spacer = ' ';
else
    spacer = '';
end

str = '';
for indx = 1:length(props)
    for jndx = 1:length(props{indx})
        value = hObj.(props{indx}{jndx});
        
        if ischar(value) || isa(value, 'function_handle')

            if isa(value, 'function_handle')
                % Convert to string
                value = ['@' char(value)];
                % Add '%s' around any strings, but don't add quotes
                valuestr = sprintf('%s', value);
            else
                % Add '%s' around any strings.
                valuestr = sprintf('''%s''', value);

            end

            if length(valuestr)+spacing > maxwidth
                valuestr = shortdescription(value);
            end

        elseif isa(value, 'embedded.fi')
            % Convert all other values to a matrix.
            valuestr = shortdescription(value);
        elseif isstruct(value) || isa(value, 'handle')
            
            valuespacing = spacing+getspacing({fieldnames(value)});
            
            % Call DISPSTR on the contained object/structure.
            valuestr = dispstr(value, valuespacing);
            
            lastline = valuestr(end, :);
            if isempty(deblank(lastline)),
                % Remove extra empty line if necessary
                valuestr(end, :)= [];
            end              

            valuecell{1} = valuestr(1, spacing+1:end);
            
            for kndx = 2:size(valuestr)
                valuecell{kndx} = sprintf('%s%s', repmat(' ', 1, spacing+1), ...
                    valuestr(kndx, spacing:end)); %#ok<AGROW>
            end
            
            valuestr = '';
            for kndx = 1:length(valuecell)
                valuestr = sprintf('%s\n%s', valuestr, valuecell{kndx});
            end
            valuestr(1) = [];
            % Clear variable before entering the new values to avoid cruft.
            clear valuecell;

        elseif iscellstr(value)
            
            % Special case the cellstr code.  This code will not work and
            % will not be hit by nested cells of cellstrs, e.g. it will not
            % work for {{'a','b'}, {'c', 'd'}}, but it will work for
            % {'a', 'b'; 'c', 'd'}.
            [rows, cols] = size(value);
            valuestr = '{';
            if rows == 1
                for cndx = 1:cols
                    valuestr = sprintf('%s''%s'' ', valuestr, value{cndx});
                end
            elseif cols == 1
                for rndx = 1:rows
                    valuestr = sprintf('%s''%s'';', valuestr, value{rndx});
                end
            else
                for rndx = 1:rows
                    for cndx = 1:cols
                        valuestr = sprintf('%s''%s'' ', valuestr, value{rndx,cndx});
                    end
                    valuestr = sprintf('%s;', valuestr(1:end-1));
                end
            end
            valuestr = sprintf('%s}', valuestr(1:end-1));
            
            if length(valuestr)+spacing > maxwidth
                valuestr = shortdescription(value);
            end
        else
            
            if iscell(value) || any(sum(size(value)) == [0 1])
                valuestr = shortdescription(value);
            else
            
                % Convert all other values to a matrix.
                valuestr = mat2str(value);
                if length(valuestr)+spacing > maxwidth
                    valuestr = shortdescription(value);
                end
            end
        end

        % Add white spacing to left align the property names.
        whites = spacing-length(props{indx}{jndx});
        whites = repmat(' ', 1, whites);
        str = strvcat(str, sprintf('%s%s: %s', whites, props{indx}{jndx}, valuestr));
    end
    
    % Add a space in between the groups.
    str = strvcat(str, spacer);
end

if nargout
    varargout = {str};
else
    disp(str);
end

% -------------------------------------------------------------------------
function setupobsolete(p, newprop, warn, err)

% NEWPROP, WARN AND ERR are optional.
if nargin < 4, err     = false; end
if nargin < 3, warn    = true; end
if nargin < 2, newprop = '';   end
if islogical(newprop)
    warn = newprop;
    newprop = '';
end

% Get the property name from P, so callers don't have to pass it.
oldprop = get(p, 'Name');

set(p, 'AccessFlags.Init', 'off', ...
    'SetFunction', {@setobsoleteprop, oldprop, newprop, warn, err}, ...
    'GetFunction', {@getobsoleteprop, oldprop, newprop, warn, err}, ...
    'Visible', 'off');

% -------------------------------------------------------------------------
function valuestr = shortdescription(value)

sz = size(value);

if sum(sz) == 0
    valuestr = '[]';
    return;
end

if iscell(value)
    valuestr = '{';
else
    valuestr = '[';
end
for kndx = 1:length(sz)-1
    valuestr = sprintf('%s%dx', valuestr, sz(kndx));
end
valuestr = sprintf('%s%d %s', valuestr, sz(end), class(value));
if iscell(value)
    valuestr = sprintf('%s}', valuestr);
else
    valuestr = sprintf('%s]', valuestr);
end

% -------------------------------------------------------------------------
function spacing = getspacing(props)

if ~iscell(props{1}), props = {props}; end

spacing = 0;
for indx = 1:length(props)
    for jndx = 1:length(props{indx})
        spacing = max(length(props{indx}{jndx}), spacing);
    end
end

% -------------------------------------------------------------------------
function value = setobsoleteprop(this, value, oldprop, newprop, warn, err)

if nargin < 6, err     = false; end  

p = findprop(this, oldprop);

% Do not warn in the set when the abortset is on because the get will warn.
if strcmpi(get(p, 'AccessFlags.AbortSet'), 'on')
    warn = false;
end

if err
    obsoleteerror(oldprop, newprop);
elseif warn
    obsoletewarning(oldprop, newprop);
end

if ~isempty(newprop)
    % Store the value in the new property.
    set(this, newprop, value)
    
    % Don't store anything.  The property needs to have a get function as well.
    value = [];
end

% -------------------------------------------------------------------------
function value = getobsoleteprop(this, value, oldprop, newprop, warn, err)

if nargin < 6, err     = false; end
if nargin < 5, warn    = false; end
if nargin < 4, newprop = '';    end
if islogical(newprop)
    warn = newprop;
    newprop = '';
end

if err
    obsoleteerror(oldprop, newprop);
elseif warn
    obsoletewarning(oldprop, newprop);
end

if ~isempty(newprop)
    % Store the value in the new property.
    value = get(this, newprop);
end

% -------------------------------------------------------------------------
function varargout = obsoletewarning(oldprop, newprop)

if isempty(newprop)
    advice = '';
else
    advice = sprintf('  Use the ''%s'' property instead.', newprop);
end

warnmsg.identifier = generatemsgid('obsoleteProp');
warnmsg.message = sprintf('The ''%s'' property is obsolete.  %s\n%s', oldprop, ...
    sprintf('Using the ''%s'' property still works,', oldprop), ...
    sprintf('but will be removed in the future.%s', advice));

if nargout
    varargout = {warnmsg};
else
    warning(warnmsg.identifier, warnmsg.message);
end

% -------------------------------------------------------------------------
function varargout = obsoleteerror(oldprop, newprop)

if isempty(newprop)
    advice = '';
else
    advice = sprintf(' Use the ''%s'' property instead.', newprop);
end

errmsg.identifier = generatemsgid('obsoleteProp');
errmsg.message = sprintf('The ''%s'' property is obsolete.%s%s', oldprop, advice);

if nargout
    varargout = {errmsg};
else
    error(errmsg.identifier, errmsg.message);
end

% [EOF]
