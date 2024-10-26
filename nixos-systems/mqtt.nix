{ pkgs, ... }:
{
  services.mosquitto = {
    enable = true;
    settings.max_keepalive = 300;
    logType = [ "debug" ];
    listeners = [
      {
        port = 1883;
        users.mqtt = {
          acl = [ "readwrite #" ];
          hashedPassword = "$7$101$bRlNec0pBNi1/0Qz$+a5CLAdQwOU5XSFENOa+vbucmlo1yBHu7q2bjDXQsu7ZXBizxXUVYK54TibWxfCQr+EEdGJ1z4SBeTI1ED3UFw==";
        };
        acl = [ "topic readwrite #" "pattern readwrite #" ];
      }
      {
        port = 8080;
        users.mqtt = {
          acl = [ "readwrite #" ];
          hashedPassword = "$7$101$bRlNec0pBNi1/0Qz$+a5CLAdQwOU5XSFENOa+vbucmlo1yBHu7q2bjDXQsu7ZXBizxXUVYK54TibWxfCQr+EEdGJ1z4SBeTI1ED3UFw==";
        };
        acl = [ "topic readwrite #" "pattern readwrite #" ];
        settings.protocol = "websockets";
      }
    ];
  };
}
