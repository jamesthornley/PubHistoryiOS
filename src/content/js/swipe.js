

var elem = document.getElementById('mySwipe');

window.mySwipe = Swipe(elem, {
  // startSlide: 4,
  // auto: 3000,
  // continuous: true,
  // disableScroll: true,
  // stopPropagation: true,)
  // callback: function(index, element) {alert(index);alert(element);},
   transitionEnd: function(index, element)
    {
  
        var $navLi = $('.nav li');
       $navLi.removeClass('selected');
       $navLi.eq(index).addClass('selected');
   }
});

function previous(mySwipe)
{
    mySwipe.prev();
}
function next(mySwipe)
{
    mySwipe.next();
}

