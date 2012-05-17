function disp(h)
%DISP Display sync list

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:31:52 $

N=numel(h.DstName);
if N==0
    fprintf('  (Sync list is empty)\n');
else
    fprintf('  # ... DestName ... Default ... Function\n');
    for i=1:N
        f = functions(h.Fcn{i});
        fcn = f.function;
        if h.Default(i), isDefault='Y'; else isDefault='N'; end
        fprintf(' %3d\t%s\t%s\t%s\n', ...
            i, h.DstName{i}, isDefault, fcn);
    end
end

% [EOF]
