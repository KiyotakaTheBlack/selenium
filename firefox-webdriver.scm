(include "common.scm")

(define anonymous-profile-name "WEBDRIVER_ANONYMOUS_PROFILE")
(define extension-name "fxdriver@googlecode.com")

(define default-preferences
  '((app.update.auto . "false")
    (app.update.enabled . "false")
    (browser.startup.page . "0")
    (browser.download.manager.showWhenStarting . "false")
    (browser.EULA.override . "true")
    (browser.EULA.3.accepted . "true")
    (browser.link.open_external . "2")
    (browser.link.open_newwindow . "2")
    (browser.offline . "false")
    (browser.safebrowsing.enabled . "false")
    (browser.search.update . "false")
    (browser.sessionstore.resume_from_crash . "false")
    (browser.shell.checkDefaultBrowser . "false")
    (browser.tabs.warnOnClose . "false")
    (browser.tabs.warnOnOpen . "false")
    (browser.startup.page . "0")
    (startup.homepage_welcome_url . "\"about:blank\"")
    (devtools.errorconsole.enabled . "true")
    (dom.disable_open_during_load . "false")
    (dom.max_script_run_time . "30")
    (extensions.logging.enabled . "true")
    (extensions.update.enabled . "false")
    (extensions.update.notifyUser . "false")
    (network.manage-offline-status . "false")
    (network.http.max-connections-per-server . "10")
    (network.http.phishy-userpass-length . "255")
    (prompts.tab_modal.enabled . "false")
    (security.fileuri.origin_policy . "3")
    (security.fileuri.strict_origin_policy . "false")
    (security.warn_entering_secure . "false")
    (security.warn_submit_insecure . "false")
    (security.warn_entering_secure.show_once . "false")
    (security.warn_entering_weak . "false")
    (security.warn_entering_weak.show_once . "false")
    (security.warn_leaving_secure . "false")
    (security.warn_leaving_secure.show_once . "false")
    (security.warn_submit_insecure . "false")
    (security.warn_viewing_mixed . "false")
    (security.warn_viewing_mixed.show_once . "false")
    (signon.rememberSignons . "false")
    (toolkit.networkmanager.disable . "true")
    (javascript.options.showInConsole . "true")
    (browser.dom.window.dump.enabled . "true")
    (webdriver_accept_untrusted_certs . "true")))


(define (install-user-prefs profile-dir)
  (let ((extensions-dir (make-pathname profile-dir "extensions"))
        (user-prefs (make-pathname profile-dir "user.js")))
    (with-output-to-file user-prefs
      (lambda ()
        (for-each (lambda (pref)
                    (print "user_pref(\"" (car pref) "\", " (cdr pref) ");"))
                  default-preferences)))))


(define (run-firefox command profile-dir)
  (open-input-pipe (sprintf "~A " command)))


(define (with-firefox-webdriver profile-dir thunk
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
    (run-firefox command profile-dir)

    ;; Wait until the webdriver starts accepting requests
    (wait-for-connection host port)

    (parameterize ((session-identifier (start-session)))
      (thunk))))
