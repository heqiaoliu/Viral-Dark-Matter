function [ds, missing, fileHeader] = xptread(filename,varargin)
%XPTREAD Creates a dataset array from data stored in a SAS XPORT format file.
%
%   DATA = XPTREAD displays a dialog box for selecting a file, then reads
%   data from the file into a dataset array. The file should be in the SAS
%   XPORT format.
%
%   DATA = XPTREAD(FILENAME) retrieves data from a SAS XPORT format file
%   FILENAME.
%
%   The XPORT format allows for 28 missing data types. These are
%   represented in the file by an upper case letter, '.' or '_'. All
%   missing data will be converted to NaN values in DATA. However, if you
%   need the specific missing types then you can recover this information
%   by specifying a second output.
%
%   [DATA,MISSING] = XPTREAD(FILENAME) returns a nominal array, MISSING, of
%   the same size as DATA containing the missing data type information from
%   the XPORT format file. The entries will be undefined for values that
%   are not present and will be one of '.', '_', 'A', ..., 'Z' for missing
%   values.
%
%   XPTREAD(..., 'ReadObsNames',TRUE) treats the first variable in the file
%   as observation names. The default value is false.
%
%   XPTREAD only supports single data sets per file.
%
%   Example:
%
%         % Read in a SAS XPORT format dataset:
%         data = xptread('sample.xpt')
%
%   SAS is a registered trademarks of SAS Institute Inc.
%
%   See also DATASET, DATASET/EXPORT.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:32 $

% The XPORT format specification can be found here:
% http://support.sas.com/techsup/technote/ts140.html

% Process input parameter name/value pairs
pnames = {'readobsnames'};
dflts =  { false };
[errid,errmsg,readObsFlag] = ...
    internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:xptread:%s',errid), errmsg);
end

% If we don't have a filename use uigetfile
if nargin == 0 || isempty(filename)
    [F,P]=uigetfile('*.xpt');
    if isequal(F,0)
        return
    end
    filename = [P,F];
end

% If we cannot find the file, try adding a .xpt extension.
origFilename = filename;
if ~exist(filename,'file')
    % Try adding .xpt extension
    [~,~,fx] = fileparts(filename);
    if ~strcmpi(fx,'xpt')
        filename = [filename '.xpt'];
    end
end
[fid,message] = fopen(filename,'rt','b');
if fid == -1
    error('stats:xptread:CouldNotOpenFile',...
        'Could not open file %s.\n%s',origFilename,message);
end
c = onCleanup(@()fclose(fid));

% The first line should be library header file line
%HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000
line = fread(fid,80, 'uint8=>char')';
if isheader(line)
    hType = headerType(line);
    % should be LIBRARY
    if ~strcmpi(hType,'LIBRARY')
        badFormatError;
    end
else
    badFormatError;
end

% Note that we use 'uint8=>char' to avoid issues with non-ASCII locales.
line = fread(fid,80, 'uint8=>char')';

% Next should be first real header
% aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                 ffffffffffffffff
% In this record:
% -- aaaaaaaa and bbbbbbbb specify 'SAS '
% -- cccccccc specifies 'SASLIB '.
% -- dddddddd specifies the version of the SAS(r) System under which the file was created.
% -- eeeeeeee specifies the operating system that creates the record.
% -- ffffffffffffffff specifies the date and time created, formatted as ddMMMyy:hh:mm:ss. Note
% that only a 2-digit year appears. If any program needs to read in this 2-digit year, be prepared
% to deal with dates in the 1900s or the 2000s.
% Another way to consider this record is as a C structure:
% struct REAL_HEADER {
% char sas_symbol[2][8];
% char saslib[8];
% char sasver[8];
% char sas_os[8];
% char blanks[24];
% char sas_create[16];
% };

FileInformation.SASVersion = strtrim(line(25:32));
FileInformation.OS = strtrim(line(33:40));
FileInformation.Created = strtrim(line(65:80));
FileInformation.CreatedDatenum = datenum(FileInformation.Created,'ddmmmyy:HH:MM:SS');

% Next line should be the date modified

line = fread(fid,80, 'uint8=>char')';
FileInformation.Modified = strtrim(line(1:16));
FileInformation.ModifiedDatenum = datenum(FileInformation.Created,'ddmmmyy:HH:MM:SS');

% Next we should have a member header
line = fread(fid,80, 'uint8=>char')';
if isheader(line)
    hType = headerType(line);
    % Should be LIBRARY
    if ~strcmpi(hType,'MEMBER')
        badFormatError;
    end
else
    badFormatError;
end

NumBytes = str2double(line(end-8:end));
% The next line should be a descriptor header
line = fread(fid,80, 'uint8=>char')';
if isheader(line)
    hType = headerType(line);
    % Should be LIBRARY
    if ~strcmpi(hType,'DSCRPTR')
        badFormatError;
    end
else
    badFormatError;
