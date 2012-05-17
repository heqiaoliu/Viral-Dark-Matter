<?php
define ('SHOW_IE6_WARNING', 'close'); 
/* 
Setting for this message. Clear cookie if you change this setting.
'none': Not show warning
'once': Show one time only
'close': Show until user check box "Not show again" and close the message
'always': Always show this message
*/

if (!SHOW_IE6_WARNING || SHOW_IE6_WARNING=='none') return;
$this->addParamCookie ('ie6w_notshowagain');
if (SHOW_IE6_WARNING!='always' && $this->getParam ('ie6w_notshowagain',0)) return;
?>
<link rel="stylesheet" href="<?php echo $this->templateurl(); ?>/layouts/blocks/ie6/ie6warning.css" type="text/css" />
<div style="" id="ie6-warning" class="wrap">
	<div class="main"><div class="inner clearfix">
		<h1><?php echo JText::_('IE6 Warning Title')?></h1>
		
		<?php echo JText::_('IE6 Warning Message')?>
		
		<ul>
			<li><a class="firefox-download" href="http://www.mozilla.com/firefox/" target="_blank" title="Download Firefox">&nbsp;</a></li>
			<li><a class="chrome-download" href="http://www.google.com/chrome" target="_blank" title="Download Chrome">&nbsp;</a></li>
			<li><a class="safari-download" href="http://www.apple.com/safari/download/" target="_blank" title="Download Safari">&nbsp;</a></li>
			<li><a class="opera-download" href="http://www.opera.com/download/" target="_blank" title="Download Opera">&nbsp;</a></li>
			<li><a class="ie-download" href="http://www.microsoft.com/windows/Internet-explorer/default.aspx" target="_blank" title="Download Internet Explorer 8 NOW!">&nbsp;</a></li>
		</ul>
		
		<div class="close">
		<a href='#' onclick='ie6w_hide(); return false;' title="<?php JText::_('Close this notice')?>">&nbsp;</a>
		<?php if (SHOW_IE6_WARNING=='close'):?>
		<label for="ie6w_notshowagain"><?php echo JText::_("Do not show this message again")?>&nbsp;&nbsp;&nbsp;&nbsp;</label>
		<input type="checkbox" name="ie6w_notshowagain" id="ie6w_notshowagain" value="0">
		<?php endif; ?>
		</div>
	</div></div>
</div>

<script type="text/javascript">
function ie6w_show() {
	var fx = new Fx.Elements ([$('ie6-warning'), $('ja-wrapper')]);
	var obj = {};
	obj[0]={'height':[205]};
	obj[1]={'margin-top':[205]};
	fx.start(obj);
}
function ie6w_hide() {
	var fx = new Fx.Elements ([$('ie6-warning'), $('ja-wrapper')]);
	fx.stop();
	var obj = {};
	obj[0]={'height':0};
	obj[1]={'margin-top':0};
	fx.start(obj);
	if ($("ie6w_notshowagain") && $("ie6w_notshowagain").checked) {
		createCookie ("<?php echo $this->template?>_ie6w_notshowagain", 1, 365);
	}
}
<?php if (SHOW_IE6_WARNING=='once'):?>
createCookie ("<?php echo $this->template?>_ie6w_notshowagain", 1, 365);
<?php endif; ?>
setTimeout(ie6w_show,2000);
</script>