function schema
%creates the scribe user object package

%   Copyright 1984-2006 The MathWorks, Inc.

schema.package('scribe');
if isempty(findtype('ScribeShapeType'))
    schema.EnumType('ScribeShapeType',...
        {'rectangle','ellipse','circle', 'arrow','textarrow',...
        'doublearrow','line','textbox','scribegrid'});
end
