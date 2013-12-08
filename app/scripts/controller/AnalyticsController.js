function isInt(n) {
   return typeof n === 'number' && n % 1 == 0;
}
(function() {
  define(["underscore"], function(_) {
    var AnalyticsController;
    return AnalyticsController = (function() {
      function AnalyticsController() {
        // TODO: make sure every time Parse.User.current() changes/changes-attributes that the updateUser(user) get called!
        this.init();
      }
      AnalyticsController.prototype.init = function() {
        this.customDimensions = new Array("Standard");
        this.screens = new Array();
        var testKey = "f2f927e0eafc7d3c36835fe-c0a84d84-18d8-11e3-3b24-00a426b17dd8";
        var liveKey = "0c159f237171213e5206f21-6bd270e2-076d-11e3-11ec-004a77f8b47f";
        this.localyticsSession = LocalyticsSession(testKey);
        this.localyticsSession.open();
        this.localyticsSession.upload();
        this.updateUser(Parse.User.current());
      };
      AnalyticsController.prototype.customDimension = function(dimension){
        if(isInt(dimension) && dimension >= 0 && dimension < this.customDimensions.length) return this.customDimensions[dimension];
        return false;
      };
      AnalyticsController.prototype.setCustomDimension = function(dimension,value){
        if(isInt(dimension) && dimension >= 0 && dimension < this.customDimensions.length) this.customDimensions[dimension] = value;
      };
      AnalyticsController.prototype.tagEvent = function(event,options) {
        this.localyticsSession.tagEvent(event, options, this.customDimensions);
      };
      AnalyticsController.prototype.pushScreen = function(screenName){
        this.localyticsSession.tagScreen(screenName);
        this.screens.push(screenName);
      }
      AnalyticsController.prototype.popScreen = function(){
        if(this.screens.length >0){ 
          this.screens.pop();
          this.localyticsSession.tagScreen(_.last(this.screens));
        }
      }
      AnalyticsController.prototype.updateUser = function(user){
        var userLevel = parseInt(user.get('userLevel'),10);
        var cdUserLevel = "Standard";
        if(userLevel == 1) cdUserLevel = "Trial";
        else if(userLevel == 2) cdUserLevel = "Plus Monthly";
        else if(userLevel == 3) cdUserLevel = "Plus Yearly";
        if(cdUserLevel != this.customDimension(0)) this.setCustomDimension(0,cdUserLevel);
        var email = user.get('email');
        if(email && email != this.localyticsSession.customerEmail) this.localyticsSession.setCustomerEmail(email);

        var identifier = user.id;
        if(identifier && identifier != this.localyticsSession.customerId) this.localyticsSession.setCustomerId(identifier);
      }
      return AnalyticsController;

    })();
  });

}).call(this);