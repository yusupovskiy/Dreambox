$(document).ready(function() {
  $(window).resize(function() {
    totalHeight();
  });

  function totalHeight() {
    var desiredHeight = document.body.clientHeight - 83;
    var amountElements = $('.box-home-lists').length;
    for (var i = 1; i <= amountElements; i++) {
      var amountChildren = $('.content-home-lists>div:nth-of-type(' + i + ')>div').length;
      var totalHeight = (desiredHeight / amountChildren) - 16;
      for (var j = 1; j <= amountChildren; j++) {
        $('.content-home-lists>div:nth-of-type(' + i + ')>div:nth-of-type(' + j + ')').css({'height':''+totalHeight+'px'});
        $('.content-home-lists>div:nth-of-type(' + i + ')>div:nth-of-type(' + j + ')>.body-list').css({'height':''+(totalHeight-46)+'px'});
      }
    }
  }
  
  var titleInput = '.title-input';

  /*$(document).mousedown(function(e) {
  	if($('.input').mousedown()) {
  		$('.input').mousedown(function() {
  			$(this).parent().children(titleInput).addClass('focus-title-input');
  		});
  	}
  	else if ($(titleInput).has(e.target).length === 0){
          $(titleInput).removeClass('focus-title-input'); // скрываем его
  	}
  });*/

  var container = $(".input");
  container.focus(function () {
    $(this).parent().children(titleInput).addClass('focus-title-input');
  });

  $(document).on("turbolinks:load", function () {
    totalHeight();
    $(".body-list").niceScroll({cursorcolor: '#e7e7e7', cursorborder: '0', cursorwidth: '3px', cursorborderradius: '3px', cursorborder: '3px solid transparent', spacebarenabled: 'false'});
    $(".home-lists").niceScroll({cursorcolor: '#e7e7e7', cursorborder: '0', cursorwidth: '3px', cursorborderradius: '3px', cursorborder: '3px solid transparent', spacebarenabled: 'false'});
    $(".bring-to-front").niceScroll({cursorcolor: '#e7e7e7', cursorborder: '0', cursorwidth: '3px', cursorborderradius: '3px', cursorborder: '3px solid transparent', spacebarenabled: 'false'});
    $(".sections-card").niceScroll({cursorcolor: '#e7e7e7', cursorborder: '0', cursorwidth: '0', cursorborderradius: '3px'});
  })
});