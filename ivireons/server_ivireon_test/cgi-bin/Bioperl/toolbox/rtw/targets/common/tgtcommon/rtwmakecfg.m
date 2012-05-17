function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to rtw make files. 
%   makeInfo=RTWMAKECFG returns a structured array containing build info. 
%   Please refer to the rtwmakecfg API section in the Real-Time workshop 
%   Documentation for details on the format of this structure.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2009/12/31 19:01:01 $

disp('### Driver Interface Libraries');

root = bdroot;
inputblocks = find_system(root,'ReferenceBlock','driver_interface_library/Input Driver');
outputblocks = find_system(root,'ReferenceBlock','driver_interface_library/Output Driver');
blocks = { inputblocks{:} outputblocks{:} };

% initialise
makeInfo.includePath = { };
makeInfo.sourcePath = { };
makeInfo.sources = { };

for i = 1:length(blocks)
  block = blocks{i};
  if ~isempty(block)
    addheader(get_param(block,'header'));
    addsrc(get_param(block,'src'));
  end
end

  function addheader(header)
    PATHSTR = fileparts(header);
    PATHSTR = expand(PATHSTR);
    paths = makeInfo.includePath;
    if ~isempty(PATHSTR)
      paths = { paths{:} PATHSTR };
      makeInfo.includePath = paths;
    end
  end

  function addsrc(src)
    PATHSTR = fileparts(src);
    PATHSTR = expand(PATHSTR);
    paths = makeInfo.sourcePath;
    if ~isempty(PATHSTR)
      paths = { paths{:} PATHSTR };
      makeInfo.sourcePath = paths;
    end
  end

  function path = expand(path)
    expansions = regexp(path,'(\$[^\\/]*)','tokens');
    for i = 1:length(expansions)
      ex = expansions{i}{1};
      fun = strrep(ex,'$','');
      str = feval(fun);
      path = strrep(path,ex,str);
    end
  end

end
