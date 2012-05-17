function s=toolboxdir(tbxdirname)
% TOOLBOXDIR Root directory for specified toolbox  
%    S=TOOLBOXDIR(TBXDIRNAME) returns a string that is the absolute
%    path to the specified toolbox directory name, TBXDIRNAME
%
%    TOOLBOXDIR is particularly useful for MATLAB Compiler. The base
%    directory of all toolboxes installed with MATLAB is
%    <matlabroot>/toolbox/<tbxdirname>. However, in deployed mode, the base
%    directories of the toolboxes are different. TOOLBOXDIR returns the
%    correct root directory irrespective of the mode in which the code is
%    running.
%
%    See also MATLABROOT, COMPILER/CTFROOT.

%    Copyright 1984-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.6 $  $Date: 2010/03/08 21:41:04 $
    
    if nargin < 1
        error(nargchk(1,1,nargin,'struct'))
    end

    if( ~isdeployed )
        s=fullfile(matlabroot,'toolbox', tbxdirname);
    else
        if (strcmpi(tbxdirname, 'matlab') || strcmpi(tbxdirname, 'compiler'))
            s=fullfile(tbxprefix,lower(tbxdirname) );
        else
            s=fullfile(ctfroot, 'toolbox', tbxdirname);
        end
    end
    if(exist(s, 'dir')~=7) 
        error('matlab:toolboxdir:DirectoryNotFound', '%s',...
              ['Could not locate the base directory for ', tbxdirname,'.']);
    end
