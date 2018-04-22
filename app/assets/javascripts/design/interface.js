document.addEventListener('turbolinks:load', function() {
  //totalHeight();
  // $(window).resize(totalHeight);
  
  $('.header-katalog>input').focus(totalHeight);
  
  
    // Функция для добавления обработчика событий
  /*function addHandler(object, event, handler) {
    if (object.addEventListener) {
      object.addEventListener(event, handler, false);
    }
    else if (object.attachEvent) {
      object.attachEvent('on' + event, handler);
    }
    else console.log("Обработчик не поддерживается");
  }
  // Добавляем обработчики для разных браузеров
  addHandler(window, 'DOMMouseScroll', wheel);
  addHandler(window, 'mousewheel', wheel);
  addHandler(document, 'mousewheel', wheel);
  // Функция, обрабатывающая событие
  function wheel(event) {
    var delta; // Направление колёсика мыши
    event = event || window.event;
    // Opera и IE работают со свойством wheelDelta
    if (event.wheelDelta) { // В Opera и IE
      delta = event.wheelDelta / 120;
      // В Опере значение wheelDelta такое же, но с противоположным знаком
      if (window.opera) delta = -delta; // Дополнительно для Opera
    }
    else if (event.detail) { // Для Gecko
      delta = -event.detail / 3;
    }
    // Запрещаем обработку события браузером по умолчанию
    if (event.preventDefault) event.preventDefault();
    event.returnValue = false;
    console.log(delta); // Выводим направление колёсика мыши
  
    if (delta < 0) {
      totalHeight();
      $('.footer').css({'top':'-34px'});
    }
    else if (delta > 0) {
      $('.katalog').css({'height':'36%'});
      $('.test').css({'height':'50%'});
      $('.footer').css({'top':'12px'});
    }
  }*/
  
  
  function totalHeight() {
    var constHeaderOpenObjects = 84;
    var desiredHeight = window.innerHeight - constHeaderOpenObjects;
    $('.katalog').css({'height':''+desiredHeight+'px'});
    $('.test').css({'height':'74px'});
  }

  $(function($){
    $(document).mouseup(function (e){ // событие клика по веб-документу
      var div = $(".katalog"); // тут указываем ID элемента
      if (!div.is(e.target) // если клик был не по нашему блоку
          && div.has(e.target).length === 0) { // и не по его дочерним элементам
        $('.katalog').css({'height':'36%'}); // скрываем его
      }
    });
  });

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
        $('.right-btns-card').css({'right':''+marginRight+'px'})
        ;
      }
      else if($('html').scrollTop() < 120) {
        $('.btns-card').removeClass('right-btns-card');
        $('.btns-card').css({'right':'0px'});

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