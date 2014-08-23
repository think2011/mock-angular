do ->
  Mock.mockjax = (module) ->
    class Item
      add: (url) ->
        for k, v of Mock._mocked
          reg = null
          if /^\/.*\/$/.test k
            reg = eval k
          else
            reg = new RegExp k

          if reg.test url
            return Mock.mock v.template

    try
      module.config ($httpProvider) ->
        item = new Item()

        $httpProvider.interceptors.push ->
          return {
          request: (config) ->
            # 匹配mock
            result = item.add config.url
            if result
              # 保存原始信息
              config.original =
                url   : config.url
                result: result
                method: config.method
                params: config.params
                data  : config.data

              config.method = "GET"
              config.url    = "?mockUrl=#{config.url}"

            return config

          response: (response) ->
            # 拦截输出mock
            original = response.config.original
            if original
              response.data = original.result
              console.log original

            return response
          }
    catch error
      console.error '生成mock.angular失败，例：var app = angular.module("app", []); Mock.mockjax(app);'