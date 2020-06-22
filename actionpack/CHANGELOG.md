*   Correctly identify the entire localhost IPv4 range as trusted proxy.

    *Nick Soracco*

*   `url_for` will now use "https://" as the default protocol when
    `Rails.application.config.force_ssl` is set to true.

    *Jonathan Hefner*

*   Accept and default to base64_urlsafe CSRF tokens.

    Base64 strict-encoded CSRF tokens are not inherently websafe, which makes
    them difficult to deal with. For example, the common practice of sending
    the CSRF token to a browser in a client-readable cookie does not work properly
    out of the box: the value has to be url-encoded and decoded to survive transport.

    Now, we generate Base64 urlsafe-encoded CSRF tokens, which are inherently safe
    to transport.  Validation accepts both urlsafe tokens, and strict-encoded tokens
    for backwards compatibility.

    *Scott Blum*

*   Support rolling deploys for cookie serialization/encryption changes.

    In a distributed configuration like rolling update, users may observe
    both old and new instances during deployment. Users may be served by a
    new instance and then by an old instance.

    That means when the server changes `cookies_serializer` from `:marshal`
    to `:hybrid` or the server changes `use_authenticated_cookie_encryption`
    from `false` to `true`, users may lose their sessions if they access the
    server during deployment.

    We added fallbacks to downgrade the cookie format when necessary during
    deployment, ensuring compatibility on both old and new instances.

    *Masaki Hara*

*   `ActionDispatch::Request.remote_ip` has ip address even when all sites are trusted.

    Before, if all `X-Forwarded-For` sites were trusted, the `remote_ip` would default to `127.0.0.1`.
    Now, the furthest proxy site is used. e.g.: It now gives an ip address when using curl from the load balancer.

    *Keenan Brock*

*   Fix possible information leak / session hijacking vulnerability.

    The `ActionDispatch::Session::MemcacheStore` is still vulnerable given it requires the
    gem dalli to be updated as well.

    CVE-2019-16782.

*   Include child session assertion count in ActionDispatch::IntegrationTest.

    `IntegrationTest#open_session` uses `dup` to create the new session, which
    meant it had its own copy of `@assertions`. This prevented the assertions
    from being correctly counted and reported.

    Child sessions now have their `attr_accessor` overridden to delegate to the
    root session.

    Fixes #32142.

    *Sam Bostock*

