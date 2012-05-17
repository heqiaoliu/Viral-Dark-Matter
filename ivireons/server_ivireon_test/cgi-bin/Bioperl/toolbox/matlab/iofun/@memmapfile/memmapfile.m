classdef memmapfile
%MEMMAPFILE Construct memory-mapped file object.
%   M = MEMMAPFILE(FILENAME) constructs a memmapfile object that maps file
%   FILENAME to memory, using default property values. FILENAME can be a partial
%   pathname relative to the MATLAB path. If the file is not found in or
%   relative to the current working directory, MEMMAPFILE searches down the
%   MATLAB search path.
%    
%   M = MEMMAPFILE(FILENAME, PROP1, VALUE1, PROP2, VALUE2, ...) constructs a
%   memmapfile object, and sets the properties of that object that are named in
%   the argument list (PROP1, PROP2, etc.) to the given values (VALUE1, VALUE2,
%   etc.). All property name arguments must be quoted strings (e.g.,
%   'Writable'). Any properties that are not specified are given their default
%   values.
%
%   Property/Value pairs and descriptions:
%
%       Format: Char array or Nx3 cell array (defaults to 'uint8').
%           Format of the contents of the mapped region. 
%
%           If a char array, Format specifies that the mapped data is to be
%           accessed as a single vector of type specified by Format's
%           value. Supported char arrays are 'int8', 'int16', 'int32', 'int64', 
%           'uint8', 'uint16', 'uint32', 'uint64', 'single', and 'double'.
%
%           If an Nx3 cell array, Format specifies that the mapped data is to be
%           accessed as a repeating series of segments of basic types, each with
%           specific dimensions and name. The cell array must be of the form
%           {TYPE1, DIMS1, NAME1; ...; TYPEn, DIMSn, NAMEn}, where TYPE is one
%           of the data type strings listed above, DIMS is a numeric row vector
%           specifying the dimensions of the segment of data to use, and NAME is
%           a char string specifying the field name to use to access the data
%           (as a subfield of the Data property). See Data property and examples
%           below.
%
%       Repeat: Positive integer or Inf (defaults to Inf).
%           Number of times to apply the specified format to the mapped
%           region of the file. If Inf, repeat until end of file. 
%
%       Offset: Nonnegative integer (defaults to 0).
%           Number of bytes from the start of the file to the start of the
%           mapped region. Offset 0 represents the start of the file.
%
%       Writable: True or false (defaults to false).
%           Access level which determines whether or not Data property (see
%           below) may be assigned to.
%
%   All the properties above may also be accessed after the memmapfile object
%   has been created by dot-subscripting the memmapfile object. For example,
%
%       M.Writable = true;
% 
%   changes the Writable property of M to true.
%
%   Two properties which may not be specified to the MEMMAPFILE constructor as
%   Property/Value pairs are listed below. These may be accessed (with
%   dot-subscripting) after the memmapfile object has been created.
%
%       Data: Numeric array or structure array.
%           Contains the actual memory-mapped data from FILENAME. If Format is a
%           char array, then Data is a simple numeric array of the type
%           specified by Format. If Format is a cell array, then Data is a
%           structure array, the field names of which are specified by the third
%           column of the cell array. The type and shape of each field of Data
%           are determined by the first and second columns of the cell array,
%           respectively. Changes to the Data field or subfields also change the
%           corresponding values in the memory-mapped file.
%
%       Filename: Char array.
%           Contains the name of the file being mapped.
%
%   Note that when a variable containing a memmapfile object goes out of scope
%   or is otherwise cleared, the memory map is automatically unmapped.
%
%   Examples:
%       % To map the file 'records.dat' to a series of unsigned 32-bit
%       % integers and set every other value to zero (in Data and
%       % records.dat): 
%       m = memmapfile('records.dat', 'Format', 'uint32', 'Writable', true);
%       m.data(1:2:end) = 0;
%
%       % To map the file 'records.dat' to a repeating series of 20 singles
%       % (as a 5-by-4 matrix) called 'sdata', followed by 10 doubles (as a
%       1-by-10 vector) called 'ddata': 
%       m = memmapfile('records.dat', 'Format', {'single' [5 4] 'sdata'; ...
%                                                'double', [1 10] 'ddata'});
%       firstSdata = m.Data(1).sdata;
%       firstDdata = m.Data(1).ddata;
%
%   See also MEMMAPFILE/DISP, MEMMAPFILE/GET, MEMMAPFILE/SUBSASGN,
%   MEMMAPFILE/SUBSREF.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2010/05/13 17:42:21 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   PROPERTIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accessible properties of the memory-mapped object
properties
    Writable = false;

    Offset   = 0;
    Format   = 'uint8';
    Repeat   = inf;

    Filename = '';
