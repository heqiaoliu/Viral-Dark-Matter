function PN_chars = dicom_encode_pn(PN_struct)
%DICOM_ENCODE_PN  Turn a structure of name info into a formatted string.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:31:05 $

% Empty values and undecorated PN strings should fall through.
if ((~isstruct(PN_struct)) || (isempty(PN_struct)))
    PN_chars = PN_struct;
    return
else
    PN_chars = '';
end

% Encode a decorated PN struct.
for p = 1:numel(PN_struct)

    % Add each of the components to the output string.
    if (isfield(PN_struct, 'FamilyName'))
        PN_chars = [PN_chars PN_struct.FamilyName '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'GivenName'))
        PN_chars = [PN_chars PN_struct.GivenName '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'MiddleName'))
        PN_chars = [PN_chars PN_struct.MiddleName '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'NamePrefix'))
        PN_chars = [PN_chars PN_struct.NamePrefix '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'NameSuffix'))
        PN_chars = [PN_chars PN_struct.NameSuffix '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    % Remove extraneous '^' separators.
    while ((~isempty(PN_chars)) && (PN_chars(end) == '^'))
        PN_chars(end) = '';
    end
    
    % Separate multiple values.
    PN_chars = [PN_chars '\'];
    
end

% Remove extra value delimiter '\'.
PN_chars(end) = '';
