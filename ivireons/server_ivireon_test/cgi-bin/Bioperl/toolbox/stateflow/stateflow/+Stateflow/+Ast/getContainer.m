function container = getContainer(obj)
% Wrapper to the get the container object

%   Copyright 2009 The MathWorks, Inc.

    try
        switch(class(obj))
          case 'Stateflow.State'
            container = Stateflow.Ast.StateContainer(obj.Id);
          case 'Stateflow.Transition'
            container = Stateflow.Ast.TransitionContainer(obj.Id);
          otherwise
            me = MException('Stateflow:Ast:BadObject','Invalid state or transition object');
            throw(me);
        end
    catch me
        if(~strcmp(me.identifier,'Stateflow:Ast:ParseError') && ~strcmp(me.identifier,'Stateflow:Ast:BadObject'))
            rethrow(me);
        end
        error(me.message);
    end
end