end

% Private properties of the memory-mapped object
% NOTE: All private properties should have mixed case names with at least one
% medial capital letter so that they are not found by @memmapfile/subsref and
% @memmapfile/subsasgn, which get/set obj.(hCapitalize(fieldname)).
properties (SetAccess='private', GetAccess='private')
    FileSize = 0; % size of file.
end

properties (SetAccess='private', GetAccess='private', Transient=true)
    CheckAlignmentNeeded = any(strcmp(computer, {'SOL2', 'SOL64'}));
    DataHandleHolder;
end
properties (SetAccess='private', GetAccess='private', Dependent=true)
    DataHandle;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   PROPERTY SET AND GET METHODS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods
    function obj = set.Writable(obj, v)
        if ~isscalar(v) || ~isa(v, 'logical')
            error('MATLAB:memmapfile:illegalWritableSetting', ...
                  'The Writable field must contain a scalar logical.');
        end
        obj.Writable = v;
    end % set(writable)

    function obj = set.Offset(obj, v)
        if ~isscalar(v) || ~isnumeric(v) || ~isreal(v)
            error('MATLAB:memmapfile:illegalOffsetType', ...
                  'The Offset field must be a real scalar number.')
        elseif ~isfinite(v) || v < 0 || (~isinteger(v) && v ~= fix(v))
            error('MATLAB:memmapfile:illegalOffsetValue', ...
                  'The Offset field must contain a finite, nonnegative integral value.');
        end
        v = double(v);
        obj.Offset = v;
    end % set(offset)

    function obj = set.Format(obj, v)
        if ~hIsValidFormat(v)
            error('MATLAB:memmapfile:illegalFormatSetting', ...
                  'The Format field specified is invalid.');
        end
        obj.Format = v;
    end % set(format)

    function obj = set.Repeat(obj, v)
        if ~isscalar(v) || ~isnumeric(v) || ~isreal(v)
            error('MATLAB:memmapfile:illegalRepeatType', ...
                  'The Repeat field must contain a real scalar number.');
        elseif isnan(v) || v <= 0 || (~isinteger(v) && v ~= fix(v))
            error('MATLAB:memmapfile:illegalRepeatValue', ...
                  'The Repeat field must contain a positive integral value, or Inf.');
        end
        v = double(v);
        obj.Repeat = v;
    end % set(repeat)

    function obj = set.DataHandle(obj, v)
        % Need to bump internal reference count of DataHandle if MATLAB is making this
        % object a copy of another object. That happens when this object's
        % DataHandle is [], and v is _not_ 0. If DataHandle is not empty, then we
        % are updating the handle internally (due to an unmap).  If v is 0, then we
        % are constructing the object from scratch, or loading the object from disk,
        % since DataHandle is transient.
        if isempty(obj.DataHandleHolder) || isequal(v, 0)
            if isempty(v) || isequal(v, 0) 
                % There's no memory map to share, so create a new DataHandle.
                v = hCreateNewDataHandle();
            end
        end
        obj.DataHandleHolder = memmap_data_handle_holder(v);
    end % set(DataHandle)
    
    function dh = get.DataHandle(obj)
        if ~isempty(obj.DataHandleHolder)
            dh = obj.DataHandleHolder.dataHandle;
        else
            dh = 0;
        end
    end
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   METHODS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

