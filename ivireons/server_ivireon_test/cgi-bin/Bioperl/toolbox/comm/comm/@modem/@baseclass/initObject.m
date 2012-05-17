function h = initObject(h, varargin)
%INITOBJECT Initialize object H to values stored in VARARGIN

% @modem/@baseclass

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/06 15:46:51 $

% Find the number of leading numeric values.
nNumeric = 0;
for k=1:nargin-1
    if ~isnumeric(varargin{k})
        break
    end
    nNumeric = nNumeric + 1;
end

% maximum number of numeric args allowed is 2 (M & PhaseOffset)
if (nNumeric > 2)
    error([getErrorId(h) ':InvalidNumericArgs'],['Invalid usage. Type ''help %s'' ' ...
        'to see correct usage.'], lower(class(h)));
end

if (nNumeric == nargin-1)
    % all input arguments are numeric - no prop/value pair
    % H = MODEM.PSKMOD(M, PHASEOFFSET)
    if ( isa(h, 'modem.pskmod') || ...
            isa(h, 'modem.pskdemod') || ...
            isa(h, 'modem.qammod') || ...
            isa(h, 'modem.qamdemod') )

        if nargin >= 2, h.M  = varargin{1}; end
        if nargin == 3, h.PhaseOffset = varargin{2}; end
    else
        error([getErrorId(h) ':InvalidArgs'],['Invalid usage. Type ' ...
            '''help %s'' to see correct usage.'], lower(class(h)));
    end;
elseif (nNumeric == 0)
    if isa(varargin{1}, 'modem.baseclass')
        modType = lower(h.Type(1:findstr(h.Type, ' ')-1));
        if strfind(h.Type, 'Demod')
            if ( strncmp(h.Type, varargin{1}.Type, 4) )
                error([getErrorId(h) ':InvalidRefObjectCopy'],['Invalid ' ...
                    'reference object. Reference object must be of type ' ...
                    'modem.%smod.\nUse <a href="matlab:help modem.copy">' ...
                    'modem.copy</a> method to create same type of object.'], ...
                    modType);
            else
                error([getErrorId(h) ':InvalidModRefObject'],['Invalid ' ...
                    'reference object. Reference object must be of type ' ...
                    'modem.%smod.'], modType);
            end
        else
            if ( strncmp(h.Type, varargin{1}.Type, 4) )
                error([getErrorId(h) ':InvalidRefObjectCopy'],['Invalid ' ...
                    'reference object. Reference object must be of type ' ...
                    'modem.%sdemod.\nUse <a href="matlab:help modem.copy">' ...
                    'modem.copy</a> method to create same type of object.'], ...
                    modType);
            else
                error([getErrorId(h) ':InvalidDemodRefObject'],['Invalid ' ...
                    'reference object. Reference object must be of type ' ...
                    'modem.%sdemod.'], modType);
            end
        end
    else
        % prop/value pair of form:
        % h = MODEM.PSKMOD(PROPERTY1, VALUE1, ...)
        h = initPropValuePairs(h, varargin{:});
    end
else
    % invalid usage
    error([getErrorId(h) ':InvalidUsage'],['Invalid usage. Type ''help %s'' ' ...
        'to see correct usage.'], lower(class(h)));
end

%-------------------------------------------------------------------------------

% [EOF]
