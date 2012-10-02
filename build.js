{
  "baseUrl":'javascripts',
  hbs : {
    templateExtension : 'hbs',
    disableI18n : true
  },
  paths  : {
    'hbs' : 'vender/require-handlebars-plugin/hbs',
    'handlebars' : 'vender/require-handlebars-plugin/Handlebars',
    "underscore" : "vender/require-handlebars-plugin/hbs/underscore",
    "i18nprecompile" : "vender/require-handlebars-plugin/hbs/i18nprecompile",
    "json2" : "vender/require-handlebars-plugin/hbs/json2"
  },
  name: "main",
  out: 'javascripts/main-built.js'
}
