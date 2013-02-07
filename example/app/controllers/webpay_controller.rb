# encoding: utf-8
class WebpayController < ApplicationController

  def show

  end

  def pay
    # Setup the payment
    @payment = TBK::Webpay::Payment.new({
      amount: 5000.0,
      order_id: SecureRandom.hex(6),
      success_url: webpay_success_url,
      confirmation_url: webpay_confirmation_url(host: '127.0.0.1', port: 80, protocol: 'http'),
      session_id: SecureRandom.hex(6),
      failure_url: webpay_failure_url # success_url is used by default
    })

    # Redirect the user to Webpay
    redirect_to @payment.redirect_url
  end

  # Confirmation callback executed from Webpay servers
  def confirmation
    # Read the confirmation data from the request
    @confirmation = TBK::Webpay::Confirmation.new(request.raw_post)

    # confirmation is invalid for some reason (wrong order_id or amount, double payment, etc...)
    if @confirmation.amount != 5000.0
      render text: @confirmation.reject
      return # reject and stop execution
    end

    if @confirmation.success?
      # EXITO!
      # perform everything you have to do here.
      self.last_confirmation = @confirmation
    end

    # Acknowledge payment
    render text: @confirmation.acknowledge
  end

  def success

    # Only for debug. This block can be safely removed.
    if params[:debug].presence and params[:debug] == 'true' and not @params.presence
      @params = {
        "TBK_ORDEN_COMPRA"=>"9b094a8c0ba1",
        "TBK_TIPO_TRANSACCION"=>"TR_NORMAL",
        "TBK_RESPUESTA"=>"0",
        "TBK_MONTO"=>"500000",
        "TBK_CODIGO_AUTORIZACION"=>"721410",
        "TBK_FINAL_NUMERO_TARJETA"=>"6623",
        "TBK_FECHA_CONTABLE"=>"0130",
        "TBK_FECHA_TRANSACCION"=>"0130",
        "TBK_HORA_TRANSACCION"=>"194634",
        "TBK_ID_SESION"=>"425abc7b347c",
        "TBK_ID_TRANSACCION"=>"6371475922",
        "TBK_TIPO_PAGO"=>"VD",
        "TBK_NUMERO_CUOTAS"=>"0",
        "TBK_VCI"=>"TSY"
      }
    end

    # Example data, replace by yours!
    # Example data has value_class set to 'text-error', don't forget remove it.
    if params[:debug].presence and params[:debug] == 'true'
      @venta = {
        nombre_del_comprador: { icon: 'icon-user', label: 'Nombre del comprador', value: 'Andrea Benítez Moreno', value_class: 'text-error' },
        rut_del_comprador: { label: '<abbr title="Rol Único Tributario">RUT</abbr> del compardor', value: '12345678-5', value_class: 'text-error' },
        nombre_del_comercio: { label: 'Nombre del comercio', value: 'Importadora Las Mosquitas S.A.', value_class: 'text-error' },
        url_del_comercio: { label: '<abbr title="Uniform Resource Locator" lang="en">URL</abbr> del comercio', value: root_url },
        direccion_del_comercio: { label: 'Dirección', value: '<address><strong>Importadora Las Mosquitas S.A.</strong><br>Avenida Argentina 2345, San Miguel<br>Santiago, Chile<br><abbr title="Teléfono"><i class="icon-phone"></i></abbr> +56 2 2345 6789</address>', value_class: 'text-error' },
        condiciones: { value: 'Lorem ipsum dolor sic amet...', value_class: 'text-error' }
      }

      @orden_de_compra = { items: [ { quantity: '2', description: 'Mouse óptico', unit_price: '$ 2.000,00', price: '$ 4.000,00' },
                                    { quantity: '1', description: 'Costo de envío', unit_price: '$ 1.000,00', price: '$ 1.000,00' } ],
                           metadata: { total_price: '$ 5.000,00'}
      }
    end
  end

  def failure

  end

  protected
    # Just a transient place to store the last confirmation received from Transbank
    mattr_accessor :last_confirmation
    delegate :last_confirmation, :last_confirmation=, to: "self.class"
    helper_method :last_confirmation
end