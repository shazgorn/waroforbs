class AppMock
  constructor: () ->
    @resource_info =
      gold:
        title: ''
        description: ''
      wood:
        title: ''
        description: ''
      stone:
        title: ''
        description: ''
      settlers:
        title: ''
        description: ''

window.App = new AppMock