methods (Access='private')

    % -------------------------------------------------------------------------
    % Compute whether accessing data with the specified format/offset/repeat would 
    % lead to an unaligned data exception.
    function bad = hIsUnaligned(obj)
        bad = false;
        if iscell(obj.Format)
            loc = obj.Offset;
            % If we can run through the full frame twice legally, we should be able
            % to run through it infinitely many times, by induction. If repeat is only 1,
            % we only need to get through one frame to be legal.
            for frame = 1:min(2, obj.Repeat)
                for elem = 1:size(obj.Format, 1)
                    if mod(loc, hFrameSize(obj.Format{elem,1})) ~= 0
                        bad = true;
                        return;
                    end
                    loc = loc + hFrameSize(obj.Format(elem,:));
                end
                % This exits the method if we can not fit two frames in the file
                % starting from the offset, and the repeat is set to inf.  In this
                % case if there are no offset problems in the first iteration, it
                % is ok.
                if (obj.Repeat == inf) &&(((loc - obj.Offset) * 2) + obj.Offset) > obj.FileSize
                    return;
                end

            end
        else

            if mod(obj.Offset, hFrameSize(obj.Format)) ~= 0
                bad = true;
                return;
            end
        end

    end % hIsUnaligned


    % -------------------------------------------------------------------------
    function hCreateMap(obj)
        if obj.CheckAlignmentNeeded && hIsUnaligned(obj)
            error('MATLAB:memmapfile:illegalAlignment', ...
                  ['Illegal format, offset, or repeat. Accessing the Data field ', ...
                   'given the\nspecified format, offset, ', ...
                   'and repeat values would cause an unaligned\naddress exception.']);
        end

        if isinf(obj.Repeat)
            numberOfFrames = 1;
        else
            numberOfFrames = obj.Repeat;
        end

        if hFrameSize(obj.Format) * numberOfFrames + obj.Offset > obj.FileSize
            error('MATLAB:memmapfile:fileTooSmall', ...
                  ['File "%s" is not large enough to map with the current format, offset, ' ...
                   'and repeat values.'], obj.Filename);
        end

        mapfileInputStruct.filename = obj.Filename;
        mapfileInputStruct.writable = obj.Writable;
        if obj.Repeat == Inf
            mapfileInputStruct.numElements = 0;
        else
            mapfileInputStruct.numElements = obj.Repeat;
        end
        mapfileInputStruct.offset = obj.Offset;
        mapfileInputStruct.format = obj.Format;
        mapfileInputStruct.dataHandle = obj.DataHandle;

        hMapFile(mapfileInputStruct);
    end % hCreateMap
    
    % -------------------------------------------------------------------------
    function siz = hGetDataSize(obj)
        framesAvailable = fix((obj.FileSize - obj.Offset) / hFrameSize(obj.Format));
        if obj.Repeat == Inf
            siz = [max(framesAvailable, 0) 1];
        elseif framesAvailable < obj.Repeat
            siz = [0 1];
        else
            siz = [obj.Repeat 1];
        end
    end % hGetDataSize

    % -------------------------------------------------------------------------
    % Update filename field of memmapfile obj. 
    %  * Make sure file is accessible. 
    %  * Replace filename with a full path version if it refers to a file on the matlabpath 
    %    or is a partial path name. 
    %  * Recompute cached size of file.
    function obj = hChangeFilename(obj, filename)

        % Validate type of filename
        if ~ischar(filename) || ~isvector(filename) || size(filename, 1) ~= 1
            error('MATLAB:memmapfile:illegalFilenameType', 'Filename must be a string.');
        end

        [fid, reason] = fopen(filename);
        if fid == -1
            error('MATLAB:memmapfile:inaccessibleFile', ...
                  'Cannot access file "%s": %s.', filename, reason);
        end

        foundFilename = fopen(fid); % if file found on MATLABPATH, fopen will return full path
                                    % to found file.

        fseek(fid, 0, 'eof');
        obj.FileSize = ftell(fid);
        fclose(fid);

        % Get full path name
        obj.Filename = hResolveFilename(filename, foundFilename);

    end % hChangeFilename


    % -------------------------------------------------------------------------
    % Handle subsasgn to Data field when it contains a numeric array.
    function [valid, s, newval] = hParseNumericDataSubsasgn(obj, s, newval)
        valid = false; 
        lenS = length(s);

        if lenS == 1
            % X.DATA = NEWVAL
            LHS = subsref(obj, s); % get array being assigned to

            if numel(LHS) == numel(newval)
                if strcmp(class(LHS), class(newval))
                    % Map the operation to X.DATA(:,:) = F(NEWVAL) (where F reshapes NEWVAL suitably)
                    [s, newval] = hMapToTwoColonIndices(LHS, s, newval);
                    valid = true;
                else
                    error('MATLAB:memmapfile:classMismatch', ...
                          'Values assigned to the Data field must have the same class as the Data field.');
                end
            else
                error('MATLAB:memmapfile:sizeMismatch', ...
                      ['In an assignment M.DATA = N, the number of elements in N and ' ...
                       'M.DATA must be the same.']);
            end
        elseif s(2).type(1)=='('
            % X.DATA(INDS)? = NEWVAL
            if lenS == 2
                % X.DATA(INDS) = NEWVAL - this is legal and handled by hSubsasgn as is.

                % Check for out of bound and single-colon indices.
                LHS = subsref(obj, s(1)); % get array being assigned to
                if hSubsasgnIndexOutOfRange(LHS, s(2).subs) || ...
                   hSubsasgnIsSubscriptedDeletion(s(2).subs, newval)
                    error(hGetCommonMemmapfileError('MATLAB:memmapfile:dataFieldSizeFixed'));
                else
                    [s, newval] = hFixSubscriptedColonAssignment(LHS, s, newval);
                    valid = true;
                end
            end
        end

    end % hParseNumericDataSubsasgn

    % -------------------------------------------------------------------------
    % Handle subsasgn to Data field when it contains a structure array.
    function [valid, s, newval] = hParseStructDataSubsasgn(obj, s, newval)
        valid = false; % When this is set to true, LHS must have already been defined.

        % x.data? = FOO
        if length(s)==1
            % x.data = FOO
            error(hGetCommonMemmapfileError('MATLAB:memmapfile:illegalDataFieldModification'));
        elseif s(2).type(1) == '.'
            % x.data.BAR? = FOO
            if length(s)==2
                % x.data.BAR = FOO
                % -  same as x.data(:).BAR = FOO  -
                s = [s(1) substruct('()', {':'}) s(2:end)];
            elseif s(3).type(1) == '('
                % x.data.BAR()? = FOO
                if length(s) == 3
                    % x.data.BAR() = FOO
                    % -  same as x.data(:).BAR() = FOO  -
                    s = [s(1) substruct('()', {':'}) s(2:end)];
                end
            end
        end

        if s(2).type(1) == '('
            % x.data()? = FOO
            if length(s) == 2
                % x.data(inds) = FOO
                error(hGetCommonMemmapfileError('MATLAB:memmapfile:illegalDataFieldModification'));
            elseif s(3).type(1) == '.'
                % x.data().BAR? = FOO
                if length(s) == 3
                    % x.data().BAR = FOO

                    if hSubsasgnIndexOutOfRange(subsref(obj, s(1)), s(2).subs)
                        error(hGetCommonMemmapfileError('MATLAB:memmapfile:dataFieldSizeFixed'));
                    end
                    LHS = subsref(obj, s); % get array being assigned to

                    if numel(LHS) == numel(newval)
                        if strcmp(class(LHS), class(newval))
                            % Map the operation to X.DATA.BAR(:,:) = F(NEWVAL) (where F
                            % reshapes NEWVAL suitably.)
                            [s, newval] = hMapToTwoColonIndices(LHS, s, newval);
                            valid = true;
                        else
                            error('MATLAB:memmapfile:classMismatchForSubfield', ...
                                  ['Values assigned to subfields of the Data field must have the same ' ...
                                   'class as the subfield.']);
                        end
                    else
                        error('MATLAB:memmapfile:sizeMismatchForSubfield', ...
                              ['In an assignment M.DATA(I).FIELD = N, the number of elements ' ...
                               'in N and M.DATA(I).FIELD must be the same.']);
                    end
                elseif s(4).type(1) == '('
                    % x.data().BAR()? = FOO
                    if length(s) == 4
                        % x.data().BAR() = FOO
                        % Check for out of bound and single-colon indices.
                        if hSubsasgnIndexOutOfRange(subsref(obj, s(1)), s(2).subs)
                            error(hGetCommonMemmapfileError('MATLAB:memmapfile:dataFieldSizeFixed'));
                        end
                        LHS = subsref(obj, s(1:3)); % get array being assigned to

                        if hSubsasgnIndexOutOfRange(LHS, s(4).subs) || ...
                           hSubsasgnIsSubscriptedDeletion(s(4).subs, newval)
                            error(hGetCommonMemmapfileError('MATLAB:memmapfile:dataSubfieldSizeFixed'));
                        else
                            [s, newval] = hFixSubscriptedColonAssignment(LHS, s, newval);
                            valid = true;
                        end
                    end
                end
            end
        end

    end % hParseStructDataSubsasgn

    % -------------------------------------------------------------------------
    % Handle subsasgn to Data field.
    function hDoDataSubsasgn(obj, s, newval)
        if ischar(obj.Format)
            [valid, s, newval] = hParseNumericDataSubsasgn(obj, s, newval);
        else
            [valid, s, newval] = hParseStructDataSubsasgn(obj, s, newval);
        end

        if valid
            if isnumeric(newval) && ~isreal(newval)
                error('MATLAB:memmapfile:illegalComplexAssignment', ...
                      'Complex values may not be assigned to Data field or its subfields.');
            end

            hSubsasgn(obj.DataHandle, s(2:end), newval);
        else
            error('MATLAB:memmapfile:illegalSubscriptedAssignment', ...
                  'Illegal subscripted assignment to Data field of memmapfile object.')
        end
    end % hDoDataSubsasgn


    % -------------------------------------------------------------------------
    % Given a subscript structure, s, that is known to index a memmapfile's Data
    % field, determine if s would attempt to assign or reference a comma-separated list.
    function isCSL = hIsCommaSeparatedListOperation(obj, s)
        isCSL = false;
        lenS = length(s);
        % If length(s) == 1, then this is just obj.data
        if lenS > 1
            % Check if data represents a struct
            if iscell(obj.Format)
                % Check if paren-indexing the struct.
                if s(2).type(1) == '(' 
                    % Check for presence of dot-indexing the results of obj.data(<inds>)
                    if lenS > 2 && s(3).type(1) == '.'
                        for i = 1:length(s(2).subs)
                            index = s(2).subs{i};
                            if isnumeric(index) || (ischar(index) && strcmp(index, ':') == 0)
                                % more or less than one numeric index is a CSL.
                                if length(index) ~= 1
                                    isCSL = true;
                                end
                            elseif islogical(index)
                                % more or less than one logical true index is a CSL
                                if sum(index) ~= 1
                                    isCSL = true;
                                end
                            else % is ':'
                                % Data field must be a column vector, so ':' can only 
                                % ever resolve to a non-scalar index when it is the first index.
                                if i == 1
                                    % If the first dimension of data is not 1, the ':' index  
                                    % generates a CSL.
                                    dataSize = hGetDataSize(obj);
                                    if dataSize(1) ~= 1
                                        isCSL = true;
                                    end
                                end
                            end
                        end
                    end
                % If not paren-indexing the struct, make sure it is a scalar
                elseif s(2).type(1) == '.'
                    % OBJ.DATA.FIELD will generate a CSL if OBJ.DATA is not scalar.
                    dataSize = hGetDataSize(obj);
                    isCSL = dataSize(1) ~= 1;
                end
            end
        end

    end % hIsCommaSeparatedListOperation
