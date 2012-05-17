function [p, v] = thisinfo(this)
%THISINFO   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:00:20 $

[p, v] = basefilter_info(this);

if isfdtbxinstalled && isprop(this, 'Arithmetic')
    
    p{end+1} = 'spacer';
    v{end+1} = 'spacer';
    
    p{end+1} = 'Arithmetic';
    v{end+1} = get(this, 'Arithmetic');
        
    [f, c] = info(this.filterquantizer);

    if ~isempty(f)
        p = [p f(:)'];
        v = [v c(:)'];
    end
end

% [EOF]
