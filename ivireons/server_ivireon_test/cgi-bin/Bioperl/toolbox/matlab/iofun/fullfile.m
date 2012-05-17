function f = fullfile(varargin)
%FULLFILE Build full filename from parts.
%   FULLFILE(D1,D2, ... ,FILE) builds a full file name from the
%   directories D1,D2, etc and filename FILE specified.  This is
%   conceptually equivalent to
%
%      F = [D1 filesep D2 filesep ... filesep FILE] 
%
%   except that care is taken to handle the cases where the directory
%   parts D1, D2, etc. may begin or end in a filesep. Specify FILE = ''
%   to build a pathname from parts. 
%
%   Examples
%     To build platform dependent paths to files:
%        fullfile(matlabroot,'toolbox','matlab','general','Contents.m')
%
%     To build platform dependent paths to a directory:
%        addpath(fullfile(matlabroot,'toolbox','matlab',''))
%
%   See also FILESEP, PATHSEP, FILEPARTS.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.19.4.4 $ $Date: 2009/02/13 15:12:17 $

error(nargchk(1, Inf, nargin, 'struct'));

fs = filesep; 
f = varargin{1};
bIsPC = ispc;

for i=2:nargin,
   part = varargin{i};
   if isempty(f) || isempty(part)
      f = [f part]; %#ok<AGROW>
   else
      % Handle the three possible cases
      if (f(end)==fs) && (part(1)==fs),
         f = [f part(2:end)]; %#ok<AGROW>
      elseif (f(end)==fs) || (part(1)==fs || (bIsPC && (f(end)=='/' || part(1)=='/')) )
         f = [f part]; %#ok<AGROW>
      else
         f = [f fs part]; %#ok<AGROW>
      end
   end
end

% Be robust to / or \ on PC
if bIsPC
   f = strrep(f,'/','\');
end