end % methods

methods

    % -------------------------------------------------------------------------

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Constructor 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = memmapfile(filename, varargin)
        
        error(nargchk(1, nargin, nargin, 'struct'));

        if rem(length(varargin), 2) ~= 0
            error('MATLAB:memmapfile:UnpairedParamsValues', 'Param/value pairs must come in pairs.');
        end

        obj.DataHandle = 0;
        obj = hChangeFilename(obj, filename);

        % Parse param-value pairs
        for i = 1:2:length(varargin)

            if ~ischar(varargin{i})
                error ('MATLAB:memmapfile:illegalParameter', ...
                       'Parameter at input %d must be a string.', i);
            end

            fieldname = varargin{i};
            if hIsPublicProperty(fieldname) && ~strcmpi(fieldname, 'Filename')
                obj.(hCapitalize(fieldname)) = varargin{i+1};
            else
                error('MATLAB:memmapfile:illegalParameter', 'Parameter "%s" is unrecognized.', ...
                      varargin{i});
            end
        end

    end % Constructor
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Sub-assignment method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = subsasgn(obj, s, newval)
        if s(1).type(1) ~= '.'
            if s(1).type(1) == '('
                error(hGetCommonMemmapfileError('MATLAB:memmapfile:illegalParenIndex'));
            else
                error(hGetCommonMemmapfileError('MATLAB:memmapfile:illegalBraceIndex'));
            end
        else
            fieldname = s(1).subs;

            if strcmpi(fieldname, 'data')
                if ~obj.Writable
                    error('MATLAB:memmapfile:dataIsReadOnly', ...
                          'Cannot modify Data field because Writable field is set to false.');
                end

                if (hIsCommaSeparatedListOperation(obj, s))
                    error(hGetCommonMemmapfileError('MATLAB:memmapfile:unsupportedCSL'));
                end

                if ~hIsMapped(obj.DataHandle)
                    hCreateMap(obj);
                end

                hDoDataSubsasgn(obj, s, newval);

            elseif strcmpi(fieldname, 'filename')
                if (length(s) > 1)
                    newname = subsasgn(obj.Filename, s(2:end), newval);
                else
                    newname = newval;
                end

                obj = hChangeFilename(obj, newname);
            else
                s(1).subs = hCapitalize(fieldname);
                builtin('subsasgn', obj, s, newval);
            end

            if hIsPublicProperty(fieldname)
                obj.DataHandle = 0;
            end
        end

    end % Subsassgn

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Sub-reference method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function varargout = subsref(obj, s)
        if (s(1).type(1) == '.')
            if strcmpi(s(1).subs, 'data')
                if (hIsCommaSeparatedListOperation(obj, s))
                    error(hGetCommonMemmapfileError('MATLAB:memmapfile:unsupportedCSL'));
                end

                if ~hIsMapped(obj.DataHandle)
                    hCreateMap(obj);
                end

                varargout{1} = hSubsref(obj.DataHandle, s(2:end));
            else
                if hIsPublicProperty(s(1).subs)
                    s(1).subs = hCapitalize(s(1).subs);
                else
                    % The names of all PrivateProperties have medial caps, which means this
                    % operation will filter them out. But all method names have
                    % only lower case letters, and this operation will not
                    % affect them.
                    s(1).subs = lower(s(1).subs);
                end
                
                [varargout{1:nargout}] = builtin('subsref', obj, s);
            end        
        else
            if s(1).type(1) == '('
                error(hGetCommonMemmapfileError('MATLAB:memmapfile:illegalParenIndex'));
            else
                error(hGetCommonMemmapfileError('MATLAB:memmapfile:illegalBraceIndex'));
            end
        end

    end % Subsref

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Get method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function mInfo = get(obj, property)
        if nargin == 1
            out.Filename = obj.Filename;
            out.Writable = obj.Writable;
            out.Offset = obj.Offset;
            out.Format = obj.Format;
            out.Repeat = obj.Repeat;
            out.Data = subsref(obj, substruct('.', 'Data'));

            if nargout == 0
                disp(out);
            else
                mInfo = out;
            end
        else
            if ischar(property)
                if hIsPublicProperty(property)
                    mInfo = obj.(hCapitalize(property));
                elseif strcmpi(property, 'data')
                    mInfo = subsref(obj, substruct('.', 'Data'));
                else
                    error('MATLAB:memmapfile:get:unknownProperty', ...
                          'There is no ''%s'' property in the ''memmapfile'' class.', ...
                          property);
                end
            elseif iscellstr(property)
                % Make sure property is a row vector.
                property = property(:)';
                mInfo = cell(1, length(property));
                for i = 1:length(property)
                    mInfo{i} = get(obj, property{i});
                end
            else
                error('MATLAB:memmapfile:illegalPropertyType', ...
                      'Property must be a string or cell array of strings.');
            end
        end

    end % GET method

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Disp method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function disp(obj)
        % %12s leaves exactly 4 spaces before the longest attribute, 'Filename', and
        % lines the other strings up by the colon, like how struct display works.
        fprintf(1, '%12s: ''%s''\n', 'Filename', obj.Filename);
        fprintf(1, '%12s: %s\n', 'Writable', mat2str(obj.Writable));
        fprintf(1, '%12s: %d\n', 'Offset', obj.Offset);

        fmt = obj.Format;
        if ischar(fmt)
            fprintf(1, '%12s: ''%s''\n', 'Format', fmt);
        else
            fprintf(1, '%12s: {', 'Format');
            for i = 1:size(fmt, 1)
                if i > 1
                   fprintf(1, '%15s', '');
                end

                fprintf(1, '''%s'' [', fmt{i,1});
                siz = fmt{i,2};
                fprintf(1, '%d ', siz(1:end-1));
                fprintf(1, '%d] ''%s''', siz(end), fmt{i,3});
                if i == size(fmt, 1)
                    fprintf(1, '}');
                end
                fprintf('\n');
            end
        end

        fprintf(1, '%12s: %d\n', 'Repeat', obj.Repeat);

        % Don't print out all of Data, it could be really big. Print a summary instead.
        fprintf(1, '%12s: ', 'Data');

        siz = hGetDataSize(obj);

        if iscell(obj.Format)
            fprintf(1, '%ldx%ld struct array with ', siz);
            fprintf(1, 'fields:\n');
            fprintf(1, '%17s\n', obj.Format{:,3});
        else
            fprintf(1, '%ldx%ld %s array\n', siz, obj.Format);
        end 

        if strcmp(get(0, 'FormatSpacing'), 'loose')
            fprintf(1, '\n');
        end

    end % Disp method

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Struct method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function s = struct(~) %#ok<STOUT>
        error('MATLAB:memmapfile:noStructConversion', ...
              'Memmapfile objects cannot be converted to structures.');
    end % Struct method

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% horzcat method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function c=horzcat(varargin) %#ok<STOUT>
        error(hGetCommonMemmapfileError('MATLAB:memmapfile:noCatenation'));
    end % horzcat

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% vertcat method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function c=vertcat(varargin) %#ok<STOUT>
        error(hGetCommonMemmapfileError('MATLAB:memmapfile:noCatenation'));
    end % vertcat

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% cat method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function c=cat(varargin) %#ok<STOUT>
        error(hGetCommonMemmapfileError('MATLAB:memmapfile:noCatenation'));
    end % cat
