function varargout = dicomwrite(X, varargin)
%DICOMWRITE   Write images as DICOM files.
%   DICOMWRITE(X, FILENAME) writes the binary, grayscale, or truecolor
%   image X to the file named in FILENAME.
%
%   DICOMWRITE(X, MAP, FILENAME) writes the indexed image X with colormap
%   MAP.
%
%   DICOMWRITE(..., PARAM1, VALUE1, PARAM2, VALUE2, ...) specifies
%   optional metadata to write to the DICOM file or parameters that
%   affect how the DICOM file is written.  PARAM1 is a string containing
%   the metadata attribute name or a DICOMWRITE-specific option.  VALUE1
%   is the corresponding value for the attribute or option.
%
%   Acceptable attribute names are listed in the data dictionary
%   dicom-dict.txt.  In addition, the following DICOM-specific options
%   are allowed:
%
%     'Endian'           The byte-ordering for the file: 'Big' or
%                        'Little' (default).  
%
%     'VR'               Whether the value representation should be
%                        written to the file: 'Explicit' or 'Implicit'
%                        (default). 
%
%     'CompressionMode'  The type of compression to use when storing the
%                        image: 'JPEG lossless', 'JPEG lossy', 'RLE', or
%                        'None' (default).
%
%     'TransferSyntax'   A DICOM UID specifying the Endian, VR and
%                        CompressionMode options. 
%
%     'Dictionary'       DICOM data dictionary containing private data
%                        attributes.
%
%     'WritePrivate'     Logical value indicating whether private data
%                        should be written to the file: true or false
%                        (default).
%
%     'CreateMode'       The method for creating the data to put in the
%                        new file. 'Create' (default) verifies input
%                        values and makes missing data values. 'Copy'
%                        simply copies all values from the input and does
%                        not generate missing values.  See the note below
%                        about file creation.
%
%   NOTE: FILE ENCODING
%   -------------------
%
%   If the TransferSyntax option is provided, DICOMWRITE ignores the values
%   of the Endian, VR, and CompressionMode options. If TransferSyntax is
%   not provided, DICOMWRITE uses the value of CompressionMode, if
%   specified, and ignores Endian and VR.  If neither TransferSyntax or
%   CompressionMode are provided, DICOMWRITE uses the values of Endian and
%   VR.  Specifying an Endian value of 'Big' and a VR value of 'Implicit'
%   is not allowed.
%
%
%   DICOMWRITE(..., 'ObjectType', IOD, ...) writes a file containing the
%   necessary metadata for a particular type of DICOM Information Object
%   (IOD).  Supported IODs are:
%
%     'Secondary Capture Image Storage' (default)
%     'CT Image Storage'
%     'MR Image Storage'
%
%   DICOMWRITE(..., 'SOPClassUID', UID, ...) provides an alternate method
%   for specifying the IOD to create.  UID is the DICOM unique identifier
%   corresponding to one of the IODs listed above.
%
%   DICOMWRITE(..., META_STRUCT, ...) specifies optional metadata or
%   options for the file via a structure.  The structure's fieldnames are
%   analogous to the parameter strings in the syntax shown above, and a
%   field's value is that parameter's value.
%
%   DICOMWRITE(..., INFO, ...) uses the metadata structure INFO produced
%   by DICOMINFO.
%
%   STATUS = DICOMWRITE(...) returns information about the metadata and
%   the descriptions used to generate the DICOM file.  STATUS is a
%   structure with the following fields:
%
%     'BadAttribute'      The attribute's internal description is bad.
%                         It may be missing from the data dictionary or
%                         have incorrect data in its description.
%
%     'MissingCondition'  The attribute is conditional but no condition
%                         has been provided about when to use it.
%
%     'MissingData'       No data was provided for an attribute that must
%                         appear in the file.
%
%     'SuspectAttribute'  Data in the attribute does not match a list of
%                         enumerated values in the DICOM spec.
%
%
%   NOTE: FILE CREATION
%   -------------------
% 
%   The DICOM format specification lists several Information Object
%   Definitions (IODs) that can be created.  These IODs correspond to
%   images and metadata produced by different real-world modalities (e.g.,
%   MR, X-ray, Ultrasound, etc.).  For each type of IOD, the DICOM
%   specification defines the set of metadata that must be present and
%   possible values for other metadata.
% 
%   DICOMWRITE fully implements a limited number of these IODs, listed
%   above in the ObjectType syntax.  For these IODs, DICOMWRITE verifies
%   that all required metadata attributes are present, creates missing
%   attributes, if necessary, and specifies default values where possible.
%   Using these supported IODs is the best way to ensure that the files you
%   create conform to the DICOM specification.  This is DICOMWRITE's
%   default behavior and corresponds to a CreateMode option value of
%   'Create'.
%
%   To write DICOM files for IODs that DICOMWRITE doesn't implement with
%   verification, use the 'Copy' value for the CreateMode option.  In this
%   mode, DICOMWRITE writes the image data to a file including the metadata
%   that you specify as a parameter, shown above in the INFO syntax. The
%   purpose of this option is to take metadata from an existing file of the
%   same modality or IOD and use it to create a new DICOM file with
%   different image pixel data.      
%
%
%   WARNING
%   -------
%
%   Use caution when using the 'Copy' CreateMode. Because DICOMWRITE copies
%   metadata to the file without verification in this mode, it is possible
%   to create a DICOM file that may not conform to the DICOM standard. For
%   example, the file may be missing required metadata, contain superfluous
%   metadata, or the metadata may no longer correspond to the modality
%   settings used to generate the original image. When using ’Copy’
%   CreateMode, make sure that the metadata you use is from the same
%   modality and IOD.  If the copy you make is unrelated to the original
%   image, use DICOMUID to create new unique identifiers for series and
%   study metadata.  See the IOD descriptions in part 3 of the DICOM spec
%   for more information on appropriate IOD values.
%
%
%   Examples
%   --------
%
%   % Write a basic "secondary capture" image.
%   X = dicomread('CT-MONO2-16-ankle.dcm');
%   dicomwrite(X, 'sc_file.dcm');
%
%   % Write a CT image with metadata.
%   % In this mode, DICOMWRITE verifies the metadata written
%   % to the file.
%   metadata = dicominfo('CT-MONO2-16-ankle.dcm');
%   dicomwrite(X, 'ct_file.dcm', metadata);
%
%   % Copy all metadata from one file to another.
%   % In this mode, DICOMWRITE does not verify the metadata written
%   % to the file.
%   dicomwrite(X, 'ct_copy.dcm', metadata, 'CreateMode', 'copy');
%
%
%   See also  DICOMDICT, DICOMINFO, DICOMREAD, DICOMUID.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/15 15:18:40 $


