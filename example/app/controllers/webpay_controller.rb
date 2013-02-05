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
  end

  def failure

  end

  protected
    # Just a transient place to store the last confirmation received from Transbank
    mattr_accessor :last_confirmation
    delegate :last_confirmation, :last_confirmation=, to: "self.class"
    helper_method :last_confirmation
end