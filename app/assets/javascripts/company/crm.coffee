# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener('turbolinks:load',
  ->
    params = JSON.parse(document.body.dataset.params)
    return unless companyId = params['company_id']

    window.vm = new Vue({
      el: "#data-lists-manager",
      data:
        isAddClientWindowOpened: false
        isLoading: false
        clients: []
        firstName: ''
        lastName: ''
        patronymic: ''
        birthday: new Date().toISOString().substr(0, 10)  # yyyy-MM-dd - 10 symbols
        phoneNumber: ''
      methods: {
        createClient: ->
          data =
            authenticity_token: AUTHENTICITY_TOKEN
            company_id: companyId
            client:
              first_name: this.firstName
              last_name: this.lastName
              patronymic: this.patronymic
              birthday: this.birthday
              phone_number: this.phoneNumber
          this.isLoading = true
          $.post(Routes.addNewClient(companyId), data, (client) =>
            this.clients.push(client)
            this.clearFields()
            this.isAddClientWindowOpened = false
          ).fail((e) =>
            messages = ''
            for field, value of e.responseJSON
              messages += '\n<' + field + '> = ' + value.join(', ')
            alert('Errors:\n' + messages)
          ).always((e) =>
            this.isLoading = false
          )
        clearFields: ->
          this.firstName   = ''
          this.lastName    = ''
          this.patronymic  = ''
          this.phoneNumber = ''
        removeClient: (index)->
          client = this.clients[index]
          options =
            method: 'DELETE'
            data:
              authenticity_token: AUTHENTICITY_TOKEN
          this.isLoading = true
          $.ajax(Routes.removeClient(companyId, client.id), options)
            .done => this.clients.splice(index, 1)
            .fail => alert(e)
            .always => this.isLoading = false
      },
      created: ->
        $.get(Routes.getAllClients(companyId), (clients) =>
          this.clients = clients
        )
    })
)
console.log "ok"