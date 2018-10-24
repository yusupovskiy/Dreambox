function updateURLParameter(url, param, paramVal){
  var newAdditionalURL = "";
  var tempArray = url.split("?");
  var baseURL = tempArray[0];
  var additionalURL = tempArray[1];
  var temp = "";
  if (additionalURL) {
    tempArray = additionalURL.split("&");
    for (var i=0; i<tempArray.length; i++){
      if(tempArray[i].split('=')[0] != param){
          newAdditionalURL += temp + tempArray[i];
          temp = "&";
      }
    }
  }

  var rows_txt = temp + "" + param + "=" + paramVal;
  return baseURL + "?" + newAdditionalURL + rows_txt;
}

function deleteURLParameter(Url, Prm) {
  var a = Url.split('?');
  var re = new RegExp('(\\?|&)' + Prm + '=[^&]+', 'g');

  Url = ('?' + a[1]).replace(re,'');
  Url = Url.replace(/^&|\?/,'');

  var dlm  = (Url == '' ) ? '' : '?';

  return a[0] + dlm + Url;
};

function validSpaces(text) {
  text = text.trim();
  text = text.replace(/ {1,}/g," ");
  
  return text;
}

function totalDate(date, d, m, y) {
  dateArray = date.split('-');

  if(dateArray[1] == 1)
    dateArray[1] = 'января';
  else if(dateArray[1] == 2)
    dateArray[1] = 'февраля';
  else if(dateArray[1] == 3)
    dateArray[1] = 'марта';
  else if(dateArray[1] == 4)
    dateArray[1] = 'апреля';
  else if(dateArray[1] == 5)
    dateArray[1] = 'мая';
  else if(dateArray[1] == 6)
    dateArray[1] = 'июля';
  else if(dateArray[1] == 7)
    dateArray[1] = 'июня';
  else if(dateArray[1] == 8)
    dateArray[1] = 'августа';
  else if(dateArray[1] == 9)
    dateArray[1] = 'сентября';
  else if(dateArray[1] == 10)
    dateArray[1] = 'октября';
  else if(dateArray[1] == 11)
    dateArray[1] = 'ноября';
  else if(dateArray[1] == 12)
    dateArray[1] = 'декабря';
  
  dDate = d ? dateArray[2] + ' ' : ''
  mDate = m ? dateArray[1] + ' ' : ''
  yDate = y ? dateArray[0] : ''

  newDate = dDate + mDate + yDate;

  return newDate;
}

function setDate(day, month, year) {
  var day = day;
  var month = month + 1;
  var year = year;

  if (month < 10) month = "0" + month;
  if (day < 10) day = "0" + day;

  var today = year + "-" + month + "-" + day;

  return today;
}

function getLastDayOfMonth(year, month) {
  var date = new Date(year, month + 1, 0);
  return date;
}

function nameMonth(month, ending) {
  var arrayNameMonth = ['январь','февраль','март','апрель','май',
    'июнь','июль','август','сентябрь','октябрь','ноябрь','декабрь'];

  var arrayNameMonth2 = ['января','февраля','марта','апреля','мая',
    'июня','июля','августа','сентября','октября','ноября','декабря'];

  if(ending == 1)
    return arrayNameMonth[month];
  else if(ending == 2)
    return arrayNameMonth2[month];
}