end % methods

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Helper method to delete underlying memory map file handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods(Static = true)
    function DeleteDataHandle(dh)
        if ~isequal(dh, 0) 
            if hIsMapped(dh) 
                n = hUnmapFile(dh); %#ok<NASGU>
            end
            hDeleteDataHandle(dh);
        end
    end
    function obj = loadobj(obj)
        if isa(obj, 'memmapfile')
            obj.DataHandle = 0;
        end
    end
    
    function obj = empty(varargin) %#ok<STOUT>
         error(hGetCommonMemmapfileError('MATLAB:memmapfile:noEmptyMethod'));
    end

end

end % Class definition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Validate memmapfile Format field setting.
function isvalid = hIsValidFormat(format)

if ischar(format)
    switch(format)
        case {'double', 'int8', 'int16', 'int32', 'int64', ...
              'uint8', 'uint16', 'uint32', 'uint64', ...
              'single'}
            isvalid = true;
        otherwise
            isvalid = false;
    end

elseif iscell(format)
    if size(format, 1) < 1 || size(format, 2) ~= 3
        isvalid = false;
    else
        isvalid = true;
        for i = 1:size(format, 1)
            field1 = format{i,1};
            field2 = format{i,2};
            field3 = format{i,3};
            % field 1 must be a string containing one of the supported
            % basic data types.
            if ~ischar(field1) || ~hIsValidFormat(field1)
                isvalid = false;
            % field 2 must be a 1xN double array such that N > 0. 
            elseif ~isa(field2, 'double') || ndims(field2) ~= 2 || ...
                    size(field2, 1) ~= 1 || size(field2, 2) < 1
                isvalid = false;
            % field 2 must contain nonnegative integral values 
            elseif any(field2 < 0 | ~isfinite(field2) | ...
                       ~isreal(field2) | field2 ~= fix(field2))
                isvalid = false;
            % field 3 must be a legal MATLAB variable name.
            elseif ~isvarname(field3)
                isvalid = false;
            end
        end
        
        % Make sure all field names are unique and that overall frame size is > 0
        if isvalid
            fields = format(:,3);
            if length(fields) > length(unique(fields))
                isvalid = false;
            elseif hFrameSize(format) == 0
                isvalid = false;
            end
        end
    end
