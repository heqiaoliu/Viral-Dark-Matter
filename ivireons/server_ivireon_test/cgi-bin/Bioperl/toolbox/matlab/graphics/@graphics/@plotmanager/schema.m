function schema
%SCHEMA Plot manager schema

%   Copyright 1984-2007 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'plotmanager');

schema.event(cls,'PlotFunctionDone');
schema.event(cls,'PlotEditPaste');
schema.event(cls,'PlotEditBeforePaste');
schema.event(cls,'PlotSelectionChange');
