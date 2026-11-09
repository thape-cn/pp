module ApplicationHelper
  def local_time_i18n
    {
      date: {
        dayNames: t("date.day_names"),
        abbrDayNames: t("date.abbr_day_names"),
        monthNames: t("date.month_names").drop(1),
        abbrMonthNames: t("date.abbr_month_names").drop(1)
      },
      time: {am: t("time.am"), pm: t("time.pm")},
      datetime: {formats: {default: t("time.formats.long")}}
    }
  end

  def svg_icon(cil_name, icon_class, options = {})
    options["xlink:href"] = asset_path(cil_name)
    content_tag :svg, nil, class: icon_class do
      content_tag :use, nil, options
    end
  end

  def markdown(text)
    return "" if text.blank?

    options = %i[
      hard_wrap autolink no_intra_emphasis tables fenced_code_blocks
      disable_indented_code_blocks strikethrough lax_spacing space_after_headers
      quote footnotes highlight underline
    ]
    Markdown.new(text, *options).to_html.html_safe
  end

  def footer
    content_tag :footer, nil, class: "footer d-print-none" do
      left_part = content_tag :div, nil do
        concat "绩效评估 © 2023 TIANHUA"
      end
      right_part = content_tag :div, nil, class: "ms-auto" do
        concat "Powered by CoreUI PRO UI Components"
      end
      left_part.concat(right_part)
    end
  end
end
