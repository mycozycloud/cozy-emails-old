	var res = function() {
	
	function viewport()
	{
	var e = window
	, a = 'inner';
	if ( !( 'innerWidth' in window ) )
	{
	a = 'client';
	e = document.documentElement || document.body;
	}
	return { width : e[ a+'Width' ] , height : e[ a+'Height' ] }
	}

	//alert($this.height);
	
	$("body").height(viewport().height - 60);
	$("div.column").height(viewport().height - 80);
	}
	$(document).ready(res);
	window.onresize = res;
