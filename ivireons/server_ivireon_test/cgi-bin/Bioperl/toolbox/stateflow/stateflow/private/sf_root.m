function result = sf_root( filename )
% RESULT = SF_ROOT returns the root directory where the Stateflow main image resides
% RESULT = SF_ROOT( FILENAME ) returns fullfile( sf_root, filename )

%	E. Mehran Mestchian
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.6.2.3 $  $Date: 2005/12/19 07:59:35 $

persistent SFROOTDIR

if isempty(SFROOTDIR)
	sfMexFile = ['sf.',mexext];
	len = length(sfMexFile);
	SFROOTDIR = which(sfMexFile);
	if length(SFROOTDIR)>len
		SFROOTDIR = SFROOTDIR(1:end-len);
	end
	if ispc
		SFROOTDIR = lower(SFROOTDIR);
	end
end

if nargin==0
	result = SFROOTDIR;
	return;
end

result = fullfile(SFROOTDIR,filename);


