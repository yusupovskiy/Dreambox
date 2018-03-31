# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

completeClients = (clients)->
  clients.forEach (client)->
    client.selected = no
  clients

class Client
  constructor: ->
    @first_name   = ''
    @last_name    = ''
    @patronymic   = ''
    @birthday     = null
    @phone_number = '+7'

window.tt = Client

document.addEventListener('turbolinks:load', ->
  params = JSON.parse(document.body.dataset.params)
  return unless companyId = params['company_id']


  # cache of VueJS instances
  dynamicWindows = {}
  loadWindow = (windowPath, windowId, data, methods) ->
    vm.isLoading = yes
    $.get(windowPath, (html) =>
      res = Vue.compile(html)
      v = new Vue({
        data: data,
        methods: methods
        render: res.render,
        staticRenderFns: res.staticRenderFns
      })
      v.$mount(document.getElementById(windowId))
      dynamicWindows[windowId] = v
    ).always(() => vm.isLoading = no)

  window.vm = vm = new Vue({
    el: "#content-list",
    data:
      isAddClientWindowOpened: no
      isClientInfoWindowOpened: no
      isLoading: no
      clients: []
      totalClients: 100
    computed:
      isWindowOpened: ->
        this.isAddClientWindowOpened || this.isClientInfoWindowOpened
    methods: {
      # Windows
      openAddClientWindow: ->
        this.isAddClientWindowOpened = yes
        windowId = 'add-client-window'
        return if dynamicWindows[windowId]
        data = new Client
        windowPath = Routes.addClientWindow()
        methods =
          closeAddClient: -> vm.isAddClientWindowOpened = no
          createClient: -> vm.createClient(this)
        loadWindow(windowPath, windowId, data, methods)
      openClientInfoWindow: (client)->
        this.isClientInfoWindowOpened = yes
        windowId = 'client-info-window'
        dw = dynamicWindows[windowId]
        data = client
        if dw
          Object.assign(dw.$data, data)
          return
        windowPath = Routes.clientInfoWindow()
        methods =
          closeClientInfo: -> vm.isClientInfoWindowOpened = no
          removeClient: ->
            vm.removeClient(client)
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

      removeClient: (client)->
        options =
          method: 'DELETE'
          data:
            authenticity_token: AUTHENTICITY_TOKEN
        this.isLoading = yes
        $.ajax(Routes.removeClient(companyId, client.id), options)
          .done =>
            this.clients.splice(this.clients.indexOf(client), 1)
            --this.totalClients
          .fail => alert(e)
          .always => this.isLoading = no

      selectClient: (client)->
        client.selected = !client.selected
    },
    created: ->
      $.get(Routes.getAllClients(companyId), (res, _statusMessage, xhr) =>
        if (xhr.getResponseHeader('Content-Type').startsWith('application/json'))
          this.clients = completeClients(res.clients)
          this.totalClients = res.total_clients
        else
          window.location = Routes.signIn()
      )
  })
)
console.log "ok"