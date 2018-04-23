# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

setSelectable = (items)->
  items.forEach (item)->
    item.selected = no
  items

class Client
  constructor: ->
    @first_name   = ''
    @last_name    = ''
    @patronymic   = ''
    @birthday     = null
    @phone_number = '+7'

window.tt = Client

document.addEventListener('turbolinks:load', ->
  return # stub
  params = JSON.parse(document.body.dataset.params)
  return unless companyId = params['company_id']


  # cache of VueJS instances
  dynamicWindows = {}
  loadWindow = (windowPath, windowId, data, methods) ->
    load = (html)->
      res = Vue.compile(html)
      v = new Vue({
        data: data,
        methods: methods
        render: res.render,
        staticRenderFns: res.staticRenderFns
      })
      v.$mount(document.getElementById(windowId))


    if win = dynamicWindows[windowPath]
      load(win)
      return

    vm.isLoading = yes
    $.get(windowPath, (html) =>
      load(html)
      dynamicWindows[windowPath] = html
    ).always(() => vm.isLoading = no)

  window.vm = vm = new Vue({
    el: "#content-list",
    data:
      isAddClientWindowOpened: no
      isClientInfoWindowOpened: no
      isAddServiceWindowOpened: no
      isServiceInfoWindowOpened: no
      isLoading: no
      clients: []
      services: []
      totalClients: 0
      totalServices: 0
    computed:
      isWindowOpened: ->
        this.isAddClientWindowOpened || this.isClientInfoWindowOpened ||
        this.isAddServiceWindowOpened || this.isServiceInfoWindowOpened
    methods: {
      # Windows
      openAddClientWindow: ->
        this.isAddClientWindowOpened = yes
        windowId = 'add-client-window'
        windowPath = Routes.addClientWindow()
        return if dynamicWindows[windowPath]
        data = new Client
        methods =
          closeAddClient: -> vm.isAddClientWindowOpened = no
          createClient: -> vm.createClient(this)
        loadWindow(windowPath, windowId, data, methods)
      openClientInfoWindow: (index)->
        client = this.clients[index]
        this.isClientInfoWindowOpened = yes
        windowId = 'client-info-window'
        data = client
        windowPath = Routes.clientInfoWindow()
        methods =
          closeClientInfo: -> vm.isClientInfoWindowOpened = no
          removeClient: ->
            vm.removeClient(index)
            this.closeClientInfo()
        loadWindow(windowPath, windowId, data, methods)

      createClient: (vm)->
        data =
          authenticity_token: AUTHENTICITY_TOKEN
          company_id: companyId
          client: vm.$data
        this.isLoading = yes
        $.post(Routes.addNewClient(companyId), data, (client) =>
          client.selected = no
          this.clients.push(client)
          this.isAddClientWindowOpened = no
          ++this.totalClients
        ).fail((e) =>
          messages = ''
          for field, value of e.responseJSON
            messages += '\n<' + field + '> = ' + value.join(', ')
          alert('Errors:\n' + messages)
        ).always((e) =>
          this.isLoading = no
        )

      removeClient: (index)->
        client = this.clients[index]
        options =
          method: 'DELETE'
          data:
            authenticity_token: AUTHENTICITY_TOKEN
        this.isLoading = yes
        $.ajax(Routes.removeClient(companyId, client.id), options)
          .done =>
            this.clients.splice(this.clients.indexOf(client), 1)
            --this.totalClients
          .fail (e) => alert(e)
          .always => this.isLoading = no

      selectClient: (client)->
        client.selected = !client.selected


      # services
      openAddServiceWindow: ->
        this.isAddServiceWindowOpened = yes
        windowId = 'add-service-window'
        windowPath = Routes.addServiceWindow()
        return if dynamicWindows[windowPath]
        data = name: ''
        methods =
          closeAddService: -> vm.isAddServiceWindowOpened = no
          createService: -> vm.createService(this)
        loadWindow(windowPath, windowId, data, methods)
      openServiceInfoWindow: (index)->
        service = this.services[index]
        this.isServiceInfoWindowOpened = yes
        windowId = 'service-info-window'
        data = service
        windowPath = Routes.serviceInfoWindow()
        methods =
          closeServiceInfo: -> vm.isServiceInfoWindowOpened = no
          removeService: ->
            vm.removeService(index)
            this.closeServiceInfo()
        loadWindow(windowPath, windowId, data, methods)

      createService: (vm)->
        data =
        authenticity_token: AUTHENTICITY_TOKEN
        company_id: companyId
        service: vm.$data
        this.isLoading = yes
        $.post(Routes.addNewService(companyId), data, (service) =>
          service.selected = no
          this.services.push(service)
          this.isAddServiceWindowOpened = no
          ++this.totalServices
        ).fail((e) =>
          messages = ''
          for field, value of e.responseJSON
            messages += '\n<' + field + '> = ' + value.join(', ')
          alert('Errors:\n' + messages)
        ).always((e) =>
          this.isLoading = no
        )

      removeService: (index)->
        service = this.services[index]
        options =
          method: 'DELETE'
          data:
            authenticity_token: AUTHENTICITY_TOKEN
        this.isLoading = yes
        $.ajax(Routes.removeService(companyId, service.id), options)
          .done =>
            this.services.splice(index, 1)
            --this.totalServices
          .fail (e) => alert(e)
          .always => this.isLoading = no

      selectService: (service)->
        service.selected = !service.selected
    },
    created: ->
      $.get(Routes.getAllClients(companyId), (res, _statusMessage, xhr) =>
        if (xhr.getResponseHeader('Content-Type').startsWith('application/json'))
          this.clients = setSelectable(res.clients)
          this.totalClients = res.total_clients
        else
          window.location = Routes.signIn()
      )

      $.get(Routes.getAllServices(companyId), (res, _statusMessage, xhr) =>
        if (xhr.getResponseHeader('Content-Type').startsWith('application/json'))
          this.services = setSelectable(res.services)
          this.totalServices = res.total_services
        else
          window.location = Routes.signIn()
      )
  })
)
console.log "ok"