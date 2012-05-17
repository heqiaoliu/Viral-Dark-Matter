function addBehaviorObjects(h)

brushGraphicObj = h.SelectionHandles;
for k=1:length(brushGraphicObj)
    % Selection graphics should have no legend
    set(brushGraphicObj(k),'DisplayName','');
    hasbehavior(double(brushGraphicObj(k)),'legend',false);

    % Exclude from M code generation
    b = hggetbehavior(brushGraphicObj(k),'MCodeGeneration');
    b.MCodeIgnoreHandleFcn = @localReturnTrue;
    b = hggetbehavior(brushGraphicObj(k),'PlotEdit');
    b.Enable = false;
    b.EnableCopy = false;
    b.EnablePaste = false;
    b = hggetbehavior(brushGraphicObj(k),'DataCursor');
    b.StartCreateFcn = {@localGetBaseObj h}; 
end

function state = localReturnTrue(obj,evd)

state = true;

function obj = localGetBaseObj(bobj)

obj = bobj.HGHandle;