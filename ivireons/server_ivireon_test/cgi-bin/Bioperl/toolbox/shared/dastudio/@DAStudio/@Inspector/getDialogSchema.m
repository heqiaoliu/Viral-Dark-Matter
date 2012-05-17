function dlgStruct = getDialogSchema(this, param)

object = this.Object;
class  = classhandle(object);
props  = find( class.Properties, 'Visible', 'on' );

% generate the schema content
content.Type        = 'panel';
content.Source      = object;
content.Items       = {};
content.LayoutGrid  = [length(props), 2];

for i = 1:length(props)
    label.Type      = 'text';
    label.Name      = props(i).Name;
    label.BackgroundColor = [200 200 200];
    label.RowSpan   = [i i];
    label.ColSpan   = [1 1];

    widget          = getStructForProperty( object, props(i) );
    widget.RowSpan  = [i i];
    widget.ColSpan  = [2 2];

    content.Items{end+1} = label;
    content.Items{end+1} = widget;
end

dlgStruct.DialogTitle   = 'Inspector';
dlgStruct.MinimalApply  = 1;
dlgStruct.Geometry      = [700 100 450 850];
dlgStruct.Items         = {content};

%--------------------------------------------------------------------------
% Helper functions

function widget = getStructForProperty(object, prop) 

switch prop.DataType
    case {'bool', 'on/off', 'slbool'}
        type = 'checkbox';
        
    case 'string'
        type = 'edit';
        
    otherwise
        if strcmp(object.getPropDataType( prop.Name ), 'enum')
            type = 'combobox';
        else
            type = 'edit';
        end
end

widget.Type             = type;
widget.ObjectProperty   = prop.Name;
widget.Enabled          = ~object.isReadonlyProperty( prop.Name );
% widget.Mode             = 1;
