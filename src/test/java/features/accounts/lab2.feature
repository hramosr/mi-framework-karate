@ignore
# LAB 2 - Ciclo CRUD de cuentas
Feature: CRUD de cuentas

  Background:
    * url baseUrl
    # Given path 'auth', 'login'
    # And request { username: '#(user)', password: '#(pass)' }
    # When method post
    # Then status 200
    # * def token = response.token
    # * configure headers = { Authorization: '#("Bearer " + token)' }
    # # cuerpo base reutilizable en todos los escenarios
    # * def body = read('classpath:data/account.json')

  Scenario: Crear una cuenta (POST)
    Given path 'accounts'
    And request body
    When method post
    Then status 201
    And match response.id == '#string'
    And match response.holderName == body.holderName
    And match response.currency == body.currency
    And match response.balance == body.initialBalance
    And match response.active == true
    And match header Location contains response.id

  Scenario: Crear, reemplazar con PUT y verificar con GET
    Given path 'accounts'
    And request body
    When method post
    Then status 201
    * def id = response.id

    # PUT reemplaza TODOS los campos mutables: no admite currency ni initialBalance
    * def changes = { holderName: 'Ana Rojas de Pérez', active: true, contact: { email: 'ana.perez@novusdemo.pe' } }
    Given path 'accounts', id
    And request changes
    When method put
    Then status 200
    And match response.holderName == 'Ana Rojas de Pérez'
    And match response.updatedAt == '#string'

    # verificar el efecto, no solo la respuesta
    Given path 'accounts', id
    When method get
    Then status 200
    And match response.holderName == 'Ana Rojas de Pérez'
    And match response.contact.email == 'ana.perez@novusdemo.pe'

  Scenario: Crear, modificar con PATCH y verificar que el resto no cambió
    Given path 'accounts'
    And request body
    When method post
    Then status 201
    * def id = response.id

    Given path 'accounts', id
    And request { active: false }
    When method patch
    Then status 200
    And match response.active == false
    And match response.holderName == body.holderName
    And match response.balance == body.initialBalance

    Given path 'accounts', id
    When method get
    Then status 200
    And match response.active == false
    And match response.holderName == body.holderName

  Scenario: Crear, eliminar con DELETE y verificar que ya no existe
    Given path 'accounts'
    And request body
    When method post
    Then status 201
    * def id = response.id

    Given path 'accounts', id
    When method delete
    Then status 204

    Given path 'accounts', id
    When method get
    Then status 404
    And match response.code == 'ACCOUNT_NOT_FOUND'

  Scenario: PATCH no permite cambiar el saldo (caso negativo)
    Given path 'accounts'
    And request body
    When method post
    Then status 201
    * def id = response.id

    Given path 'accounts', id
    And request { balance: 5 }
    When method patch
    Then status 400
    And match response.code == 'IMMUTABLE_FIELD'
    And match response.field == 'balance'

  # Reto extra: el alias es único por alumno
  Scenario: Alias duplicado devuelve 409
    * set body.alias = 'qa-' + karate.uuid().substring(0, 8)
    Given path 'accounts'
    And request body
    When method post
    Then status 201

    Given path 'accounts'
    And request body
    When method post
    Then status 409
    And match response.code == 'ALIAS_ALREADY_EXISTS'
    And match response.field == 'alias'
