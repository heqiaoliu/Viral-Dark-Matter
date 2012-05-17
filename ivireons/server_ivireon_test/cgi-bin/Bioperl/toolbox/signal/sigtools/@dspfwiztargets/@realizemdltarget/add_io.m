function add_io(hTar, full_src, full_dst, varargin)
%ADD_IO Add connections between the blocks FULL_SRC and FULL_DST

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:15 $

error(nargchk(3,4,nargin,'struct'));

sys = hTar.system;

% One source
[dummy,src] = fileparts(full_src);

% Multiple destinations
for j=1:length(full_dst),
    [dummy,dst] = fileparts(full_dst{j});
    conn = get_param(full_dst{j}, 'portconnectivity');
    if nargin>3,
        connType = varargin{1};
    else
        for i=1:length(conn),
            if conn(i).SrcBlock==-1, % unconnected source port
                connType = conn(i).Type;
            end
        end
    end
    add_line(sys, [src '/1'], [dst '/' connType], 'autorouting', 'on');
end
