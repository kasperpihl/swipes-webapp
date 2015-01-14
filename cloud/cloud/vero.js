exports.track = function(eventName,options,callback){

    var user = Parse.User.current();
    if(options && options.user) user = options.user;
    if(!user && callback) return callback(false,'You have to be logged in');
    else if(!user) return false;

    var email = user.get('email');
    if(!email || !validateEmail(email)) email = user.get('username');
    if((!email || !validateEmail(email)) && callback) return callback(false,'User has no email');
    else if(!email || !validateEmail(email)) return false;
    
    Parse.Cloud.httpRequest({
        url:'http://api.swipesapp.com/vero',
        method:'POST',
        headers:{
            'Content-Type': 'application/json'
        },
        params:{

        },
        body:{
            eventName: eventName,
            identifier: user.id,
            email: email
        },
        success:function(result){
            if(callback) callback(result);
        },
        error:function(error){
            if(callback) callback(false,error);
        }
    });
};
function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
};
exports.unsubscribe = function(userId,callback){
};
exports.sendMultiple = function(eventName,identities,callback){
    var conf = require('cloud/conf.js');
    var keys = conf.keys;
    var newIdentities = [];
    if(identities && identities.length > 0){
        for(var i = 0 ; i < identities.length ; i++){
            newIdentities[i] = {id:identities[i]};
        }
         
    }
    Parse.Cloud.httpRequest({
        url:'https://www.getvero.com/api/v2/events/track.json',
        method:'POST',
        params:{
            auth_token:keys.veroToken,
            identity:JSON.stringify(newIdentities),
            event_name:eventName,
            development_mode:keys.veroDevelopment
        },
        success:function(result){
            if(callback) callback(result);
        },
        error:function(error){
            sendError(false,error);
            if(callback) callback(false,error);
        }
    });
};