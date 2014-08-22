do ->
  Mock.mockjax = (module) ->

    item =
      find: (url) ->
        @template = {}
        for k, v of Mock._mocked
          if k is url
            return @template = Mock.mock v.template

      template: {}

    try
      module.config ($httpProvider) ->
        $httpProvider.interceptors.push ->
          return {
          request: (config) ->
            item.find config.url
            config.url = "?mockUrl=#{config.url}"
            return config

          response: (response) ->
            response.data = item.template
            return response
          }
    catch error
      console.error '生成mock.angular失败，例：var app = angular.module("app", []); Mock.mockjax(app);'