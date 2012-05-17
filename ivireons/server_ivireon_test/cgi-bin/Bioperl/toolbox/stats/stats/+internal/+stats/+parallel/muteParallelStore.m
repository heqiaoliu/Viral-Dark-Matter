function muteParallelStore( name, value )
%MUTEPARALLELSTORE is a silent STATPARALLELSTORE for use with PCTRUNONALL.
%
%   MUTEPARALLELSTORE is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

    val = internal.stats.parallel.statParallelStore(name, value);
end

