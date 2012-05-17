function [errTxt, newValue] = ec_check_user_entered_fields(csParam, oldValue, varargin)
%EC_CHECK_USER_ENTERED_FIELDS Checks the validity of user entered fields in GUI
%
% Inputs:
%    csParam:  name of a configuration set parameter
%    oldValue: value of the configuration set parameter
% Outputs:
%    errTxt:   generated error message when user entered field is invalid
%    newValue: oldValue with leading and/or trailing whitespace removed

%  Copyright 2004-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.11 $
%

errTxt = '';
newValue = oldValue;

switch csParam
  %%% Global data placement
  case 'DataDefinitionFile'
    newValue = strtrim(oldValue);
    [errTxt,hasDelimiters]= slprivate('check_generated_filename',newValue,'.c');
    if hasDelimiters
      errTxt = sprintf('Delimiters are not allowed in file name. %s',errTxt);
    end
  case 'DataReferenceFile'
    newValue = strtrim(oldValue);
    [errTxt,hasDelimiters]= slprivate('check_generated_filename',newValue,'.h');
    if hasDelimiters
      errTxt = sprintf('Delimiters are not allowed in file name. %s',errTxt);
    end

    %%% Module name
  case 'ModuleName'
    newValue = strtrim(oldValue);
    if ~iscvar(newValue)
      errTxt = 'Module name must be a valid C identifier.';
    end

    %%% #define naming
  case 'DefineNamingFcn'
    [errTxt,newValue] = check_custom_file(oldValue,1);

    %%% Parameter naming
  case 'ParamNamingFcn'
    [errTxt,newValue] = check_custom_file(oldValue,1);

    %%% Signal naming
  case 'SignalNamingFcn'
    [errTxt,newValue] = check_custom_file(oldValue,1);

    %%% Custom comments
  case 'CustomCommentsFcn'
    [errTxt,newValue] = check_custom_file(oldValue,2);
    %%% ReplacementTypes
  case 'ReplacementTypes'
    %  varargin{1}: ReplacementTypes 
    %  varargin{2}: 'int' or 'uint' or 'char'
    if length(varargin) > 1
      dtype = varargin{2};
    else
      dtype = '';
    end
    [errTxt, newValue] = validate_name(oldValue,varargin{1},dtype);
  otherwise
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errTxt,fileName] = check_custom_file(fileName,ctr)

errTxt = '';

fileName = strtrim(fileName);
if isempty(fileName)
  errTxt = sprintf('File name empty.');
  return
end

[fPath, fName, fExt] = fileparts(fileName);

okchars = '_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
if ~isempty(fPath)
  errTxt = 'File or function name cannot contain directories. ';
elseif (~iscvar(fName)) || ...
      (~ismember(fName(1),okchars(12:end))) || ...
      (~isempty(setdiff(fName(2:end),okchars)))
  %Valid File Name: begins with an alphabetic character, the rest characters
  %can be a combination of alphabetic characters, digits and underscores  
  errTxt = sprintf('File name ''%s'' is invalid. ',fName);
elseif (~isempty(fExt)) && (ctr == 1) &&  ~(isequal(fExt,'.m') || isequal(fExt,'.p'))
  errTxt = 'File name extension must be ''.m'' or ''.p''. ';
elseif (~isempty(fExt)) && (ctr == 2) && ~(isequal(fExt,'.tlc') || isequal(fExt,'.m'))
  errTxt = 'File name extension must be ''.tlc'' or ''.m''. ';