else
    isvalid = false;
end

end % hIsValidFormat


% -------------------------------------------------------------------------
% Return size of a single frame in bytes.
function sz = hFrameSize(format)

sz = 0;
if iscell(format)
    for i=1:size(format, 1)
        sz = sz + hFrameSize(format{i,1}) * prod(format{i,2});
    end
else
    switch format
        case {'int8', 'uint8'}
            sz = 1;
            
        case {'int16', 'uint16'}
            sz = 2;
            
        case {'int32', 'uint32', 'single'}
            sz = 4;
            
        case {'double', 'int64', 'uint64'}
            sz = 8;
    end
end

end % hFrameSize

% -------------------------------------------------------------------------
% Resolve a filename into a fullpath name. origFilename is the name specified by the user;
% foundFilename is the name found by fopen (which includes path information if found on 
% the MATLABPATH).
function resolvedName = hResolveFilename(origFilename, foundFilename)
[directory, basename, extension] = fileparts(origFilename);
if isempty(directory)
    % If we can avoid CD'ing around, lets do it. CD'ing can be slow.
    
    % File found either on path or in current directory. Need to decide which
    directoryOfFound = fileparts(foundFilename);
    if isempty(directoryOfFound)
        % Must have been found in current directory
        resolvedName = fullfile(pwd, origFilename);
    else
        resolvedName = foundFilename;
    end
