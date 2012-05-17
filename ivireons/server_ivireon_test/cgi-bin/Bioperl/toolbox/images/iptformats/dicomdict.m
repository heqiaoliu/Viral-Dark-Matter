function varargout = dicomdict(command, varargin)
%DICOMDICT  Get or set active DICOM data dictionary.
%    DICOMDICT('set', DICTIONARY) sets the DICOM data dictionary to the
%    value stored in DICTIONARY, a string containing the filename of the
%    dictionary.  DICOM-related functions will use this dictionary by
%    default, unless a different dictionary is provided at the command
%    line.
%
%    DICTIONARY = DICOMDICT('get') returns a string containing the
%    filename of the stored DICOM data dictionary.
%
%    DICOMDICT('factory') resets the DICOM data dictionary to its default
%    startup value.
%
%    See also dicom-dict.txt, DICOMINFO, DICOMREAD, DICOMWRITE.

%    DICTIONARY = DICOMDICT('get_current') returns the value of the
%    currently active data dictionary.  This may differ from the value
%    returned by DICOMDICT('get') if a dictionary was specified at the
%    command line.
%
%    DICOMDICT('set_current', DICTIONARY) sets the current dictionary.
%    Use this only when a dictionary was specified at the command line.
%
%    DICOMDICT('reset_current') resets the value of the active data
%    dictionary to match the value of the stored data dictionary (either
%    the value stored by DICOMDICT('set', ...) or the default value).

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:30:22 $

if (nargout > 1)
    error('Images:dicomdict:tooManyOutputs', 'Too many output arguments')
end

persistent dictionary

if (isempty(dictionary))
    % Prevent clearing the workspace from removing these values.
    dictionary = setup_dictionary;
    mlock
end

switch (lower(command))
case 'factory'
    
    dictionary = setup_dictionary;
    
case 'get'

    varargout{1} = dictionary.stored_dictionary;
    
case 'set'
    
    dictionary.stored_dictionary = validateFilename(varargin{1});
    dictionary.current_dictionary = dictionary.stored_dictionary;
    
case 'get_current'
    
    varargout{1} = dictionary.current_dictionary;
    
case 'reset_current'
    
    dictionary.current_dictionary = dictionary.stored_dictionary;
    
case 'set_current'
    
    dictionary.current_dictionary = validateFilename(varargin{1});
    
otherwise
    
    error('Images:dicomdict:invalidCommand', ...
          'Invalid command ''%s''.', command)
    
end



function dictionary = setup_dictionary
%SETUP_DICTIONARY  Reset the dictionary to its factory state.

dictionary.stored_dictionary = validateFilename('dicom-dict.txt');
dictionary.current_dictionary = dictionary.stored_dictionary;



function filenameWithPath = validateFilename(filenameIn)
%VALIDATEFILENAME  Validate the existence of a file and get full pathname.

fid = fopen(filenameIn);
if (fid < 0)
    error('Images:dicomdict:fileNotFound', ...
          'Could not open dictionary file "%s".', ...
          filenameIn);
end
filenameWithPath = fopen(fid);
fclose(fid);

% Take care of the case where the requested dictionary is in the current
% directory.  This file should use a full path, too.
if isempty(find((filenameWithPath == '/') | ...
                (filenameWithPath == '\')))
    filenameWithPath = fullfile(pwd, filenameWithPath);
end
