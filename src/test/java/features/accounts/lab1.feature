# LAB 1 - Login y consulta de cuentas
Feature: Consulta de cuentas

  Background:
    * url baseUrl
    # Given path 'auth', 'login'
    # And request { username: '#(user)', password: '#(pass)' }
    # When method post
    # Then status 200
    # And match response.tokenType == 'Bearer'
    # * def token = response.token
    # # configure headers: el token viaja en TODAS las peticiones del Scenario
    # * configure headers = { Authorization: '#("Bearer " + token)' }

  Scenario: Detalle de una cuenta (path)
    Given path 'accounts', 'acc-005'
    When method get
    Then status 200
    And match response.id == 'acc-005'
    And match response.currency == 'PEN'
    And match response.active == true

  Scenario: Listado paginado (10 por página)
    Given path 'accounts'
    When method get
    Then status 200
    And match response.items == '#[10]'
    And match response.page == 1
    And match response.pageSize == 10
    # el total puede variar si el alumno creó cuentas en el lab 2
    And match response.total == '#number'

  Scenario: Cuenta inexistente
    Given path 'accounts', 'acc-999'
    When method get
    Then status 404
    And match response.code == 'ACCOUNT_NOT_FOUND'

  Scenario: Filtrar por moneda (query param)
    Given path 'accounts'
    And param currency = 'USD'
    When method get
    Then status 200
    And match each response.items contains { currency: 'USD' }

  Scenario: Paginar con pageSize = 5
    Given path 'accounts'
    And params { page: 2, pageSize: 5 }
    When method get
    Then status 200
    And match response.page == 2
    And match response.pageSize == 5
    And match response.items == '#[5]'

  Scenario: Tipos de acc-001 con marcadores
    Given path 'accounts', 'acc-001'
    When method get
    Then status 200
    And match response contains
      """
      {
        id: '#string', accountNumber: '#string', holderName: '#string',
        currency: '#string', balance: '#number', active: '#boolean',
        contact: '#object', tags: '#array'
      }
      """

  # Reto extra: cuentas inactivas (la semilla deja inactiva a acc-007)
  Scenario: Cuentas inactivas
    Given path 'accounts'
    And param active = 'false'
    When method get
    Then status 200
    And match each response.items contains { active: false }
    And match response.items[*].id contains 'acc-007'
