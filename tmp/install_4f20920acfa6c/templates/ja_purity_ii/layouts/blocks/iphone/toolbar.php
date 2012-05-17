    <div class="toolbar">
        <h1 id="pageTitle"></h1>
        <a id="backButton" class="button" href="#"></a>
        <a class="button" href="#nav0" onclick="toogleMenu(this)">Menu</a>
    </div>
	<script type="text/javascript">
	function toogleMenu(a) {
		if (a.innerHTML == 'Close') {
			a.innerHTML = 'Menu';
		} else {
			a.innerHTML = 'Close';
		}
	}
	</script>