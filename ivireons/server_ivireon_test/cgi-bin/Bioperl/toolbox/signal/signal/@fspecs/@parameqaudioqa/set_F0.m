function F0 = set_F0(this, F0)
%SET_F0 PreSet function for the 'F0' property

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:52 $

if isequal(F0,1) || isequal(F0,0)
    error(generatemsgid('invalidSpecs'),...
        ['F0 cannot be 0 or 1 for specification type ',...
        '''N,F0,Qa,Gref,G0'', if you want to design a shelving filter',...
        ' you may use specs ''N,F0,Fc,Qa,G0'', or ''N,F0,Fc,S,G0''']);
end
% [EOF]
