function Name=getfullname(Handle)
%GETFULLNAME Get full path name to block.
%   NAME=GETFULLNAME(HANDLE) returns the full pathname to the block
%   or line specified by HANDLE.

%   Loren Dean
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.10.2.2 $

m = size(Handle,1);
n = size(Handle,2);

if (n == 1 & m == 1) | ischar(Handle),
  %
  %  Scalar input
  %

  % input argument is a ref to one block or line
  type = get_param(Handle, 'Type');
  
  if strcmp(type, 'line')
    %
    % The HANDLE is a line
    %
    blkH = get_param(Handle, 'SrcBlockHandle');
    if ishandle(blkH)
      blkPath = getfullname(blkH);
      portNum = get_param(get_param(Handle, 'SrcPortHandle'), 'PortNumber');
      Name = [blkPath '/' num2str(portNum)];
    else
      Name = '';
    end
    
  else
    %
    % The HANDLE can be block, block_diagram or anything else.
    %
    PName=get_param(Handle,'Parent');
    Name=strrep(get_param(Handle,'Name'),'/','//');
    
    if ~isempty(PName),
      Name=[ PName '/'  Name];
    end
  end
  
else
  %
  % Vector input
  %
  
  Name = cell(m,n);
  if iscell(Handle),
    Handle = reshape([Handle{:}],m,n);
  end
    
  for i=1:m,
    for j=1:n,
      % Call getfullname recursively
      Name(i,j) = {getfullname(Handle(i,j))};
    end
  end
  
end

% end getfullname
