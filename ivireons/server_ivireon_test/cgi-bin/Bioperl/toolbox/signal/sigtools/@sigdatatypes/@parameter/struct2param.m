function struct2param(hPrm, struct)
%STRUCT2PARAM Set the parameters with the information in a structure

%    Author(s): J. Schickler & P. Costa
%    Copyright 1988-2002 The MathWorks, Inc.
%    $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:17:58 $ 

error(nargchk(2,2,nargin,'struct'));

if ~isempty(struct),
    
    tags = fieldnames(struct);
    
    for i = 1:length(tags),
        h = find(hPrm, 'Tag', tags{i});
        if ~isempty(h),
            setvalue(h, struct.(tags{i}));
        end
    end
end

% [EOF]
