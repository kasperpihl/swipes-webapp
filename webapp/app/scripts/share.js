function shareEmail(tasks){
  var mailToString = "mailto:?subject=Tasks to complete&body="+encodeURIComponent("Tasks: \r\n");
  for(var i = 0 ; i < tasks.length ; i++){
    task = tasks[i];
    mailToString += encodeURIComponent("◯ "+task.get('title') + "\r\n");
  }
  mailToString += encodeURIComponent("\r\nSent from Swipes - http://swipesapp.com\r\n");
  window.location.href=mailToString;
}