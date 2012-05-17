function a = ChannelNameCheck(a,Name)
% Checks specified I/O names

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2008/10/02 18:47:09 $

if isempty(a),  
   a = a(:);   % make 0x1
   return  
end

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(a) && ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) && ndims(a)==2 && min(size(a))==1,
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1),
      ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,'IDDATA')
   end
   
else
    ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,'IDDATA')
    %{
       (sprintf('%s %s\n%s',Name,...
      'must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])',...
      'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'))
    %}
end

% Make sure that nonempty I/O names are unique
as = sortrows(char(a));
repeat = (any(as~=' ',2) & all(as==strvcat(as(2:end,:),' '),2));
if any(repeat)
   ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,'IDDATA')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
