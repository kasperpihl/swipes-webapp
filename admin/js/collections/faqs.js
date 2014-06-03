var faqModel = Parse.Object.extend('FAQ');
var faqCollectionQuery = new Parse.Query(faqModel);
faqCollectionQuery.descending('createdAt');
App.collections.Faqs = Parse.Collection.extend({
	model: faqModel,
	query: faqCollectionQuery
});