end
% Now read the member header information
line = fread(fid,80, 'uint8=>char')';
member.DataSetName = strtrim(line(9:16));
member.SASVersion = strtrim(line(25:32));
member.OS = strtrim(line(33:40));
member.Created = strtrim(line(65:80));
member.CreatedDatenum = datenum(member.Created,'ddmmmyy:HH:MM:SS');
member.NumBytes = NumBytes;
% Next line should be the date modified

line = fread(fid,80, 'uint8=>char')';
member.Modified = strtrim(line(1:16));
member.ModifiedDatenum = datenum(member.Modified,'ddmmmyy:HH:MM:SS');

% Next we should have a namestr header
line = fread(fid,80, 'uint8=>char')';
if isheader(line)
    hType = headerType(line);
    % Should be NAMESTR
    if ~strcmpi(hType,'NAMESTR')
        badFormatError;
    end
else
    badFormatError;
end

numVariables = str2double(line(55:58));

% now we get to the information about the variables

% The format Spec says that the record looks like this:

% short ntype; /* VARIABLE TYPE: 1=NUMERIC, 2=CHAR */
% short nhfun; /* HASH OF NNAME (always 0) */
% short nlng; /* LENGTH OF VARIABLE IN OBSERVATION */
% short nvar0; /* VARNUM */
% char8 nname; /* NAME OF VARIABLE */
% char40 nlabel; /* LABEL OF VARIABLE */
% char8 nform; /* NAME OF FORMAT */
% short nfl; /* FORMAT FIELD LENGTH OR 0 */
% short nfd; /* FORMAT NUMBER OF DECIMALS */
% short nfj; /* 0=LEFT JUSTIFICATION, 1=RIGHT JUST */
% char nfill[2]; /* (UNUSED, FOR ALIGNMENT AND FUTURE) */
% char8 niform; /* NAME OF INPUT FORMAT */
% short nifl; /* INFORMAT LENGTH ATTRIBUTE */
% short nifd; /* INFORMAT NUMBER OF DECIMALS */
% long npos; /* POSITION OF VALUE IN OBSERVATION */
% char rest[52]; /* remaining fields are irrelevant */

