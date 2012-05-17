function [p, v] = thisinfo(this)
%THISINFO   

%   Author(s): M. Chugh
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/10/14 16:24:52 $

p = {'Filter Structure', 'Latency'};
v = {get(this, 'FilterStructure'), num2str(get(this,'Latency'))};

if isquantized(this)
    p{end+1} = 'Arithmetic';
    v{end+1} = get(this, 'Arithmetic');
        
    [f, c] = info(this.filterquantizer);

    if ~isempty(f)
        p = [p f(:)'];
        v = [v c(:)'];
    end
end

% [EOF]
