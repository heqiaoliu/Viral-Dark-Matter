function s = pload(fileroot, varargin)
%PLOAD  Load a file into a parallel session
%   PLOAD(FILEROOT) loads the data from the files named [fileroot
%   num2str(labindex)] into Parallel MATLAB.  The files should have been
%   created by a PSAVE command.  The number of labs should be the same as
%   the number of files.  The files should be on a shared file system.  Any
%   codistributed arrays will be reconstructed by this function.  If FILEROOT
%   contains an extension, the character representation of the labindex
%   will be inserted before the extension.  Thus, pload('abc') will
%   attempt to load the file 'abc1.mat' on lab 1, 'abc2.mat' on lab2, etc.
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
%   See also PSAVE, NUMLABS, LABINDEX, PMODE, SAVE, LOAD.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/12/03 19:00:22 $

[p, name, ext] = fileparts(fileroot);
filename = fullfile(p,[name num2str(labindex) ext]);

sVar = load(filename, varargin{:});
names = fieldnames(sVar)';

for idx = names
    name = idx{1};
    if isa(sVar.(name), 'codistributed')
        dist = getCodistributor(sVar.(name));
        verifyCodistributor(dist);
    end
    if nargout == 0
        assignin('caller', name, sVar.(name));
    else
        s.(name) = sVar.(name);
    end
end
end % End of pload

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function verifyCodistributor(codistr)
storedNumLabs = codistr.hNumLabs();
if storedNumLabs ~= numlabs
    ex = MException('distcomp:pload:NumlabsMismatch', ...
            ['The number of labs must be the same when loading a ' ...
             'codistributed array as it was when the array was saved.  ' ...
             'This array was saved with numlabs equal to %d, but numlabs ' ...
             'is now %d.'], storedNumLabs, numlabs);
    throwAsCaller(ex);
end
end % End of verifyCodistributor.
