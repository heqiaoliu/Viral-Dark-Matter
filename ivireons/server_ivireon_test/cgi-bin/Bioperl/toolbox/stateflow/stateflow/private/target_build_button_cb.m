function target_build_button_cb(h,dialog)

buildCommands = target_methods('buildCommands', h.Id);
if ~isempty(dialog)
    val = dialog.getWidgetValue('sfTargetdlg_targetComboTag') + 1;
else
    val = 1;
end

% {'Private','target_methods','build', h.Id, buildCommands{val,3}};
target_methods('build',h.Id,buildCommands{val,3});

end

