function sys = pvset(sys,varargin)
%PVSET  Set properties of LTI models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2008/03/13 17:21:00 $

% RE: PVSET is performing object-specific property value setting
%     for the generic LTI/SET method. It expects true property names.

for i=1:2:nargin-1,
   % Set each PV pair in turn
   Property = varargin{i};
   Value = varargin{i+1};

   % Set property values
   switch Property
      case 'InputName'
         if isempty(Value)
            % Interpret as clearing the input names
            sys.InputName(:) = {''};
         else
            sys.InputName = ChannelNameCheck(Value,'InputName');
         end

      case 'OutputName'
         if isempty(Value)
            sys.OutputName(:) = {''};
         else
            sys.OutputName = ChannelNameCheck(Value,'OutputName');
         end

      case 'InputGroup'
         if isempty(Value)
            Value = struct;
         elseif isstruct(Value)
            % Remove empty groups
            Value = localRemoveEmptyGroups(Value);
         end
         % All error checking deferred to CHECKSYS
         sys.InputGroup = Value;
         
      case 'OutputGroup'
         if isempty(Value)
            Value = struct;
         elseif isstruct(Value)
            % Remove empty groups
            Value = localRemoveEmptyGroups(Value);
         end
         % All error checking deferred to CHECKSYS
         sys.OutputGroup = Value;
         
      case 'Name'
         if ~ischar(Value)
            ctrlMsgUtils.error('Control:ltiobject:setLTI2','Name')
         end
         sys.Name = Value;
         
      case 'Notes'
         if ischar(Value),  
            Value = {Value}; 
         elseif ~iscellstr(Value)
             ctrlMsgUtils.error('Control:ltiobject:setLTI2','Notes')
         elseif ~isempty(Value)
            Value = Value(:);
         end
         sys.Notes = Value;
         
      case 'UserData'
         sys.UserData = Value;
         
      otherwise
         % This should not happen
         ctrlMsgUtils.error('Control:utility:pnmatch2',Property)
         
   end % switch
end % for


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name)
% Checks specified I/O names

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(a) && ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) && isvector(a)
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1),
       ctrlMsgUtils.error('Control:ltiobject:setLTI3',Name)
   end
   
else
   ctrlMsgUtils.error('Control:ltiobject:setLTI3',Name)
end

% Make sure that nonempty I/O names are unique
as = sortrows(char(a));
repeat = (any(as~=' ',2) & all(as==strvcat(as(2:end,:),' '),2));
if any(repeat),
   ctrlMsgUtils.warning('Control:ltiobject:RepeatedChannelNames')
end
   

function g = localRemoveEmptyGroups(g)
% Removes groups with empty channel sets (simplifies group 
% creation in functions like LQGTRACK)
ie = structfun(@isempty,g);
if any(ie)
   f = fieldnames(g);
   g = rmfield(g,f(ie));
end