else
  % valid fileName with correct ext. (.m, .p, .tlc) or without ext.
  % check if specified file with correct ext. is fist found on the path
  if ~isempty(fExt)
    ffNameE = which(fileName);  %with ext. For non m or p file, need have ext. in which, such as tlc
    if isempty(ffNameE)
      errTxt = sprintf('File ''%s%s'' is undefined or not on the MATLAB path. ',fName,fExt);
    end
    return
  else
    %without ext
    if exist(fName)==5  % fName is a built-in function
      if ctr == 1 || (ctr ==2 && exist([fName '.tlc'],'file') ~= 2)
         errTxt = sprintf('File ''%s'' is a matlab built-in function. ',fName);
         return
      end
    end
    ffName = which(fName); %without ext.
    if isempty(ffName)
      if ctr == 2
        %even if fName is not found, fName + '.tlc' may be found.
        if exist([fName '.tlc'],'file') ~= 2
          errTxt = sprintf('File ''%s'' is undefined or not on the MATLAB path. ',fName);
        end
      else
        errTxt = sprintf('File ''%s'' is undefined or not on the MATLAB path. ',fName);
      end
    elseif isequal(ffName,'variable')
      errTxt = sprintf('''%s'' is a workspace variable. ',fName);
    else
      [fPath, name, ffExt] = fileparts(ffName);
      if (ctr == 1) && ~(isequal(ffExt,'.m') || isequal(ffExt,'.p'))
        %valid extension: .m or .p, otherwise invalid
        errTxt = 'Specified file must be an MATLAB or P file on the MATLAB path. ';
      elseif (ctr == 2) && ~(isequal(ffExt,'.m') || isequal(ffExt,'.tlc'))
        %valid extension: .tlc or .m, otherwise invalid
        errTxt = 'Specified file must be a TLC or MATLAB file on the MATLAB path. ';
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: validate_name()
%   This is called when the user specifies values in the Replacement Types pane.
%   This function does some validation on the users input. This is called once per
%   specified replacement type. varargin is the type being replaced and
%   rtypeName is the replacement type name. repTypes is the complete array of
%   replacement type names (passed so we can check for illegal collisions).
%
%   Note that we cannot do complete
%   validation at this point in time because we don't have complete information.
%   For instance, we might know here that the user is replacing types "int8" and
%   "boolean" with the replacement typename "s1", but we may not know until build time
%   what "s1"'s value is. Nonetheless, we can do some name-checking and
%   consistency-checking here. Also see ec_replacetype_consistency_check() which is
%   the build-time check.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errTxt, rtype] = validate_name(rtypeName,repTypes, varargin)

% Check if replacement type name is a valid name. Also check for it not
% being a keyword or a builtin datatype name.

errTxt = '';
rtype = strtrim(rtypeName);
if isempty(rtype)
  return
end

cKeyword = {'asm','auto','break','case','char','const','continue',...
  'default','do','double','else','entry','enum','extern',...
  'float','for','fortran','goto','if','int','long',...
  'register','return','short','signed','sizeof','static',...
  'struct','switch','typedef','union','unsigned','void',...
  'volatile','while'};
rtwTypes = {'real_T','real64_T','real32_T','int32_T', 'int16_T', 'int8_T',...
  'uint32_T','uint16_T', 'uint8_T', 'boolean_T','int_T','uint_T',...
  'char_T','byte_T','time_T','FALSE','TRUE','false','true',...
  'creal_T','creal64_T','creal32_T','cint32_T', 'cint16_T', ...
  'cint8_T','cuint32_T','cuint16_T', 'cuint8_T'};

if ~iscvar(rtype)
  errTxt = sprintf('Replacement type ''%s'' must be a valid C identifier. ',rtype);
elseif ismember(rtype,cKeyword)
  errTxt = sprintf('''%s'' is a C keyword and can not be used as a replacement type. ',rtype);
elseif ismember(rtype,rtwTypes)
  errTxt = sprintf('''%s'' is a Real-Time Workshop default data type and can not be used as a replacement type. ',rtype);
elseif ~isempty(rtype)
  
  if ~isempty(varargin{1})
    
    % Check for duplicate replacement types.
    % I.e. what we're doing here is checking that the user does not map two 
    % non-compatible types to the *same* replacement type.
    % For instance, mapping both 'boolean' and 'double' to the same replacement type 'x'
    % would not be allowed.

    rdouble = repTypes.double;
    rsingle = repTypes.single;
    rint32 = repTypes.int32;
    rint16 = repTypes.int16;
    rint8 = repTypes.int8;
    ruint32 = repTypes.uint32;
    ruint16 = repTypes.uint16;
    ruint8 = repTypes.uint8;
    rboolean = repTypes.boolean;
    rint = repTypes.int;
    ruint = repTypes.uint;
    rchar = repTypes.char;

    btype = varargin{1};
    eTxt = sprintf('''%s'' is an invalid duplicate replacement type for ''%s''. ', rtype, btype);
    
    % btype is the type we're mapping, rtype is the name we're mapping it to,
    % rxxx is the current replacement mapping for xxx

    % At this point we allow any of the integer types to share a mapping with boolean.
    % In ec_replacetype_consistency_check (at build time) we'll do the appropriate checks.
 
    switch btype
      case 'double'
        if ismember(rtype,{rsingle,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,rchar})
          errTxt = eTxt;
        end
      case 'single'
        if ismember(rtype,{rdouble,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,rchar})
          errTxt = eTxt;
        end
      case 'int32'
        if ismember(rtype,{rdouble,rsingle,rint16,rint8,ruint32,ruint16,ruint8,ruint,rchar})
          errTxt = eTxt;
        end
      case 'int16'
        if ismember(rtype,{rdouble,rsingle,rint32,rint8,ruint32,ruint16,ruint8,ruint,rchar})
          errTxt = eTxt;
        end
      case 'int8'
        if ismember(rtype,{rdouble,rsingle,rint32,rint16,ruint32,ruint16,ruint8,ruint,rchar})
          errTxt = eTxt;
        end
      case 'uint32'
        if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint16,ruint8,rint,rchar})
          errTxt = eTxt;
        end
      case 'uint16'
        if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint8,rint,rchar})
          errTxt = eTxt;
        end
      case 'uint8'
        if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint16,rint,rchar})
          errTxt = eTxt;
        end
      case 'boolean'
        if ismember(rtype,{rdouble,rsingle,rchar})
          errTxt = eTxt;
        end
      case 'int'
        % int can share replacement type with any of the intN's
        % Also int can share replacement type with boolean
        if ismember(rtype,{rdouble,rsingle,ruint32,ruint16,ruint8,ruint,rchar})
          errTxt = eTxt;
        end
      case 'uint'
        % uint can share replacement type with any of the uintN's
        % Also uint can share replacement type with boolean
        if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,rint,rchar})
          errTxt = eTxt;
        end
      case 'char'
        if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint})
          errTxt = eTxt;
        end
    end
  end
end

%EOF