%
% Parse input arguments. 
%

if (nargin < 2)
    eid = 'Images:dicomwrite:tooFewInputs';
    error(eid, '%s', 'At least two input arguments required.')
elseif (nargout > 1)
    eid = 'Images:dicomwrite:tooManyOutputs';
    error(eid, '%s', 'Too many output arguments.')
end

checkDataDimensions(X);
[filename, map, metadata, options] = parse_inputs(varargin{:});


%
% Register SOP classes, dictionary etc.
%

dicomdict('set_current', options.dictionary);


%
% Write the DICOM file.
%

try
    
    status = write_message(X, filename, map, metadata, options);

    if (nargout == 1)
        varargout{1} = status;
    end
    
catch ME
    
    dicomdict('reset_current');
    rethrow(ME)
    
end

dicomdict('reset_current');



function varargout = write_message(X, filename, map, metadata, options)
%WRITE_MESSAGES  Write the DICOM message.

%
% Abstract syntax negotiation.
% (SOP class and transfer syntax)
%

if (isequal(options.createmode, 'create'))
    SOP_UID = determine_IOD(options, metadata);
end
options.txfr = determine_txfr_syntax(options, metadata);


%
% Construct, encode, and write SOP instance.
%

num_frames = size(X, 4);
for p = 1:num_frames
    
    % Construct the SOP instance's IOD.
    if (isequal(options.createmode, 'create'))
        
        [attrs, msg, status] = dicom_create_IOD(SOP_UID, X(:,:,:,p), map, ...
                                                metadata, options);
        
    elseif (isequal(options.createmode, 'copy'))
        
        [attrs, msg, status] = dicom_copy_IOD(X(:,:,:,p), map, ...
                                              metadata, options);
        
    else
        
        eid = 'Images:dicomwrite:badCreateMode';
        error(eid, '%s', 'Unsupported value for CreateMode');
        
    end
    
    if (~isempty(msg))
        eid = 'Images:dicomwrite:iodCreationError';
        error(eid, '%s', msg);
    end
    
    attrs = sort_attrs(attrs);
    attrs = remove_duplicates(attrs);
    
    % Encode the attributes.
    data_stream = dicom_encode_attrs(attrs, options.txfr);
    
    % Write the SOP instance.
    destination = get_filename(filename, p, num_frames);
    msg = write_stream(destination, data_stream);
    if (~isempty(msg))
        eid = 'Images:dicomwrite:streamWritingError';
        error(eid, '%s', msg);
    end
    
