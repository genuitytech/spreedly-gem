require 'test_helper'
require 'unit/response_stubs/add_apple_pay_stubs'

class AddApplePayTest < Test::Unit::TestCase

  include AddApplePayStubs

  def setup
    @environment = Spreedly::Environment.new("key", "secret")
  end

  def test_successful_add_apple_pay
    t = add_apple_pay_using(successful_add_apple_pay_response)

    assert_kind_of(Spreedly::AddPaymentMethod, t)
    assert_kind_of(Spreedly::ApplePay, t.payment_method)

    assert_equal 'JCGkbSqUDHcbbntf96rsqrVs3ga', t.token
    assert !t.retained?
    assert t.succeeded?
    assert_equal Time.parse("2016-11-22T21:58:51Z"), t.created_at
    assert_equal Time.parse("2016-11-22T21:58:51Z"), t.updated_at
    assert_equal 'Succeeded!', t.message

    assert_equal "BKkIkMsszEkzCrdMqcPhKCqD8rJ", t.payment_method.token
    assert_equal "Chad Boyd", t.payment_method.full_name
    assert_equal "Don't test everything here, since find_payment_method tests it all.", t.payment_method.data
  end

  def test_request_body_params
    body = get_request_body(successful_add_apple_pay_response) do
      @environment.add_apple_pay(full_apple_pay_details)
    end

    payment_method = body.xpath('./payment_method')
    assert_xpaths_in payment_method,
      [ './retained', "true" ],
      [ './first_name', "Chad" ],
      [ './last_name', "Boyd" ],
      [ './email', "chad@txt2give.it" ],
      [ './address1', "123 St" ],
      [ './address2', "Apt. C" ],
      [ './city', "Nixa" ],
      [ './state', "MO" ],
      [ './zip', "65714" ],
      [ './country', "United States" ]

    payment_data = body.xpath('./payment_method/apple_pay/payment_data')
    assert_xpaths_in payment_data,
      [ './version', 'EC_v1' ],
      [ './data', 'QlzLxRFnNP9/GTaMhBwgmZ2ywntbr9iOcBY4TjPZyNrnCwsJd2cq61bDQjo3agVU0LuEot2VIHHocVrp5jdy0FkxdFhGd+j7hPvutFYGwZPcuuBgROb0beA1wfGDi09I+OWL+8x5+8QPl+y8EAGJdWHXr4CuL7hEj4CjtUhfj5GYLMceUcvwgGaWY7WzqnEO9UwUowlDP9C3cD21cW8osn/IKROTInGcZB0mzM5bVHM73NSFiFepNL6rQtomp034C+p9mikB4nc+vR49oVop0Pf+uO7YVq7cIWrrpgMG7ussnc3u4bmr3JhCNtKZzRQ2MqTxKv/CfDq099JQIvTj8hbqswv1t+yQ5ZhJ3m4bcPwrcyIVej5J241R7dNPu9xVjM6LSOX9KeGZQGud' ],
      [ './signature', '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' ]

    header = body.xpath('./payment_method/apple_pay/payment_data/header')
    assert_xpaths_in header,
      [ './ephemeralPublicKey', 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQwjaSlnZ3EXpwKfWAd2e1VnbS6vmioMyF6bNcq/Qd65NLQsjrPatzHWbJzG7v5vJtAyrf6WhoNx3C1VchQxYuw==' ],
      [ './transactionId', 'e220cc1504ec15835a375e9e8659e27dcbc1abe1f959a179d8308dd8211c9371' ],
      [ './publicKeyHash', '/4UKqrtx7AmlRvLatYt9LDt64IYo+G9eaqqS6LFOAdI=' ]
  end

  private

  def add_apple_pay_using(response)
    @environment.stubs(:raw_ssl_request).returns(response)
    @environment.add_apple_pay(full_apple_pay_details)
  end

  def full_apple_pay_details
    {
      apple_pay: {
        payment_data: {
          version: "EC_v1",
          data: "QlzLxRFnNP9/GTaMhBwgmZ2ywntbr9iOcBY4TjPZyNrnCwsJd2cq61bDQjo3agVU0LuEot2VIHHocVrp5jdy0FkxdFhGd+j7hPvutFYGwZPcuuBgROb0beA1wfGDi09I+OWL+8x5+8QPl+y8EAGJdWHXr4CuL7hEj4CjtUhfj5GYLMceUcvwgGaWY7WzqnEO9UwUowlDP9C3cD21cW8osn/IKROTInGcZB0mzM5bVHM73NSFiFepNL6rQtomp034C+p9mikB4nc+vR49oVop0Pf+uO7YVq7cIWrrpgMG7ussnc3u4bmr3JhCNtKZzRQ2MqTxKv/CfDq099JQIvTj8hbqswv1t+yQ5ZhJ3m4bcPwrcyIVej5J241R7dNPu9xVjM6LSOX9KeGZQGud",
          signature: "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",
          header: {
            ephemeralPublicKey: "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQwjaSlnZ3EXpwKfWAd2e1VnbS6vmioMyF6bNcq/Qd65NLQsjrPatzHWbJzG7v5vJtAyrf6WhoNx3C1VchQxYuw==",
            transactionId: "e220cc1504ec15835a375e9e8659e27dcbc1abe1f959a179d8308dd8211c9371",
            publicKeyHash: "/4UKqrtx7AmlRvLatYt9LDt64IYo+G9eaqqS6LFOAdI="
          }
        }
      },
      retained: true,
      first_name: "Chad",
      last_name: "Boyd",
      email: "chad@txt2give.it",
      address1: "123 St",
      address2: "Apt. C",
      city: "Nixa",
      state: "MO",
      zip: "65714",
      country: "United States"
    }
  end

end