else
    % Expand partial path name to full name
    ws = warning('off', 'all');
    warningGuard = onCleanup(@() warning(ws));
    oldDir = cd(directory);
    resolvedName = fullfile(cd(oldDir), [basename extension]);
    clear warningGuard
end

end % hResolveFilename

% -------------------------------------------------------------------------

% A(:)=B or A.f(:)=B has the internal effect of replacing
% A with B (after appropriate error checking is made). This causes us 
% to lose the memory mapped data pointer. To work around this,
% we transform to A(:,:)=reshape(B, size(A, 1), []) or
% A.f(:,:)=reshape(B, size(A, 1), [])
function [S, RHS] = hMapToTwoColonIndices(LHS, S, RHS)
RHS = reshape(RHS, size(LHS, 1), []);
S = [S substruct('()', {':', ':'})];
end % hMapToTwoColonIndices

% -------------------------------------------------------------------------
% Check to see if we need to work around internal optimization of single colon
% index. If subscript-assigning a non-scalar to a single-colon indexed variable,
% we need to map to an equivalent double colon index.
function [S, RHS] = hFixSubscriptedColonAssignment(LHS, S, RHS)
if isequal(S(end).subs, {':'}) && ~isscalar(RHS) && ...
        numel(LHS) == numel(RHS)
    [S, RHS] = hMapToTwoColonIndices(LHS, S(1:end-1), RHS);
