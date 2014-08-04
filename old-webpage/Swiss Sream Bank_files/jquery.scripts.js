$(document).ready(function() {

  
  $('#nav li a').click(function(e){
    e.preventDefault();
    var href = $(this).attr('href');
    $(window).scrollTo(href, 400);
      
  });
  
});
		
		

/*
  Scroll To plugin sur http://trevordavis.net/blog/jquery-one-page-navigation-plugin
*/	 