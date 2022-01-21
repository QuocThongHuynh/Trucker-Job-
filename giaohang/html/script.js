$(document).ready(function () {
	// Retrieval form vars

	window.addEventListener('message', function (event) {
		var data = event.data;


		if (data.type === "display") {
			if (data.show) {
				OpenUI(data.vehicle)
			} else {
				$('#main').hide(500);
			}
		}
	});

	// On 'Esc' call close method
	document.onkeyup = function (data) {
		if (data.which == 27 ) {
			$.post('http://giaohang/escape', JSON.stringify({}));
		}
	};
	
	function OpenUI(table) {
		var html = '';
		for(var i = 0; i < table.length; i++) {
			var row = `<div class="box-veh">
				<div class="box-header">${table[i].note}</div>
				<div class="veh-img" style="background-image: url('https://i.imgur.com/${table[i].linkanh}.png');"></div>
				<button id="vehicle-spawn" class="veh-bt" value='${table[i].name}'>Chọn</button>
			</div>`
			html = html + row;
		}
		$('#main').html(html);
		$('#main').show(500)
	}

	$('body').on('click', '#vehicle-spawn', function () {
		var value = $(this).val()
		$.post('http://giaohang/rentveh', JSON.stringify(value));
	});	
});
