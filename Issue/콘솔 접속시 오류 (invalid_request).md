

## Troubleshooting a Kubernetes cryptic error when viewing the Kibana console



에러 메세지 

```
{"error":"invalid_request","error_description":"The request is missing a required parameter,
 includes an invalid parameter value, includes a parameter more than once, or is otherwise malformed."}
```



리다이렉트 URL 확인 

```
[root@bastion ~]# oc get oauthclient
NAME                           SECRET                                        WWW-CHALLENGE   TOKEN-MAX-AGE   REDIRECT URIS
console                        KbQvPg6yXe69HtuJ_rUWxaZip39VwhLqS9vGYP18qAs   false           default         https://console-openshift-console.apps.ocp4.test.fu.igotit.co.kr/auth/callback
openshift-browser-client       5LNzaPwWGvCckPQaCjRsU-4UuPjoriHGW9lVCmbvM0s   false           default         https://oauth-openshift.apps.ocp4.test.fu.igotit.co.kr/oauth/token/display
openshift-challenging-client                                                 true            default         https://oauth-openshift.apps.ocp4.test.fu.igotit.co.kr/oauth/token/implicit

```



리다이렉트 URL 수정 

```
oc edit oauthclient console
```

