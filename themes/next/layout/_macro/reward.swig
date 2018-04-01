<div style="padding: 10px 0; margin: 20px auto; width: 90%; text-align: center;">
  <div>{{ theme.reward_comment }}</div>
  
  <div id="QR">

    {% if theme.wechatpay %}
      <div id="wechat" style="display: inline-block">
        <img style="width:220px;margin-right:20px" id="wechat_qr" src="{{ theme.wechatpay }}" alt="{{ theme.author }} WeChat Pay"/>
        <p>WeChat Pay</p>
      </div>
    {% endif %}

    {% if theme.alipay %}
      <div id="alipay" style="display: inline-block">
        <img style="width:180px;" id="alipay_qr" src="{{ theme.alipay }}" alt="{{ theme.author }} Alipay"/>
        <p>Alipay</p>
      </div>
    {% endif %}

    {% if theme.bitcoin %}
      <div id="bitcoin" style="display: inline-block">
        <img id="bitcoin_qr" src="{{ theme.bitcoin }}" alt="{{ theme.author }} Bitcoin"/>
        <p>Bitcoin</p>
      </div>
    {% endif %}

  </div>
</div>
