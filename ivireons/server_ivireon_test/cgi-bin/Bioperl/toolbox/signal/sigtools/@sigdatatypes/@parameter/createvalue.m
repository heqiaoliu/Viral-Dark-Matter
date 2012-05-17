function createvalue(this)
%CREATEVALUE Create the value property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:21:19 $

valid = get(this, 'ValidValues');

if iscell(valid),
    createvaluefromcell(this);
elseif isa(valid, 'function_handle')
    createValueFromFcn(this);
elseif isnumeric(valid),
    createValueFromVector(this);
elseif ischar(valid),
    % If valid is a string, it must be a predefined data type
    createValueFromType(this);
end

% -----------------------------------------------------------------------
function createValueFromType(this)

schema.prop(this, 'Value', this.ValidValues);

% -----------------------------------------------------------------------
function createValueFromFcn(this)

valid    = get(this, 'ValidValues');
typename = getuniquetype(this, valid);

schema.prop(this, 'Value', typename);

% -----------------------------------------------------------------------
function createValueFromVector(this)

vv = this.ValidValues;

if length(vv) ~= 2 && length(vv) ~= 3,
    error('''ValidValues'' must be a vector of length 2 or 3.');
end

if vv(end) < vv(1),
    error('''ValidValues'' last input argument must be greater than its first.');
end

schema.prop(this, 'Value', 'double');