var(numVariables).ntype = 0;
for count = 1:numVariables
    var(count).ntype = fread(fid,1, 'int16');
    var(count).nhfun = fread(fid,1, 'int16');
    var(count).nlng = fread(fid,1, 'int16');
    var(count).nvar0 = fread(fid,1, 'int16');
    var(count).Name = strtrim(fread(fid,8,'uint8=>char')');
    var(count).vname = genvarname(var(count).Name);
    var(count).Label = deblank(strtrim(fread(fid,40,'uint8=>char')'));
    var(count).Format = deblank(fread(fid,8,'uint8=>char')');
    var(count).nfl = fread(fid,1, 'int16');
    var(count).nfd = fread(fid,1, 'int16');
    var(count).nfj = fread(fid,1, 'int16');
    fread(fid,2,'uint8=>char');
    var(count).niform = strtrim(fread(fid,8,'uint8=>char')');
    var(count).nifl = fread(fid,1, 'int16');
    var(count).nifd = fread(fid,1, 'int16');
    var(count).npos = fread(fid,1, 'int32');
    % There are 52 bytes used at the end as buffer space
    fread(fid,52,'uint8=>char');
end

fileHeader = FileInformation;
fileHeader.DataSetName = member.DataSetName;

% remove the information that we don't care about
Variables = rmfield(var,{'ntype','nhfun','nlng','nvar0','vname','nfl','nfd','nfj','niform','nifl','npos','nifd'});

fileHeader.Variables = Variables;

obsLength = sum([var.nlng]);
% The spec suggests that there should be
% rem(numVariables*member.NumBytes,80) padding spaces however several
% examples that I found seem to differ from this by up to 80 characters
% so rather than assume that the spacing is correct, look for the next
% instance of HEADER. If we don't find the header then error.
padding = 80+rem(numVariables*member.NumBytes,80);
line = fread(fid,padding,'uint8=>char')';
headerPos = findstr(line,'HEADER');
if ~isempty(headerPos)
    reAlignLen = headerPos(1)-padding-1;
    fseek(fid, reAlignLen,0);
else
    badFormatError;
end

% Should be an observation header
line = fread(fid,80, 'uint8=>char')';

if isheader(line)
    hType = headerType(line);
    % should be OBS
    if ~strcmpi(hType,'OBS')
        badFormatError;
    end
else
    badFormatError;
end

% Figure out how much space there is in the file
% This will need modification to work with multi-record files
currPos = ftell(fid);
fseek(fid,0,1);
endPos = ftell(fid);
fseek(fid,currPos,-1);
numObs = floor((endPos-currPos)/obsLength);

emptyObs = false(numObs,1);

% Pre-allocate the data either with zeros or '';
for theVar = 1:numVariables
    if var(theVar).ntype == 1
        obs.(var(theVar).vname)(numObs) = 0;
    else
        obs.(var(theVar).vname){numObs} = '';
    end
end

% Create the missing cell array
missing = repmat({''},numObs,numVariables);

for theObs = 1:numObs
    emptyVar = false(numel(numVariables),1);
    for theVar = 1:numVariables
        if var(theVar).ntype == 1
            % Numeric values could be "missing". There are 28 possible
            % missing types, '.',_,A-Z.
            % Load the bytes then check for problems or missing values.
            checkVal = fread(fid,var(theVar).nlng,'uint8=>char');
            % Catch the case where we go beyond the end of the data and
            % there is whitespace before the next header.
            if isempty(checkVal)
                obs.(var(theVar).vname)(theObs:end) = [];
                continue
            end
            if all(checkVal==' ')
                emptyVar(theVar) = true;
            end
            if numel(checkVal)>1 && all(checkVal(2:end)==0) && ((checkVal(1)>='A'&&checkVal<='Z')||checkVal(1)=='_'||double(checkVal(1))== '.')
                obs.(var(theVar).vname)(theObs) = NaN;
                % Populate the missing array
                missing{theObs,theVar} = checkVal(1);
            else % Otherwise unpack the bytes from the IBM floating point format to IEEE format
                    theVal = ibm2ieee(double(checkVal'));
                 % The spec suggests that IBM integer values are also
                 % permitted but no examples of there were found. This code
                 % should unpack these.
                 %
                 %   expandBytes = 2.^(var(theVar).nlng-1:-1:0)';
                 %   theVal = double(checkVal')*expandBytes;
                 %
                obs.(var(theVar).vname)(theObs) = theVal;
            end
        else
            theString = strtrim(fread(fid,var(theVar).nlng,'uint8=>char')');
            if isempty(theString)
                emptyVar(theVar) = true;
            end
            obs.(var(theVar).vname){theObs} = theString;
        end
    end
    % Use this to clean up empty observations
    if all(emptyVar)
        emptyObs(theObs) = true;
    end
end
% Making the missing output nominal has some advantages.
%
missing = nominal(missing);

for theVar = 1:numVariables
    obs.(var(theVar).vname) = obs.(var(theVar).vname)';
    obs.(var(theVar).vname)(emptyObs) = [];
end

% Create dataset from struct
ds = dataset(obs);
ds = set(ds,'Description',fileHeader.DataSetName);
% Add the format information to the variable description if it exists
for count = 1:numVariables
    if ~isempty(var(count).Format)
        if ~isempty(var(count).Label)
            var(count).Label = sprintf('%s ,Format:%s',var(count).Label,var(count).Format);
        else
            var(count).Label = sprintf('Format:%s',var(count).Format);
        end
    end
end
ds = set(ds,'VarDescription',{var.Label});
if readObsFlag
    % We see if the first variable can be used as observations. If so, then
    % we remove it from the dataset and remove corresponding missing
    % values.
    try
        ds = set(ds,'ObsNames',obs.(var(1).vname));
        ds.(var(1).vname) = [];
        missing(:,1) = [];
    catch theEx
        % If the variable is inappropriate for observations then warn but
        % keep going in the most obvious cases
        if strcmpi(theEx.identifier,'stats:dataset:setobsnames:DuplicateObsnames')
            warning('stats:xptread:DuplicateObsnames',...
                'The first variable in the file contained duplicate values so cannot be used for observation names.');
        elseif strcmpi(theEx.identifier,'stats:dataset:setobsnames:InvalidObsnames')
            warning('stats:xptread:InvalidObsnames',...
                'The first variable in the file contained values that cannot be used for observation names.');
        else
            rethrow(theEx)
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some utility functions for dealing with the repeated nature of the header
% format.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = isheader(line)
tf = strncmpi(line,'HEADER',6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hType = headerType(line)

% header lines look like this
%HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000
%HEADER RECORD*******MEMBER  HEADER RECORD!!!!!!!000000000000000001600000000140
%HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000
hType = strtrim(regexp(line(21:end),'\w[^\W]*\s','match','once'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function badFormatError
% Throw a consistent error message
theException = MException('stats:xptread:BadXPTFormat',...
    'Unable to read the XPT file. Check the file format.');
throwAsCaller(theException)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = ibm2ieee(b)
% d = ibm2ieee(b)
% Convert IBM 360 floating point format, as used in SAS XPORT files,
%    to an IEEE double, as used by MATLAB.
% Input: 1-by-8 vector of "flints", integer-valued doubles in the
%    range 0 <= b(j) < 256.
% Output: a solitary double.

% Thanks to Cleve Moler for providing this routine.

% The XPORT spec allows for truncation of zero bytes so although we expect
% there to be 8 bytes in most case this is generalized to allow for 2 or
% more bytes.

p = 1./16.^(2*(1:numel(b)-1));   % Inverse powers of 16^2

% d = (+|-)16^(b(1)-64)*(b(2)/16^2 + b(3)/16^4 + ... + b(8)/16^14)
e = mod(b(1),128)-64;    % Exponent, base 16
d = 16^e*(b(2:end)*p');  % Vector inner product
if b(1) >= 128           % Negative number
    d = -d;
end

