document.addEventListener('turbolinks:load', function() {

  $(".open-objects>div").niceScroll({cursorcolor:"transparent", cursorborder:"transparent"});

  totalHeight();
  $(window).resize(totalHeight);
  
  $('.header-katalog>input').focus(function () {
    $('html, body').animate({scrollTop: $('html').height()}, 500);
  });

  
  function totalHeight() {
    var constHeaderOpenObjects = 84;
    var windowHeight = window.innerHeight;
    var desiredHeight = windowHeight - constHeaderOpenObjects;
    var topMargin = windowHeight / 1.55;
    $('.katalog').css({'height':''+desiredHeight+'px', 'margin-top':''+topMargin+'px'});
    $('.open-objects>div>div').css({'margin-left':parseFloat($('.katalog').css('margin-left'))});
  }

  // При нажатии за пределами блока
/*  $(function($){
    $(document).mouseup(function (e){ // событие клика по веб-документу
      var div = $(".katalog"); // тут указываем ID элемента
      if (!div.is(e.target) // если клик был не по нашему блоку
          && div.has(e.target).length === 0 && $('html').scrollTop() > 20) { // и не по его дочерним элементам
        $('html, body').animate({scrollTop:$('.footer').position().top}, 500);
      }
    });
  });*/





  // таб
  var $wrapper = $('.tabs'),
    $allTabs = $wrapper.find('.cont-category-book>div'),
    $tabMenu = $wrapper.find('.menu-with-options>div');
  
  $allTabs.not(':first-of-type').hide();
  $allTabs.addClass('active-tab-category');
  
  $tabMenu.each(function(i) {
    $(this).attr('data-tab', 'tab'+i);
  });
  
  $allTabs.each(function(i) {
    $(this).attr('data-tab', 'tab'+i);
  });
  
  $tabMenu.on('click', function() {
    
    var dataTab = $(this).data('tab'),
        $getWrapper = $(this).closest($wrapper);
    
    $getWrapper.find($tabMenu).removeClass('active');
    $(this).addClass('active');
    
    $allTabs.removeClass('active-tab-category');
    $getWrapper.find($allTabs).hide();
    $getWrapper.find($allTabs).filter('[data-tab='+dataTab+']').show();
    setTimeout(function() {
      $allTabs.addClass('active-tab-category');
    }, 50);
  });
  
  // скрыть
  $('.compact>h3').click(function() {
    if($(this).parent().hasClass('active-compact')) {
      $(this).parent().removeClass('active-compact');
    }
    else {
      $(this).parent().addClass('active-compact');
    }
  });

  window.onload = function() {
    setInterval(function() {
      if($('html').scrollTop() > 120) {
        $('.btns-card').addClass('right-btns-card');
        var marginRight = parseFloat($('.card').css('margin-left')) - 50;
        $('.right-btns-card').css({'right':''+marginRight+'px'});
      }
      else if($('html').scrollTop() < 120) {
        $('.btns-card').removeClass('right-btns-card');
        $('.btns-card').css({'right':'0px'});
      }


      if($('html').scrollTop() > window.innerHeight / 3 && $('body').hasClass('home')) {
        $('body').addClass('top-panel');
      }
      else if($('html').scrollTop() < window.innerHeight / 3 && $('body').hasClass('home')) {
        $('body').removeClass('top-panel');
      }

      // 
      if($('html').scrollTop() > 50 && $('body').hasClass('page')) {
        $('body').addClass('opacity-panel');
      }
      else if($('html').scrollTop() < 50 && $('body').hasClass('page')) {
        $('body').removeClass('opacity-panel');
      }
    }, 100);
  }

  // Раскрывает меню с функциями карты
  $('.btn-show-list').click(function () {
    $('.panel-show').css({'display':'grid'});
  });
  $(document).mouseup(function (e){ // событие клика по веб-документу
    var div = $(".panel-show"); // тут указываем ID элемента
    // if (!div.is(e.target) // если клик был не по нашему блоку
    //     && div.has(e.target).length === 0) { // и не по его дочерним элементам
      div.hide(); // скрываем его
    // }
  });

  // скролл при нажатии кнопки
  // $('.top-scroll').click(function () {
  //   $('html').scrollTop(0);
  // });
  $('.top-scroll').click(function(){
    $('html, body').animate({scrollTop:$('.footer').position().top}, 1000);
  });


  $('.icon-sorting').click(function(){
    if($('.panel-sorting').css('display') == 'none') {
        $('.panel-sorting').css({'display':'block'});
    }
    else {
        $('.panel-sorting').css({'display':'none'});
    }
  });
});