*   Add SameSite protection to every written cookie.

    Enabling `SameSite` cookie protection is an addition to CSRF protection,
    where cookies won't be sent by browsers in cross-site POST requests when set to `:lax`.

    `:strict` disables cookies being sent in cross-site GET or POST requests.

    Passing `:none` disables this protection and is the same as previous versions albeit a `; SameSite=None` is appended to the cookie.

    See upgrade instructions in config/initializers/new_framework_defaults_6_1.rb.

    More info [here](https://tools.ietf.org/html/draft-west-first-party-cookies-07)

    _NB: Technically already possible as Rack supports SameSite protection, this is to ensure it's applied to all cookies_

    *Cédric Fabianski*

*   Bring back the feature that allows loading external route files from the router.

    This feature existed back in 2012 but got reverted with the incentive that
    https://github.com/rails/routing_concerns was a better approach. Turned out
    that this wasn't fully the case and loading external route files from the router
    can be helpful for applications with a really large set of routes.
    Without this feature, application needs to implement routes reloading
    themselves and it's not straightforward.

    ```ruby
    # config/routes.rb

    Rails.application.routes.draw do
      draw(:admin)
    end

    # config/routes/admin.rb

    get :foo, to: 'foo#bar'
    ```

    *Yehuda Katz*, *Edouard Chin*

*   Fix system test driver option initialization for non-headless browsers.

    *glaszig*

*   `redirect_to.action_controller` notifications now include the `ActionDispatch::Request` in
    their payloads as `:request`.

    *Austin Story*

*   `respond_to#any` no longer returns a response's Content-Type based on the
    request format but based on the block given.

    Example:

    ```ruby
      def my_action
        respond_to do |format|
          format.any { render(json: { foo: 'bar' }) }
        end
      end

      get('my_action.csv')
    ```

    The previous behaviour was to respond with a `text/csv` Content-Type which
    is inaccurate since a JSON response is being rendered.

    Now it correctly returns a `application/json` Content-Type.

    *Edouard Chin*

*   Replaces (back)slashes in failure screenshot image paths with dashes.

    If a failed test case contained a slash or a backslash, a screenshot would be created in a
    nested directory, causing issues with `tmp:clear`.

    *Damir Zekic*

*   Add `params.member?` to mimic Hash behavior.

    *Younes Serraj*

*   `process_action.action_controller` notifications now include the following in their payloads:

    * `:request` - the `ActionDispatch::Request`
    * `:response` - the `ActionDispatch::Response`

    *George Claghorn*

*   Updated `ActionDispatch::Request.remote_ip` setter to clear set the instance
    `remote_ip` to `nil` before setting the header that the value is derived
    from.

    Fixes #37383.

    *Norm Provost*

*   `ActionController::Base.log_at` allows setting a different log level per request.

    ```ruby
    # Use the debug level if a particular cookie is set.
    class ApplicationController < ActionController::Base
      log_at :debug, if: -> { cookies[:debug] }
    end
    ```

    *George Claghorn*

*   Allow system test screen shots to be taken more than once in
    a test by prefixing the file name with an incrementing counter.

    Add an environment variable `RAILS_SYSTEM_TESTING_SCREENSHOT_HTML` to
    enable saving of HTML during a screenshot in addition to the image.
    This uses the same image name, with the extension replaced with `.html`

    *Tom Fakes*

*   Add `Vary: Accept` header when using `Accept` header for response.

    For some requests like `/users/1`, Rails uses requests' `Accept`
    header to determine what to return. And if we don't add `Vary`
    in the response header, browsers might accidentally cache different
    types of content, which would cause issues: e.g. javascript got displayed
    instead of html content. This PR fixes these issues by adding `Vary: Accept`
    in these types of requests. For more detailed problem description, please read:

    https://github.com/rails/rails/pull/36213

    Fixes #25842.

    *Stan Lo*

*   Fix IntegrationTest `follow_redirect!` to follow redirection using the same HTTP verb when following
    a 307 redirection.

    *Edouard Chin*

*   System tests require Capybara 3.26 or newer.

    *George Claghorn*

*   Reduced log noise handling ActionController::RoutingErrors.

    *Alberto Fernández-Capel*

*   Add DSL for configuring HTTP Feature Policy.

    This new DSL provides a way to configure an HTTP Feature Policy at a
    global or per-controller level. Full details of HTTP Feature Policy
    specification and guidelines can be found at MDN:

    https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy

    Example global policy:

    ```ruby
    Rails.application.config.feature_policy do |f|
      f.camera      :none
      f.gyroscope   :none
      f.microphone  :none
      f.usb         :none
      f.fullscreen  :self
      f.payment     :self, "https://secure.example.com"
    end
    ```

    Example controller level policy:

    ```ruby
    class PagesController < ApplicationController
      feature_policy do |p|
        p.geolocation "https://example.com"
      end
    end
    ```

    *Jacob Bednarz*

*   Add the ability to set the CSP nonce only to the specified directives.

    Fixes #35137.

    *Yuji Yaginuma*

*   Keep part when scope option has value.

    When a route was defined within an optional scope, if that route didn't
    take parameters the scope was lost when using path helpers. This commit
    ensures scope is kept both when the route takes parameters or when it
    doesn't.

    Fixes #33219.

    *Alberto Almagro*

*   Added `deep_transform_keys` and `deep_transform_keys!` methods to ActionController::Parameters.

    *Gustavo Gutierrez*

*   Calling `ActionController::Parameters#transform_keys`/`!` without a block now returns
    an enumerator for the parameters instead of the underlying hash.

    *Eugene Kenny*

*   Fix strong parameters blocks all attributes even when only some keys are invalid (non-numerical).
    It should only block invalid key's values instead.

    *Stan Lo*


Please check [6-0-stable](https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md) for previous changes.
