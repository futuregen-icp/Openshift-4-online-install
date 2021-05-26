## 노드를 추가 하려고 할 때 x509인증서 오류가 발생하거나 ign 파일을 삭제하였을 경우 해결 방법



### master/worker의 배포되는 기본 ign   파일 구조

```
{
  "ignition": {
    "config": {
      "append": [
        {
          "source": "https://api-int.ocp.example.com:22623/config/worker",
          "verification": {}
        }
      ]
    },
    "security": {
      "tls": {
        "certificateAuthorities": [
          {
            "source": "data:text/plain;charset=utf-8;base64,xxxxxxxxx",
            "verification": {}
          }
        ]
      }
    },
    "timeouts": {},
    "version": "2.2.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}
```



### 현재 사용되는  root-ca확인 방법 

```
openssl s_client -connect api-int.<clustername>.<baseDomain>:22623 -showcerts
```

**결과**

```
CONNECTED(00000003)
depth=0 CN = system:machine-config-server
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 CN = system:machine-config-server
verify error:num=21:unable to verify the first certificate
verify return:1
---
Certificate chain
 0 s:/CN=system:machine-config-server
   i:/OU=openshift/CN=root-ca
-----BEGIN CERTIFICATE-----
MIIDZDCCAkygAwIBAgIIZopBEnfkIigwDQYJKoZIhvcNAQELBQAwJjESMBAGA1UE
CxMJb3BlbnNoaWZ0MRAwDgYDVQQDEwdyb290LWNhMB4XDTIxMDQyNjIyNDg1MVoX
DTMxMDQyNDIyNDg1MlowJzElMCMGA1UEAxMcc3lzdGVtOm1hY2hpbmUtY29uZmln
LXNlcnZlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANiN+LTpTJMA
dQraGA2yeOVFChElioOK/A8VhPFF66aF/9LO5MyiCdFQAboqi6ILuIM56e3EgMfh
lb6Da2Rg4+WVK54HoqrIWdlneO8aMLEDBqxj3v2jNaoIk1KJ3J3k2DSOaOpitc/g
1BZrcT+yBb7DcrN6npl9met6GHWeQshMpRTONZSzi3L19k8eDlKN9KE2dWGsT2es
mEtoWGuLkDgTwrGZ4XBnayz+Hie7MxWxoRQcTLa1XRd9sN10YfOhPvbmIKPYpZw2
jVlcgy94+3i2c5E1jEFQJOH8yEuTRIS1pUDhmBVWrZc2e1khxrCagWJltyHo5jcj
vwRMUonzaHMCAwEAAaOBlDCBkTATBgNVHSUEDDAKBggrBgEFBQcDATAMBgNVHRMB
Af8EAjAAMB0GA1UdDgQWBBTZkhN4a2cct/EcPzos2r8kt1WpXTAfBgNVHSMEGDAW
gBRLhSJeCcuc5UdQYXhffHKK+qTbzjAsBgNVHREEJTAjgiFhcGktaW50Lm9jcDQu
dGVzdC5mdS5pZ290aXQuY28ua3IwDQYJKoZIhvcNAQELBQADggEBAJ7cVVy1tXIo
ZtGE+g0AkFVZ64G/eg8X3cYmlhHkaoXVWgFbrmsuLePRReNTk3CCPVFP5rB7l2MA
quKO9sHH0ild8mbosGrC9e5HawMdr18eEraQGOjGgvOirvB3a1ZJXjusH2PRc9nw
ZY6DzCdDpaSial2qc5nHQlm5UVHBwHJDYlgaHLvbK4u7+6EN8+3hOJNcwLEc82QE
iD03eIm+C5D1ANFz+WQp+ylzPx/XNnwsMl7JjbnyrH0jIkkauDENIVw4kGafQMrh
Qc/uRluWg6SWivzbLJ4bN21ZEqharpdlT9RCFZI+m2Mea71yO2ZQMVMOaN+HDb3i
eYfpWTxSYZU=
-----END CERTIFICATE-----
---
Server certificate
subject=/CN=system:machine-config-server
issuer=/OU=openshift/CN=root-ca
---
No client certificate CA names sent
Peer signing digest: SHA512
Server Temp Key: ECDH, P-256, 256 bits
---
SSL handshake has read 1493 bytes and written 415 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES128-GCM-SHA256
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES128-GCM-SHA256
    Session-ID: C8F3E69B416337D7459152B374B329728D0F856AEC598A5F15FFC031CAC87283
    Session-ID-ctx: 
    Master-Key: 3432D24C06085CA1716FEEBEEA88FEA1B580E3CAD4EF3713E0BA47064349803E5C9F567C58804CE6BB93DFF9ED06630A
    Key-Arg   : None
    Krb5 Principal: None
    PSK identity: None
    PSK identity hint: None
    TLS session ticket:
    0000 - da 3e f3 16 34 c7 7e df-a4 88 e3 ee 57 1d a6 47   .>..4.~.....W..G
    0010 - 1d bf e5 e1 63 75 4a de-a9 a8 05 32 2c 45 59 72   ....cuJ....2,EYr
    0020 - 54 17 16 9d 9a 00 04 17-22 f6 a9 06 d3 b5 7b 4a   T.......".....{J
    0030 - 4a 6b 12 b3 56 c1 67 54-ce 91 49 9e 8c 56 99 c3   Jk..V.gT..I..V..
    0040 - 2a 47 1e 65 0c 59 dc 5c-9c e2 76 87 27 0a b9 2c   *G.e.Y.\..v.'..,
    0050 - e0 bc 88 2d 0a b2 b0 ce-ca 33 dd 71 c2 a9 7e 92   ...-.....3.q..~.
    0060 - 2d 99 c1 72 86 cd e7 be-fe fb 97 cb 69 70 08 df   -..r........ip..
    0070 - 62 df 70 ed fd 03 21 74-80 10 33 02 9e f6 3b 31   b.p...!t..3...;1
    0080 - e0                                                .

    Start Time: 1622071732
    Timeout   : 300 (sec)
    Verify return code: 21 (unable to verify the first certificate)
---

HTTP/1.1 400 Bad Request
Content-Type: text/plain; charset=utf-8
Connection: close

400 Bad Requestclosed

```



