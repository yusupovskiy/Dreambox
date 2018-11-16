document.addEventListener('turbolinks:load', function() {

  // document.getElementById('main-list').onscroll = function() {
  //   console.log(document.getElementById('main-list').scrollTop);
  // }
  setInterval(
    () => {
      let scroll = document.getElementById("main-list").scrollTop;

      if(scroll >= 10) {
        $('#search').addClass('scroll-main-list');
      }
      else if(scroll < 10) {
        $('#search').removeClass('scroll-main-list');
      }
    },
  500);

  $(".open-tabs>div>div").niceScroll({cursorcolor:"transparent", cursorborder:"transparent"});

  // totalHeight();
  // $(window).resize(totalHeight);
  
  var scrollPanel = function () {
    $('html, body').animate({scrollTop: $('html').height()}, 500);
  };

  $('.header-katalog>input').focus(scrollPanel).click(scrollPanel);

  
  function totalHeight() {
    var constHeaderOpenObjects = 80;
    var windowHeight = window.innerHeight;
    var desiredHeight = windowHeight - constHeaderOpenObjects;
    $('.panel-list').css({'height':''+desiredHeight+'px'});
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

  var menuPnlOptionally = $('.pnl-optionally');
  $('.btn-open-optionally').click(function() {
    menuPnlOptionally.addClass('open');
  });
  $('.btn-close-pnl-add').click(function() {
    menuPnlOptionally.removeClass('open');
  });
  $(document).mouseup(function (e) {
    if (!menuPnlOptionally.is(e.target) && menuPnlOptionally.has(e.target).length === 0) {
      menuPnlOptionally.removeClass('open');
    }
  });

///

  var menuPnlAdd = $('.pnl-add');
  $('.btn-add-menu').click(function() {
    menuPnlAdd.addClass('open');
  });
  $('.btn-close-pnl-add').click(function() {
    menuPnlAdd.removeClass('open');
  });
  var menuHeaderPnlAdd = $('.header-pnl-add');
  $(document).mouseup(function (e) {
    if (!menuHeaderPnlAdd.is(e.target) && menuHeaderPnlAdd.has(e.target).length === 0) {
      menuPnlAdd.removeClass('open');
    }
  });

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
    if($(this).parents('.block-information').hasClass('parent-compact')) {
      $(this).parents('.block-information').removeClass('parent-compact');
    }
    else {
      $(this).parents().addClass('parent-compact');
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

  // show panel
  var btnShowPanel = $('.btn-show-panel');
  btnShowPanel.click(function() {
    $(this).parents('.show-and-hide-container').addClass('show-container');
  });
  var btnHidePanel = $('.btn-hide-panel');
  btnHidePanel.click(function() {
    $(this).parents('.show-and-hide-container').removeClass('show-container');
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