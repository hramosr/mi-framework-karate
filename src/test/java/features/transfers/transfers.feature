Feature: Transfers

Background:
   * url baseUrl  

Scenario: Crear una transferencia y verificar el debito
    Given path 'accounts', 'acc-001'
    When method get
    Then status 200
    * def before = response.balance

    Given path 'transfers'
    And request { fromAccountId: 'acc-001', toAccountId: 'acc-002', amount: 350.50}
    When method post
    Then status 201
    And match response.status == 'pending'
    And match response.completedAt == null
    * def transferId = response.id

    Given path 'accounts', 'acc-001'
    When method get
    Then match response.balance == before - 350.50