**-----BEGIN CERTIFICATE----- 부터  -----END CERTIFICATE-----까지 복사하여 base64로 인코딩**

```
echo "-----BEGIN CERTIFICATE-----
> MIIDZDCCAkygAwIBAgIIZopBEnfkIigwDQYJKoZIhvcNAQELBQAwJjESMBAGA1UE
> CxMJb3BlbnNoaWZ0MRAwDgYDVQQDEwdyb290LWNhMB4XDTIxMDQyNjIyNDg1MVoX
> DTMxMDQyNDIyNDg1MlowJzElMCMGA1UEAxMcc3lzdGVtOm1hY2hpbmUtY29uZmln
> LXNlcnZlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANiN+LTpTJMA
> dQraGA2yeOVFChElioOK/A8VhPFF66aF/9LO5MyiCdFQAboqi6ILuIM56e3EgMfh
> lb6Da2Rg4+WVK54HoqrIWdlneO8aMLEDBqxj3v2jNaoIk1KJ3J3k2DSOaOpitc/g
> 1BZrcT+yBb7DcrN6npl9met6GHWeQshMpRTONZSzi3L19k8eDlKN9KE2dWGsT2es
> mEtoWGuLkDgTwrGZ4XBnayz+Hie7MxWxoRQcTLa1XRd9sN10YfOhPvbmIKPYpZw2
> jVlcgy94+3i2c5E1jEFQJOH8yEuTRIS1pUDhmBVWrZc2e1khxrCagWJltyHo5jcj
> vwRMUonzaHMCAwEAAaOBlDCBkTATBgNVHSUEDDAKBggrBgEFBQcDATAMBgNVHRMB
> Af8EAjAAMB0GA1UdDgQWBBTZkhN4a2cct/EcPzos2r8kt1WpXTAfBgNVHSMEGDAW
> gBRLhSJeCcuc5UdQYXhffHKK+qTbzjAsBgNVHREEJTAjgiFhcGktaW50Lm9jcDQu
> dGVzdC5mdS5pZ290aXQuY28ua3IwDQYJKoZIhvcNAQELBQADggEBAJ7cVVy1tXIo
> ZtGE+g0AkFVZ64G/eg8X3cYmlhHkaoXVWgFbrmsuLePRReNTk3CCPVFP5rB7l2MA
> quKO9sHH0ild8mbosGrC9e5HawMdr18eEraQGOjGgvOirvB3a1ZJXjusH2PRc9nw
> ZY6DzCdDpaSial2qc5nHQlm5UVHBwHJDYlgaHLvbK4u7+6EN8+3hOJNcwLEc82QE
> iD03eIm+C5D1ANFz+WQp+ylzPx/XNnwsMl7JjbnyrH0jIkkauDENIVw4kGafQMrh
> Qc/uRluWg6SWivzbLJ4bN21ZEqharpdlT9RCFZI+m2Mea71yO2ZQMVMOaN+HDb3i
> eYfpWTxSYZU=
> -----END CERTIFICATE-----" | base64
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURaRENDQWt5Z0F3SUJBZ0lJWm9wQkVuZmtJ
aWd3RFFZSktvWklodmNOQVFFTEJRQXdKakVTTUJBR0ExVUUKQ3hNSmIzQmxibk5vYVdaME1SQXdE
Z1lEVlFRREV3ZHliMjkwTFdOaE1CNFhEVEl4TURReU5qSXlORGcxTVZvWApEVE14TURReU5ESXlO
RGcxTWxvd0p6RWxNQ01HQTFVRUF4TWNjM2x6ZEdWdE9tMWhZMmhwYm1VdFkyOXVabWxuCkxYTmxj
blpsY2pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmlOK0xUcFRK
TUEKZFFyYUdBMnllT1ZGQ2hFbGlvT0svQThWaFBGRjY2YUYvOUxPNU15aUNkRlFBYm9xaTZJTHVJ
TTU2ZTNFZ01maApsYjZEYTJSZzQrV1ZLNTRIb3FySVdkbG5lTzhhTUxFREJxeGozdjJqTmFvSWsx
S0ozSjNrMkRTT2FPcGl0Yy9nCjFCWnJjVCt5QmI3RGNyTjZucGw5bWV0NkdIV2VRc2hNcFJUT05a
U3ppM0wxOWs4ZURsS045S0UyZFdHc1QyZXMKbUV0b1dHdUxrRGdUd3JHWjRYQm5heXorSGllN014
V3hvUlFjVExhMVhSZDlzTjEwWWZPaFB2Ym1JS1BZcFp3MgpqVmxjZ3k5NCszaTJjNUUxakVGUUpP
SDh5RXVUUklTMXBVRGhtQlZXclpjMmUxa2h4ckNhZ1dKbHR5SG81amNqCnZ3Uk1Vb256YUhNQ0F3
RUFBYU9CbERDQmtUQVRCZ05WSFNVRUREQUtCZ2dyQmdFRkJRY0RBVEFNQmdOVkhSTUIKQWY4RUFq
QUFNQjBHQTFVZERnUVdCQlRaa2hONGEyY2N0L0VjUHpvczJyOGt0MVdwWFRBZkJnTlZIU01FR0RB
VwpnQlJMaFNKZUNjdWM1VWRRWVhoZmZIS0srcVRiempBc0JnTlZIUkVFSlRBamdpRmhjR2t0YVc1
MExtOWpjRFF1CmRHVnpkQzVtZFM1cFoyOTBhWFF1WTI4dWEzSXdEUVlKS29aSWh2Y05BUUVMQlFB
RGdnRUJBSjdjVlZ5MXRYSW8KWnRHRStnMEFrRlZaNjRHL2VnOFgzY1ltbGhIa2FvWFZXZ0Zicm1z
dUxlUFJSZU5UazNDQ1BWRlA1ckI3bDJNQQpxdUtPOXNISDBpbGQ4bWJvc0dyQzllNUhhd01kcjE4
ZUVyYVFHT2pHZ3ZPaXJ2QjNhMVpKWGp1c0gyUFJjOW53ClpZNkR6Q2REcGFTaWFsMnFjNW5IUWxt
NVVWSEJ3SEpEWWxnYUhMdmJLNHU3KzZFTjgrM2hPSk5jd0xFYzgyUUUKaUQwM2VJbStDNUQxQU5G
eitXUXAreWx6UHgvWE5ud3NNbDdKamJueXJIMGpJa2thdURFTklWdzRrR2FmUU1yaApRYy91Umx1
V2c2U1dpdnpiTEo0Yk4yMVpFcWhhcnBkbFQ5UkNGWkkrbTJNZWE3MXlPMlpRTVZNT2FOK0hEYjNp
CmVZZnBXVHhTWVpVPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
```



