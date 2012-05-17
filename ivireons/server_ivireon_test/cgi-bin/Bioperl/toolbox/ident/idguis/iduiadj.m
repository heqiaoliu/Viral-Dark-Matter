function iduiadj(f)

% Copyright 2005 The MathWorks, Inc.

ch = get(f,'children');
sc = [0.1994 0.0767 0.2 0.0769];
p = get(f,'pos');
set(f,'units','char');
set(f,'pos',p.*sc);
set(f,'units','pix');
p2 = get(f,'pos');
set(f,'pos',[p(1:2),p2(3:4)]);
for k = ch'
    p = get(k,'pos');
    set(k,'units','char')
    set(k,'pos',p.*sc)
end
set(ch,'units','norm');    
    