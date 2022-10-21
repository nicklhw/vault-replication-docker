{{ with pkiCert "pki_int/issue/example-dot-com" "common_name=test.example.com" }}
<html>
    <head>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css" integrity="sha384-B0vP5xmATw1+K9KRQjQERJvTumQW0nPEzvF6L/Z6nronJ3oUOFUFpCjEUQouq2+l" crossorigin="anonymous">
    </head>
    <body>
        <div class="alert alert-success" role="alert">
        <h5 class="alert-heading">Secret path &#58; pki_int/issue/example-dot-com</h5>
            <li><strong>Timestamp</strong> &#58; {{ timestamp }}</li>
            <li><strong>Key</strong> &#58; {{ .Data.Key }}</li>
            <li><strong>Cert</strong> &#58; {{ .Data.Cert }}</li>
            <li><strong>CA</strong> &#58; {{ .Data.CA }}</li>
        </div>
    </body>
</html>
{{ end }}
