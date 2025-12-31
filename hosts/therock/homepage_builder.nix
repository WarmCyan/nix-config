# a service should look like: 
# {
#   name = "CGit";
#   addr = "http://192.168.130.2";
#   port = 9000;
#   url = "";
#   desc = "Local git repos";
# }

{ ... }:
rec {
  renderService = service: 
    /* html */ ''
      <div class="service">
        <a href="${service.addr}"><div class="service-icon">${service.icon}</div><div class="service-name">${service.name}</div></a><div class="service-desc">${service.desc}</div>
      </div> <!-- /service -->
    '';

  renderServices = services: defaultAddr:
    builtins.concatStringsSep "\n"
    (builtins.map (service: renderService
      {
        name = service.name;
        addr = "${service.addr or defaultAddr}${if service ? port then ":${toString service.port}" else ""}${if service ? url then "/${service.url}" else ""}";
        desc = service.desc or "";
        icon = service.icon or "";
      }
    ) services);

  generateHomepageHTML = {
    title ? null,
    services ? [],
    defaultAddr ? null,
    additionalHead ? "",
    css ? "",
    bodyTop ? null,
    bodyBottom ? "",
  }:
    /* html */ ''
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>${title}</title>
          <style>
            body {
              background-color: #333333;
              color: white;
              padding: 20px;
            }
            a {
              color: blue;
            }
            .service {
              padding: 10px;
              display: flex;
              align-items: center;
              gap: 5px;
            }
            .service a div {
              display: inline-block;
              vertical-align: middle;
            }
            .service-icon {
              padding-right: 5px;
            }
            ${css}
          </style>
          ${additionalHead}
        </head>
        <body>
          ${if bodyTop != null then "${bodyTop}" else "<h1 class='title'>${title}</h1>"}

          <div class="services">
            ${renderServices services defaultAddr}
          </div> <!-- /services -->
          
          ${bodyBottom}
        </body>
      </html>
    '';
}
