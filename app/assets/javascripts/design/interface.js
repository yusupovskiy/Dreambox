document.addEventListener('turbolinks:load', function() {

  $(".open-tabs>div>div").niceScroll({cursorcolor:"transparent", cursorborder:"transparent"});

  totalHeight();
  $(window).resize(totalHeight);
  
  var scrollPanel = function () {
    $('html, body').animate({scrollTop: $('html').height()}, 500);
  };

  $('.header-katalog>input').focus(scrollPanel).click(scrollPanel);

  
  function totalHeight() {
    var constHeaderOpenObjects = 84;
    var windowHeight = window.innerHeight;
    var desiredHeight = windowHeight - constHeaderOpenObjects;
    var topMargin = windowHeight / 1.55;
    $('.katalog').css({'height':''+desiredHeight+'px', 'margin-top':''+topMargin+'px'});
    $('.open-tabs>div>div>div').css({'margin-left':parseFloat($('.katalog').css('margin-left'))});
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
  
  $('.tabs .menu-with-options>div:nth-of-type(1)').addClass('active');
  

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
  $('.click-compact').click(function() {
    if($(this).parent('.block-information').hasClass('parent-compact')) {
      $(this).parent('.block-information').removeClass('parent-compact');
    }
    else {
      $(this).parent().addClass('parent-compact');
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


      // if($('html').scrollTop() > window.innerHeight / 3 && $('body').hasClass('home')) {
      //   $('body').addClass('top-panel');
      // }
      // else if($('html').scrollTop() < window.innerHeight / 3 && $('body').hasClass('home')) {
      //   $('body').removeClass('top-panel');
      // }

      // // 
      // if($('html').scrollTop() > 50 && $('body').hasClass('page')) {
      //   $('body').addClass('opacity-panel');
      // }
      // else if($('html').scrollTop() < 50 && $('body').hasClass('page')) {
      //   $('body').removeClass('opacity-panel');
      // }
    }, 100);
  }

  // // Раскрывает меню с функциями карты
  // $('.btn-show-list').click(function () {
  //   $(this).children(".panel-show").css({'display':'grid'});
  // });
  // $(document).mouseup(function (e){ // событие клика по веб-документу
  //   var div = $(".btn-show-list .panel-show"); // тут указываем ID элемента
  //   // if (!div.is(e.target) // если клик был не по нашему блоку
  //   //     && div.has(e.target).length === 0) { // и не по его дочерним элементам
  //     div.hide(); // скрываем его
  //   // }
  // });

  // // var showPanelLeftSideElem = function () {
  // //   $(".left-side-elem>.panel-show").css({'display':'none'});
  // //   $(this).children(".panel-show").css({'display':'grid'});
  // // };


  // // $('.left-side-elem').hover(showPanelLeftSideElem).click(showPanelLeftSideElem);

  // // $('.left-side-elem').mouseleave(function () {
  // //   $(".left-side-elem>.panel-show").css({'display':'none'});
  // // });

  // // $(document.body).click(function(e){
  // //   var activeSideElem = $(e.target).closest(".left-side-elem");
  // //   if(activeSideElem.length === 0)
  // //       return;
  // //   showPanelLeftSideElem;
  // //   console.log(activeSideElem); // элемент, на котором произошло событие
  // // });

  // focus input
  var focusInput = $('.finput .finput-input');
  focusInput.focus(function() {
    $(this).parents('.finput').addClass('focus');
  });
  focusInput.focusout(function() {
    this.value || $(this).parents('.finput').removeClass('focus');
  });
  for (let input of focusInput) {
    input.value && $(input).parents('.finput').addClass('focus')
  }

  // show panel for the sale of a subscription
  var btnTicketSale = $('.subscription-sale');
  btnTicketSale.mouseup(function() {
    $(this).parents('.item-element').children('.show-and-hide-panel').css('display', 'grid');
    $(this).parents('.panel-show').css('display', 'none');
  });

  // show and hide panel
  var btnShowPanel = $('.btn-show-panel');
  btnShowPanel.click(function() {
    $(this).parent('.show-and-hide-container').children('.show-and-hide-panel').css('display', 'grid');
    $(this).hide();
  });
  var btnHidePanel = $('.btn-hide-panel');
  btnHidePanel.click(function() {
    $(this).parents('.show-and-hide-panel').hide();
    $(this).parents('.show-and-hide-container').children('.btn-show-panel').show();
  });



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



  $('#cancel').click(function(){
    $('#cancel-panel').show();
  });
  $('#btn-cancel-panel').click(function(){
    $('#cancel-panel').hide();
  });

  $('#renewal').click(function(){
    $('#renewal-panel').show();
  });
  $('#btn-renewal-panel').click(function(){
    $('#renewal-panel').hide();
  });

  $('#recalculation').click(function(){
    $('#recalculation-panel').show();
  });
  $('#btn-recalculation-panel').click(function(){
    $('#recalculation-panel').hide();
  });
});