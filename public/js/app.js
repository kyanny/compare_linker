$(function(){
  $("button").each(function(index,elem){
    $(elem).on("click", function(event){
      $.post("/add_webhook", {"repo_full_name":$(elem).data("repo-full-name")}, function(data){
        if (data === "ok") {
          alert("Webhook created successfully");
        } else {
          alert("Something went to wrong. Try it again!");
        }
      });
    });
  });
});
