$(function(){
  $("button").each(function(index,elem){
    $(elem).on("click", function(event){
      $.post("/add_webhook", {"repo_full_name":$(elem).data("repo-full-name")}, function(data){
        console.log(data);
      });
    });
  });
});
