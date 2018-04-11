$(document).ready(function() {
  //totalHeight();
  // $(window).resize(totalHeight);
  
  $('.header-katalog>input').focus(totalHeight);
  
  
    // Функция для добавления обработчика событий
  function addHandler(object, event, handler) {
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
  }
  
  
  function totalHeight() {
    var constHeaderOpenObjects = 84;
    var desiredHeight = document.body.clientHeight - constHeaderOpenObjects;
    $('.katalog').css({'height':''+desiredHeight+'px'});
    $('.test').css({'height':'74px'});
  }
});