### ign  파일 작성 및 수정

```
{
  "ignition": {
    "config": {
      "append": [
        {
          "source": "https://api-int.ocp.example.com:22623/config/worker",
          "verification": {}
        }
      ]
    },
    "security": {
      "tls": {
        "certificateAuthorities": [
          {
            "source": "data:text/plain;charset=utf-8;base64,LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURaRENDQWt5Z0F3SUJBZ0lJWm9wQkVuZmtJ
aWd3RFFZSktvWklodmNOQVFFTEJRQXdKakVTTUJBR0ExVUUKQ3hNSmIzQmxibk5vYVdaME1SQXdEZ1lEVlFRREV3ZHliMjkwTFdOaE1CNFhEVEl4TURReU5qSXlORGcxTVZvWApEVE14TURReU5ESXlORGcxTWxvd0p6RWxNQ01HQTFVRUF4TWNjM2x6ZEdWdE9tMWhZMmhwYm1VdFkyOXVabWxuCkxYTmxjblpsY2pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmlOK0xUcFRKTUEKZFFyYUdBMnllT1ZGQ2hFbGlvT0svQThWaFBGRjY2YUYvOUxPNU15aUNkRlFBYm9xaTZJTHVJTTU2ZTNFZ01maApsYjZEYTJSZzQrV1ZLNTRIb3FySVdkbG5lTzhhTUxFREJxeGozdjJqTmFvSWsxS0ozSjNrMkRTT2FPcGl0Yy9nCjFCWnJjVCt5QmI3RGNyTjZucGw5bWV0NkdIV2VRc2hNcFJUT05a
U3ppM0wxOWs4ZURsS045S0UyZFdHc1QyZXMKbUV0b1dHdUxrRGdUd3JHWjRYQm5heXorSGllN014V3hvUlFjVExhMVhSZDlzTjEwWWZPaFB2Ym1JS1BZcFp3MgpqVmxjZ3k5NCszaTJjNUUxakVGUUpPSDh5RXVUUklTMXBVRGhtQlZXclpjMmUxa2h4ckNhZ1dKbHR5SG81amNqCnZ3Uk1Vb256YUhNQ0F3RUFBYU9CbERDQmtUQVRCZ05WSFNVRUREQUtCZ2dyQmdFRkJRY0RBVEFNQmdOVkhSTUIKQWY4RUFqQUFNQjBHQTFVZERnUVdCQlRaa2hONGEyY2N0L0VjUHpvczJyOGt0MVdwWFRBZkJnTlZIU01FR0RBVwpnQlJMaFNKZUNjdWM1VWRRWVhoZmZIS0srcVRiempBc0JnTlZIUkVFSlRBamdpRmhjR2t0YVc1MExtOWpjRFF1CmRHVnpkQzVtZFM1cFoyOTBhWFF1WTI4dWEzSXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSjdjVlZ5MXRYSW8KWnRHRStnMEFrRlZaNjRHL2VnOFgzY1ltbGhIa2FvWFZXZ0Zicm1zdUxlUFJSZU5UazNDQ1BWRlA1ckI3bDJNQQpxdUtPOXNISDBpbGQ4bWJvc0dyQzllNUhhd01kcjE4ZUVyYVFHT2pHZ3ZPaXJ2QjNhMVpKWGp1c0gyUFJjOW53ClpZNkR6Q2REcGFTaWFsMnFjNW5IUWxtNVVWSEJ3SEpEWWxnYUhMdmJLNHU3KzZFTjgrM2hPSk5jd0xFYzgyUUUKaUQwM2VJbStDNUQxQU5GeitXUXAreWx6UHgvWE5ud3NNbDdKamJueXJIMGpJa2thdURFTklWdzRrR2FmUU1yaApRYy91Umx1V2c2U1dpdnpiTEo0Yk4yMVpFcWhhcnBkbFQ5UkNGWkkrbTJNZWE3MXlPMlpRTVZNT2FOK0hEYjNpCmVZZnBXVHhTWVpVPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
            "verification": {}
          }
        ]
      }
    },
    "timeouts": {},
    "version": "2.2.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}
```