end

varargout{1} = status;



function [filename, map, metadata, options] = parse_inputs(varargin)
%PARSE_INPUTS   Obtain filename, colormap, and metadata values from input.

metadata = struct([]);
options.writeprivate = false;  % Don't write private data by default.
options.createmode = 'create';  % Create/verify data by default.
options.dictionary = dicomdict('get_current');

[filename, map, currentArg] = getFilenameAndColormap(varargin{:});

% Process metadata.
%
% Structures containing multiple values can occur anywhere in the
% metadata information as long as they don't split a parameter-value
% pair.  Any number of structures can appear.

while (currentArg <= nargin)

    if (ischar(varargin{currentArg}))
        
        % Parameter-value pair.
        
        if (currentArg ~= nargin)  % Make sure it's part of a pair.

            [metadata, options] = processPair(metadata, options, ...
                                      varargin{currentArg:(currentArg + 1)});
            
        else

            eid = 'Images:dicomwrite:missingValue';
            msg = sprintf('Parameter %s must have an associated value.', ...
                          varargin{currentArg});
            error(eid, '%s', msg);
            
        end
        
        currentArg = currentArg + 2;
        
    elseif (isstruct(varargin{currentArg}))
        
        % Structure of parameters and values.

        str = varargin{currentArg};
        fields = fieldnames(str);
        
        for p = 1:numel(fields)
            
            [metadata, options] = processPair(metadata, options, ...
                                              fields{p}, str.(fields{p}));
        end
        
        currentArg = currentArg + 1;
        
    else
        
        eid = 'Images:dicomwrite:expectedFilenameOrColormapOrMetadata';
        msg = 'Argument must be filename, colormap, or metadata parameter.';
        error(eid, '%s', msg);
        
    end

end

% make sure options.createmode is lower case (see g320584) so the code works
% regardless of the casing.
options.createmode = lower(options.createmode);


function SOP_UID = determine_IOD(options, metadata)
%DETERMINE_IOD   Pick the DICOM information object to create.
  
if (isfield(options, 'objecttype'))
  
    switch (lower(options.objecttype))
    case 'ct image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.2';

    case 'mr image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.4';
     
    case 'secondary capture image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.7';
        
    otherwise
        
        eid = 'Images:dicomwrite:unsupportedObjectType';
        error(eid, 'Unsupported ObjectType "%s"', num2str(options.objecttype));
     
    end
    
elseif (isfield(options, 'sopclassuid'))

    if (ischar(options.sopclassuid))
      
        SOP_UID = options.sopclassuid;
        
    else
      
        eid = 'Images:dicomwrite:InvalidSOPClassUID';
        error(eid, 'SOPClassUID must be a character array.')
        
    end
    
elseif (isfield(metadata, 'SOPClassUID'))

    if (ischar(options.SOPClassUID))
      
        SOP_UID = options.SOPClassUID;
        
    else
      
        eid = 'Images:dicomwrite:InvalidSOPClassUID';
        error(eid, 'SOPClassUID must be a character array.')
        
    end
  
elseif ((isfield(metadata, 'Modality')) && (isequal(metadata.Modality, 'CT')))
      
    SOP_UID = '1.2.840.10008.5.1.4.1.1.2';
    
elseif ((isfield(metadata, 'Modality')) && (isequal(metadata.Modality, 'MR')))
      
    SOP_UID = '1.2.840.10008.5.1.4.1.1.4';
    
