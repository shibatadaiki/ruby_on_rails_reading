*   Deprecate template names with `.`

    *John Hawthorn*

*   `ActionView::Base.annotate_template_file_names` annotates HTML output with template file names.

    *Joel Hawksley*, *Aaron Patterson*

*   `ActionView::Helpers::TranslationHelper#translate` returns nil when
    passed `default: nil` without a translation matching `I18n#translate`.

    *Stefan Wrobel*

*   `OptimizedFileSystemResolver` prefers template details in order of locale,
    formats, variants, handlers.

    *Iago Pimenta*

*   Added `class_names` helper to create a CSS class value with conditional classes.

    *Joel Hawksley*, *Aaron Patterson*

*   Add support for conditional values to TagBuilder.

    *Joel Hawksley*

*   `ActionView::Helpers::FormOptionsHelper#select` should mark option for `nil` as selected.

    ```ruby
    @post = Post.new
    @post.category = nil

    # Before
    select("post", "category", none: nil, programming: 1, economics: 2)
    # =>
    # <select name="post[category]" id="post_category">
    #   <option value="">none</option>
    #  <option value="1">programming</option>
    #  <option value="2">economics</option>
    # </select>

    # After
    select("post", "category", none: nil, programming: 1, economics: 2)
    # =>
    # <select name="post[category]" id="post_category">
    #   <option selected="selected" value="">none</option>
    #  <option value="1">programming</option>
    #  <option value="2">economics</option>
    # </select>
    ```

    *bogdanvlviv*

*   Log lines for partial renders and started template renders are now
    emitted at the `DEBUG` level instead of `INFO`.

    Completed template renders are still logged at the `INFO` level.

    *DHH*

*   ActionView::Helpers::SanitizeHelper: support rails-html-sanitizer 1.1.0.

    *Juanito Fatas*

*   Added `phone_to` helper method to create a link from mobile numbers.

    *Pietro Moro*

*   annotated_source_code returns an empty array so TemplateErrors without a
    template in the backtrace are surfaced properly by DebugExceptions.

    *Guilherme Mansur*, *Kasper Timm Hansen*

*   Add autoload for SyntaxErrorInTemplate so syntax errors are correctly raised by DebugExceptions.

    *Guilherme Mansur*, *Gannon McGibbon*

*   `RenderingHelper` supports rendering objects that `respond_to?` `:render_in`.

    *Joel Hawksley*, *Natasha Umer*, *Aaron Patterson*, *Shawn Allen*, *Emily Plummer*, *Diana Mounter*, *John Hawthorn*, *Nathan Herald*, *Zaid Zawaideh*, *Zach Ahn*

*   Fix `select_tag` so that it doesn't change `options` when `include_blank` is present.

    *Younes SERRAJ*


Please check [6-0-stable](https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md) for previous changes.