end
end % hFixSubscriptedColonAssignment

% -------------------------------------------------------------------------
% Check maximum value of subscript values in each subscript position against
% actual size of LHS in corresponding dimension. As a special case, if
% only one subscript position is used (i.e. A(M)=N) then check maximum value of
% M against total number of elements in N.
function outOfRange = hSubsasgnIndexOutOfRange(LHS, indices)
for index = 1:length(indices)
    I = indices{index};
    % colon index can never be bigger than existing dimension.
    if ~isequal(I, ':')
        % Convert logical indices to numeric indices with FIND.
        if islogical(I)
            Imax = max([0; find(I(:))]);
        else
            Imax = max([0; I(:)]);
        end
        
        if (length(indices) == 1 && Imax > numel(LHS)) || ...
                length(indices)  > 1 && Imax > size(LHS, index)
            outOfRange = true;
            return;
        end
    end
end
outOfRange = false;
end % hSubsasgnIndexOutOfRange

% -------------------------------------------------------------------------
% Check if an subscripted assignment operation is actually a subscripted delete
% operation (i.e. assigning [] to a piece of an array). 
function isDeletion = hSubsasgnIsSubscriptedDeletion(subs, RHS)
if isempty(RHS) && (isa(RHS, 'double') || isa(RHS, 'char'))
    % if any subscript is empty, then don't consider this subscripted assignment. It
    % is either legal (if subs only contains one element) or an illegal
    % operation that hSubsasgn and MATLAB's built-in indexing code will catch
    % ("Indexed empty matrix assignment is not allowed.")
    isDeletion = ~any(cellfun('isempty',subs));
else
    isDeletion = false;
end
end % hSubsasgnIsSubscriptedDeletion

% -------------------------------------------------------------------------
% Lookup and return error struct for common error messages
function out = hGetCommonMemmapfileError(id)
switch lower(id)
    case 'matlab:memmapfile:nocatenation'
        msg = 'Memmapfile objects cannot be concatenated.';

    case 'matlab:memmapfile:illegaldatafieldmodification'
        msg = sprintf(['When the Data field of a memmapfile object is a structure,\n' ... 
               'it may not be replaced by assignment.']);
        
    case 'matlab:memmapfile:datafieldsizefixed'
        msg = sprintf(['Cannot change the size of the Data field via subscripted ' ...
                       'assignment.\nThe size of the Data field is determined by ' ...
                       'the Repeat and Format fields.']);

    case 'matlab:memmapfile:datasubfieldsizefixed'
        msg = sprintf(['Cannot change the size of a subfield of the Data field via ' ...
                       'subscripted\nassignment. The sizes of subfields of the Data ' ...
                       'field are determined\nby the Format field.']);
        
    case 'matlab:memmapfile:illegalparenindex'
        msg = 'Memmapfile objects may not be subscripted using ().';

    case 'matlab:memmapfile:illegalbraceindex'
        msg = 'Memmapfile objects may not be subscripted using {}.';

    case 'matlab:memmapfile:unsupportedcsl'
        msg = sprintf(['A subscripting operation on the Data field attempted to ' ...
                       'create a\ncomma-separated list. The memmapfile class does ' ...
                       'not support the use of\ncomma-separated lists when subscripting.']);
    case 'matlab:memmapfile:noemptymethod'
        msg = 'Empty memmapfile objects cannot be created.';
    otherwise
        msg = 'Memmapfile error.';
end

out.identifier = id;
out.message = msg;
end % hGetCommonMemmapfileError

% -------------------------------------------------------------------------
% Capitalize input string (i.e. upper-case the first character, lower-case rest).
function out = hCapitalize(in)
out = lower(in);
out(1) = upper(out(1));
end % hCapitalize

% -------------------------------------------------------------------------
% Determine if input string is the name of a public property, case-insensitively.
function isPublicProperty = hIsPublicProperty(in)
persistent publicProperties;
if isempty(publicProperties)
    publicProperties = properties(mfilename);
end
isPublicProperty = any(strcmpi(publicProperties, in));
end % hIsPublicProperty