else
  
    % Create SC Storage objects by default.
    SOP_UID = '1.2.840.10008.5.1.4.1.1.7';
    
end



function txfr = determine_txfr_syntax(options, metadata)
%DETERMINE_TXFR_SYNTAX   Find the transfer syntax from user-provided options.
%
% The rules for determining transfer syntax are followed in this order:
%
% (1) Use the command line option 'TransferSyntax'.
%
% (2) Use the command line option 'CompressionMode'.
%
% (3) Use a combination of the command line options 'VR' and 'Endian'.
%
% (4) Use the metadata's 'TransferSyntaxUID' field.
%
% (5) Use the default implicit VR, little-endian transfer syntax.


% Rule (1): 'TransferSyntax' option.
if (isfield(options, 'transfersyntax'))

    txfrStruct = dicom_uid_decode(options.transfersyntax);
    
    if (~isempty(txfrStruct) && ...
        isequal(txfrStruct.Type, 'Transfer Syntax'))
      
        txfr = options.transfersyntax;
        
    else
      
        error('Images:dicomwrite:unsupportedTransferSyntax', ...
              'Unsupported transfer syntax "%s".', ...
              num2str(options.transfersyntax))
        
    end
    
    return
    
end

% Rule (2): 'CompressionMode' option.
if (isfield(options, 'compressionmode'))
    
    switch (lower(options.compressionmode))
    case 'none'
        
        % Pick transfer syntax below.
        
    case 'rle'
        
        txfr = '1.2.840.10008.1.2.5';
        return
    
    case 'jpeg lossless'
        
        txfr = '1.2.840.10008.1.2.4.70';
        return
        
    case 'jpeg lossy'

        txfr = '1.2.840.10008.1.2.4.50';
        return
    
    otherwise
        
        eid = 'Images:dicomwrite:unrecognizedCompressionMode';
        error(eid, 'Unrecognized compression mode "%s".', ...
              num2str(options.compressionmode));
        
    end
    
end

% Handle rules (3), (4), and (5) together.
if ((isfield(options, 'vr')) || (isfield(options, 'endian')))
    
    override_txfr = true;
    
else
    
    override_txfr = false;
    
end

if (~isfield(options, 'vr'))
    options(1).vr = 'implicit';
end

    
if (~isfield(options, 'endian'))
    options(1).endian = 'ieee-le';
end
        
switch (options.vr)
case 'explicit'
    
    switch (lower(options.endian))
    case 'ieee-be'
        txfr = '1.2.840.10008.1.2.2';
    case 'ieee-le'
        txfr = '1.2.840.10008.1.2.1';
    otherwise
        eid = 'Images:dicomwrite:invalidEndianValue';
        error(eid, '%s', 'Endian value must be ''ieee-be'' or ''ieee-le''.');
    end
    
case 'implicit'
    
    switch (lower(options.endian))
    case 'ieee-be'
        eid = 'Images:dicomwrite:invalidVREndianCombination';
        error(eid, '%s', 'Implicit VR and ieee-be endian is an invalid combination.')
    case 'ieee-le'
        txfr = '1.2.840.10008.1.2';
    otherwise
        eid = 'Images:dicomwrite:invalidEndianValue';
        error(eid, '%s', 'Endian value must be ''ieee-be'' or ''ieee-le''.');
    end

otherwise

    eid = 'Images:dicomwrite:invalidVRValue';
    error(eid, '%s', 'VR value must be ''explicit'' or ''implicit''.')
    
end

if (override_txfr)
    
    % Rule (3): 'VR' and/or 'Endian' options provided.
    return
    
else
    
    if (isfield(metadata, 'TransferSyntaxUID'))
        
        % Rule (4): 'TransferSyntaxUID' metadata field.
        txfr = metadata.TransferSyntaxUID;
        return
        
    else
        
        % Rule (5): Default transfer syntax.
        return
        
    end
    
end



function out = sort_attrs(in)
%SORT_ATTRS   Sort the attributes by group and element.

attr_pairs = [[in(:).Group]', [in(:).Element]'];
[tmp, idx_elt] = sort(attr_pairs(:, 2));
[tmp, idx_grp] = sort(attr_pairs(idx_elt, 1));

