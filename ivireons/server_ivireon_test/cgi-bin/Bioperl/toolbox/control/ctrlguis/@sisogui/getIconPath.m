function pathstr = getIconPath(config,varargin)

%   Author(s): C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/10/16 04:47:33 $

if nargin == 2;
    Thumb= 'Thumb';
else
    Thumb = '';
end

switch config;
    case -1
        pathstr = fullfile(matlabroot,'toolbox','shared','controllib','graphics', ...
            'Resources','SISOConfign1.png');
    otherwise
        pathstr = fullfile(matlabroot,'toolbox','shared','controllib','graphics', ...
            'Resources',['SISOConfig',num2str(config),Thumb,'.png']);
end



