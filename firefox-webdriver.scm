(include "common.scm")


(define (run-firefox command)
  (open-input-pipe (sprintf "~A " command)))


(define (with-firefox-webdriver thunk
                                #!key (scheme 'http)
                                      (host "127.0.0.1")
                                      (port 4444)
                                      (path "/")
                                      (command "geckodriver")
                                      (capabilities
                                       '((alwaysMatch .
                                          #((browserName . "firefox"))))))
  (parameterize
    ((command-executor-scheme scheme)
     (command-executor-host host)
     (command-executor-port port)
     (command-executor-path path)
     (w3c-capabilities capabilities))
    (run-firefox command)

    ;; Wait until the webdriver starts accepting requests
    (wait-for-connection host port)

    (parameterize ((session-identifier (start-session)))
      (thunk))))
