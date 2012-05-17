function psave(fileroot, varargin)
%PSAVE  Save data from a parallel session
%   PSAVE(FILEROOT) saves the data into the files named [fileroot
%   num2str(labindex)].  The files can be loaded by using the PLOAD command
%   with the same FILEROOT. FILEROOT should be pointing at a shared file
%   system.  If FILEROOT contains an extension, the character
%   representation of the labindex will be inserted before the extension.
%   Thus, psave('abc') will create the file 'abc1.mat', 'abc2.mat' etc.
%
%   Example:
%      clear all
%      rep = speye(numlabs)
%      var = magic(labindex)
%      D = eye(numlabs,codistributor())
%      psave('threeThings')
%
%   creates 3 variables - one replicated, one a variant and one codistributed
%   - in a parallel session.
%
%      clear all, whos, ls
%
%   clears the workspace, confirms no variables are present in the
%   parallel session and shows the files threeThings1.mat created by lab 1,
%   threeThings2.mat created by lab 2, and so on.
%
%      pload('threeThings')
%      whos
%
%   loads the variables rep, var and D into the parallel session again.
%
%   See also PLOAD, NUMLABS, LABINDEX, PMODE, SAVE, LOAD.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/06/24 17:03:35 $

[p, name, ext] = fileparts(fileroot);
filename = fullfile(p,[name num2str(labindex) ext]);

str = ['save(''' filename ''''];
for i = 2 : nargin
    str = strcat(str, ', ''');
    str = strcat(str, varargin{i-1});
    str = strcat(str, '''');
end
str = strcat(str, ')');

evalin('caller', str);