out = in(idx_elt(idx_grp));



function out = remove_duplicates(in)
%REMOVE_DUPLICATES   Remove duplicate attributes.
  
attr_pairs = [[in(:).Group]', [in(:).Element]'];
delta = sum(abs(diff(attr_pairs, 1)), 2);

out = [in(1), in(find(delta ~= 0) + 1)];



function status = write_stream(destination, data_stream)
%WRITE_STREAM   Write an encoded data stream to the output device.

% NOTE: Currently local only.
file = dicom_create_file_struct;
file.Filename = destination;
    
file = dicom_open_msg(file, 'w');
    
[file, status] = dicom_write_stream(file, data_stream);

dicom_close_msg(file);



function filename = get_filename(file_base, frame_number, max_frame)
%GET_FILENAME   Create the filename for this frame.

if (max_frame == 1)
    filename = file_base;
    return
end

% Create the file number.
num_length = ceil(log10(max_frame + 1));
format_string = sprintf('%%0%dd', num_length);
number_string = sprintf(format_string, frame_number);

% Look for an extension.
idx = max(strfind(file_base, '.'));

if (~isempty(idx))
    
    base = file_base(1:(idx - 1));
    ext  = file_base(idx:end);  % Includes '.'
    
else
    
    base = file_base;
    ext  = '';
    
end

% Put it all together.
filename = sprintf('%s_%s%s', base, number_string, ext);



function [filename, map, currentArg] = getFilenameAndColormap(varargin)
% Filename and colormap.
if (ischar(varargin{1}))
    
    filename = varargin{1};
    map = [];
    currentArg = 2;
    
elseif (isnumeric(varargin{1}))
    
    map = varargin{1};
    
    if ((nargin > 1) && (ischar(varargin{2})))
        filename = varargin{2};
    else
        eid = 'Images:dicomwrite:filenameMustBeString';
        msg = 'Filename must be a string.';
        error(eid, '%s', msg);
    end
    
    currentArg = 3;
    
else
    
    % varargin{1} is second argument to DICOMWRITE.
    eid = 'Images:dicomwrite:expectedFilenameOrColormap';
    msg = 'Second argument must be a filename or colormap.';
    error(eid, '%s', msg);
    
end



function [metadata, options] = processPair(metadata, options, param, value)

dicomwrite_fields = {'colorspace'
                     'vr'
                     'endian'
                     'compressionmode'
                     'transfersyntax'
                     'objecttype'
                     'sopclassuid'
                     'dictionary'
                     'writeprivate'
                     'createmode'};

idx = strmatch(lower(param), dicomwrite_fields);
            
if (numel(idx) > 1)
    eid = 'Images:dicomwrite:ambiguousParameter';
    error(eid, 'Ambiguous parameter "%s" specified.', param);
end
            
if (~isempty(idx))
  
    % It's a DICOMWRITE option.
    options(1).(dicomwrite_fields{idx}) = value;
  
    if (isequal(dicomwrite_fields{idx}, 'transfersyntax'))
      
        % Store TransferSyntax in both options and metadata.
        metadata(1).TransferSyntax = value;
                    
    end
    
else
  
    % It's a DICOM metadata attribute.
    metadata(1).(param) = value;
    
end
            


function checkDataDimensions(data)

% How many bytes does each element occupy in the file?  This assumes
% pixels span the datatype.
switch (class(data))
case {'uint8', 'int8', 'logical'}

    elementSize = 1;
    
case {'uint16', 'int16', 'double'}

    elementSize = 2;
    
case {'uint32', 'int32'}

    elementSize = 4;
    
otherwise

    % Let a later function error about unsupported datatype.
    elementSize = 1;
    
end

% Validate that the dataset/image will fit within 32-bit offsets.
max32 = double(intmax('uint32'));

if (any(size(data) > max32))
    
    error('Images:dicomwrite:sideTooLong', ...
          'Images must have fewer than 2^32 - 1 elements on a side.')
    
elseif ((numel(data) * elementSize) > max32)
    
    error('Images:dicomwrite:tooMuchData', ...
          'Images must contain fewer than 2^32 - 1 bytes of data.')
    
end
